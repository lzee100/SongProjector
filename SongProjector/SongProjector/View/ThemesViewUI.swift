//
//  ThemesViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseFirestoreSwift


@MainActor class ThemesViewModel: ObservableObject {
    
    @Published var error: LocalizedError?
    
    @Published private(set) var themes: [ThemeCodable] = []
    @Published private(set) var showingLoader = false
    @Published var showingSubscriptionsView = false
    @Published var isSavingEnabled = true

    
    func reload() async {
        await setThemes(searchText: nil)
    }
    
    func filterOn(_ searchText: String) async {
        await setThemes(searchText: searchText == "" ? nil : searchText)
    }
    
    private func setThemes(searchText: String?) async {
        var predicates = [Predicate]()
        if let searchText {
            predicates += [.customWithValue(format: "title CONTAINS[cd] %@", value: searchText.lowercased())]
        }
        predicates += [.skipHidden]
        themes = await GetThemesUseCase().fetch(predicates: predicates, sort: .position(asc: true))
    }
    
    func fetchRemoteThemes() async {
        await reload()
        setIsLoading(true)
        do {
            let result = try await FetchThemesUseCase(fetchAll: false).fetch()
            if result.count > 0 {
                await fetchRemoteThemes()
            } else {
                setIsLoading(false)
            }
        } catch {
            setIsLoading(false)
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func createDefaultTheme() async -> ThemeCodable? {
        do {
            return try await CreateThemeUseCase().create()
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
            return nil
        }
    }
    
    func delete(_ theme: ThemeCodable) async {
        setIsLoading(true)
        var theme = theme
        theme.deleteDate = Date()
        if uploadSecret != nil {
            theme.rootDeleteDate = Date()
        }
        do {
            try await SubmitUseCase(endpoint: .themes, requestMethod: .delete, uploadObjects: [theme]).submit()
            await reload()
        } catch {
            setIsLoading(false)
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }

    func checkSubscriptionsStatus() async {
        let status = await GetActiveSubscriptionsUseCase().fetch()
        isSavingEnabled = status != .none
    }

    private func setIsLoading(_ showingLoader: Bool) {
        withAnimation(.linear) {
            self.showingLoader = showingLoader
        }
    }
}

struct ThemesViewUI: View {
    
    @StateObject private var viewModel = ThemesViewModel()
    @State private var searchText: String = ""
    @State fileprivate(set) var selectedTheme: SheetViewModel? = nil
    @State private var deleteThemeError: LocalizedError?

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                Text("\(selectedTheme?.title ?? "")")
                    .hidden()
                if viewModel.showingLoader {
                    ProgressView()
                }
                VStack {
                    List {
                        ForEach(viewModel.themes) { theme in
                            Button {
                                Task {
                                    selectedTheme = try await SheetViewModel(cluster: nil, theme: theme, defaultTheme: theme, sheet: nil, sheetType: .SheetTitleContent, sheetEditType: .theme)
                                }
                            } label: {
                                HStack {
                                    Text(theme.title ?? "")
                                        .styleAs(font: .xNormal)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.borderless)
                            .swipeActions {
                                if theme.isDeletable {
                                    deleteButton(theme)
                                }
                            }
                        }
                    }
                    .navigationTitle(AppText.Themes.title)
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            newthemeButton
                        }
                    }
                    .searchable(text: $searchText)
                }
            }
        }
        .task {
            await viewModel.checkSubscriptionsStatus()
            await viewModel.fetchRemoteThemes()
        }
        .errorAlert(error: $viewModel.error)
        .onChange(of: searchText, { oldValue, newValue in
            Task {
                await viewModel.filterOn(newValue)
            }
        })
        .sheet(isPresented: $viewModel.showingSubscriptionsView, content: {
            SubscriptionsViewUI(subscriptionsStore: SubscriptionsStore())
        })
        .sheet(item: $selectedTheme, onDismiss: {
            Task {
                await viewModel.reload()
            }
        }, content: { model in
            EditThemeOrSheetViewUI(
                navigationTitle: AppText.EditTheme.title,
                delegate: self,
                sheetViewModel: model
            )
        })
        .errorAlert(error: $deleteThemeError)
    }
    
    @ViewBuilder func deleteButton(_ theme: ThemeCodable) -> some View {
        Button {
            Task {
                await viewModel.delete(theme)
            }
        } label: {
            Image(systemName: "trash")
                .tint(.white)
        }
        .tint(Color(uiColor: .red1))

    }
    
    @ViewBuilder var newthemeButton: some View {
        Button {
            if viewModel.isSavingEnabled {
                Task {
                    do {
                        if let theme = await viewModel.createDefaultTheme() {
                            selectedTheme = try await SheetViewModel(cluster: nil, theme: nil, defaultTheme: theme, sheet: nil, sheetType: .SheetTitleContent, sheetEditType: .theme)
                        }
                    } catch {

                    }
                }
            } else {
                viewModel.showingSubscriptionsView.toggle()
            }
        } label: {
            Image(systemName: "plus")
                .tint(Color(uiColor: themeHighlighted))
        }
    }
    

}

extension ThemesViewUI: EditThemeOrSheetViewUIDelegate {
    
    func dismissAndSave(model: SheetViewModel) {
    }
    
    func dismiss() {
        selectedTheme = nil
        Task {
            await viewModel.reload()
        }
    }
}

struct ThemesViewUI_Previews: PreviewProvider {
    static var previews: some View {
        ThemesViewUI()
    }
}

extension View {
    func errorAlert(error: Binding<LocalizedError?>, buttonTitle: String = "OK") -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}

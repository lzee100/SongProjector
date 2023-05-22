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

    
    func reload() {
        setThemes(searchText: nil)
    }
    
    func filterOn(_ searchText: String) {
        setThemes(searchText: searchText == "" ? nil : searchText)
    }
    
    private func setThemes(searchText: String?) {
        let predicates: [NSPredicate] = [searchText?.lowercased()]
            .compactMap { $0 }
            .map { NSPredicate(format: "title CONTAINS[cd] %@", $0) }
        let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: predicates + [.skipDeleted, .skipRootDeleted, .skipHidden], sort: NSSortDescriptor(key: "title", ascending: true))
        self.themes = themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }
    }
    
    func fetchRemoteThemes() async {
        reload()
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

    func delete(_ theme: ThemeCodable) async {
        setIsLoading(true)
        var theme = theme
        theme.deleteDate = Date()
        if uploadSecret != nil {
            theme.rootDeleteDate = Date()
        }
        do {
            try await SubmitUseCase(endpoint: .themes, requestMethod: .put, uploadObjects: [theme]).submit()
            reload()
        } catch {
            setIsLoading(false)
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
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
    @State fileprivate(set) var selectedTheme: ThemeCodable?
    @State private var isShowingThemesEditor = false
    @State private var deleteThemeError: LocalizedError?

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                if viewModel.showingLoader {
                    ProgressView()
                }
                VStack {
                    List {
                        ForEach(viewModel.themes) { theme in
                            Button {
                                selectedTheme = theme
                            } label: {
                                HStack {
                                    Text(theme.title ?? "")
                                        .styleAs(font: .xNormal)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.borderless)
                            .swipeActions {
                                deleteButton(theme)
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
            await viewModel.fetchRemoteThemes()
        }
        .errorAlert(error: $viewModel.error)
        .onChange(of: searchText) { newValue in
            viewModel.filterOn(newValue)
        }
        .sheet(item: $selectedTheme, content: { theme in
            if let model = EditSheetOrThemeViewModel(editMode: .theme(theme), isUniversal: uploadSecret != nil) {
                EditThemeOrSheetViewUI(
                    navigationTitle: AppText.EditTheme.title,
                    delegate: self,
                    editSheetOrThemeModel: WrappedStruct(withItem: model)
                )
            }
        })
        .sheet(isPresented: $isShowingThemesEditor) {
            if let model = EditSheetOrThemeViewModel(editMode: .theme(nil), isUniversal: uploadSecret != nil) {
                EditThemeOrSheetViewUI(
                    navigationTitle: AppText.EditTheme.title,
                    delegate: self,
                    editSheetOrThemeModel: WrappedStruct(withItem: model)
                )
            }
        }
        .errorAlert(error: $deleteThemeError)
        .onChange(of: isShowingThemesEditor) { _ in
            viewModel.reload()
        }
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
            isShowingThemesEditor.toggle()
        } label: {
            Image(systemName: "plus")
                .tint(Color(uiColor: themeHighlighted))
        }
    }
    

}

extension ThemesViewUI: EditThemeOrSheetViewUIDelegate {
    
    func dismiss() {
        selectedTheme = nil
        isShowingThemesEditor = false
        viewModel.reload()
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

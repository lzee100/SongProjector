//
//  ThemesViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class ThemesViewModel: ObservableObject {
    
    @Published var error: LocalizedError?
    
    @Published private(set) var themes: [ThemeCodable] = []
    @Published private(set) var showingLoader = false

    
    func reloadThemes() {
        setThemes(searchText: nil)
    }
    
    func filterOn(_ searchText: String) {
        setThemes(searchText: searchText == "" ? nil : searchText)
    }
    
    private func setThemes(searchText: String?) {
        let predicates: [NSPredicate] = [searchText?.lowercased()]
            .compactMap { $0 }
            .map { NSPredicate(format: "title CONTAINS[cd] %@", $0) }
        let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: predicates + [.skipDeleted, .skipRootDeleted], sort: NSSortDescriptor(key: "title", ascending: true))
        self.themes = themes.compactMap { ThemeCodable(managedObject: $0, context: moc) }
    }
    
    func fetchRemoteThemes() async {
        reloadThemes()
        showingLoader = true
        do {
            let result = try await FetchCollectionsUseCase(fetchAll: false).fetch()
            switch result {
            case .succes(let clusters): saveLocally(clusters)
            case .failed(let error):
                showingLoader = false
                self.error = error
            }
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    private func saveLocally(_ entities: [ClusterCodable]) {
        ManagedObjectContextHandler<ClusterCodable>().save(entities: entities, completion: { [weak self] _ in
            self?.reload()
            if entities.count > 0 {
                Task {
                    await fetchRemoteCollections()
                }
            } else {
                self?.showingLoader = false
            }
        })
    }

}

struct ThemesViewUI: View {
        
    @ObservedObject private var viewModel = WrappedStruct(withItem: ThemesViewModel())
    @State private var searchText: String = ""
    @State private var deleteThemeProgress: RequesterResult = .idle
    @State fileprivate(set) var selectedTheme: ThemeCodable?
    @State private var isShowingThemesEditor = false
    @State private var deleteThemeError: LocalizedError?

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                List {
                    ForEach(viewModel.item.themes) { theme in
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
        .onAppear {
            viewModel.item.reloadThemes()
        }
        .onChange(of: searchText) { newValue in
            viewModel.item.filterOn(newValue)
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
        .onChange(of: deleteThemeProgress) { newValue in
            switch newValue {
            case .finished(let result):
                switch result {
                case .success: viewModel.item.reloadThemes()
                case .failure(let error):
                    deleteThemeError = error as? LocalizedError // TODO: is this value a localized error?
                }
            default: break
            }
        }
        .onChange(of: isShowingThemesEditor) { _ in
            viewModel.item.reloadThemes()
        }
    }
    
    @ViewBuilder func deleteButton(_ theme: ThemeCodable) -> some View {
        Button {
            var theme = theme
            theme.deleteDate = Date()
            if uploadSecret != nil {
                theme.rootDeleteDate = Date()
            }
            SubmitEntitiesUseCase<ThemeCodable>(endpoint: .themes, requestMethod: .put, uploadObjects: [theme], result: $deleteThemeProgress).submit()
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

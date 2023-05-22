//
//  TagsViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class TagsViewModel: ObservableObject {
    
    @Published private(set) var tags: [TagCodable] = []
    @Published var error: LocalizedError?
    @Published var showingLoader = false
    
    func fetchTags() {
        let tags: [Tag] = DataFetcher().getEntities(moc: moc, sort: .positionAsc)
        self.tags = tags.compactMap { TagCodable(managedObject: $0, context: moc) }
    }
    
    func fetchTagsWithRemote() async {
        fetchTags()
        do {
            let result = try await FetchTagsUseCase().fetch()
            if result.count > 0 {
                fetchTags()
            }
        } catch {
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func delete(tag: TagCodable) async {
        var changeableTag = tag
        changeableTag.deleteDate = Date()
        if uploadSecret != nil {
            changeableTag.rootDeleteDate = Date()
        }
        await submit([changeableTag])
    }
    
    func submit(_ tags: [TagCodable]) async {
        showingLoader = true
        do {
            _ = try await SubmitUseCase(endpoint: .tags, requestMethod: .put, uploadObjects: tags).submit()
            fetchTags()
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
}

struct TagsViewUI: View {
    
    @StateObject private var viewModel = TagsViewModel()
    @State private var selectedTag: TagCodable?
    @State private var showingErrorAlert = false
    @State private var showingNewTag = false
    
    var body: some View {
        NavigationStack {
            List(selection: $selectedTag, content: {
                ForEach(viewModel.tags) { tag in
                    Button {
                        selectedTag = tag
                    } label: {
                        HStack {
                            Text(tag.title ?? "")
                                .styleAs(font: .xNormal)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderless)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.delete(tag: tag)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .tint(.white)
                        }
                        .tint(Color(uiColor: .red1))

                    }
                }
                .onMove(perform: move)
            })
            .blur(radius: viewModel.showingLoader ? 5 : 0)
            .overlay {
                if viewModel.showingLoader {
                    ProgressView()
                        .frame(width: 50, height: 50)
                }
            }
            .navigationTitle(AppText.Tags.title)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingNewTag.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .tint(Color(uiColor: themeHighlighted))
                    }
                    .allowsHitTesting(!viewModel.showingLoader)
                }
            }
            .errorAlert(error: $viewModel.error)
            .sheet(isPresented: $showingNewTag, onDismiss: {
                viewModel.fetchTags()
            }, content: {
                NewTagViewUI(showingNewTagViewUI: $showingNewTag)
            })
            .sheet(item: $selectedTag, onDismiss: {
                viewModel.fetchTags()
            }, content: { selectedTag in
                TagEditorViewUI(
                    isShowingTagEditor: $selectedTag,
                    viewModel: TagEditorViewModel(tag: selectedTag)
                )
            })
            .task {
                await viewModel.fetchTagsWithRemote()
            }
        }
        
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        var movableTags = viewModel.tags
        movableTags.move(fromOffsets: source, toOffset: destination)
        let tagsEnumerated = movableTags
        movableTags = []
        for (index, tag) in tagsEnumerated.enumerated() {
            var changableTag = tag
            changableTag.position = Int16(index)
            movableTags.append(changableTag)
        }
        Task {
            await viewModel.submit(movableTags)
        }
    }
    
    
}

struct TagsViewUI_Previews: PreviewProvider {
    static var previews: some View {
        TagsViewUI()
    }
}

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
    
    func fetchTags() async {
        tags = await GetTagsUseCase().fetch()
    }
    
    func fetchTagsWithRemote() async {
        guard !showingLoader else { return }
        showingLoader = true
        await fetchTags()
        do {
            let result = try await FetchTagsUseCase().fetch()
            if result.count > 0 {
                await fetchTags()
                showingLoader = false
            } else {
                showingLoader = false
            }
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    func delete(tag: TagCodable) async {
        showingLoader = true
        var changeableTag = tag
        changeableTag.deleteDate = Date()
        if uploadSecret != nil {
            changeableTag.rootDeleteDate = Date()
        }
        await submit([changeableTag])
        showingLoader = false
    }
    
    func submit(_ tags: [TagCodable]) async {
        showingLoader = true
        do {
            _ = try await SubmitUseCase(endpoint: .tags, requestMethod: .put, uploadObjects: tags).submit()
            await fetchTags()
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
            if viewModel.showingLoader {
                ProgressView()
            }
            VStack {
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
                            if tag.isDeletable {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.delete(tag: tag)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .tint(.white)
                                }
                                .disabled(viewModel.showingLoader)
                                .tint(Color(uiColor: .red1))
                            }
                        }
                    }
                    .onMove(perform: move)
                })
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
                    .disabled(viewModel.showingLoader)
                }
            }
            .errorAlert(error: $viewModel.error)
            .sheet(isPresented: $showingNewTag, onDismiss: {
                Task {
                    await viewModel.fetchTags()
                }
            }, content: {
                NewTagViewUI(showingNewTagViewUI: $showingNewTag)
            })
            .sheet(item: $selectedTag, onDismiss: {
                Task {
                    await viewModel.fetchTags()
                }
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
            changableTag.position = index
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

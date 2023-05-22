//
//  TagEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class TagEditorViewModel: ObservableObject {
    
    @Published private(set) var tag: TagCodable
    @Published private(set) var error: Error?
    @Published private(set) var showingLoader = false

    init(tag: TagCodable) {
        self.tag = tag
    }
    
    func set(title: String) {
        tag.title = title
    }
    
    func update() async {
        showingLoader = true
        do {
            let updatedTags = try await SubmitUseCase<TagCodable>.init(endpoint: .tags, requestMethod: .put, uploadObjects: [tag]).submit()
            if let updatedTag = updatedTags.first {
                self.tag = updatedTag
            }
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error
        }
    }
    
}

struct TagEditorViewUI: View {
    
    @Binding var isShowingTagEditor: TagCodable?
    @StateObject var viewModel: TagEditorViewModel
    
    @State private var tagTitle = TextBindingManager()
    @State private var showingTitleIsBlancError = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(AppText.Tags.name, text: $tagTitle.text)
                        .textFieldStyle(.roundedBorder)
                        .padding([.top, .bottom], 20)
                }
            }
            .blur(radius: viewModel.showingLoader ? 5 : 0)
            .overlay {
                if viewModel.showingLoader {
                    ProgressView()
                }
            }
            .onAppear {
                tagTitle.text = viewModel.tag.title ?? ""
            }
            .onChange(of: tagTitle.text, perform: { title in
                viewModel.set(title: title)
            })
            .alert(AppText.Tags.errorEmptyTitle, isPresented: $showingTitleIsBlancError) {
                Button(AppText.Actions.ok, role: .cancel) {
                }
            }
            .navigationTitle(AppText.Tags.editTag)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        isShowingTagEditor = nil
                    } label: {
                        Text(AppText.Actions.cancel)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        if tagTitle.text.isBlanc {
                            showingTitleIsBlancError.toggle()
                        } else {
                            Task {
                                await viewModel.update()
                                isShowingTagEditor = nil
                            }
                        }
                    } label: {
                        Text(AppText.Actions.save)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                    .allowsHitTesting(!viewModel.showingLoader)
                }
            }
        }
    }
}

struct TagEditorViewUI_Previews: PreviewProvider {
    @State static var selectedTag1: TagCodable? = TagCodable.makeDefault()!
    @State static var selectedTag: TagCodable = TagCodable.makeDefault()!
    static var previews: some View {
        TagEditorViewUI(isShowingTagEditor: $selectedTag1, viewModel: TagEditorViewModel(tag: selectedTag))
    }
}

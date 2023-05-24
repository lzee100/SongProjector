//
//  NewTagViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class NewTagEditorViewModel: ObservableObject {
        
    @Published private(set) var error: LocalizedError?
    @Published private(set) var newTag: TagCodable?
    @Published private(set) var showingLoader = false

    func submitTagWith(title: String) async {
        showingLoader = true
        do {
            let tag = try createTagWith(title: title)
            let createdTags = try await SubmitUseCase<TagCodable>.init(endpoint: .tags, requestMethod: .put, uploadObjects: [tag]).submit()
            if let createdTag = createdTags.first {
                self.newTag = createdTag
            }
            showingLoader = false
        } catch {
            showingLoader = false
            self.error = error as? LocalizedError ?? RequestError.unknown(requester: "", error: error)
        }
    }
    
    private func createTagWith(title: String) throws -> TagCodable {
        var tag = TagCodable.makeDefault()
        tag?.title = title
        let tags: [Tag] = DataFetcher().getEntities(moc: moc, sort: .positionDesc)
        if let persitedTagPosition = tags.first?.position {
            tag?.position = persitedTagPosition + 1
        } else {
            tag?.position = 0
        }
        if let tag {
            return tag
        } else {
            throw RequestError.unAuthorizedNoUser(requester: "")
        }
    }
    
}

struct NewTagViewUI: View {
    
    @Binding var showingNewTagViewUI: Bool
    
    @StateObject private var viewModel = NewTagEditorViewModel()
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
            .navigationTitle(AppText.Tags.newTag)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        showingNewTagViewUI.toggle()
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
                                await viewModel.submitTagWith(title: tagTitle.text)
                                await MainActor.run(body: {
                                    showingNewTagViewUI.toggle()
                                })
                            }
                        }
                    } label: {
                        Text(AppText.Actions.save)
                            .tint(Color(uiColor: themeHighlighted))
                    }
                    .allowsHitTesting(!viewModel.showingLoader)
                }
            }
            .alert(AppText.Tags.errorEmptyTitle, isPresented: $showingTitleIsBlancError) {
                Button(AppText.Actions.ok, role: .cancel) {
                }
            }
        }
    }
}

struct NewTagViewUI_Previews: PreviewProvider {
    @State static var showing = false
    static var previews: some View {
        NewTagViewUI(showingNewTagViewUI: $showing)
    }
}

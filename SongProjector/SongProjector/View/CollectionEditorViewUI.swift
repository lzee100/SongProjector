//
//  CollectionEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct CollectionEditorViewUI: View {
    
    @ObservedObject private var model: WrappedStruct<ClusterEditorModel>
    private var themeSelectionModel: WrappedStruct<ThemesSelectionModel>
    private var tagsSelectionModel: WrappedStruct<TagsSelectionModel>
    @Binding var showingCollectionEditor: CollectionsViewUI.CollectionEditor?
    @State private var lyricsOrBibleStudyText: String = ""
    @State private var sheetContentSize: CGSize = .zero
    @State private var screenWidth: CGFloat = .zero
    @State private var isShowingLyricsOrBibleStudyInputView = false
    @State private var selectedSheetModel: WrappedStruct<EditSheetOrThemeViewModel>?
    @State private var isShowingNoThemeSelectedAlert = false
    @State private var isShowingChangeEditControllerTypeAlert = false
    @State private var isShowingLosingOtherSheetsAlert = false

    init(model: WrappedStruct<ClusterEditorModel>, showingCollectionEditor: Binding<CollectionsViewUI.CollectionEditor?>) {
        self.model = model
        self.themeSelectionModel = WrappedStruct(withItem: ThemesSelectionModel(selectedTheme: model.item.selectedClusterTheme, didSelectTheme: { theme in
            model.item.selectedClusterTheme = theme
        }))
        self.tagsSelectionModel = WrappedStruct(withItem: TagsSelectionModel(label: AppText.Tags.title, selectedTags: model.item.selectedTags, didSelectTags: { selectedTags in
            model.item.selectedTags = selectedTags
        }))
        self._showingCollectionEditor = showingCollectionEditor
    }
    
    var body: some View {
        
        NavigationStack {
            
            GeometryReader { screenProxy in
                
                VStack(spacing: 10) {
                    
                    VStack(spacing: 10) {
                        let boundTitle = Binding(
                            get: { self.model.item.title },
                            set: { self.model.item.title = $0 }
                        )
                        
                        TextFieldViewUI(textFieldViewModel: TextFieldViewModel(
                            label: nil,
                            placeholder: AppText.NewSong.titlePlaceholder,
                            characterLimit: TextFieldViewModel.CharacterLimit.standaard.rawValue,
                            text: boundTitle
                        ))
                        
                        TagSelectionDropdownViewUI(model: tagsSelectionModel)
                        
                    }
                    .styleAsSectionBackground(color: .gray)
                    
                    VStack(spacing: 10) {
                        
                        ThemesScrollViewUI(model: themeSelectionModel)
                        
                        GeometryReader { proxy in
                            ScrollView(.vertical, showsIndicators: true) {
                                sheets(proxy.size)
                            }
                            .onChange(of: proxy.size) { newValue in
                                screenWidth = newValue.width
                            }
                        }
                        .onPreferenceChange(SizePreferenceKey.self) { size in
                            self.sheetContentSize = size
                            if model.item.editController.isBibleStudy {
                                model.item.bibleStudyTextDidChange(lyricsOrBibleStudyText, contentTextViewContentSize: size, scaleFactor: getScaleFactor(width: screenWidth))
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 25, leading: 10, bottom: 0, trailing: 10))
                    .background(.gray.opacity(0.2))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    
                }
                .padding([.leading, .trailing, .top])
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(AppText.NewSong.title)
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(AppText.Actions.close) {
                        showingCollectionEditor = nil
                    }
                    .tint(Color(uiColor: themeHighlighted))
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    menu
                }
            })
            
        }
        .sheet(isPresented: $isShowingLyricsOrBibleStudyInputView) {
            LyricsOrBibleStudyInputViewUI(content: $lyricsOrBibleStudyText, isShowingLyricsOrBibleStudyInputView: $isShowingLyricsOrBibleStudyInputView)
        }
        .sheet(item: $selectedSheetModel, content: { model in
            EditThemeOrSheetViewUI(navigationTitle: AppText.SheetPickerMenu.pickCustom, delegate: self, editingCollectionModel: self.model, editSheetOrThemeModel: model)
        })
        .alert(AppText.CustomSheets.errorSelectTheme, isPresented: $isShowingNoThemeSelectedAlert, actions: {
            Button("OK", role: .cancel) { }
        })
        .alert(AppText.CustomSheets.errorChangeSheetGenerator, isPresented: $isShowingChangeEditControllerTypeAlert, actions: {
            Button(AppText.Actions.continue, role: .destructive) {
                lyricsOrBibleStudyText = ""
                if model.item.editController.isBibleStudy {
                    model.item.editController = .lyrics
                } else {
                    model.item.editController = .bibleStudy
                }
                isShowingLyricsOrBibleStudyInputView.toggle()
            }
            Button(AppText.Actions.cancel, role: .cancel) { }
        })
        .alert(AppText.CustomSheets.errorLoseOtherSheets, isPresented: $isShowingLosingOtherSheetsAlert, actions: {
            Button(AppText.Actions.continue, role: .destructive) {
                lyricsOrBibleStudyText = ""
                isShowingLyricsOrBibleStudyInputView.toggle()
            }
            Button(AppText.Actions.cancel, role: .cancel) { }
        })
        .onChange(of: lyricsOrBibleStudyText) { newValue in
            if model.item.editController.isBibleStudy {
                model.item.bibleStudyTextDidChange(newValue, contentTextViewContentSize: sheetContentSize, scaleFactor: getScaleFactor(width: screenWidth))
            } else {
                model.item.lyricsTextDidChange(newValue, screenWidth: screenWidth)
            }
        }
    }
    
    @ViewBuilder func sheets(_ viewSize: CGSize) -> some View {
        VStack {
            switch model.item.editController {
            case .bibleStudy:
                bibleStudySheets(viewSize)
            case .lyrics, .customSheet, .none:
                VStack {
                    ForEach(model.item.sheets) { sheetModel in
                        SheetUIHelper.sheet(viewSize: viewSize, editSheetOrThemeModel: WrappedStruct(withItem: sheetModel), isForExternalDisplay: false)
                            .onTapGesture {
                                if model.item.editController == .lyrics {
                                    isShowingLyricsOrBibleStudyInputView.toggle()
                                }
                            }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 2, bottom: 25, trailing: 2))
    }
    
    @ViewBuilder func bibleStudySheets(_ viewSize: CGSize) -> some View {
        VStack {
            if lyricsOrBibleStudyText.count > 0 {
                ForEach(model.item.sheets) { sheetModel in
                    SheetUIHelper.sheet(viewSize: viewSize, editSheetOrThemeModel: WrappedStruct(withItem: sheetModel), isForExternalDisplay: false)
                        .onTapGesture {
                            isShowingLyricsOrBibleStudyInputView.toggle()
                        }
                }
            }
        }
    }

    private var menu: some View {
        Menu {
            Section {
                Button(AppText.SheetsMenu.lyrics) {
                    if model.item.selectedClusterTheme == nil {
                        isShowingNoThemeSelectedAlert = true
                    } else if ![.none, .lyrics].contains(model.item.editController) && lyricsOrBibleStudyText.count > 0 {
                        isShowingChangeEditControllerTypeAlert.toggle()
                    } else {
                        model.item.editController = .lyrics
                        isShowingLyricsOrBibleStudyInputView.toggle()
                    }
                }
            }
            Section {
                ForEach(SheetType.all, id: \.rawValue) { type in
                    Button(type.name) {
                        model.item.editController = .customSheet(type: type)
                        self.selectedSheetModel = model.item.customSheetsEditModel
                    }
                }
            }
            Section {
                Button(AppText.Lyrics.titleBibleText) {
                    if model.item.selectedClusterTheme == nil {
                        isShowingNoThemeSelectedAlert = true
                    } else if ![.none, .bibleStudy].contains(model.item.editController) && lyricsOrBibleStudyText.count > 0 {
                        isShowingChangeEditControllerTypeAlert.toggle()
                    } else if ![.none, .bibleStudy].contains(model.item.editController) && model.item.sheets.count > 0 {
                        isShowingLosingOtherSheetsAlert.toggle()
                    } else {
                        model.item.editController = .bibleStudy
                        isShowingLyricsOrBibleStudyInputView.toggle()
                    }
                }
            }
        } label: {
            Label(AppText.Actions.add, systemImage: "plus")
        }
        .tint(Color(uiColor: themeHighlighted))
        
    }
    
}

extension CollectionEditorViewUI: EditThemeOrSheetViewUIDelegate {
    
    func dismiss() {
        selectedSheetModel = nil
    }
}

struct CollectionEditorViewUI_Previews: PreviewProvider {
    @State static var showingCollectionEditor: CollectionsViewUI.CollectionEditor? = nil
    @State static var model = WrappedStruct(withItem: ClusterEditorModel(cluster: nil)!)
    static var previews: some View {
        CollectionEditorViewUI(model: model, showingCollectionEditor: $showingCollectionEditor)
    }
}

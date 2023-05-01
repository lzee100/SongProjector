//
//  CollectionEditorViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct CollectionEditorViewUI: View {
    
    enum EditController: Equatable {
        case none
        case lyrics
        case bibleStudy
        case customSheet(type: SheetType)
        
        var sheet: SheetMetaType? {
            switch self {
            case .customSheet(type: let type):
                return type.makeDefault()
            default: return nil
            }
        }
        
        var sheetType: SheetType? {
            switch self {
            case .customSheet(type: let type):
                return type
            default: return nil
            }
        }
    }
    
    @ObservedObject private var model: WrappedStruct<ClusterEditorModel>
    private var themeSelectionModel: WrappedStruct<ThemesSelectionModel>
    private var tagsSelectionModel: WrappedStruct<TagsSelectionModel>
    @State private var editController: EditController = .none
    @State private var bibleStudyText: String = ""
    @State private var bibleStudySheetContent: [(title: String?, content: String)] = []
    @State private var isShowingBibleStudy = false
    @State private var sheetContentSize: CGSize = .zero
    @State private var screenWidth: CGFloat = .zero
    @State private var isShowingLyricsOrBibleStudyInputView = false
    @State private var isShowingSheetEditor = false
    
    init(model: WrappedStruct<ClusterEditorModel>) {
        self.model = model
        self.themeSelectionModel = WrappedStruct(withItem: ThemesSelectionModel(selectedTheme: model.item.selectedClusterTheme, didSelectTheme: { theme in
            model.item.selectedClusterTheme = theme
        }))
        self.tagsSelectionModel = WrappedStruct(withItem: TagsSelectionModel(label: AppText.Tags.title, selectedTags: model.item.selectedTags, didSelectTags: { selectedTags in
            model.item.selectedTags = selectedTags
        }))
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
                        
                        TagSelectionViewUI(model: tagsSelectionModel)
                        
                    }
                    .portraitSectionBackgroundFor(viewSize: screenProxy.size, color: .gray)
                    
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
                            generateBibleStudySheets()
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
                        
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    menu
                }
            })
            
        }
        .onChange(of: editController) { newValue in
            
        }
        .sheet(isPresented: $isShowingLyricsOrBibleStudyInputView) {
            LyricsOrBibleStudyInputViewUI(content: $bibleStudyText, isShowingLyricsOrBibleStudyInputView: $isShowingLyricsOrBibleStudyInputView)
        }
        .sheet(isPresented: $isShowingSheetEditor, content: {
            if let type = editController.sheetType, let sheet = editController.sheet, let model = EditSheetOrThemeViewModel(editMode: .sheet((model.item.cluster, sheet), sheetType: type), isUniversal: uploadSecret != nil) {
                EditThemeOrSheetViewUI(dismiss: { dismissPresenting in
                }, navigationTitle: AppText.SheetPickerMenu.pickCustom, editSheetOrThemeModel: WrappedStruct(withItem: model))
            } else {
                EmptyView()
            }
        })
        .onChange(of: bibleStudyText) { newValue in
            if newValue.count > 0 {
                generateBibleStudySheets()
            }
        }
        
    }
    
    @ViewBuilder func sheets(_ viewSize: CGSize) -> some View {
        VStack {
            switch editController {
            case .bibleStudy:
                bibleStudySheets(viewSize)
            case .lyrics, .customSheet, .none:
                VStack {
                    ForEach(model.item.sheets) { sheetModel in
                        SheetUIHelper.sheet(viewSize: viewSize, editSheetOrThemeModel: WrappedStruct(withItem: sheetModel), isForExternalDisplay: false)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 2, bottom: 25, trailing: 2))
    }
    
    @ViewBuilder func bibleStudySheets(_ viewSize: CGSize) -> some View {
        VStack {
            if bibleStudyText.count > 0, !isShowingLyricsOrBibleStudyInputView {
                if let cluster = ClusterCodable.makeDefault(), let titleContentSheet = SheetTitleContentCodable.makeDefault(), let model = EditSheetOrThemeViewModel(editMode: .sheet((cluster: cluster, sheet: titleContentSheet), sheetType: .SheetTitleContent), isUniversal: false) {
                    SheetUIHelper.sheet(viewSize: viewSize, editSheetOrThemeModel: WrappedStruct(withItem: model), isForExternalDisplay: false)
                } else {
                    EmptyView()
                }
            } else if bibleStudySheetContent.count > 0 {
                ForEach(model.item.sheets) { sheetModel in
                    SheetUIHelper.sheet(viewSize: viewSize, editSheetOrThemeModel: WrappedStruct(withItem: sheetModel), isForExternalDisplay: false)
                }
            }
        }
    }
    
    private func generateBibleStudySheets() {
        guard let theme = model.item.selectedClusterTheme, bibleStudyText.count > 0 else {
            return
        }
        let bibleStudyTitleContent =  BibleStudyTextUseCase.generateSheetsFromText(
            bibleStudyText,
            contentSize: sheetContentSize,
            theme: theme,
            scaleFactor: getScaleFactor(width: screenWidth),
            cluster: model.item.cluster
        )
        isShowingLyricsOrBibleStudyInputView = true
        model.item.sheets = bibleStudyTitleContent // TODO: ADD EMPTY SHEETS BASED ON THEME SETTINGS
    }
    
    private var menu: some View {
        Menu {
            Section {
                Button(AppText.Lyrics.titleLyrics) {
                    editController = .bibleStudy
                    isShowingBibleStudy.toggle()
                }
            }
            Section {
                ForEach(SheetType.all, id: \.rawValue) { type in
                    Button(type.name) {
                        editController = .customSheet(type: type)
                        self.isShowingSheetEditor.toggle()
                    }
                }
            }
            Section {
                Button(AppText.Lyrics.titleBibleText) {
                    if model.item.selectedClusterTheme == nil {
                        // TODO: show alert
                    } else {
                        editController = .bibleStudy
                        isShowingBibleStudy.toggle()
                    }
                }
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
        
    }
    
}

struct CollectionEditorViewUI_Previews: PreviewProvider {
    @State static var model = WrappedStruct(withItem: ClusterEditorModel(cluster: nil)!)
    static var previews: some View {
        CollectionEditorViewUI(model: model)
    }
}

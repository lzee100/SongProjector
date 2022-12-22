//
//  NewOrEditIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol NewOrEditIphoneControllerDelegate {
	func didCreate(sheet: VSheet)
	func didCloseNewOrEditIphoneController()
}

enum ModificationMode: String {
	case newTheme
	case editTheme
	case newCustomSheet
	case editCustomSheet
    
    var isTheme: Bool {
        switch self {
        case .newTheme, .editTheme: return true
        case .newCustomSheet, .editCustomSheet: return false
        }
    }
}

class NewOrEditIphoneController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource {
	
	
	
    @IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet var previewView: UIView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var sheetContainerView: UIView!
	@IBOutlet var sheetContainerViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet var previewViewRatioConstraint: NSLayoutConstraint!
	
	
	// MARK: - Typ
	
	enum Section: String {
		case input
		case general
		case title
		case content
		case image
		
		static let all = [input, general, title, content, image]
		
		static let titleContent = [input, general, title, content]
		static let titleImage = [input, general, title, content, image]
		static let sheetPastors = [input, general, title, content, image]
		static let sheetSplit = [input, general, title, content]
		static let sheetEmpty = [input, general]
		static let activity = [input, general, title, content]
		
		static func `for`(_ section: Int, type: SheetType) -> Section {
			switch type {
			case .SheetTitleContent:
				return titleContent[section]
			case .SheetTitleImage:
				return titleImage[section]
			case .SheetPastors:
				return sheetPastors[section]
			case .SheetSplit:
				return sheetSplit[section]
			case .SheetEmpty:
				return sheetEmpty[section]
			case .SheetActivities:
				return activity[section]
			}
		}
	}
    
    enum Cell {
        case title(String?)
        case content(String?)
        case contentLeft(String?)
        case contentRight(String?)

        case asTheme([ThemeCodable])
        case hasEmptySheet(Bool)
        case hasEmptySheetBeginning(Bool)
        case allHaveTitle(Bool)
        case backgroundColor(UIColor?)
        case backgroundImage(UIImage?)
        case backgroundTransparancy(Double)
        case displayTime(Bool)
                
        case titleFontFamily(String)
        case titleFontSize(Float)
        case titleBackgroundColor(UIColor?)
        case titleAlignment(Int)
        case titleBorderSize(Float)
        case titleTextColor(UIColor?)
        case titleBorderColor(UIColor?)
        case titleBold(Bool)
        case titleItalic(Bool)
        case titleUnderlined(Bool)

        case lyricsFontFamily(String)
        case lyricsFontSize(Float)
        case lyricsAlignment(Int)
        case lyricsBorderSize(Float)
        case lyricsTextColor(UIColor?)
        case lyricsBorderColor(UIColor?)
        case lyricsBold(Bool)
        case lyricsItalic(Bool)
        case lyricsUnderlined(Bool)

        case image(UIImage?)
        case pastorImage(UIImage?)
        case hasBorder(Bool)
        case imageBorderSize(Int)
        case imageBorderColor(UIColor?)
        case contentMode(Int)
        
        var cellIdentifier: String {
            switch self {
            case .title: return LabelTextFieldCell.identifier
            case .content, .contentLeft, .contentRight: return LabelTextViewCell.identifier
            case .asTheme: return LabelPickerCell.identifier
            case .hasEmptySheet: return LabelSwitchCell.identifier
            case .hasEmptySheetBeginning: return LabelSwitchCell.identifier
            case .allHaveTitle: return LabelSwitchCell.identifier
            case .backgroundColor: return LabelColorPickerNewCell.identifier
            case .backgroundImage: return LabelPhotoPickerCell.identifier
            case .backgroundTransparancy: return LabelSliderCell.identifier
            case .displayTime: return LabelSwitchCell.identifier
            case .titleFontFamily: return LabelPickerCell.identifier
            case .titleFontSize: return LabelNumberCell.identifier
            case .titleBackgroundColor: return LabelColorPickerNewCell.identifier
            case .titleAlignment: return LabelPickerCell.identifier
            case .titleBorderSize: return LabelNumberCell.identifier
            case .titleTextColor: return LabelColorPickerNewCell.identifier
            case .titleBorderColor: return LabelColorPickerNewCell.identifier
            case .titleBold: return LabelSwitchCell.identifier
            case .titleItalic: return LabelSwitchCell.identifier
            case .titleUnderlined: return LabelSwitchCell.identifier
            case .lyricsFontFamily: return LabelPickerCell.identifier
            case .lyricsFontSize: return LabelNumberCell.identifier
            case .lyricsAlignment: return LabelPickerCell.identifier
            case .lyricsBorderSize: return LabelNumberCell.identifier
            case .lyricsTextColor: return LabelColorPickerNewCell.identifier
            case .lyricsBorderColor: return LabelColorPickerNewCell.identifier
            case .lyricsBold: return LabelSwitchCell.identifier
            case .lyricsItalic: return LabelSwitchCell.identifier
            case .lyricsUnderlined: return LabelSwitchCell.identifier
            case .image: return LabelPhotoPickerCell.identifier
            case .pastorImage: return LabelPhotoPickerCell.identifier
            case .hasBorder: return LabelSwitchCell.identifier
            case .imageBorderSize: return LabelNumberCell.identifier
            case .imageBorderColor: return LabelColorPickerNewCell.identifier
            case .contentMode: return LabelPickerCell.identifier
            }
        }
        
        var updateDynamicHeigts: Bool {
            switch self {
            case .asTheme, .backgroundImage, .backgroundTransparancy, .titleFontFamily, .titleAlignment, .lyricsFontFamily, .lyricsAlignment, .image, .pastorImage, .contentMode: return true
            default: return false
            }
        }
    }
    
    
	
	enum CellInput: String {
		case title
		case content
		case contentLeft
		case contentRight
		
		static let all = [title, content, contentLeft, contentRight]
		
		static let theme = [title]
        static let activities = [title]
        static let empty = [title]
		static let sheetTitleContent = [title, content]
		static let sheetSplit = [title, contentLeft, contentRight]
		
		static func `for`(indexPath: IndexPath, sheetType: SheetType, modificationMode: ModificationMode) -> CellInput? {
			if modificationMode == .newTheme || modificationMode == .editTheme {
				return title
			}
			switch sheetType {
			case .SheetTitleContent, .SheetTitleImage, .SheetPastors: return CellInput.sheetTitleContent[indexPath.row]
			case .SheetSplit: return CellInput.sheetSplit[indexPath.row]
            case .SheetActivities: return CellInput.activities[indexPath.row]
			default: return title
			}
		}
		
		func set(themeAttribute: inout ThemeAttribute?, sheetAttribute: inout SheetAttribute?, identifier: inout String?, modificationMode: ModificationMode) {
			switch self {
			case .title:
				if modificationMode == .newTheme || modificationMode == .editTheme {
					themeAttribute = ThemeAttribute.title
				} else {
					sheetAttribute = .SheetTitle
				}
				identifier = LabelTextFieldCell.identifier
			case .content:
				sheetAttribute = .SheetContent
				identifier = LabelTextViewCell.identifier
			case .contentLeft:
				sheetAttribute = .SheetContentLeft
				identifier = LabelTextViewCell.identifier
			case .contentRight:
				sheetAttribute = .SheetContentRight
				identifier = LabelTextViewCell.identifier
			}
		}
	}
	
	enum CellGeneral: String {
		case asTheme
		case hasEmptySheet
        case hasEmptySheetBeginning
		case allHaveTitle
		case backgroundColor
		case backgroundImage
		case backgroundTransparancy
		case displayTime
				
        static func getThemeList(sheetType: SheetType?, emptySheet: Bool, hasImage: Bool) -> [CellGeneral] {
            guard sheetType == nil else {
                return hasImage ? sheetCellsTransBackground : sheetCells
            }
            var list: [CellGeneral] = [asTheme, hasEmptySheet]
            if emptySheet {
                list += [hasEmptySheetBeginning]
            }
            list += [allHaveTitle, backgroundColor, backgroundImage]
            if hasImage {
                list += [backgroundTransparancy]
            }
            list += [displayTime]
            return list
        }

		static let sheetCells = [asTheme, backgroundColor, backgroundImage]
		static let sheetCellsTransBackground = [asTheme, backgroundColor, backgroundImage, backgroundTransparancy]
        
        static func `for`(_ indexPath: IndexPath, type: SheetType?, modificationMode: ModificationMode, hasImage: Bool, hasEmptySheet: Bool) -> CellGeneral {

				if modificationMode == .newTheme || modificationMode == .editTheme {
                    return getThemeList(sheetType: type, emptySheet: hasEmptySheet, hasImage: hasImage)[indexPath.row]
                } else {
					return hasImage ? sheetCellsTransBackground[indexPath.row] : sheetCells[indexPath.row]
				}
		}
		
		var cellIdentifier: (ThemeAttribute, String) {
			switch self {
			case .asTheme: return (.asTheme ,LabelPickerCell.identifier)
            case .hasEmptySheet: return (.hasEmptySheet, LabelSwitchCell.identifier)
            case .hasEmptySheetBeginning: return (.isEmptySheetFirst, LabelSwitchCell.identifier)
			case .allHaveTitle: return (.allHaveTitle, LabelSwitchCell.identifier)
			case .backgroundColor: return (.backgroundColor ,LabelColorPickerNewCell.identifier)
			case .backgroundImage: return (.backgroundImage, LabelPhotoPickerCell.identifier)
			case .backgroundTransparancy: return (.backgroundTransparancy , LabelSliderCell.identifier)
			case .displayTime: return (.displayTime, LabelSwitchCell.identifier)
			}
		}
	}
	
	enum CellTitle: String {
		case fontFamily
		case fontSize
		case backgroundColor
		case alignment
		case borderSize
		case textColor
		case borderColor
		case bold
		case italic
		case underlined
		
		static let all = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		
		static let sheetTitleContent = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let titleImage = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetPastors = [fontFamily, fontSize, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetSplit = [fontFamily, fontSize, backgroundColor, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetEmpty: [CellTitle] = []
		static let sheetActivities = [fontFamily, borderSize, textColor, borderColor, bold, italic, underlined]
		
		static func `for`(_ indexPath: IndexPath, type: SheetType, modificationMode: ModificationMode) -> CellTitle? {
			switch type {
			case .SheetTitleContent:
				return sheetTitleContent[indexPath.row]
			case .SheetTitleImage:
				return titleImage[indexPath.row]
			case .SheetPastors:
				return sheetPastors[indexPath.row]
			case .SheetSplit:
				return sheetSplit[indexPath.row]
			case .SheetActivities:
				return sheetActivities[indexPath.row]
			default:
				return nil
			}
		}
		
		func set( themeAttribute: inout ThemeAttribute?, sheetAttribute: inout SheetAttribute?, identifier: inout String?) {
			switch self {
			case .fontFamily:
				themeAttribute = .titleFontName
				identifier = LabelPickerCell.identifier
			case .fontSize:
				themeAttribute = .titleTextSize
				identifier = LabelNumberCell.identifier
			case .backgroundColor:
				themeAttribute = .titleBackgroundColor
				identifier = LabelColorPickerNewCell.identifier
			case .alignment:
				themeAttribute = .titleAlignment
				identifier = LabelPickerCell.identifier
			case .borderSize:
				themeAttribute = .titleBorderSize
				identifier = LabelNumberCell.identifier
			case .textColor:
				themeAttribute = .titleTextColorHex
				identifier = LabelColorPickerNewCell.identifier
			case .borderColor:
				themeAttribute = .titleBorderColorHex
				identifier = LabelColorPickerNewCell.identifier
			case .bold:
				themeAttribute = .isTitleBold
				identifier = LabelSwitchCell.identifier
			case .italic:
				themeAttribute = .isTitleItalic
				identifier = LabelSwitchCell.identifier
			case .underlined:
				themeAttribute = .isTitleUnderlined
				identifier = LabelSwitchCell.identifier
			}
		}
	}
	
	enum CellLyrics: String {
		case fontFamily
		case fontSize
		case alignment
		case borderSize
		case textColor
		case borderColor
		case bold
		case italic
		case underlined
		
		static let all = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		
		static let themeTitleContent = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetTitleContent = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let titleImage = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetPastor = [fontFamily, fontSize, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetSplit = [fontFamily, fontSize, alignment, borderSize, textColor, borderColor, bold, italic, underlined]
		static let sheetEmpty: [CellLyrics] = []
		static let sheetActivities = [fontFamily, borderSize, textColor, borderColor, bold, italic, underlined]
		
		static func `for`(_ indexPath: IndexPath, type: SheetType, modificationMode: ModificationMode) -> CellLyrics? {
			switch  type{
			case .SheetTitleContent:
				return (modificationMode == .newCustomSheet || modificationMode == .editCustomSheet) ? sheetTitleContent[indexPath.row] : themeTitleContent[indexPath.row]
			case .SheetTitleImage:
				return titleImage[indexPath.row]
			case .SheetPastors:
				return sheetPastor[indexPath.row]
			case .SheetSplit:
				return sheetSplit[indexPath.row]
			case .SheetActivities:
				return sheetActivities[indexPath.row]
			default:
				return nil
			}
		}
		
		func set( themeAttribute: inout ThemeAttribute?, sheetAttribute: inout SheetAttribute?, identifier: inout String?) {
			switch self {
			case .fontFamily:
				themeAttribute = .contentFontName
				identifier = LabelPickerCell.identifier
			case .fontSize:
				themeAttribute = .contentTextSize
				identifier = LabelNumberCell.identifier
			case .alignment:
				themeAttribute = .contentAlignment
				identifier = LabelPickerCell.identifier
			case .borderSize:
				themeAttribute = .contentBorderSize
				identifier = LabelNumberCell.identifier
			case .textColor:
				themeAttribute = .contentTextColorHex
				identifier = LabelColorPickerNewCell.identifier
			case .borderColor:
				themeAttribute = .contentBorderColor
				identifier = LabelColorPickerNewCell.identifier
			case .bold:
				themeAttribute = .isContentBold
				identifier = LabelSwitchCell.identifier
			case .italic:
				themeAttribute = .isContentItalic
				identifier = LabelSwitchCell.identifier
			case .underlined:
				themeAttribute = .isContentUnderlined
				identifier = LabelSwitchCell.identifier
			}
		}
		
	}
	
	enum CellImage: String {
		case image
		case pastorImage
		case hasBorder
		case borderSize
		case borderColor
		case contentMode
		
		static let all = [image, pastorImage, hasBorder, borderSize, borderColor, contentMode]
		static let sheetTitleImage = [image, hasBorder, borderSize, borderColor, contentMode]
		static let noBorder = [image, hasBorder, contentMode]
		static let sheetPastors = [pastorImage]
		
		static func `for`(_ indexPath: IndexPath) -> CellImage {
			return all[indexPath.row]
		}
		
		static func `for`(_ indexPath: IndexPath, type: SheetType, hasBorder: Bool) -> CellImage? {
			if type == .SheetTitleImage, hasBorder {
				return sheetTitleImage[indexPath.row]
			} else if type == .SheetTitleImage {
				return noBorder[indexPath.row]
			} else if type == .SheetPastors {
				return sheetPastors[indexPath.row]
			} else {
				return nil
			}
		}
		
		var cellIdentifier: (SheetAttribute, String) {
			switch self {
			case .image: return (.SheetImage, LabelPhotoPickerCell.identifier)
			case .pastorImage: return (.SheetPastorImage, LabelPhotoPickerCell.identifier)
			case .hasBorder: return (.SheetImageHasBorder , LabelSwitchCell.identifier)
			case .borderSize: return (.SheetImageBorderSize, LabelNumberCell.identifier)
			case .borderColor: return (.SheetImageBorderColor, LabelColorPickerNewCell.identifier)
			case .contentMode: return (.SheetImageContentMode, LabelPickerCell.identifier)
			}
		}
	}
	
	private var  cellImageContentMode = LabelPickerCell()
		
//	override var requesters: [RequesterType] {
//		return [ThemeSubmitter]
//	}
	
	var delegate: NewOrEditIphoneControllerDelegate?
	var modificationMode: ModificationMode = .newTheme
	var theme: VTheme! {
		didSet {
			if let sheet = sheet {
				sheet.hasTheme = theme
			}
		}
	}
	var sheet: VSheet! {
		didSet {
			if let theme = theme {
				sheet.hasTheme = theme
			}
			if sheet.hasTheme?.isHidden == true {
				theme = sheet.hasTheme
			}
		}
	}
	
	var dismissMenu: (() -> Void)?
	
	private var isSetup = true
	private var titleAttributes: [NSAttributedString.Key : Any] = [:]
	private var contentAttributes: [NSAttributedString.Key: Any] = [:]
	private var externalDisplayRatioConstraint: NSLayoutConstraint?
	private var newSheetContainerViewHeightConstraint: NSLayoutConstraint?
	private var activeIndexPath: IndexPath?
	
    private lazy var colorPickerViewController: ColorPickerViewController = {
        let vc = Storyboard.MainStoryboard.instantiateViewController(identifier: "ColorPickerViewController") as! ColorPickerViewController
        view.addSubview(vc.view)
        vc.view.frame = tableView.frame.offsetBy(dx: view.bounds.width, dy: 0)
        vc.didMove(toParent: self)
        return vc
    }()
	
	
	// MARK: - Functions
	
	// MARK: UIViewController functions

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.unwrap()?.viewWillAppear(animated)
    }
	
	// MARK: UITableview functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		switch sheet.type {
		case .SheetTitleContent:
			return Section.titleContent.count
		case .SheetTitleImage, .SheetPastors:
			return Section.titleImage.count
		case .SheetSplit:
			return Section.sheetSplit.count
		case .SheetEmpty:
			return Section.sheetEmpty.count
		case .SheetActivities:
			return Section.activity.count
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section, type: sheet.type) {
		case .input:
			let isTheme = modificationMode == .newTheme || modificationMode == .editTheme
			switch sheet.type {
			case .SheetTitleContent, .SheetTitleImage, .SheetPastors: return isTheme ? CellInput.theme.count : CellInput.sheetTitleContent.count
			case .SheetSplit: return CellInput.sheetSplit.count
            case .SheetActivities: return CellInput.activities.count
            case .SheetEmpty: return CellInput.empty.count
			}
		case .general:
			if modificationMode == .newTheme || modificationMode == .editTheme {
                let hasImage = (theme?.tempSelectedImage ?? theme.backgroundImage) != nil
                return CellGeneral.getThemeList(sheetType: modificationMode.isTheme ? nil : sheet.type, emptySheet: theme?.hasEmptySheet ?? false, hasImage: hasImage).count
			} else {
				return (theme?.tempSelectedImage ?? theme.backgroundImage) != nil ? CellGeneral.sheetCellsTransBackground.count : CellGeneral.sheetCells.count
			}
		case .title:
			switch sheet.type {
			case .SheetTitleContent: return CellTitle.sheetTitleContent.count
			case .SheetTitleImage: return CellTitle.titleImage.count
			case .SheetPastors: return CellTitle.sheetPastors.count
			case .SheetSplit: return CellTitle.sheetSplit.count
			case .SheetEmpty: return CellTitle.sheetEmpty.count
			case .SheetActivities: return CellTitle.sheetActivities.count
			}
		case .content:
			let isSheet = (modificationMode == .newCustomSheet || modificationMode == .editCustomSheet)
			switch sheet.type {
			case .SheetTitleContent: return isSheet ? CellLyrics.sheetTitleContent.count : CellLyrics.themeTitleContent.count
			case .SheetTitleImage: return CellLyrics.titleImage.count
			case .SheetPastors: return CellLyrics.sheetPastor.count
			case .SheetSplit: return CellLyrics.sheetSplit.count
			case .SheetEmpty: return CellLyrics.sheetEmpty.count
			case .SheetActivities: return CellLyrics.sheetActivities.count
			}
		case .image:
			switch sheet.type {
			case .SheetTitleImage: return (sheet as! VSheetTitleImage).imageHasBorder ? CellImage.sheetTitleImage.count : CellImage.noBorder.count
			case .SheetPastors: return CellImage.sheetPastors.count
			default:
				return 0
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell? = nil
		var themeAttribute: ThemeAttribute? = nil
		var sheetAttribute: SheetAttribute? = nil
		var identifier: String? = nil
		
		switch Section.for(indexPath.section, type: sheet.type) {
		
		case .input:
			CellInput.for(indexPath: indexPath, sheetType: sheet.type, modificationMode: modificationMode)!.set(themeAttribute: &themeAttribute, sheetAttribute: &sheetAttribute, identifier: &identifier, modificationMode: modificationMode)
		case .general:
			let hasImage = (theme?.tempSelectedImage ?? theme.backgroundImage) != nil
            themeAttribute = CellGeneral.getThemeList(sheetType: modificationMode.isTheme ? nil : sheet.type, emptySheet: theme?.hasEmptySheet ?? false, hasImage: hasImage)[indexPath.row].cellIdentifier.0
            identifier = CellGeneral.getThemeList(sheetType: modificationMode.isTheme ? nil : sheet.type, emptySheet: theme?.hasEmptySheet ?? false, hasImage: hasImage)[indexPath.row].cellIdentifier.1
		case .title:
			CellTitle.for(indexPath, type: sheet.type, modificationMode: modificationMode)?.set(themeAttribute: &themeAttribute, sheetAttribute: &sheetAttribute, identifier: &identifier)
			
		case .content:
			CellLyrics.for(indexPath, type: sheet.type, modificationMode: modificationMode)?.set(themeAttribute: &themeAttribute, sheetAttribute: &sheetAttribute, identifier: &identifier)
			
		case .image:
			var imageHasBorder = false
			if let sheet = sheet as? VSheetTitleImage {
				imageHasBorder = sheet.imageHasBorder
			}
			sheetAttribute = CellImage.for(indexPath, type: sheet.type, hasBorder: imageHasBorder)?.cellIdentifier.0
			identifier = CellImage.for(indexPath, type: sheet.type, hasBorder: imageHasBorder)?.cellIdentifier.1
		}
		
		if let identifier = identifier {
			cell = tableView.dequeueReusableCell(withIdentifier: identifier)
			
			(cell as? LabelTextFieldCell)?.getModificationMode = getModificationMode
			(cell as? LabelPhotoPickerCell)?.sender = self
            
			if let themeAttribute = themeAttribute, var cell = cell as? ThemeImplementation {
				if let cell = cell as? LabelTextFieldCell {
					cell.getModificationMode = getModificationMode
				}
				cell.apply(theme: theme, themeAttribute: themeAttribute)
				cell.valueDidChange = valueDidChange(cell:)
			}
			
			if let sheetAttribute = sheetAttribute, var cell = cell as? SheetImplementation {
				cell.apply(sheet: sheet, sheetAttribute: sheetAttribute)
				cell.valueDidChange = valueDidChange(cell:)
			}
			
			if var cell = cell as? DynamicHeightCell {
				cell.isActive = activeIndexPath?.row == indexPath.row && activeIndexPath?.section == indexPath.section
			}
		}
		
		if let cell = cell {
			return cell
		} else {
			return UITableViewCell()
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if let cell = self.tableView(tableView, cellForRowAt: indexPath) as? DynamicHeightCell {
			return cell.preferredHeight
		}
		return 60
	}
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HeaderView.height
    }
    
	func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return HeaderView.height
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.basicHeaderView else { return nil }
		switch Section.for(section, type: sheet.type) {
		case .input:
			view.descriptionLabel.text = AppText.NewTheme.sectionInput
		case .general:
			view.descriptionLabel.text = AppText.NewTheme.sectionGeneral
		case .title:
			view.descriptionLabel.text = AppText.NewTheme.sectionTitle
		case .content:
			view.descriptionLabel.text = AppText.NewTheme.sectionLyrics
		case .image:
			view.descriptionLabel.text = AppText.NewSheetTitleImage.title
		}
		return view
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		activeIndexPath = activeIndexPath == indexPath ? nil : indexPath
		if let cell = tableView.cellForRow(at: indexPath), cell is DynamicHeightCell {
			if activeIndexPath != nil {
				self.reloadDataWithScrollTo(cell)
			} else {
				tableView.reloadData()
			}
        }
        if let cell = tableView.cellForRow(at: indexPath) as? LabelColorPickerNewCell {
            
            let colorPickerController = UIColorPickerViewController()
            colorPickerController.selectedColor = cell.selectedColor ?? .whiteColor
            cell.tag = 1
            colorPickerController.delegate = self
            self.present(colorPickerController, animated: true)
        }
	}
	
	
	
	// MARK: - Delegate functions
	
	func valueDidChange(cell: UITableViewCell) {
		var needsReload = false
		if let cell = cell as? ThemeImplementation, let themeAttribute = cell.themeAttribute {
			
			switch themeAttribute {
			case .backgroundTransparancy: updateTransparency()
			case .title, .titleBorderSize, .titleFontName, .titleTextSize, .titleAlignment, .titleTextColorHex, .titleBorderColorHex, .isTitleBold, .isTitleItalic, .isTitleUnderlined: updateSheetTitle()
			case .contentFontName, .contentTextSize, .contentTextColorHex, .contentAlignment, .contentBorderColor, .contentBorderSize, .isContentBold, .isContentItalic, .isContentUnderlined: updateSheetContent()
			case .displayTime: updateTime()
			case .backgroundImage:
				updateBackgroundImage()
				needsReload = true
			case .backgroundColor, .titleBackgroundColor:
                updateBackgroundColor()
                updateTransparency()
			case .asTheme:
				let cell = cell as! LabelPickerCell
                let id = cell.pickerValues[cell.selectedIndex].0
                if let theme: Theme = DataFetcher().getEntity(moc: moc, predicates: [.get(id: id)]) {
                    updateAsTheme(VTheme(theme: theme, context: moc))
                }
			default: break
			}
		}
		
		if let cell = cell as? SheetImplementation, let sheetAttribute = cell.sheetAttribute {
				switch sheetAttribute {
				case .SheetTitle: updateSheetTitle()
				case .SheetContent, .SheetContentLeft, .SheetContentRight: updateSheetContent()
                case .SheetImageHasBorder, .SheetImageContentMode, .SheetImageBorderSize:
					updateSheetImage()
					needsReload = true
				case .SheetImage, .SheetPastorImage:
					let cell = cell as! LabelPhotoPickerCell
					set(image: cell.pickedImage, for: sheet)
					updateSheetImage()
					needsReload = true
				default: break
			}
		}
		
		if !(cell is LabelSliderCell) && !(cell is LabelColorPickerNewCell) {
			if var cell = cell as? DynamicHeightCell {
				if !needsReload && !(cell is LabelTextViewCell) {
					let isActive = !cell.isActive
					cell.isActive = isActive
					activeIndexPath = nil
					tableView.beginUpdates()
					tableView.endUpdates()
				}
			}
		}
        if let cell = cell as? LabelSwitchCell, cell.themeAttribute == .some(.hasEmptySheet), let index = CellGeneral.getThemeList(sheetType: modificationMode.isTheme ? nil : sheet.type, emptySheet: true, hasImage: true).firstIndex(of: .hasEmptySheetBeginning) {
            if cell.switch.isOn {
                tableView.insertRows(at: [IndexPath(row: index, section: 1)], with: .top)
            } else {
                cell.sheetTheme?.isEmptySheetFirst = false
                tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .top)
            }
        }
		
		if needsReload {
			tableView.reloadData()
		}
		
	}
	
	func getModificationMode() -> ModificationMode {
		return modificationMode
	}
	
	
	
	// MARK:  Submit Delegate Functions
	
	override func handleRequestFinish(requesterId: String, result: Any?) {
		shutDownExternalDisplay()
		delegate?.didCloseNewOrEditIphoneController()
	}
    
    override func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        save.isEnabled = true
        presentedViewController?.dismiss(animated: false)
        super.requesterDidFinish(requester: requester, result: result, isPartial: isPartial)
    }
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		switch modificationMode {
			
		case .newTheme:
            let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: false))
            let position = (themes.first?.position ?? 0) + 1
			
			let sheet = VSheetTitleContent()
			sheet.title = AppText.NewTheme.sampleTitle
			sheet.content = AppText.NewTheme.sampleLyrics
			self.sheet = sheet
			let theme = VTheme()
			theme.title = AppText.NewTheme.sampleTitle
			theme.isHidden = false
			theme.titleTextSize = 14
            theme.textColorTitle = UIColor(hex: "000000")
			theme.contentTextSize = 10
            theme.textColorLyrics = UIColor(hex: "000000")
			theme.titleFontName = "Avenir"
			theme.contentFontName = "Avenir"
			theme.backgroundTransparancy = 100
			theme.titleAlignmentNumber = 0
			theme.contentAlignmentNumber = 0
			theme.position = position
			theme.backgroundColor = UIColor(hex: "FFFFFF")!.hexCode
			self.theme = theme
			
		case .editTheme:
			let sheet = VSheetTitleContent()
			sheet.title = AppText.NewTheme.sampleTitle
			sheet.content = AppText.NewTheme.sampleLyrics
			self.sheet = sheet
			
		case .newCustomSheet:
			let theme = VTheme()
			theme.title = "theme"
			theme.isHidden = true
			theme.titleTextSize = 14
			theme.textColorTitle = UIColor(hex: "000000")
			theme.contentTextSize = 10
			theme.textColorLyrics = UIColor(hex: "000000")
			theme.backgroundTransparancy = 100
			theme.allHaveTitle = true
			theme.hasEmptySheet = false
			theme.titleAlignmentNumber = 0
			theme.contentAlignmentNumber = 0
			theme.titleFontName = "Avenir"
			theme.contentFontName = "Avenir"
			theme.backgroundColor = UIColor(hex: "FFFFFF")!.hexCode
			sheet.title = AppText.NewTheme.sampleTitle
			if let sheet = sheet as? VSheetTitleContent {
				sheet.content = AppText.NewTheme.sampleLyrics
			}
			if let sheet = sheet as? VSheetTitleImage {
				sheet.content = AppText.NewTheme.sampleLyrics
			}
			if let sheet = sheet as? VSheetSplit {
				sheet.textLeft = AppText.NewTheme.sampleLyrics
				sheet.textRight = AppText.NewTheme.sampleLyrics
			}
			if let sheet = sheet as? VSheetPastors {
				theme.textColorTitle = UIColor(hex: "000000")
				theme.textColorLyrics = UIColor(hex: "000000")
				theme.isTitleItalic = true
				theme.isContentItalic = true
				theme.titleAlignmentNumber = 1
				theme.contentAlignmentNumber = 1
				
				sheet.title = AppText.NewPastorsSheet.title
				sheet.content = AppText.NewPastorsSheet.content
				sheet.title = sheet.title
			}
			self.theme = theme
			
		case .editCustomSheet:
			break
		}

        tableView.backgroundColor = .clear
		NotificationCenter.default.addObserver(forName: .externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
		
        tableView.register(header: BasicHeaderView.identifier)
		tableView.register(cell: Cells.labelNumberCell)
		tableView.register(cell: LabelColorPickerNewCell.identifier)
		tableView.register(cell: Cells.LabelPickerCell)
		tableView.register(cell: Cells.LabelSwitchCell)
		tableView.register(cell: Cells.labelTextFieldCell)
		tableView.register(cell: Cells.LabelPhotoPickerCell)
		tableView.register(cell: LabelTextViewCell.identifier)
		tableView.register(cell: LabelSliderCell.identifier)
		tableView.register(cell: LabelDoubleSwitchCell.identifier)
		
		refineSheetRatio()
		
		cancel.title = AppText.Actions.cancel
		save.title = AppText.Actions.save
        cancel.tintColor = themeHighlighted
        save.tintColor = themeHighlighted
		
		hideKeyboardWhenTappedAround()
		
		tableView.keyboardDismissMode = .interactive
		
		isSetup = false
		buildPreview(isSetup: false)
	}
	
	private func reloadDataWithScrollTo(_ cell: UITableViewCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			tableView.reloadData()
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
				self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
			}
		}
	}
	
	private func buildPreview(isSetup: Bool) {
		if !isSetup {
			
			for subview in previewView.subviews {
				subview.removeFromSuperview()
			}
			
            previewView.addSubview(SheetView.createWith(frame: previewView.bounds, cluster: nil, sheet: sheet, theme: theme, scaleFactor: getScaleFactor(width: previewView.bounds.width), toExternalDisplay: true))
			
		}
	}
	
	private func updateTransparency() {
		if let view = previewView.subviews.first {
			
			if let sheet = view as? SheetView {
				sheet.updateOpacity()
			}
			if let view = externalDisplayWindow?.subviews.first as? SheetView {
				view.updateOpacity()
			}
		}
	}
	
	private func updateSheetTitle() {
		if let view = previewView.subviews.first as? SheetView {
			view.updateTitle()
		}
		if let view = externalDisplayWindow?.subviews.first as? SheetView {
			view.updateTitle()
		}
	}
	
	private func updateSheetContent() {
		if let view = previewView.subviews.first as? SheetView {
			view.updateContent()
		}
		if let view = externalDisplayWindow?.subviews.first as? SheetView {
			view.updateContent()
		}
	}
		
	private func updateBackgroundImage() {
		if let view = previewView.subviews.first as? SheetView {
			view.updateBackgroundImage()
		}
		if let view = externalDisplayWindow?.subviews.first as? SheetView {
			view.updateBackgroundImage()
		}
	}
	
	private func updateSheetImage() {
		if let view = previewView.subviews.first, let sheet = view as? SheetView {
			sheet.updateSheetImage()
		}
		if let view = externalDisplayWindow?.subviews.first as? SheetView {
			view.updateSheetImage()
		}
	}
	
	private func updateBackgroundColor() {
		if let view = previewView.subviews.first as? SheetView {
			view.updateBackgroundColor()
		}
		if let view = externalDisplayWindow?.subviews.first as? SheetView {
			view.updateBackgroundColor()
		}
	}
	
	private func updateTime() {
		if let view = previewView.subviews.first, let sheet = view as? SheetView {
			sheet.updateTime(isOn: theme.displayTime)
		}
		if let view = externalDisplayWindow?.subviews.first as? SheetView {
			view.updateTime(isOn: theme.displayTime)
		}
	}
	
	private func updateAsTheme(_ theme: VTheme?) {
		if let theme = theme {
			self.theme.getValues(from: theme)
            if self.sheet.type == .SheetPastors {
                self.theme.titleAlignmentNumber = Int16(NSTextAlignment.center.rawValue)
                self.theme.contentAlignmentNumber = Int16(NSTextAlignment.center.rawValue)
            }
		}
		tableView.reloadData()
		buildPreview(isSetup: false)
	}

	@objc func externalDisplayDidChange(_ notification: Notification) {
		refineSheetRatio()
	}
	
	private func set(image: UIImage?, for sheet: VSheet) {
		if let sheet = sheet as? VSheetPastors {
			do {
                try sheet.set(image: image, imageName: nil)
			} catch {
				show(message: error.localizedDescription)
			}
		}
		if let sheet = sheet as? VSheetTitleImage {
			do {
				try sheet.set(image: image, imageName: nil)
			} catch {
				show(message: error.localizedDescription)
			}
		}
	}
	
	private func refineSheetRatio() {
		
		// sheet ratio ajustments
		
		// deactivate standard constraint
		previewViewRatioConstraint.isActive = false
		
		// remove previous constraint
		if let externalDisplayRatioConstraint = externalDisplayRatioConstraint {
			previewView.removeConstraint(externalDisplayRatioConstraint)
		}
		
		// add new constraint
		externalDisplayRatioConstraint = NSLayoutConstraint(item: previewView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: previewView, attribute: NSLayoutConstraint.Attribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
		previewView.addConstraint(externalDisplayRatioConstraint!)
		
		
//		// Container view height ajustments
//
//		// remove previous active constraint
//		if let newHeightconstraint = newSheetContainerViewHeightConstraint {
//			sheetContainerView.removeConstraint(newHeightconstraint)
//		}
//		// deactivate standard constraint
//		sheetContainerViewHeightConstraint.isActive = false
//
//		// add new constraint
//		newSheetContainerViewHeightConstraint = NSLayoutConstraint(item: sheetContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIScreen.main.bounds.width - 20) * externalDisplayWindowRatio)
//		sheetContainerView.addConstraint(newSheetContainerViewHeightConstraint!)
		previewView.layoutIfNeeded()
		buildPreview(isSetup: isSetup)
		
	}
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		set(image: nil, for: sheet)
        let theme: Theme? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: self.theme.id)])
		if let original = theme {
            self.theme.getPropertiesFrom(entity: original, context: moc)
		}
		self.shutDownExternalDisplay()
		self.dismiss(animated: true)
	}
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
        save.isEnabled = false
		var showError = false
		switch modificationMode {
		case .newTheme, .editTheme: showError = (theme.title == "" || theme.title == nil)
		case .newCustomSheet, .editCustomSheet: showError = (sheet.title == "" || sheet.title == nil)
		}
		
		if showError {
			let message = UIAlertController(title: AppText.NewTheme.errorTitle, message:
				AppText.NewTheme.errorMessage, preferredStyle: .alert)
			message.addAction(UIAlertAction(title: AppText.Actions.close, style: .default, handler: nil))
			
			self.present(message, animated: true, completion: nil)
			
		} else {
			
			switch modificationMode {
				
			case .newTheme, .editTheme:
				let requestMethod: RequestMethod = modificationMode == .newTheme ? .post : .put
                if theme.tempSelectedImage != nil {
                    showProgress(requester: ThemeSubmitter)
                } else {
                    ThemeSubmitter.addObserver(self)
                    showLoader()
                }
                ThemeSubmitter.submit([theme], requestMethod: requestMethod)
                
			case .newCustomSheet, .editCustomSheet:
				sheet.hasTheme = theme
				shutDownExternalDisplay()
				delegate?.didCreate(sheet: sheet)
				dismissMenu?()
				dismiss(animated: true)
			}
		}
		
	}
	
	private func shutDownExternalDisplay() {
		if let externalDisplayWindow = externalDisplayWindow {
			let view = UIView(frame: externalDisplayWindow.frame)
			view.backgroundColor = .black
			externalDisplayWindow.addSubview(view)
		}
	}
	
}

extension NewOrEditIphoneController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        (tableView.visibleCells.first(where: { $0.tag == 1 }) as? LabelColorPickerNewCell)?.setNewColor(viewController.selectedColor)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        (tableView.visibleCells.first(where: { $0.tag == 1 }) as? LabelColorPickerNewCell)?.setNewColor(viewController.selectedColor)
        tableView.visibleCells.first(where: { $0.tag == 1 })?.tag = 0
    }
}

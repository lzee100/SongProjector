//
//  VTheme.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import FirebaseAuth

struct VTheme: VEntityType, Codable {
	
//	class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil) -> [VTheme] {
//        guard Thread.isMainThread else {
//            fatalError()
//        }
//		if let attributeName = attributeName, let ascending = ascending {
//			CoreTheme.setSortDescriptor(attributeName: attributeName, ascending: ascending)
//		}
//		return CoreTheme.getEntities().map({ VTheme(theme: $0) })
//	}
//
//	class func single(with id: String?) -> VTheme? {
//        guard Thread.isMainThread else {
//            fatalError()
//        }
//		if let id = id, let theme = CoreTheme.getEntitieWith(id: id) {
//			return VTheme(theme: theme)
//		}
//		return nil
//	}
    
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
	
	var allHaveTitle: Bool = false
	var backgroundColor: String? = nil
	var backgroundTransparancyNumber: Double = 0
	var displayTime: Bool = false
	var hasEmptySheet: Bool = false
	var imagePath: String? = nil
	var imagePathThumbnail: String? = nil
	var isEmptySheetFirst: Bool = false
	var isHidden: Bool = false
	var isContentBold: Bool = false
	var isContentItalic: Bool = false
	var isContentUnderlined: Bool = false
	var isTitleBold: Bool = false
	var isTitleItalic: Bool = false
	var isTitleUnderlined: Bool = false
	var contentAlignmentNumber: Int16 = 0
	var contentBorderColorHex: String? = nil
	var contentBorderSize: Float = 0
	var contentFontName: String? = "Avenir"
	var contentTextColorHex: String? = "000000"
	var contentTextSize: Float = 9
	var position: Int16 = 0
	var titleAlignmentNumber: Int16 = 0
	var titleBackgroundColor: String? = nil
	var titleBorderColorHex: String? = nil
	var titleBorderSize: Float = 0
	var titleFontName: String? = "Avenir"
	var titleTextColorHex: String? = "000000"
	var titleTextSize: Float = 11
	var imagePathAWS: String? = nil
	var isUniversal: Bool = false
    var isDeletable: Bool = true
    
    var tempSelectedImage: UIImage? {
        didSet {
            tempSelectedImageThumbNail = tempSelectedImage?.resized(withPercentage: 0.5)
        }
    }
    var tempSelectedImageThumbNail: UIImage?
    var isTempSelectedImageDeleted = false
    var tempLocalImageName: String?
    
	var hasClusters: [VCluster] = []
	var hasSheets: [VSheet] = []
    
    var hasNewRemoteImage: Bool {
        if let imagePathAWS = imagePathAWS {
            if
                let imagePath = imagePath,
                let url = URL(string: imagePath),
                let remoteURL = URL(string: imagePathAWS),
                url.lastPathComponent == remoteURL.lastPathComponent
            {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
	
	enum CodingKeysTheme:String,CodingKey
	{
        case id
        case userUID
        case title
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
		case allHaveTitle
		case backgroundColor
		case backgroundTransparancyNumber = "backgroundTransparancy"
		case displayTime
		case hasEmptySheet
		case imagePath
		case imagePathThumbnail
		case isEmptySheetFirst
		case isHidden
		case isContentBold
		case isContentItalic
		case isContentUnderlined
		case isTitleBold
		case isTitleItalic
		case isTitleUnderlined
		case contentAlignment  = "contentAlignmentNumber"
		case contentBorderColorHex = "contentBorderColor"
		case contentBorderSize
		case contentFontName
		case contentTextColorHex = "contentTextColor"
		case contentTextSize
		case position
		case titleAlignment = "titleAlignmentNumber"
		case titleBackgroundColor
		case titleBorderColorHex = "titleBorderColor"
		case titleBorderSize
		case titleFontName
		case titleTextColorHex = "titleTextColor"
		case titleTextSize
		case imagePathAWS
		case isUniversal
        case isDeletable
	}
    
    init?(theme: Theme?) {
        guard let theme = theme else { return nil }
        id = theme.id
        userUID = theme.userUID
        title = theme.title
        createdAt = theme.createdAt
        updatedAt = theme.updatedAt
        deleteDate = theme.deleteDate
        rootDeleteDate = theme.rootDeleteDate?.date
        backgroundColor = theme.backgroundColor
        backgroundTransparancyNumber = theme.backgroundTransparancyNumber
        displayTime = theme.displayTime
        hasEmptySheet = theme.hasEmptySheet
        imagePath = theme.imagePath
        imagePathThumbnail = theme.imagePathThumbnail
        isEmptySheetFirst = theme.isEmptySheetFirst
        isHidden = theme.isHidden
        isContentBold = theme.isContentBold
        isContentItalic = theme.isContentItalic
        isContentUnderlined = theme.isContentUnderlined
        isTitleBold = theme.isTitleBold
        isTitleItalic = theme.isTitleItalic
        isTitleUnderlined = theme.isTitleUnderlined
        contentAlignmentNumber = theme.contentAlignmentNumber
        contentBorderColorHex = theme.contentBorderColorHex
        contentBorderSize = theme.contentBorderSize
        contentFontName = theme.contentFontName
        contentTextColorHex = theme.contentTextColorHex
        contentTextSize = theme.contentTextSize
        position = theme.position
        titleAlignmentNumber = theme.titleAlignmentNumber
        titleBackgroundColor = theme.titleBackgroundColor
        titleBorderColorHex = theme.titleBorderColorHex
        titleBorderSize = theme.titleBorderSize
        titleFontName = theme.titleFontName
        titleTextColorHex = theme.titleTextColorHex
        titleTextSize = theme.titleTextSize
        imagePathAWS = theme.imagePathAWS
        isUniversal = theme.isUniversal
        isDeletable = theme.isDeletable
    }
    
    init(id: String = "CHURCHBEAM" + UUID().uuidString, userUID: String, title: String?, createdAt: NSDate = Date().localDate() as NSDate, updatedAt: NSDate?, deleteDate: NSDate? = nil, rootDeleteDate: Date? = nil, allHaveTitle: Bool = false, backgroundColor: String? = nil, backgroundTransparancyNumber: Double = 0, displayTime: Bool = false, hasEmptySheet: Bool = false, imagePath: String? = nil, imagePathThumbnail: String? = nil, isEmptySheetFirst: Bool = false, isHidden: Bool = false, isContentBold: Bool = false, isContentItalic: Bool = false, isContentUnderlined: Bool = false, isTitleBold: Bool = false, isTitleItalic: Bool = false, isTitleUnderlined: Bool = false, contentAlignmentNumber: Int16 = 0, contentBorderColorHex: String? = nil, contentBorderSize: Float = 0, contentFontName: String? = "Avenir", contentTextColorHex: String? = "000000", contentTextSize: Float = 9, position: Int16 = 0, titleAlignmentNumber: Int16 = 0, titleBackgroundColor: String? = nil, titleBorderColorHex: String? = nil, titleBorderSize: Float = 0, titleFontName: String? = "Avenir", titleTextColorHex: String? = "000000", titleTextSize: Float = 11, imagePathAWS: String? = nil, isUniversal: Bool = false, isDeletable: Bool = true) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.rootDeleteDate = rootDeleteDate

        self.allHaveTitle = allHaveTitle
        self.backgroundColor = backgroundColor
        self.backgroundTransparancyNumber = backgroundTransparancyNumber
        self.displayTime = displayTime
        self.hasEmptySheet = hasEmptySheet
        self.imagePath = imagePath
        self.imagePathThumbnail = imagePathThumbnail
        self.isEmptySheetFirst = isEmptySheetFirst
        self.isHidden = isHidden
        self.isContentBold = isContentBold
        self.isContentItalic = isContentItalic
        self.isContentUnderlined = isContentUnderlined
        self.isTitleBold = isTitleBold
        self.isTitleItalic = isTitleItalic
        self.isTitleUnderlined = isTitleUnderlined
        self.contentAlignmentNumber = contentAlignmentNumber
        self.contentBorderColorHex = contentBorderColorHex
        self.contentBorderSize = contentBorderSize
        self.contentFontName = contentFontName
        self.contentTextColorHex = contentTextColorHex
        self.contentTextSize = contentTextSize
        self.position = position
        self.titleAlignmentNumber = titleAlignmentNumber
        self.titleBackgroundColor = titleBackgroundColor
        self.titleBorderColorHex = titleBorderColorHex
        self.titleBorderSize = titleBorderSize
        self.titleFontName = titleFontName
        self.titleTextColorHex = titleTextColorHex
        self.titleTextSize = titleTextSize
        self.imagePathAWS = imagePathAWS
        self.isUniversal = isUniversal
        self.isDeletable = isDeletable
    }
    
	// MARK: - Encodable
	
    public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeysTheme.self)
        
        try container.encodeIfPresent(title, forKey: .title)
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        try container.encode(userUID, forKey: .userUID)

       try container.encode((createdAt as Date).intValue, forKey: .createdAt)
        if let updatedAt = updatedAt {
//            let updatedAtString = GlobalDateFormatter.localToUTCNumber(date: updatedAt as Date)
            try container.encode((updatedAt as Date).intValue, forKey: .updatedAt)
        } else {
            try container.encode((createdAt as Date).intValue, forKey: .updatedAt)
        }
        if let deleteDate = deleteDate {
//            let deleteDateString = GlobalDateFormatter.localToUTCNumber(date: deleteDate as Date)
            try container.encode((deleteDate as Date).intValue, forKey: .deleteDate)
        }
        if let rootDeleteDate = rootDeleteDate {
            try container.encode(rootDeleteDate.intValue, forKey: .rootDeleteDate)
        }
                
        try container.encode(id, forKey: .id)
		try container.encode(Int(truncating: NSNumber(value: allHaveTitle)), forKey: .allHaveTitle)
		try container.encode(backgroundColor, forKey: .backgroundColor)
		try container.encode(backgroundTransparancyNumber.description, forKey: .backgroundTransparancyNumber)
		try container.encode(Int(truncating: NSNumber(value: displayTime)), forKey: .displayTime)
		try container.encode(Int(truncating: NSNumber(value: hasEmptySheet)), forKey: .hasEmptySheet)
		try container.encode(Int(truncating: NSNumber(value: isEmptySheetFirst)), forKey: .isEmptySheetFirst)
		try container.encode(Int(truncating: NSNumber(value: isHidden)), forKey: .isHidden)
		try container.encode(Int(truncating: NSNumber(value: isContentBold)), forKey: .isContentBold)
		try container.encode(Int(truncating: NSNumber(value: isContentItalic)), forKey: .isContentItalic)
		try container.encode(Int(truncating: NSNumber(value: isContentUnderlined)), forKey: .isContentUnderlined)
		try container.encode(Int(truncating: NSNumber(value: isTitleBold)), forKey: .isTitleBold)
		try container.encode(Int(truncating: NSNumber(value: isTitleItalic)), forKey: .isTitleItalic)
		try container.encode(Int(truncating: NSNumber(value: isTitleUnderlined)), forKey: .isTitleUnderlined)
		try container.encode(contentAlignmentNumber, forKey: .contentAlignment)
		try container.encode(contentBorderColorHex, forKey: .contentBorderColorHex)
		try container.encode(contentBorderSize, forKey: .contentBorderSize)
		try container.encode(contentFontName, forKey: .contentFontName)
		try container.encode(contentTextColorHex, forKey: .contentTextColorHex)
		try container.encode(contentTextSize, forKey: .contentTextSize)
		try container.encode(position, forKey: .position)
		try container.encode(titleAlignmentNumber, forKey: .titleAlignment)
		try container.encode(titleBackgroundColor, forKey: .titleBackgroundColor)
		try container.encode(titleBorderColorHex, forKey: .titleBorderColorHex)
		try container.encode(titleBorderSize, forKey: .titleBorderSize)
		try container.encode(titleFontName, forKey: .titleFontName)
		try container.encode(titleTextColorHex, forKey: .titleTextColorHex)
		try container.encode(titleTextSize, forKey: .titleTextSize)
		try container.encode(imagePathAWS, forKey: .imagePathAWS)
        try container.encode(Int(truncating: NSNumber(value: isDeletable)), forKey: .isDeletable)
        
	}
	
	
	
	// MARK: - Decodable
	
    public init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeysTheme.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
//        isTemp = false
        let createdAtInt = try container.decode(Int64.self, forKey: .createdAt)
        let updatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .updatedAt)
        let deletedAtInt = try container.decodeIfPresent(Int64.self, forKey: .deleteDate)
        createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt) / 1000) as NSDate

        if let updatedAtInt = updatedAtInt {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtInt) / 1000) as NSDate
        } else {
            updatedAt = nil
        }
        if let deletedAtInt = deletedAtInt {
            deleteDate = Date(timeIntervalSince1970: TimeInterval(deletedAtInt) / 1000) as NSDate
        } else {
            deleteDate = nil
        }
        if let rootdeleteDateInt = try container.decodeIfPresent(Int.self, forKey: .rootDeleteDate) {
            rootDeleteDate = Date(timeIntervalSince1970: TimeInterval(rootdeleteDateInt / 1000))
        } else {
            rootDeleteDate = nil
        }
        
		isTempSelectedImageDeleted = false
		allHaveTitle = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .allHaveTitle) ?? 0) as NSNumber)
		backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
		let transparencyString = try container.decodeIfPresent(String.self, forKey: .backgroundTransparancyNumber) ?? ""
		backgroundTransparancyNumber = Double(truncating: NSDecimalNumber(decimal:Decimal(string: transparencyString) ?? 0.0))
		displayTime = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .displayTime) ?? 0) as NSNumber)
		hasEmptySheet = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .hasEmptySheet) ?? 0) as NSNumber)
		isEmptySheetFirst = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isEmptySheetFirst) ?? 0) as NSNumber)
		isHidden = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isHidden) ?? 0) as NSNumber)
		isContentBold = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentBold) ?? 0) as NSNumber)
		isContentItalic = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentItalic) ?? 0) as NSNumber)
		isContentUnderlined = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isContentUnderlined) ?? 0) as NSNumber)
		isTitleBold = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleBold) ?? 0) as NSNumber)
		isTitleItalic = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleItalic) ?? 0) as NSNumber)
		isTitleUnderlined = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isTitleUnderlined) ?? 0) as NSNumber)
		contentAlignmentNumber = try container.decodeIfPresent(Int16.self, forKey: .contentAlignment) ?? 0
		contentBorderColorHex = try container.decodeIfPresent(String.self, forKey: .contentBorderColorHex)
		contentBorderSize = try container.decodeIfPresent(Float.self, forKey: .contentBorderSize) ?? 14
		contentFontName = try container.decodeIfPresent(String.self, forKey: .contentFontName)
		contentTextColorHex = try container.decodeIfPresent(String.self, forKey: .contentTextColorHex)
		contentTextSize = try container.decodeIfPresent(Float.self, forKey: .contentTextSize) ?? 14
		position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
		titleAlignmentNumber = try container.decodeIfPresent(Int16.self, forKey: .titleAlignment) ?? 0
		titleBackgroundColor = try container.decodeIfPresent(String.self, forKey: .titleBackgroundColor)
		titleBorderColorHex = try container.decodeIfPresent(String.self, forKey: .titleBorderColorHex)
		titleBorderSize = try container.decodeIfPresent(Float.self, forKey: .titleBorderSize) ?? 0
		titleFontName = try container.decodeIfPresent(String.self, forKey: .titleFontName)
		titleTextColorHex = try container.decodeIfPresent(String.self, forKey: .titleTextColorHex)
		titleTextSize = try container.decodeIfPresent(Float.self, forKey: .titleTextSize) ?? 14
		imagePathAWS = try container.decodeIfPresent(String.self, forKey: .imagePathAWS)
		isUniversal = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isUniversal) ?? 0) as NSNumber)
        isDeletable = try Bool(truncating: (container.decodeIfPresent(Int.self, forKey: .isDeletable) ?? 0) as NSNumber)
        
	}
	
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        func setPropertiesTo(theme: Theme, context: NSManagedObjectContext) {
            
            theme.id = id
            theme.title = title
            theme.userUID = userUID
            theme.createdAt = createdAt
            theme.updatedAt = updatedAt
            theme.deleteDate = deleteDate
            //        entity.isTemp = isTemp
            theme.rootDeleteDate = rootDeleteDate as NSDate?
            
            
            theme.allHaveTitle = self.allHaveTitle
            theme.backgroundColor = self.backgroundColor
            theme.backgroundTransparancyNumber = self.backgroundTransparancyNumber
            theme.displayTime = self.displayTime
            theme.hasEmptySheet = self.hasEmptySheet
            theme.imagePath = self.imagePath
            theme.imagePathThumbnail = self.imagePathThumbnail
            if imagePathAWS == nil {
                theme.imagePath = nil
                theme.imagePathThumbnail = nil
            }
            theme.isTempSelectedImageDeleted = self.isTempSelectedImageDeleted
            theme.isEmptySheetFirst = self.isEmptySheetFirst
            theme.isHidden = self.isHidden
            theme.isContentBold = self.isContentBold
            theme.isContentItalic = self.isContentItalic
            theme.isContentUnderlined = self.isContentUnderlined
            theme.isTitleBold = self.isTitleBold
            theme.isTitleItalic = self.isTitleItalic
            theme.isTitleUnderlined = self.isTitleUnderlined
            theme.contentAlignmentNumber = self.contentAlignmentNumber
            theme.contentBorderColorHex = self.contentBorderColorHex
            theme.contentBorderSize = self.contentBorderSize
            theme.contentFontName = self.contentFontName
            theme.contentTextColorHex = self.contentTextColorHex
            theme.contentTextSize = self.contentTextSize
            theme.position = self.position
            theme.titleAlignmentNumber = self.titleAlignmentNumber
            theme.titleBackgroundColor = self.titleBackgroundColor
            theme.titleBorderColorHex = self.titleBorderColorHex
            theme.titleBorderSize = self.titleBorderSize
            theme.titleFontName = self.titleFontName
            theme.titleTextColorHex = self.titleTextColorHex
            theme.titleTextSize = self.titleTextSize
            theme.imagePathAWS = self.imagePathAWS
            theme.isUniversal = self.isUniversal
            theme.isDeletable = self.isDeletable
            
        }

        if let theme: Theme = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(theme: theme, context: context)
            return theme
        } else {
            let theme: Theme = DataFetcher().createEntity(moc: context)
            setPropertiesTo(theme: theme, context: context)
            return theme
        }
    }
}



extension VTheme {
	
	// theme as other theme
	/// entity (Base) properties  will not be overridden
	func getValues(from: VTheme) -> VTheme {
        
        VTheme(id: self.id, userUID: from.id, title: from.title, createdAt: from.createdAt, updatedAt: from.updatedAt, deleteDate: from.deleteDate, rootDeleteDate: from.rootDeleteDate, allHaveTitle: from.allHaveTitle, backgroundColor: from.backgroundColor, backgroundTransparancyNumber: from.backgroundTransparancyNumber, displayTime: from.displayTime, hasEmptySheet: from.hasEmptySheet, imagePath: from.imagePath, imagePathThumbnail: from.imagePathThumbnail, isEmptySheetFirst: from.isEmptySheetFirst, isHidden: from.isHidden, isContentBold: from.isContentBold, isContentItalic: from.isContentItalic, isContentUnderlined: from.isContentUnderlined, isTitleBold: from.isTitleBold, isTitleItalic: from.isTitleItalic, isTitleUnderlined: from.isTitleUnderlined, contentAlignmentNumber: from.contentAlignmentNumber, contentBorderColorHex: from.contentBorderColorHex, contentBorderSize: from.contentBorderSize, contentFontName: from.contentFontName, contentTextColorHex: from.contentTextColorHex, contentTextSize: from.contentTextSize, position: from.position, titleAlignmentNumber: from.titleAlignmentNumber, titleBackgroundColor: from.titleBackgroundColor, titleBorderColorHex: from.titleBorderColorHex, titleBorderSize: from.titleBorderSize, titleFontName: from.titleFontName, titleTextColorHex: from.titleTextColorHex, titleTextSize: from.titleTextSize, imagePathAWS: from.imagePathAWS, isUniversal: isUniversal, isDeletable: isDeletable)
	}
    
    mutating func updateTempLocalImageName(name: String?) {
        tempLocalImageName = name
    }
    
    mutating func updateImagePathAWS(path: String?) {
        imagePathAWS = path
    }

}

extension VTheme {
    
    var uploadObjecs: [UploadObject] {
        let themesPaths = [self].compactMap({ $0.tempLocalImageName })
        return themesPaths.compactMap({ UploadObject(fileName: $0) })
    }
    
    var downloadObjects: [DownloadObject] {
        let themesPaths = [self].filter({ $0.hasNewRemoteImage }).compactMap({ $0.imagePathAWS })
        return themesPaths.compactMap({ URL(string: $0) }).compactMap({ DownloadObject(remoteURL: $0) })
    }
    
    mutating func setUploadValues(_ uploadObjects: [UploadObject]) {
        for upload in uploadObjects.compactMap({ $0 as UploadObject }) {
            if tempLocalImageName == upload.fileName {
                updateImagePathAWS(path: upload.fileName)
            }
        }
    }
    
    func setDownloadValues(_ downloadObjects: [DownloadObject]) {
        for download in downloadObjects.compactMap({ $0 as DownloadObject }) {
            if imagePathAWS == download.remoteURL.absoluteString {
                do {
                    try setBackgroundImage(image: download.image, imageName: download.filename)
                } catch {
                    print(error)
                }
            }
        }
    }
    
}

//
//  ClusterCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreData

public struct ClusterCodable: EntityCodableType, Identifiable, Equatable {
    
    static func makeDefault(userUID: String? = nil) -> ClusterCodable? {
#if DEBUG
        let userId = "userid"
#else
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
#endif
        
        return ClusterCodable(userUID: userUID ?? userId)
    }
    
    init(
        id: String = "CHURCHBEAM" + UUID().uuidString,
        userUID: String = "",
        title: String? = nil,
        createdAt: Date = Date.localDate(),
        updatedAt: Date? = nil,
        deleteDate: Date? = nil,
        isTemp: Bool = false,
        rootDeleteDate: Date? = nil,
        hasSheets: [SheetMetaType] = [SheetTitleContentCodable.makeDefault()].compactMap { $0 },
        hasInstruments: [InstrumentCodable] = [],
        hasTags: [TagCodable] = [],
        root: String? = nil,
        isLoop: Bool = false,
        position: Int16 = 0,
        time: Double = 0,
        themeId: String = "",
        lastShownAt: Date? = nil,
        instrumentIds: String = "",
        sheetIds: [String] = [],
        church: String? = nil,
        startTime: Double = 0.0,
        hasSheetPastors: Bool = false,
        tagIds: [String] = [],
        showEmptySheetBibleText: Bool = true
    ) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.isTemp = isTemp
        self.rootDeleteDate = rootDeleteDate
        self.hasSheets = hasSheets
        self.hasInstruments = hasInstruments
        self.hasTags = hasTags
        self.root = root
        self.isLoop = isLoop
        self.position = position
        self.time = time
        self.themeId = themeId
        self.lastShownAt = lastShownAt
        self.instrumentIds = instrumentIds
        self.sheetIds = sheetIds
        self.church = church
        self.startTime = startTime
        self.hasSheetPastors = hasSheetPastors
        self.tagIds = tagIds
    }
    
    var listViewID = ""
    public var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date.localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    var theme: ThemeCodable?
    
    var hasSheets: [SheetMetaType] = []
    var hasInstruments: [InstrumentCodable] = []
    var hasTags: [TagCodable] = []
    var root: String? = nil
    var isLoop: Bool = false
    var position: Int16 = 0
    var time: Double = 0
    var themeId: String = UUID().uuidString
    var lastShownAt: Date? = nil
    var instrumentIds: String = ""
    var sheetIds: [String] = []
    var church: String?
    var startTime: Double = 0.0
    var hasSheetPastors = false
    var tagIds: [String] = []
    var showEmptySheetBibleText = true
    
    public var isTypeSong: Bool {
        if hasSheets.contains(where: { $0.theme?.isHidden ?? false }) {
            return false
        }
        return !hasSheets.contains(where: { $0.theme?.isHidden == true  }) && hasSheets.count > 0 && !hasSheets.compactMap({ $0 as? SheetTitleContentCodable }).contains(where: { $0.isBibleVers })
    }
    
    public var hasBibleVerses: Bool {
        return hasSheets.compactMap({ $0 as? SheetTitleContentCodable }).contains(where: { $0.isBibleVers })
    }
    
    public var hasPianoSolo: Bool {
        guard hasLocalMusic else { return false }
        return hasInstruments.contains(where: { $0.type == .pianoSolo && $0.resourcePath != nil })
    }
    
    public var hasRemoteMusic: Bool {
        return hasInstruments.contains(where: { $0.resourcePathAWS != nil })
    }
    
    public var hasLocalMusic: Bool {
        return hasInstruments.contains(where: { $0.resourcePath != nil })
    }
    
    enum CodingKeysCluster:String,CodingKey
    {
        case id
        case title
        case userUID
        case createdAt
        case updatedAt
        case deleteDate = "deletedAt"
        case rootDeleteDate
        
        case root
        case isLoop
        case position
        case time
        case theme = "theme"
        case themeId = "theme_id"
        case hasSheets = "sheets"
        case hasInstruments = "instruments"
        case tagids = "tagids"
        case lastShownAt
        case church
        case startTime
        case hasSheetPastors
        case showEmptySheetBibleText
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysCluster.self)
        try container.encode(root, forKey: .root)
        try container.encode(Int(truncating: NSNumber(value: isLoop)), forKey: .isLoop)
        try container.encode(position, forKey: .position)
        try container.encode(time, forKey: .time)
        try container.encode(themeId, forKey: .themeId)
        try container.encode(hasSheets.map(AnySheet.init), forKey: .hasSheets)
        try container.encode(hasInstruments, forKey: .hasInstruments)
        if let lastShownAt = lastShownAt {
            try container.encode(lastShownAt.intValue, forKey: .lastShownAt)
        }
        try container.encode(church, forKey: .church)
        try container.encode(tagIds.joined(separator: ","), forKey: .tagids)
        try container.encode(String(startTime), forKey: .startTime)
        try container.encode(Int(truncating: NSNumber(value: hasSheetPastors)), forKey: .hasSheetPastors)
        try container.encode(Int(truncating: NSNumber(value: showEmptySheetBibleText)), forKey: .showEmptySheetBibleText)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(title, forKey: .title)
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        try container.encode(userUID, forKey: .userUID)

       try container.encode(createdAt.intValue, forKey: .createdAt)
        if let updatedAt = updatedAt {
            try container.encode(updatedAt.intValue, forKey: .updatedAt)
        } else {
            try container.encode(createdAt.intValue, forKey: .updatedAt)
        }
        if let deleteDate = deleteDate {
            try container.encode(deleteDate.intValue, forKey: .deleteDate)
        }
        if let rootDeleteDate = rootDeleteDate {
            try container.encode(rootDeleteDate.intValue, forKey: .rootDeleteDate)
        }
    }
    
    init?(managedObject: NSManagedObject) {
        guard let entity = managedObject as? Cluster else { return nil }
        id = entity.id
        userUID = entity.userUID
        title = entity.title
        createdAt = entity.createdAt.date
        updatedAt = entity.updatedAt?.date
        deleteDate = entity.deleteDate?.date
        rootDeleteDate = entity.rootDeleteDate?.date
                
        root = entity.root
        isLoop = entity.isLoop
        position = Int16(entity.position)
        time = entity.time
        themeId = entity.themeId
        lastShownAt = entity.lastShownAt as Date?
        instrumentIds = entity.instrumentIds ?? ""
        church = entity.church
        startTime = entity.startTime
        hasSheetPastors = entity.hasSheetPastors
        
        sheetIds = entity.sheetIds.split(separator: ",").compactMap({ String($0) })
        tagIds = entity.tagIds.split(separator: ",").compactMap({ String($0) })
        instrumentIds = entity.instrumentIds ?? ""
        church = entity.church
        startTime = entity.startTime
        showEmptySheetBibleText = entity.showEmptySheetBibleText
    }

    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeysCluster.self)
        root = try container.decodeIfPresent(String.self, forKey: .root)
        isLoop = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isLoop) ?? 0) as NSNumber)
        position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
        time = try container.decodeIfPresent(Double.self, forKey: .time) ?? 0
        themeId = try container.decode(String.self, forKey: .themeId)
        if let lastShownAtInt = try container.decodeIfPresent(Int.self, forKey: .lastShownAt) {
            lastShownAt = Date(timeIntervalSince1970: TimeInterval(lastShownAtInt / 1000))
        }
        church = try container.decodeIfPresent(String.self, forKey: .church)
        let startTimeString = try container.decodeIfPresent(String.self, forKey: .startTime)
        startTime = Double(startTimeString ?? "0") ?? 0
        let tempTagIds = try (container.decodeIfPresent(String.self, forKey: .tagids) ?? "")
        tagIds = tempTagIds.split(separator: ",").compactMap({ String($0) })
        hasSheets = try container.decode([AnySheet].self, forKey: .hasSheets).map{ $0.base }
        
        sheetIds = hasSheets.compactMap({ $0.id })
        
        hasInstruments = try container.decodeIfPresent([InstrumentCodable].self, forKey: .hasInstruments) ?? []
        instrumentIds = hasInstruments.compactMap({ $0.id }).joined(separator: ",")
        hasSheetPastors = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .hasSheetPastors) ?? 0) as NSNumber)
        showEmptySheetBibleText = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .showEmptySheetBibleText) ?? 1) as NSNumber)
        
        id  = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        userUID = try container.decode(String.self, forKey: .userUID)
        
        let createdAtInt = try container.decode(Int64.self, forKey: .createdAt)
        let updatedAtInt = try container.decodeIfPresent(Int64.self, forKey: .updatedAt)
        let deletedAtInt = try container.decodeIfPresent(Int64.self, forKey: .deleteDate)
        createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtInt) / 1000)
        
        if let updatedAtInt = updatedAtInt {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(updatedAtInt) / 1000)
        }
        if let deletedAtInt = deletedAtInt {
            deleteDate = Date(timeIntervalSince1970: TimeInterval(deletedAtInt) / 1000) 
        }
        if let rootdeleteDateInt = try container.decodeIfPresent(Int.self, forKey: .rootDeleteDate) {
            rootDeleteDate = Date(timeIntervalSince1970: TimeInterval(rootdeleteDateInt))
        }
    }
    
    public static func == (lhs: ClusterCodable, rhs: ClusterCodable) -> Bool {
        return lhs.id == rhs.id
    }
}


extension ClusterCodable: FileTransferable {
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
        var updatedSheets: [SheetMetaType] = []
        hasSheets.forEach { sheet in
            var sheet = sheet
            var theme = sheet.theme
            theme?.clearDataForDeletedObjects(forceDelete: forceDelete)
            sheet.clearDataForDeletedObjects(forceDelete: forceDelete)
            if let theme {
                sheet = sheet.set(theme: theme)
            }
            updatedSheets.append(sheet)
        }
        self.hasSheets = updatedSheets
    }
    
    func getDeleteObjects(forceDelete: Bool) -> [DeleteObject] {
        hasSheets.getDeleteObjects(forceDelete: forceDelete) + hasInstruments.flatMap { $0.getDeleteObjects(forceDelete: forceDelete) }
    }
    
    var uploadObjects: [TransferObject] {
        let instrumentsUploadObjects = hasInstruments
            .filter { $0.resourcePathAWS == nil }
            .compactMap { $0.resourcePath }
            .compactMap { UploadObject(fileName: $0) }
        return hasSheets.uploadObjects + instrumentsUploadObjects
    }
    
    var downloadObjects: [TransferObject] {
        hasSheets.downloadObjects
    }
    
    var transferObjects: [TransferObject] {
        uploadObjects + downloadObjects
    }
    
    mutating func setTransferObjects(_ transferObjects: [TransferObject]) throws {
        let sheets = try hasSheets.setObjects(transferObjects: transferObjects)
        self.hasSheets = sheets
        
        var updatedInstruments: [InstrumentCodable] = []
        try hasInstruments.forEach { instrument in
            var changedInstrument = instrument
            try changedInstrument.setTransferObjects(transferObjects)
            updatedInstruments.append(changedInstrument)
        }
        self.hasInstruments = updatedInstruments
    }
    
    func setDeleteDate() -> FileTransferable {
        var modifiedDocument = self
        if uploadSecret != nil {
            modifiedDocument.rootDeleteDate = Date()
        } else {
            modifiedDocument.deleteDate = Date()
        }
        return modifiedDocument
    }
    
    func setUpdatedAt() -> FileTransferable {
        var modifiedDocument = self
        modifiedDocument.updatedAt = Date()
        return modifiedDocument
    }
    
    func setUserUID() throws -> FileTransferable {
        var modifiedDocument = self
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        modifiedDocument.userUID = userUID
        return modifiedDocument
    }

    
}

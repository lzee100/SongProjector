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

public struct ClusterCodable: EntityCodableType {
    
    init?(managedObject: NSManagedObject, context: NSManagedObjectContext) {
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
        
        func getSheets() -> [SheetMetaType] {
            let predicates: [NSPredicate] = sheetIds.map { .get(id: $0) }
            let data: [Sheet] = DataFetcher().getEntities(moc: context, predicates: predicates, predicateCompoundType: .or)
            return data.getSheets(context: context)
        }
        
        sheetIds = entity.sheetIds.split(separator: ",").compactMap({ String($0) })
        hasSheets = getSheets()
        tagIds = entity.tagIds.split(separator: ",").compactMap({ String($0) })
        hasInstruments = entity.hasInstruments(moc: context).compactMap { InstrumentCodable(managedObject: $0, context: context) }
        let predicates: [NSPredicate] = tagIds.map { .get(id: $0) }
        let tags: [Tag] = DataFetcher().getEntities(moc: context, predicates: predicates, predicateCompoundType: .or)
        hasTags = tags.compactMap { TagCodable(managedObject: $0, context: context) }
        church = entity.church
        startTime = entity.startTime
        hasSheetPastors = entity.hasSheetPastors
    }
    
    func getManagedObjectFrom(_ context: NSManagedObjectContext) -> NSManagedObject {
        
        if let entity: Cluster = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity, context: context)
            return entity
        } else {
            let entity: Cluster = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity, context: context)
            return entity
        }
    }
    
    private func setPropertiesTo(_ entity: Cluster, context: NSManagedObjectContext) {
        entity.id = id
        entity.userUID = userUID
        entity.title = title
        entity.createdAt = createdAt.nsDate
        entity.updatedAt = updatedAt?.nsDate
        entity.deleteDate = deleteDate?.nsDate
        entity.rootDeleteDate = rootDeleteDate?.nsDate
        
        entity.sheetIds = sheetIds.joined(separator: ",")
        entity.instrumentIds = instrumentIds
        entity.root = root
        entity.isLoop = isLoop
        entity.position = Int16(position)
        entity.time = time
        entity.themeId = themeId
        entity.church = church
        entity.startTime = startTime
        entity.lastShownAt = lastShownAt as NSDate?
        entity.hasSheetPastors = hasSheetPastors
        entity.instrumentIds = instrumentIds
        entity.sheetIds = sheetIds.joined(separator: ",")
        entity.tagIds = tagIds.joined(separator: ",")
        
        hasSheets.forEach { _ = $0.getManagedObjectFrom(context) }
        hasInstruments.forEach { _ = $0.getManagedObjectFrom(context) }
    }
    
    var id: String = "CHURCHBEAM" + UUID().uuidString
    var userUID: String = ""
    var title: String? = nil
    var createdAt: Date = Date().localDate()
    var updatedAt: Date? = nil
    var deleteDate: Date? = nil
    var isTemp: Bool = false
    var rootDeleteDate: Date? = nil
    
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
        
        try container.encodeIfPresent(title, forKey: .title)
        guard let userUID = Auth.auth().currentUser?.uid else {
            throw RequestError.unAuthorizedNoUser(requester: String(describing: self))
        }
        try container.encode(userUID, forKey: .userUID)

       try container.encode((createdAt ).intValue, forKey: .createdAt)
        if let updatedAt = updatedAt {
            try container.encode((updatedAt ).intValue, forKey: .updatedAt)
        } else {
            try container.encode((createdAt ).intValue, forKey: .updatedAt)
        }
        if let deleteDate = deleteDate {
            try container.encode((deleteDate ).intValue, forKey: .deleteDate)
        }
        if let rootDeleteDate = rootDeleteDate {
            try container.encode(rootDeleteDate.intValue, forKey: .rootDeleteDate)
        }
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
}


extension ClusterCodable: FileTransferable {
    
    mutating func clearDataForDeletedObjects(forceDelete: Bool) {
    }
    
    func getDeleteObjects(forceDelete: Bool) -> [String] {
        []
    }
    
    var uploadObjects: [TransferObject] {
        []
    }
    
    var downloadObjects: [TransferObject] {
        let sheetThemesPaths = hasSheets.getThemes(context: newMOCBackground).filter({ $0.hasNewRemoteImage }).compactMap({ $0.imagePathAWS })
        let pastorstPaths = hasSheets.compactMap({ $0 as? VSheetPastors }).filter({ $0.hasNewRemoteImage }).compactMap({ $0.imagePathAWS })
        let titleImagePaths = hasSheets.compactMap({ $0 as? VSheetTitleImage }).filter({ $0.hasNewRemoteImage }).compactMap({ $0.imagePathAWS })
        
        var allPaths = sheetThemesPaths
        allPaths += pastorstPaths
        allPaths += titleImagePaths
        
        allPaths = allPaths.unique
        
        return allPaths.compactMap({ URL(string: $0) }).compactMap({ DownloadObject(remoteURL: $0) })
    }
    
    var transferObjects: [TransferObject] {
        uploadObjects + downloadObjects
    }
    
    mutating func setTransferObjects(_ transferObjects: [TransferObject]) throws {
//        let uploadObjects = transferObjects.compactMap { $0 as? UploadObject }
//        for uploadObject in uploadObjects {
//            if newSelectedThemeImageTempDirPath == uploadObject.fileName {
//                imagePathAWS = uploadObject.fileName
//            }
//            if newSelectedSheetImageTempDirPath == uploadObject.fileName {
//                imagePathAWS = uploadObject.fileName
//            }
//        }
//        for download in downloadObjects.compactMap({ $0 as? DownloadObject }) {
//            if imagePathAWS == download.remoteURL.absoluteString {
//                try setBackgroundImage(image: download.image, imageName: download.filename)
//            }
//        }
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

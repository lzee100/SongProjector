//
//  VCluster.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/12/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import FirebaseFirestore
import FirebaseAuth

struct VCluster: VEntityType, Codable {
    
    
//    class func list(sortOn attributeName: String? = nil, ascending: Bool? = nil, skipDeleted: Bool) -> [VCluster] {
//        guard Thread.isMainThread else {
//            fatalError()
//        }
//        if let attributeName = attributeName, let ascending = ascending {
//            CoreCluster.setSortDescriptor(attributeName: attributeName, ascending: ascending)
//        }
//        CoreCluster.managedObjectContext = mocBackground
//        return CoreCluster.getEntities(skipDeleted: skipDeleted).map({ VCluster(cluster: $0) })
//    }
//
//    class func single(with id: String?) -> VCluster? {
//        guard Thread.isMainThread else {
//            fatalError()
//        }
//        if let id = id, let cluster = CoreCluster.getEntitieWith(id: id) {
//            return VCluster(cluster: cluster)
//        }
//        return nil
//    }
    let id: String
    var userUID: String
    var title: String?
    var createdAt: NSDate
    var updatedAt: NSDate?
    var deleteDate: NSDate?
    var rootDeleteDate: Date?
    
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

    var deletedSheetsImageURLs: [String] = []
    
    var hasInstruments: [VInstrument] = []
    
    private(set) var hasSheets: [VSheet] = []
    
    
    var tagIds: [String] = []
    
    func hasTheme(moc: NSManagedObjectContext) -> VTheme? {
        let theme: Theme? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: themeId)])
        return [theme].compactMap({ $0?.vTheme }).first
    }
    
    func hasTags(moc: NSManagedObjectContext) -> [Tag] {
        let tags: [Tag] = tagIds.compactMap({ DataFetcher().getEntity(moc: moc, predicates: [.get(id: $0)]) })
        return tags
    }
    
    public var isTypeSong: Bool {
        return !hasSheets.contains(where: { $0.hasTheme?.isHidden == true  }) && hasSheets.count > 0 && !hasSheets.compactMap({ $0 as? VSheetTitleContent }).contains(where: { $0.isBibleVers })
    }
    
    public var hasBibleVerses: Bool {
        return hasSheets.compactMap({ $0 as? VSheetTitleContent }).contains(where: { $0.isBibleVers })
    }
    
    public var hasPianoSolo: Bool {
        return hasInstruments.contains(where: { $0.type == .pianoSolo && $0.resourcePath != nil })
    }
    
    public var hasRemoteMusic: Bool {
        return hasInstruments.contains(where: { $0.resourcePathAWS != nil })
    }
    
    public var hasLocalMusic: Bool {
           return hasInstruments.contains(where: { $0.resourcePath != nil })
       }
    
    private var clusterSheets: [SheetMetaType] {
        return hasSheets.compactMap({ $0 as? SheetMetaType })
    }
    
    
    enum CodingKeysCluster:String,CodingKey
    {
        case id
        case userUID
        case title
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
    
    mutating func setInstruments(instruments: [VInstrument]) {
        hasInstruments = instruments
        instrumentIds = hasInstruments.compactMap({ $0.id }).joined(separator: ",")
    }
    
    mutating func setSheets(sheets: [VSheet]) {
        sheetIds = sheets.compactMap({ $0.id })
        self.hasSheets = sheets
    }
    
    init(cluster: Cluster, context: NSManagedObjectContext) {
        self.id = cluster.id
        self.userUID = cluster.userUID
        self.title = cluster.title
        self.createdAt = cluster.createdAt
        self.updatedAt = cluster.updatedAt
        self.deleteDate = cluster.deleteDate
        self.rootDeleteDate = cluster.rootDeleteDate?.date

        self.root = cluster.root
        self.isLoop = cluster.isLoop
        self.position = cluster.position
        self.time = cluster.time
        self.themeId = cluster.themeId
        self.lastShownAt = cluster.lastShownAt?.date
        self.instrumentIds = cluster.instrumentIds ?? ""
        self.sheetIds = cluster.sheetIds.split(separator: ",").map { String($0) }
        self.church = cluster.church
        self.startTime = cluster.startTime
        self.hasSheetPastors = cluster.hasSheetPastors
        
        let sheets: [Sheet] = DataFetcher().getEntities(moc: moc, predicates: self.sheetIds.map { NSPredicate(format: "id == \($0)") }, predicatesCompoundType: .or)
        self.hasSheets = sheets.vSheets.sorted(by: { $0.position < $1.position })
        let instruments: [Instrument] = DataFetcher().getEntities(moc: moc, predicates: self.instrumentIds.split(separator: ",").map { NSPredicate(format: "id == \($0)") }, predicatesCompoundType: .or)
        self.hasInstruments = instruments.map { VInstrument($0) }
    }
    
    init(id: String = "CHURCHBEAM" + UUID().uuidString, userUID: String, title: String?, createdAt: NSDate = Date().localDate() as NSDate, updatedAt: NSDate?, deleteDate: NSDate? = nil, rootDeleteDate: Date? = nil, root: String? = nil, isLoop: Bool = false, position: Int16 = 0, time: Double = 0, themeId: String = UUID().uuidString, lastShownAt: Date? = nil, instrumentIds: String = "", sheetIds: [String] = [], church: String?, startTime: Double = 0.0, hasSheetPastors: Bool = false, hasSheets: [VSheet] = [], hasInstruments: [VInstrument] = []) {
        self.id = id
        self.userUID = userUID
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deleteDate = deleteDate
        self.rootDeleteDate = rootDeleteDate
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
    }
    
    
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysCluster.self)
        
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
        
        try container.encode(root, forKey: .root)
        try container.encode(Int(truncating: NSNumber(value: isLoop)), forKey: .isLoop)
        try container.encode(position, forKey: .position)
        try container.encode(time, forKey: .time)
        try container.encode(themeId, forKey: .themeId)
        try container.encode(clusterSheets.map(AnySheet.init), forKey: .hasSheets)
        try container.encode(hasInstruments, forKey: .hasInstruments)
        if let lastShownAt = lastShownAt {
            try container.encode(lastShownAt.intValue, forKey: .lastShownAt)
        }
        try container.encode(church, forKey: .church)
        try container.encode(tagIds.joined(separator: ","), forKey: .tagids)
        try container.encode(String(startTime), forKey: .startTime)
        try container.encode(Int(truncating: NSNumber(value: hasSheetPastors)), forKey: .hasSheetPastors)
        
    }
    
    
    
    // MARK: - Decodable
    
    public init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: CodingKeysCluster.self)
        
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
        let metas = try container.decode([AnySheet].self, forKey: .hasSheets).map{ $0.base }
        
        var sheetUnsorted: [VSheet] = []
        metas.compactMap({ $0 as? VSheet }).forEach { (sheet) in
            if sheet is VSheetTitleContent {
                sheetUnsorted.append((sheet as! VSheetTitleContent))
            } else if sheet is VSheetTitleImage {
                sheetUnsorted.append((sheet as! VSheetTitleImage))
            } else if sheet is VSheetPastors {
                sheetUnsorted.append((sheet as! VSheetPastors))
            } else if sheet is VSheetSplit {
                sheetUnsorted.append((sheet as! VSheetSplit))
            } else if sheet is VSheetEmpty {
                sheetUnsorted.append((sheet as! VSheetEmpty))
            } else if sheet is VSheetActivities {
                sheetUnsorted.append((sheet as! VSheetActivities))
            }
        }
        hasSheets = sheetUnsorted.sorted(by: { $0.position < $1.position })
        sheetIds = hasSheets.compactMap({ $0.id })
        
        let instruments = try container.decodeIfPresent([VInstrument].self, forKey: .hasInstruments) ?? []
        instrumentIds = hasInstruments.compactMap({ $0.id }).joined(separator: ",")
        hasSheetPastors = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .hasSheetPastors) ?? 0) as NSNumber)
        
    }
    
    @discardableResult
    func getManagedObject(context: NSManagedObjectContext) -> Entity {
        func setPropertiesTo(cluster: Cluster, context: NSManagedObjectContext) {
                cluster.id = id
                cluster.title = title
                cluster.userUID = userUID
                cluster.createdAt = createdAt
                cluster.updatedAt = updatedAt
                cluster.deleteDate = deleteDate
                cluster.rootDeleteDate = rootDeleteDate as NSDate?

                cluster.root = root
                cluster.isLoop = isLoop
                cluster.position = Int16(position)
                cluster.time = time
                cluster.themeId = themeId
                cluster.church = church
                cluster.startTime = startTime
                cluster.lastShownAt = lastShownAt as NSDate?
                cluster.hasSheetPastors = hasSheetPastors
                let instruments = hasInstruments.compactMap({ $0.getManagedObject(context: context) })
                cluster.instrumentIds = instruments.map({ $0.id }).joined(separator: ",")
                let sheets = hasSheets.map({ $0.getManagedObject(context: context) })
                cluster.sheetIds = sheets.compactMap({ $0.id }).joined(separator: ",")
                let tags = hasTags(moc: context)
                cluster.tagIds = tags.compactMap({ $0.id }).joined(separator: ",")
        }

        if let cluster: Cluster = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(cluster: cluster, context: context)
            return cluster
        } else {
            let cluster: Cluster = DataFetcher().createEntity(moc: context)
            setPropertiesTo(cluster: cluster, context: context)
            return cluster
        }
    }

}


extension VCluster {
    
    var uploadObjecs: [UploadObject] {
        let sheetThemesPaths = hasSheets.compactMap({ $0.hasTheme }).compactMap({ $0.tempLocalImageName })
        let pastorstPaths = hasSheets.compactMap({ $0 as? VSheetPastors }).compactMap({ $0.tempLocalImageName })
        let titleImagePaths = hasSheets.compactMap({ $0 as? VSheetTitleImage }).compactMap({ $0.tempLocalImageName })
        
        var allPaths = sheetThemesPaths
        allPaths += pastorstPaths
        allPaths += titleImagePaths

        allPaths = allPaths.unique
        
        return allPaths.compactMap({ UploadObject(fileName: $0) })
    }
    
    var uploadMusicObjects: [UploadObject] {
        var allPaths: [String] = []
        if UserDefaults.standard.object(forKey: secretKey) != nil {
            let musicPaths = hasInstruments.compactMap({ $0.resourcePath })
            allPaths += musicPaths
        }
        
        allPaths = allPaths.unique
        
        return allPaths.compactMap({ UploadObject(fileName: $0) })
    }
    
    var downloadObjects: [DownloadObject] {
        let sheetThemesPaths = hasSheets.compactMap({ $0.hasTheme }).filter({ $0.hasNewRemoteImage }).compactMap({ $0.imagePathAWS })
        let pastorstPaths = hasSheets.compactMap({ $0 as? VSheetPastors }).filter({ $0.hasNewRemoteImage }).compactMap({ $0.imagePathAWS })
        let titleImagePaths = hasSheets.compactMap({ $0 as? VSheetTitleImage }).filter({ $0.hasNewRemoteImage }).compactMap({ $0.imagePathAWS })
        
        var allPaths = sheetThemesPaths
        allPaths += pastorstPaths
        allPaths += titleImagePaths
        
        allPaths = allPaths.unique
        
        return allPaths.compactMap({ URL(string: $0) }).compactMap({ DownloadObject(remoteURL: $0) })
    }
    
    var musicDownloadObjects: [DownloadObject] {
        let musicPaths = hasInstruments.compactMap({ $0.resourcePathAWS })
        return musicPaths.compactMap({ URL(string: $0) }).compactMap({ DownloadObject(remoteURL: $0) })
    }
    
    mutating func setUploadValues(_ uploadObjects: [UploadObject]) throws {
        var updatedSheets: [VSheet] = hasSheets
        var updatedInstruments: [VInstrument] = hasInstruments
        
        for upload in uploadObjects.compactMap({ $0 as UploadObject }) {
            var newUpdatedSheets: [VSheet] = []
            try updatedSheets.forEach { sheet in
                var updatedSheet = sheet
                var updatedTheme = sheet.hasTheme
                if updatedTheme?.tempLocalImageName == upload.fileName {
                    updatedTheme?.imagePathAWS = upload.remoteURL?.absoluteString
                    if let image = updatedTheme?.tempSelectedImage {
                        try updatedTheme?.setBackgroundImage(image: image, imageName: updatedTheme?.imagePath)
                    }
                }
                if var newpastorSheet = updatedSheet as? VSheetPastors {
                    if newpastorSheet.tempLocalImageName == upload.fileName {
                        newpastorSheet.imagePathAWS = upload.remoteURL?.absoluteString
                    }
                    if let image = newpastorSheet.tempSelectedImage {
                        try newpastorSheet.set(image: image, imageName: newpastorSheet.imagePath)
                    }
                    updatedSheet = newpastorSheet
                }
                
                if var updatedTitleImageSheet = updatedSheet as? VSheetTitleImage {
                    if updatedTitleImageSheet.tempLocalImageName == upload.fileName {
                        updatedTitleImageSheet.imagePathAWS = upload.remoteURL?.absoluteString
                    }
                    if let image = updatedTitleImageSheet.tempSelectedImage {
                        try updatedTitleImageSheet.set(image: image, imageName: updatedTitleImageSheet.imagePath)
                    }
                    updatedSheet = updatedTitleImageSheet
                }
                newUpdatedSheets.append(updatedSheet)
            }
            updatedSheets = newUpdatedSheets
            
            var newUpdatedInstruments: [VInstrument] = []
            updatedInstruments.forEach { instrument in
                var updatedInstrument = instrument
                if updatedInstrument.resourcePath == upload.fileName {
                    updatedInstrument.resourcePathAWS = upload.remoteURL?.absoluteString
                }
                newUpdatedInstruments.append(updatedInstrument)
            }
            updatedInstruments = newUpdatedInstruments
        }
        hasSheets = updatedSheets
        hasInstruments = updatedInstruments
    }
    
    mutating func setDownloadValues(_ downloadObjects: [DownloadObject]) throws {
        var updatedSheets = hasSheets
        var updatedInstruments: [VInstrument] = []
        
        for download in downloadObjects.compactMap({ $0 as DownloadObject }) {
            var newUpdatedSheets: [VSheet] = []
            try updatedSheets.forEach { sheet in
                var updatedSheet = sheet
                if updatedSheet.hasTheme?.imagePathAWS == download.remoteURL.absoluteString {
                    do {
                        try updatedSheet.hasTheme?.setBackgroundImage(image: download.image, imageName: download.filename)
                    }
                }
                
                if var updatedSheetPastors = updatedSheet as? VSheetPastors {
                    if updatedSheetPastors.imagePathAWS == download.remoteURL.absoluteString {
                        do {
                            try updatedSheetPastors.set(image: download.image, imageName: download.filename)
                        }
                    }
                    updatedSheet = updatedSheetPastors
                }
                
                if var updatedSheetTitleImage = updatedSheet as? VSheetTitleImage {
                    if updatedSheetTitleImage.imagePathAWS == download.remoteURL.absoluteString {
                        do {
                            try updatedSheetTitleImage.set(image: download.image, imageName: download.filename)
                        }
                    }
                    updatedSheet = updatedSheetTitleImage
                }
                newUpdatedSheets.append(updatedSheet)
            }
            updatedSheets = newUpdatedSheets
            
            var newUpdatedInstruments: [VInstrument] = []
            updatedInstruments.forEach { instrument in
                var updatedInstrument = instrument
                if updatedInstrument.resourcePathAWS == download.remoteURL.absoluteString {
                    updatedInstrument.resourcePath = download.localURL?.absoluteString
                }
                newUpdatedInstruments.append(updatedInstrument)
            }
            updatedInstruments = newUpdatedInstruments
        }
        hasSheets = updatedSheets
        hasInstruments = updatedInstruments
    }
    
}

extension VCluster {
    
    mutating func setLastShownAt() {
        let lsa = Date()
        lastShownAt = lsa
        getManagedObject(context: moc)
        do {
            try moc.save()
        } catch {}
        
        Firestore.firestore().collection("clusters").document(self.id).updateData(["lastShownAt" : lsa.intValue])
        
    }
    
}

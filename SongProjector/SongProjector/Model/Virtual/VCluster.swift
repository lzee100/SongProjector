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

public class VCluster: VEntity {
    
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

    var deletedSheetsImageURLs: [String] = []
    
    var hasInstruments: [VInstrument] = [] {
        didSet {
            instrumentIds = hasInstruments.compactMap({ $0.id }).joined(separator: ",")
        }
    }
    
    var hasSheets: [VSheet] = [] {
        didSet {
            sheetIds = hasSheets.compactMap({ $0.id })
        }
    }
    
    var tagIds: [String] = []
    
    func hasTheme(moc: NSManagedObjectContext) -> VTheme? {
        let theme: Theme? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: themeId)])
        return [theme].compactMap({ $0 }).map({ VTheme(entity: $0, context: moc) }).first
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
        case rootDeleteDate
        case startTime
    }
    
    
    // MARK: - Init
    
    public override func initialization(decoder: Decoder) throws {
        
    }
    
    
    
    // MARK: - Encodable
    
    override public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeysCluster.self)
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

        try super.encode(to: encoder)
        
    }
    
    
    
    // MARK: - Decodable
    
    required public convenience init(from decoder: Decoder) throws {
        
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeysCluster.self)
        root = try container.decodeIfPresent(String.self, forKey: .root)
        isLoop = try Bool(truncating: (container.decodeIfPresent(Int16.self, forKey: .isLoop) ?? 0) as NSNumber)
        position = try container.decodeIfPresent(Int16.self, forKey: .position) ?? 0
        time = try container.decodeIfPresent(Double.self, forKey: .time) ?? 0
        themeId = try container.decode(String.self, forKey: .themeId)
        if let lastShownAtInt = try container.decodeIfPresent(Int.self, forKey: .lastShownAt) {
            lastShownAt = Date(timeIntervalSince1970: TimeInterval(lastShownAtInt))
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
        
        hasInstruments = try container.decodeIfPresent([VInstrument].self, forKey: .hasInstruments) ?? []
        instrumentIds = hasInstruments.compactMap({ $0.id }).joined(separator: ",")
        
        try super.initialization(decoder: decoder)
        
    }
    
    public override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as? Cluster
        copy?.isLoop = isLoop
        copy?.position = position
        copy?.time = time
        copy?.themeId = themeId
        copy?.root = root
        copy?.instrumentIds = instrumentIds
        copy?.tagIds = tagIds.joined(separator: ",")
        copy?.lastShownAt = lastShownAt as NSDate?
        copy?.church = church

        return copy!
    }
    
    override func getPropertiesFrom(entity: Entity, context: NSManagedObjectContext) {
        super.getPropertiesFrom(entity: entity, context: context)
        if let cluster = entity as? Cluster {
            
            root = cluster.root
            isLoop = cluster.isLoop
            position = Int16(cluster.position)
            time = cluster.time
            themeId = cluster.themeId
            lastShownAt = cluster.lastShownAt as Date?
            instrumentIds = cluster.instrumentIds ?? ""
            church = cluster.church
            startTime = cluster.startTime

            func getSheets(sheets: [Sheet]) -> [VSheet] {
                return sheets.map({
                    if let sheet = $0 as? SheetTitleContentEntity {
                        return VSheetTitleContent(entity: sheet, context: context) as VSheet
                    } else if let sheet = $0 as? SheetTitleImageEntity {
                        return VSheetTitleImage(entity: sheet, context: context) as VSheet
                    } else if let sheet = $0 as? SheetSplitEntity {
                        return VSheetSplit(entity: sheet, context: context) as VSheet
                    } else if let sheet = $0 as? SheetPastorsEntity {
                        return VSheetPastors(entity: sheet, context: context) as VSheet
                    } else if let sheet = $0 as? SheetEmptyEntity {
                        return VSheetEmpty(entity: sheet, context: context) as VSheet
                    } else if let sheet = $0 as? SheetActivitiesEntity {
                        return VSheetActivities(entity: sheet, context: context) as VSheet
                    } else {
                        return VSheet(entity: $0, context: context)
                    }
                })
            }
            
            sheetIds = cluster.sheetIds.split(separator: ",").compactMap({ String($0) })
            hasSheets = getSheets(sheets: cluster.hasSheets(moc: context)).sorted(by: { $0.position < $1.position })
            hasInstruments = cluster.hasInstruments(moc: context).compactMap({ VInstrument(instrument: $0, context: context) })
            tagIds = cluster.splitTagIds
            
        }
    }
    
    override func setPropertiesTo(entity: Entity, context: NSManagedObjectContext) {
        super.setPropertiesTo(entity: entity, context: context)
        if let cluster = entity as? Cluster {
            cluster.root = root
            cluster.isLoop = isLoop
            cluster.position = Int16(position)
            cluster.time = time
            cluster.themeId = themeId
            cluster.church = church
            cluster.startTime = startTime
            cluster.lastShownAt = lastShownAt as NSDate?
            let instruments = hasInstruments.compactMap({ $0.getManagedObject(context: context) })
            cluster.instrumentIds = instruments.map({ $0.id }).joined(separator: ",")
            let sheets = hasSheets.map({ $0.getManagedObject(context: context) })
            cluster.sheetIds = sheets.compactMap({ $0.id }).joined(separator: ",")
            let tags = hasTags(moc: context)
            cluster.tagIds = tags.compactMap({ $0.id }).joined(separator: ",")
        }
    }
    
    convenience init(cluster: Cluster, context: NSManagedObjectContext) {
        self.init()
        getPropertiesFrom(entity: cluster, context: context)
    }
    
    @discardableResult
    override func getManagedObject(context: NSManagedObjectContext) -> Entity {
        if let entity: Cluster = DataFetcher().getEntity(moc: context, predicates: [.get(id: id)]) {
            setPropertiesTo(entity: entity, context: context)
            return entity
        } else {
            let entity: Cluster = DataFetcher().createEntity(moc: context)
            setPropertiesTo(entity: entity, context: context)
            return entity
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
    
    func setUploadValues(_ uploadObjects: [UploadObject]) throws {
        let sheetThemes = hasSheets.compactMap({ $0.hasTheme })
        let pastorsSheets = hasSheets.compactMap({ $0 as? VSheetPastors })
        let titleImageSheets = hasSheets.compactMap({ $0 as? VSheetTitleImage })
        
        for upload in uploadObjects.compactMap({ $0 as UploadObject }) {
            try sheetThemes.forEach { theme in
                if theme.tempLocalImageName == upload.fileName {
                    theme.imagePathAWS = upload.remoteURL?.absoluteString
                    if let image = theme.tempSelectedImage {
                        try theme.setBackgroundImage(image: image, imageName: theme.imagePath)
                    }
                }
            }
            try pastorsSheets.forEach { pastorSheet in
                if pastorSheet.tempLocalImageName == upload.fileName {
                    pastorSheet.imagePathAWS = upload.remoteURL?.absoluteString
                }
                if let image = pastorSheet.tempSelectedImage {
                    try pastorSheet.set(image: image, imageName: pastorSheet.imagePath)
                }
            }
            try titleImageSheets.forEach { titleImageSheet in
                if titleImageSheet.tempLocalImageName == upload.fileName {
                    titleImageSheet.imagePathAWS = upload.remoteURL?.absoluteString
                }
                if let image = titleImageSheet.tempSelectedImage {
                    try titleImageSheet.set(image: image, imageName: titleImageSheet.imagePath)
                }
            }
            hasInstruments.forEach { instrument in
                if instrument.resourcePath == upload.fileName {
                    instrument.resourcePathAWS = upload.remoteURL?.absoluteString
                }
            }
        }
    }
    
    func setDownloadValues(_ downloadObjects: [DownloadObject]) {
        let sheetThemes = hasSheets.compactMap({ $0.hasTheme })
        let pastorsSheets = hasSheets.compactMap({ $0 as? VSheetPastors })
        let titleImageSheets = hasSheets.compactMap({ $0 as? VSheetTitleImage })
        
        for download in downloadObjects.compactMap({ $0 as DownloadObject }) {
            sheetThemes.forEach { theme in
                if theme.imagePathAWS == download.remoteURL.absoluteString {
                    do {
                        try theme.setBackgroundImage(image: download.image, imageName: download.filename)
                    } catch {
                        print(error)
                    }
                }
            }
            pastorsSheets.forEach { pastorSheet in
                if pastorSheet.imagePathAWS == download.remoteURL.absoluteString {
                    do {
                        try pastorSheet.set(image: download.image, imageName: download.filename)
                    } catch {
                        print(error)
                    }
                }
            }
            titleImageSheets.forEach { titleImageSheet in
                if titleImageSheet.imagePathAWS == download.remoteURL.absoluteString {
                    do {
                        try titleImageSheet.set(image: download.image, imageName: download.filename)
                    } catch {
                        print(error)
                    }
                }
            }
            hasInstruments.forEach { instrument in
                if instrument.resourcePathAWS == download.remoteURL.absoluteString {
                    instrument.resourcePath = download.localURL?.absoluteString
                }
            }
        }
    }
    
}

extension VCluster {
    
    
    func setLastShownAt() {
        lastShownAt = Date()
        getManagedObject(context: moc)
        do {
            try moc.save()
        } catch {}
        ClusterSubmitter.dontUploadFiles = true
        ClusterSubmitter.submit([self], requestMethod: .put)
    }
}

//
//  UniversalClusterFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

let fetchPastors = true

// base guitar
// https://firebasestorage.googleapis.com/v0/b/churchbeam-7a169.appspot.com/o/development%2Faudio%2FDF9349F6-A247-44A1-BBB4-3AF0831A8FDD.m4a?alt=media&token=b7b8b548-c9d5-46b4-bc89-5fe88daf0849

// drums:

// https://firebasestorage.googleapis.com/v0/b/churchbeam-7a169.appspot.com/o/development%2Faudio%2FA5087DC2-E58B-4B20-9B5A-522DB326CBA7.m4a?alt=media&token=0f989f3d-a748-49ca-ad32-2a2931b46ed9

// guitar:

// https://firebasestorage.googleapis.com/v0/b/churchbeam-7a169.appspot.com/o/development%2Faudio%2FAF659180-2537-4C73-A8D6-4401450054A6.m4a?alt=media&token=57a4de71-66d0-44c7-97cc-f5609445e542

// piano

// https://firebasestorage.googleapis.com/v0/b/churchbeam-7a169.appspot.com/o/development%2Faudio%2F57E34D76-A3AA-4CE9-8B7D-4232B8CC95E7.m4a?alt=media&token=7382235b-0cf6-4e15-a030-e857fc7d71e1


// activiteiten slider
// sheet 0 theme imagepathaws
// https://firebasestorage.googleapis.com/v0/b/churchbeamtest.appspot.com/o/images%2F20200718133400186F0741D6-D8DA-4EBA-97F5-C39FA2813CC1.jpg?alt=media&token=65cbad34-c368-40c7-a1ea-ff53fcab1569

// sheet 1 theme imagepathaws
// https://firebasestorage.googleapis.com/v0/b/churchbeamtest.appspot.com/o/images%2F2020071813340035B3CE03A8-598F-4F4C-814F-83D74F680BDE.jpg?alt=media&token=80149fce-a056-4125-b712-829361c1892a

// sheet 2 theme imagepathaws
// https://firebasestorage.googleapis.com/v0/b/churchbeamtest.appspot.com/o/images%2F202007181335003270D5EB3D-FDC1-4F91-87E7-AA2C6EF0CCEA.jpg?alt=media&token=0dd67e9b-63fd-4c62-ae11-33802dba342b

// tim and kelly
// sheet imagepathaws
// https://firebasestorage.googleapis.com/v0/b/churchbeamtest.appspot.com/o/images%2F2020071813310026602A0D35-D510-4133-ABFC-1C29429DCB04.jpg?alt=media&token=75e235cc-0c07-446a-a92e-091da671a422

// theme imagepathaws
// https://firebasestorage.googleapis.com/v0/b/churchbeamtest.appspot.com/o/images%2F202007151304005918A665B3-6937-480A-BD1E-6C2E48E3BDC7.jpg?alt=media&token=b1041e53-627b-4cf1-8e8d-7cd2eed4e590


let UniversalClusterFetcher = UiversalClusterFetcher()


class UiversalClusterFetcher: Requester<VCluster> {
    
    override var id: String {
        return "UniversalClusterFetcher"
    }
    override var path: String {
        return "universalclusters"
    }
    
    override var fetchUniversal: Bool {
        return true
    }
    
    override var dependencies: [RequesterBase] {
        return [ClusterFetcher, UniversalUpdatedAtFetcher]
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: .hasSongSubscription, object: nil, queue: .main) { _ in
            self.fetch()
        }
    }
    
    override func getLastUpdatedAt(moc: NSManagedObjectContext) -> Date? {
        let universalUpdatedAt: UniversalUpdatedAtEntity? = DataFetcher().getLastUpdated(moc: moc)
        if universalClusters.count > 0 {
            return universalClusters.first?.updatedAt as Date?
        } else if uploadSecret != nil && universalUpdatedAt == nil {
            return nil
        } else {
            return universalUpdatedAt?.universalUpdatedAt as Date?
        }
    }
    
    private var universalClusters: [VCluster] = []
    
    private func getTheme(moc: NSManagedObjectContext) -> VTheme? {
        var predicates: [NSPredicate] = []
        predicates.append("isDeletable", equals: "NO")
        let theme: Theme? = DataFetcher().getEntity(moc: moc, predicates: predicates)
        return [theme].compactMap({ $0 }).map({ VTheme(theme: $0, context: moc) }).first
    }
    
    private func getTag(moc: NSManagedObjectContext) -> VTag? {
        var predicates: [NSPredicate] = []
        predicates.append("isDeletable", equals: "NO")
        let moc = newMOCBackground
        let tag: Tag? = DataFetcher().getEntity(moc: moc, predicates: predicates)
        return [tag].compactMap({ $0 }).map({ VTag(tag: $0, context: moc) }).first
    }
    
    private func getChurch(moc: NSManagedObjectContext) -> VChurch? {
        let context = newMOCBackground
        let church: Church? = DataFetcher().getEntity(moc: context, predicates: [.skipDeleted])
        return [church].compactMap({ $0 }).map({ VChurch(church: $0, context: context) }).first
    }
    
    override func addFetchingParamsFor(userId: String, context: NSManagedObjectContext, collection: inout Query) {
        let dateInt: Int64 = self.getLastUpdatedAt(moc: context)?.intValue ?? 1
        var newCollection = Firestore.firestore().collection(self.path).order(by: self.lastUpdatedAtKey, descending: false).whereField(self.lastUpdatedAtKey, isGreaterThan: dateInt).limit(to: self.fetchCount)
        let church: Church? = DataFetcher().getEntity(moc: moc)
        if let churchId = church?.id {
            newCollection = newCollection.whereField("church", isEqualTo: churchId)
        }
        if !fetchPastors {
            newCollection = newCollection.whereField("hasSheetPastors", isEqualTo: 0)
        }
        collection = newCollection
    }
    
    override func additionalProcessing(_ context: NSManagedObjectContext, _ entities: [VCluster], completion: @escaping ((Requester<VCluster>.AdditionalProcessResult) -> Void)) {
        
        // fetch all universal clusters, if > 0, save locally and get updatedAt else add to array
        if entities.count == 0 {
            universalClusters = []
        } else {
            universalClusters += entities
            universalClusters.sort(by: { ($0.updatedAt ?? $0.createdAt) as Date > ($1.updatedAt ?? $1.createdAt) as Date })
        }
        guard let themeId = self.getTheme(moc: context)?.id else {
            completion(.failed(error: .hasNoThemeForUniversalCluster(requester: self.id)))
            return
        }
        
        guard let churchName = self.getChurch(moc: context)?.title else {
            completion(.failed(error: .hasNoChurchForUniversalCluster(requester: self.id)))
            return
        }
        
        if let date = entities.sorted(by: { (($0.updatedAt ?? NSDate()) as Date) > $1.updatedAt as Date? ?? Date() }).first?.updatedAt as Date? {
            
            var vUniversalUpdatedAt: VUniversalUpdatedAt {
                let ua: UniversalUpdatedAtEntity? = DataFetcher().getEntity(moc: context)
                if let universalAt = ua {
                    let vUa = VUniversalUpdatedAt(entity: universalAt, context: context)
                    vUa.universalUpdatedAt = date
                    return vUa
                } else {
                    let universalAt = VUniversalUpdatedAt()
                    universalAt.universalUpdatedAt = date
                    return universalAt
                }
            }
            
            UniversalClusterSubmitterOperations.addUUASubmit(uua: [vUniversalUpdatedAt])
//            UniversalClusterUpdatedAtSubmitter.submit([vUniversalUpdatedAt], requestMethod: .post)
        }
        
        if uploadSecret == nil {
            // check if universal was deleted
            var newEntities: [VCluster] = []
            let persitentClusters: [Cluster] = DataFetcher().getEntities(moc: context, predicates: [])
            let existing = persitentClusters.map({ VCluster(cluster: $0, context: context) })
            
            entities.forEach { (entity) in
                if let existing = existing.first(where: { $0.root == entity.id }) {
                    if existing.deleteDate == nil {
                        existing.deleteDate = entity.deleteDate
                    }
                    existing.rootDeleteDate = entity.rootDeleteDate
                    existing.startTime = entity.startTime
                    entity.id = existing.id // keep this user's id
                    newEntities.append(existing)
                } else {
                    newEntities.append(entity)
                    entity.root = entity.id
                    entity.church = churchName
                    entity.id = UUID().uuidString // new id for this user, not universal user
                    entity.tagIds = [self.getTag(moc: context)?.id].compactMap({ $0 })
                    entity.themeId = themeId
                }
            }
            
            if newEntities.count > 0 {
//                ClusterSubmitter.dontUploadFiles = true
//                CsterSubmitter().submit(newEntities, requestMethod: .post)
                UniversalClusterSubmitterOperations.addClustersToSubmit(clusters: newEntities)
            }
        }
                
        // don't save these entities, but create new ones on google with this data for with own uid
        completion(.succes(result: entities))
        
    }
    func initialFetch() {
        UniversalClusterOperations.fetch()
    }

}

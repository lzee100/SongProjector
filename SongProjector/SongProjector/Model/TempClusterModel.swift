//
//  TempClusterModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/09/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation

class TempClustersModel {
    
    private struct Constants {
        static let songServiceId = "songServiceId"
        static let clusterOrComment = "clusterOrComment"
        static let comment = "comment"
        static let saveDate = "saveDate"
    }
    
    var clusters: [ClusterOrComment] = []
    var songServiceSettings: VSongServiceSettings?
    var sectionedClusterOrComment: [[ClusterOrComment]]
    var clusterToChange: ClusterOrComment?
    var hasNoSongs: Bool {
        return (songServiceSettings != nil && sectionedClusterOrComment.count == 0) || (clusters.count == 0 && songServiceSettings == nil)
    }
    var errorIndexPath: IndexPath?
    private let defaults = UserDefaults.standard

    static func load() -> TempClustersModel? {
        
        func checkDate(date: Date) -> Bool {
            let toSunday: [Weekday] = [.thursday, .friday, .saturday, .sunday]
            let toWednesday: [Weekday] = [.monday, .tuesday, .wednesday]
            if toWednesday.contains(date.dayOfWeek) && toWednesday.contains(Date().dayOfWeek) {
                return true
            } else if toSunday.contains(date.dayOfWeek) && toSunday.contains(Date().dayOfWeek) {
                return true
            } else {
                return false
            }
        }
        
        let defaults = UserDefaults.standard
        guard let saveDate = defaults.object(forKey: Constants.saveDate) as? Date, checkDate(date: saveDate) else {
            TempClustersModel.resetSavedValues()
            return nil
        }
        if
            let songserivceId = defaults.object(forKey: Constants.songServiceId) as? String,
            let clusterOrComment = defaults.object(forKey: Constants.clusterOrComment) as? [String]
        {
            
            
            guard let s: SongServiceSettings = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted, .get(id: songserivceId)]) else {
                TempClustersModel.resetSavedValues()
                return nil
            }
            let songServiceSettings = VSongServiceSettings(songserviceSettings: s, context: moc)
            let sectionedClusterOrComment: [[ClusterOrComment]] = clusterOrComment.map({
                let clusterOrComments = $0.split(separator: ",").compactMap({ String($0) })
                return clusterOrComments.compactMap { (coc) in
                    if coc == Constants.comment {
                        return ClusterOrComment(cluster: nil)
                    } else if let cluster: Cluster = DataFetcher().getEntity(moc: moc, predicates: [.get(id: coc)]) {
                        return ClusterOrComment(cluster: VCluster(cluster: cluster, context: moc))
                    }
                    return nil
                }
            })
            return TempClustersModel(songServiceSettings: songServiceSettings, sectionedClusterIdsWithComments: sectionedClusterOrComment)
        } else if let clusterOrComments = defaults.object(forKey: Constants.clusterOrComment) as? [String] {
            return TempClustersModel(clusters:
                clusterOrComments.compactMap { (coc) in
                    if coc == Constants.comment {
                        return ClusterOrComment(cluster: nil)
                    } else if let cluster: Cluster = DataFetcher().getEntity(moc: moc, predicates: [.get(id: coc)]) {
                        return ClusterOrComment(cluster: VCluster(cluster: cluster, context: moc))
                    }
                    return nil
                }
            )
        } else {
            TempClustersModel.resetSavedValues()
            return nil
        }
    }
    
    init(clusters: [ClusterOrComment] = [], songServiceSettings: VSongServiceSettings? = nil, sectionedClusterIdsWithComments: [[ClusterOrComment]] = []) {
        self.clusters = clusters
        self.songServiceSettings = songServiceSettings
        self.sectionedClusterOrComment = sectionedClusterIdsWithComments
    }
    
    func refresh() {
        sectionedClusterOrComment.flatMap({ $0 }).forEach({ $0.refresh() })
    }
    
    func contains(_ cOrC: ClusterOrComment) -> Bool {
        if songServiceSettings != nil {
            if let sectionIndex = self.sectionedClusterOrComment.firstIndex(where: { (array) -> Bool in
                return array.contains(where: { $0.id == cOrC.id })
            }) {
                return self.sectionedClusterOrComment[sectionIndex].contains(where: { $0.id == cOrC.id })
            } else {
                return false
            }
        } else {
            return clusters.contains(where: { $0.id == cOrC.id })
        }
    }
    
    func delete(_ cOrC: ClusterOrComment) {
        if songServiceSettings == nil, let index = clusters.firstIndex(where: { $0.id == cOrC.id }) {
            clusters.remove(at: index)
        }
    }
    
    func append(_ cOrC: ClusterOrComment) {
        if songServiceSettings == nil {
            clusters.append(cOrC)
        }
    }
    
    func changePosition(_ cOrC: ClusterOrComment, to indexPath: IndexPath) {
        if songServiceSettings != nil {
            if let sectionIndex = self.sectionedClusterOrComment.firstIndex(where: { (array) -> Bool in
                return array.contains(where: { $0.id == cOrC.cluster?.id })
            }) {
                if let rowIndex = self.sectionedClusterOrComment[sectionIndex].firstIndex(where: { $0.id == cOrC.id }) {
                    self.sectionedClusterOrComment[sectionIndex].remove(at: rowIndex)
                    self.sectionedClusterOrComment[indexPath.section].insert(cOrC, at: indexPath.row)
                }
            }
        } else {
            if let index = clusters.firstIndex(where: { $0.id == cOrC.id }) {
                clusters.remove(at: index)
            }
            clusters.insert(cOrC, at: indexPath.row)
        }
    }
    
    @discardableResult
    func change(old: ClusterOrComment, for new: ClusterOrComment) -> Bool {
        var updated = false
        if songServiceSettings != nil {
            if let sectionIndex = self.sectionedClusterOrComment.firstIndex(where: { (array) -> Bool in
                return array.contains(where: { $0.id == old.id })
            }) {
                if let rowIndex = self.sectionedClusterOrComment[sectionIndex].firstIndex(where: { $0.id == old.id }) {
                    self.sectionedClusterOrComment[sectionIndex].remove(at: rowIndex)
                    self.sectionedClusterOrComment[sectionIndex].insert(new, at: rowIndex)
                    updated = true
                }
                updated = false
            }
            updated = false
        } else {
            if let index = clusters.firstIndex(where: { $0.id == old.id }) {
                clusters.remove(at: index)
                clusters.insert(new, at: index)
                updated = true
            }
            updated = false
        }
        updatePositions()
        return updated
    }
    
    func getManditoryTagsIds() -> [String] {
        if let songServiceSettings = songServiceSettings, let clusterToChange = clusterToChange {
            if let index = sectionedClusterOrComment.firstIndex(where: { (array) -> Bool in
                return array.contains(where: { $0.id == clusterToChange.id })
            }) {
                return songServiceSettings.sections[index].tagIds
            }
        }
        return []
    }
    
    func save() {
        TempClustersModel.resetSavedValues()
        if let songServiceSettings = songServiceSettings {
            guard sectionedClusterOrComment.count > 0 else {
                return
            }
            defaults.setValue(songServiceSettings.id, forKey: Constants.songServiceId)
            let mappedCoC = sectionedClusterOrComment.compactMap({ $0.compactMap({ $0.id ?? Constants.comment }).joined(separator: ",") })
            defaults.setValue(mappedCoC, forKey: Constants.clusterOrComment)
            defaults.setValue(Date(), forKey: Constants.saveDate)
        } else {
            defaults.setValue(clusters.map({ $0.id ?? Constants.comment }), forKey: Constants.clusterOrComment)
            defaults.setValue(Date(), forKey: Constants.saveDate)
        }
    }
    
    static func resetSavedValues() {
        UserDefaults.standard.removeObject(forKey: Constants.saveDate)
        UserDefaults.standard.removeObject(forKey: Constants.songServiceId)
        UserDefaults.standard.removeObject(forKey: Constants.clusterOrComment)
    }
    
    private func updatePositions() {
        for (index, cluster) in clusters.enumerated() {
            cluster.cluster?.position = Int16(exactly: index) ?? 0
        }
        sectionedClusterOrComment.forEach { (clusterOrComments) in
            for (index, clusterOrComment) in clusterOrComments.enumerated() {
                clusterOrComment.cluster?.position = Int16(exactly: index) ?? 0
            }
        }
    }
}

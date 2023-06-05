//
//  SongServiceGeneratorUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

enum ClusterComment: Identifiable {
    case cluster(ClusterCodable)
    case comment
    
    var id: String {
        switch self {
        case .cluster(let cluster): return cluster.id
        case .comment: return ""
        }
    }
    
    var cluster: ClusterCodable? {
        switch self {
        case .cluster(let cluster): return cluster
        case .comment: return nil
        }
    }
}

struct SongServiceSectionWithSongs: Identifiable {
    
    public var id: String {
        return title + cocList.map({ $0.id }).joined()
    }
    let title: String
    var cocList: [ClusterComment]
    let songs: [SongObjectUI]
    var indexToChange: Int? = nil
    var selectedCollectionIds: [String] {
        return cocList.compactMap { $0.cluster?.id }
    }
    
    init(title: String, cocList: [ClusterComment]) {
        self.title = title
        self.cocList = cocList
        songs = cocList.compactMap { $0.cluster }.map { SongObjectUI(cluster: $0) }
    }
    
}

actor SongServiceGeneratorUseCase {
    
    private let line = "----------------"
    
    func generate(for songService: SongServiceSettingsCodable) async -> [SongServiceSectionWithSongs] {
        
        var position: Int16 = 0
        return await songService.sections.asyncMap { section in
            var clustersForSection: [ClusterCodable] = []
            await filterOn(section.tagIds, to: &clustersForSection)
            filterOnPlayDate(&clustersForSection, numberOfSongs: section.numberOfSongs.intValue)
            return SongServiceSectionWithSongs(title: section.title ?? "", cocList: map(clustersForSection, numberOfSongs: section.numberOfSongs.intValue, position: &position))
        }
    }
    
    func generateShareForCustomSelection(_ clusters: [ClusterCodable]) -> (title: String, content: String)? {
        let title = generateTitle()
        let content = clusters.map { generateTextForCluster($0, withContent: false) }.joined(separator: "\n\n")
        return (title, content)
    }

    func generateShareForSongServiceSettings(_ sections: [SongServiceSectionWithSongs], withContent: Bool) -> (title: String, content: String)? {
        
        let title = generateTitle()
        
        let sectionedText = sections.map { generateTextForSection($0, withContent: withContent) }.joined(separator: "\n\n")
        
        return (title, sectionedText)
    }
    
    private func filterOn(_ tagIds: [String], to clustersForSection: inout [ClusterCodable]) async {
        let tags = await GetTagsUseCase().fetch(predicates: tagIds.map { .get(id: $0) }, sort: .position(asc: true), predicateCompoundPredicateType: .or)
        clustersForSection = await FilteredCollectionsUseCase.getCollections(searchText: nil, showDeleted: false, selectedTags: tags)
    }
    
    private func filterOnPlayDate(_ clustersForSection: inout [ClusterCodable], numberOfSongs: Int) {
        
        clustersForSection.sort(by: { $0.lastShownAt ?? .distantPast < $1.lastShownAt ?? .distantPast })
        
        if clustersForSection.count >= numberOfSongs {
            
            var randomClusters: [ClusterCodable] = []
            
            for _ in 0..<numberOfSongs {
                if let cluster = clustersForSection.prefix(5).randomElement() {
                    randomClusters.append(cluster)
                }
            }
            
        }
    }
    
    private func map(_ clustersForSection: [ClusterCodable], numberOfSongs: Int, position: inout Int16) -> [ClusterComment] {
        var clusterComments: [ClusterComment] = []
        for index in 0..<numberOfSongs {
            if let cluster = clustersForSection[safe: index] {
                var changeableCluster = cluster
                changeableCluster.position = position
                clusterComments.append(.cluster(changeableCluster))
                position += 1
            } else {
                clusterComments.append(.comment)
            }
        }
        return clusterComments
    }
    
    func update(_ songServiceSectionWithSongs: [SongServiceSectionWithSongs]) async -> [SongServiceSectionWithSongs] {
        
        var updatedSongServiceSectionWithSongs: [SongServiceSectionWithSongs] = []
        
        await songServiceSectionWithSongs.concurrentForEach { section in
            var clusterCodables: [ClusterComment] = []
            
            await section.cocList.concurrentForEach { clusterComment in
                switch clusterComment {
                case .cluster(let cluster):
                    let refreshedCluster = await GetClustersUseCase().fetch(predicates: [.get(id: cluster.id)]).first
                    
                    if let refreshedCluster {
                        clusterCodables.append(.cluster(refreshedCluster))
                    } else {
                        clusterCodables.append(.comment)
                    }
                case .comment:
                    clusterCodables.append(.comment)
                }
            }
            updatedSongServiceSectionWithSongs.append(SongServiceSectionWithSongs(title: section.title, cocList: clusterCodables))
        }
        return updatedSongServiceSectionWithSongs
    }

    private func generateTitle() -> String {
        let formatter = DateFormatter()
        formatter.locale =  (Locale.current.language.region?.identifier.lowercased().contains("nl") ?? true) ? Locale(identifier: "nl_NL") : Locale.current
        formatter.dateFormat = "EEEE"
        let fullDay = formatter.string(from: Date())
        formatter.dateFormat = "d MMMM"
        let dateString = formatter.string(from: Date())
        let morningEvening = Date().hour < 12 ? AppText.NewSongService.morning : AppText.NewSongService.evening
        
        let fullDateString = fullDay + morningEvening + " " + dateString
        
        return AppText.NewSongService.shareSongServiceText(date: fullDateString)
    }
    
    private func generateTextForSection(_ section: SongServiceSectionWithSongs, withContent: Bool) -> String {
        
        var sectionTitle = [line + line]
        sectionTitle += [section.title]
        sectionTitle += [line + line]
        
        let clusterText = section.cocList.compactMap { $0.cluster }.map { generateTextForCluster($0, withContent: withContent) }.joined(separator: "\n\n")
        
        return [sectionTitle.joined(separator: "\n"), clusterText].joined(separator: "\n\n")
        
    }
    
    private func generateTextForCluster(_ cluster: ClusterCodable, withContent: Bool) -> String {
        let titleAndTime = ([cluster.title] + [String(cluster.startTime)]).compactMap({ $0 }).joined(separator: "\n")
            
        let formattedTitle = line + line + "\n" + titleAndTime + "\n" + line + line
        
        let sheetText = withContent ? cluster.hasSheets.compactMap { $0.sheetContent }.joined(separator: "\n\n") : nil
        
        return [formattedTitle, sheetText].compactMap { $0 }.joined(separator: "\n\n")
    }
    
}

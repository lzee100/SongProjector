//
//  SongsController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 13-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit
import SwiftUI

protocol SongsControllerDelegate {
    func finishedSelection(_ model: TempClustersModel)
}

class SongsController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, CustomSheetsControllerDelegate {
    
    @IBOutlet var new: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var cancel: UIBarButtonItem!
    
    
    // MARK: - Private Properties
    
    private var searchController: UISearchController!
    private var tags: [VTag] = []
    private var selectedTags: [VTag] = []
    private var selectedCluster: VCluster?
    private var filteredClusters: [Cluster] = []
    private var downloadingSongs: [MusicDownloadManager] = []
    private var playingCluster: VCluster?
    
    
    // MARK: Properties
    
    var delegate: SongsControllerDelegate?
    var tempClusterModel: TempClustersModel?
    
    override var requesters: [RequesterBase] {
        return [ClusterFetcher, ClusterSubmitter, UniversalClusterSubmitter]
    }
    var manditoryTagIds: [String]?
    
    // MARK: - UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        //        let numbers = [0]
        //        numbers[4]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoader()
        ClusterFetcher.fetch()
        selectedTags = []
        manditoryTagIds = tempClusterModel?.songServiceSettings == nil ? nil : tempClusterModel?.getManditoryTagsIds()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.tintColor = themeHighlighted
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = AppText.Songs.SearchSongPlaceholder
        searchController.definesPresentationContext = false
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        
        navigationItem.searchController = searchController
        
        if SubscriptionsSettings.hasLimitedAccess {
            SubscriptionsSettings.showSubscriptionsViewController(presentingViewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SoundPlayer.stop()
        if delegate != nil {
            presentingViewController?.viewWillAppear(animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.unwrap() as? CustomSheetsController {
            vc.delegate = self
            vc.preferredContentSize = CGSize(width: view.bounds.width * 0.95, height: 450)
            if let nav = segue.destination as? UINavigationController {
                nav.preferredContentSize = CGSize(width: view.bounds.width * 0.95, height: 450)
            }
            if sender is String {
                vc.cluster = selectedCluster!
                vc.isNew = false
            }
        }
    }
    
    
    
    // MARK: UITableview Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredClusters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
        
        if let cell = cell as? BasicCell {
            let cluster = filteredClusters[indexPath.row].vEntity
            cell.setup(data: cluster, title: cluster.title)
            let hasUnsectionedClusters = tempClusterModel?.clusters.count ?? 0 != 0
            var clusters = hasUnsectionedClusters ? tempClusterModel?.clusters : tempClusterModel?.sectionedClusterOrComment.flatMap({ $0 })
            if let clusterToChange = tempClusterModel?.clusterToChange {
                clusters?.append(clusterToChange)
            }
            cell.selectedCell = clusters?.contains(where: { filteredClusters[indexPath.row].id == $0.id }) ?? false
            
            if !cluster.hasLocalMusic && cluster.hasRemoteMusic {
                let isUserinteractionEnabled = !downloadingSongs.contains(where: { $0.id == cluster.id })
                cell.setAction(icon: UIImage(named: "DownloadIcon")!, buttonBackgroundColor: .softBlueGrey, isUserinteractionEnabled: isUserinteractionEnabled) {
                    Queues.main.async {
                        self.downloadSongFilesFor(song: cluster)
                    }
                }
            } else if cluster.hasLocalMusic {
                if cluster == playingCluster {
                    cell.setAction(icon: nil, buttonBackgroundColor: .clear, iconColor: .clear, action: { [weak self] in
                        self?.playingCluster = nil
                        if let playingCluster = self?.playingCluster {
                            SoundPlayer.play(song: playingCluster)
                        } else {
                            SoundPlayer.stop()
                        }
                        self?.tableView.reloadData()
                    })
                    cell.animatePlaying()
                } else {
                    cell.setAction(icon: UIImage(named: "Play")!, buttonBackgroundColor: .clear, iconColor: .blackColor, action: { [weak self] in
                        self?.playingCluster = self?.playingCluster == nil ? cluster : self?.playingCluster != cluster ? cluster : nil
                        if let playingCluster = self?.playingCluster {
                            SoundPlayer.play(song: playingCluster)
                        } else {
                            SoundPlayer.stop()
                        }
                        self?.tableView.reloadData()
                    })
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let song = filteredClusters[indexPath.row].vEntity
        var actions: [UIContextualAction] = []
        
        if selectedTags.contains(where: { $0.title == AppText.Tags.deletedClusters }) {
            // restore song
            let deleteAction = UIContextualAction(style: .normal, title: nil) { (_, _, completionHandler) in
                self.restoreSong(indexPath: indexPath, song: song)
                completionHandler(true)
            }
            deleteAction.title = AppText.Actions.restore
            deleteAction.backgroundColor = .green1
            actions.append(deleteAction)
            
        } else {
            // delete song
            let deleteAction = UIContextualAction(style: .normal, title: nil) { (_, _, completionHandler) in
                self.deleteSong(indexPath: indexPath, song: song)
                completionHandler(true)
            }
            deleteAction.image = UIImage(named: "Trash")
            deleteAction.backgroundColor = .red1
            actions.append(deleteAction)
            
            // delete music
            if song.hasLocalMusic {
                let deleteFiles = UIContextualAction(style: .normal, title: nil) { (_, _, completionHandler) in
                    self.deleteMusic(indexPath: indexPath, song: song)
                    completionHandler(true)
                }
                deleteFiles.image = UIImage(named: "TrashMusic")
                deleteFiles.backgroundColor = .red2
                actions.append(deleteFiles)
            }
        }
        
        if actions.count > 0 {
            let configuration = UISwipeActionsConfiguration(actions: actions)
            configuration.performsFirstActionWithFullSwipe = true
            return configuration
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let deleteView = tableView.subviews.compactMap({ $0.subviews }).first(where: { $0.contains(where: { $0 is BasicCell }) })?.first
        deleteView?.style(tableView: tableView, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCluster = filteredClusters[indexPath.row].vEntity
        if let delegate = delegate {
            let currentCorC = ClusterOrComment(cluster: filteredClusters[indexPath.row].vEntity)
            if let model = tempClusterModel, let clusterToChange = model.clusterToChange {
                if !model.sectionedClusterOrComment.flatMap({ $0 }).contains(where: { $0.id == currentCorC.id }) && !model.clusters.contains(where: { $0.id == currentCorC.id }) {
                    model.change(old: clusterToChange, for: currentCorC)
                    delegate.finishedSelection(model)
                    self.dismiss(animated: true)
                }
            }
            else if tempClusterModel?.songServiceSettings == nil {
                if tempClusterModel?.contains(currentCorC) ?? false {
                    tempClusterModel?.delete(currentCorC)
                } else {
                    tempClusterModel?.append(currentCorC)
                }
            }
            // if not able to delete, then append
            else if tempClusterModel?.contains(ClusterOrComment(cluster: filteredClusters[indexPath.row].vEntity)) ?? false {
                tempClusterModel?.delete(ClusterOrComment(cluster: filteredClusters[indexPath.row].vEntity))
            } else {
                tempClusterModel?.append(ClusterOrComment(cluster: filteredClusters[indexPath.row].vEntity))
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            
            guard !SubscriptionsSettings.hasLimitedAccess else {
                SubscriptionsSettings.showSubscriptionsViewController(presentingViewController: self)
                return
            }
//            requesters.forEach({ $0.removeObserver(self) })
//            performSegue(withIdentifier: "customSheetsControllerSegue", sender: "existing")
            let cluster: Cluster? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: selectedCluster?.id ?? "-1")])
//            if let cluster {
//                showCollectionEditorController(ClusterCodable(managedObject: cluster, context: moc))
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
        let needsPopUpSwipeToDelete = PopUpTimeManager(key: .deleteSongFromSongs, numberOfTimes: 1, showAgainAfterHours: 0).needsTrigger()
        if indexPath.row > 0, needsPopUpSwipeToDelete {
            Queues.main.asyncAfter(deadline: .now() + 1) {
                PopUpManager.present(AppText.NewSongService.swipeToDeleteHint, backgroundColor: .softBlueGrey, origin: .view(source: cell, sourceRect: cell.bounds), viewController: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    
    
    // MARK: - CollectionView Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath)
        
        if let collectionCell = collectionCell as? ThemeCellCollection {
            collectionCell.setup(themeName: tags[indexPath.row].title ?? "")
            if let manditoryTagIds = manditoryTagIds {
                let manditoryTags = tags.filter({ manditoryTagIds.contains($0.id) })
                collectionCell.isSelectedCell = manditoryTags.contains(entity: tags[indexPath.row])
            } else {
                collectionCell.isSelectedCell = selectedTags.contains(entity: tags[indexPath.row])
            }
        }
        return collectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if manditoryTagIds != nil {
            return
        }
        if let index = selectedTags.firstIndex(entity: tags[indexPath.row]) {
            self.selectedTags.remove(at: index)
        } else {
            self.selectedTags.append(tags[indexPath.row])
        }
        setFilteredClusters()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont.systemFont(ofSize: 17)
        let width = (tags[indexPath.row].title ?? "").width(withConstrainedHeight: 22, font: font) + 50
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        setFilteredClusters()
    }
    
    override func handleRequestFinish(requesterId: String, result: Any?) {
        Queues.main.async {
            if requesterId == ClusterSubmitter.id, let updatedCluster = (result as? [VCluster])?.first, let index = self.filteredClusters.firstIndex(where: { $0.id == updatedCluster.id }) {
                if ClusterSubmitter.requestMethod == .delete {
                    self.tempClusterModel?.delete(ClusterOrComment(cluster: self.filteredClusters[index].vEntity))
                    self.setFilteredClusters(reloadData: false)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    Queues.main.asyncAfter(deadline: .now() + 0.4) {
                        self.tableView.reloadData()
                    }
                } else if ClusterSubmitter.requestMethod == .put {
                    self.setFilteredClusters(reloadData: false)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                    Queues.main.asyncAfter(deadline: .now() + 0.4) {
                        self.tableView.reloadData()
                    }
                }
            } else {
                self.tempClusterModel?.refresh()
                self.update()
            }
            self.hideLoader()
        }
    }
    
    
    
    // CustomSheetsController Delegate Functions
    
    func didCloseCustomSheet() {
        requesters.forEach({ $0.addObserver(self) })
        presentedViewController?.dismiss(animated: true, completion: nil)
        update()
    }
    
    private func setup() {
        
        tableView.register(cell: Cells.basicCellid)
        collectionView.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)
        
        hideKeyboardWhenTappedAround()
        
        title = AppText.Songs.title
        cancel.title = AppText.Actions.done
        cancel.tintColor = delegate == nil ? .clear : themeHighlighted
        new.tintColor = themeHighlighted
        
        if delegate == nil {
            self.navigationItem.leftBarButtonItem = nil
        }
        navigationController?.navigationBar.backgroundColor = .whiteColor
        tableView.keyboardDismissMode = .interactive
        tableView.backgroundColor = .clear
        NotificationCenter.default.addObserver(forName: .autoRenewableSubscriptionDidChange, object: nil, queue: .main) { (_) in
            self.update()
        }
    }
    
    override func update() {
        setFilteredClusters()
    }
    
    private func setFilteredClusters(reloadData: Bool = true) {
        
        let searchString = self.searchController.searchBar.text?.lowercased() ?? ""
        
        var tagsResult: [VTag] = []
        var indexToScrollTo: IndexPath? = nil
        var predicates: [NSPredicate] = []
        
        //        let user = VUser.first(moc: moc)
        //        if let user = VUser.first(moc: moc), !user.hasActiveSongContract {
        //            var songPreds: [NSPredicate] = []
        //            if !user.hasActiveSongContract {
        //                songPreds.append(NSPredicate(format: "instrumentIds == nil"))
        //                songPreds.append(NSPredicate(format: "instrumentIds == %@", ""))
        //                let comp = NSCompoundPredicate(orPredicateWithSubpredicates: songPreds)
        //                predicates.append(and: [comp])
        //            }
        //        }
                
        var deletedPredicate: [NSPredicate] = []
        if self.selectedTags.contains(where: { $0.title == AppText.Tags.deletedClusters }) {
            if uploadSecret != nil {
                deletedPredicate.append(format: "rootDeleteDate != nil")
            } else {
                deletedPredicate.append(NSPredicate(format: "deleteDate != nil"))
            }
        } else {
            predicates += [.skipDeleted, .skipRootDeleted]
        }
        if selectedTags.count > 0 {
            let selectedTagsWithoutDeleted = self.selectedTags.filter({ $0.title != AppText.Tags.deletedClusters })
            let selectedTagsPred = NSCompoundPredicate(orPredicateWithSubpredicates: selectedTagsWithoutDeleted.map({ NSPredicate(format:"tagIds CONTAINS %@", $0.id) }) + deletedPredicate)
            predicates.append(selectedTagsPred)
        }
        
        if let manditoryTagIds = self.manditoryTagIds, manditoryTagIds.count > 0 {
            let manditoryTagIdsPred = NSCompoundPredicate(orPredicateWithSubpredicates: self.manditoryTagIds?.map({ NSPredicate(format:"tagIds CONTAINS %@", $0) }) ?? [])
            predicates.append(manditoryTagIdsPred)
        }
        if searchString != "" {
            predicates.append(NSPredicate(format: "title contains[c] %@", searchString))
        }
        let pClustersFiltered: [Cluster] = DataFetcher().getEntities(moc: moc, predicates: predicates, sort: NSSortDescriptor(key: "title", ascending: true))
        pClustersFiltered.forEach({ moc.refresh($0, mergeChanges: false) })
        
        let tagIdsPredicates = self.manditoryTagIds?.map({ NSPredicate(format:"tagIds CONTAINS %@", $0) }) ?? []
        predicates = tagIdsPredicates + [.skipDeleted]
        
        let pTags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
        tagsResult = pTags.compactMap({ VTag(tag: $0, context: moc) })
        if let deletedTag = self.selectedTags.first(where: { $0.title == AppText.Tags.deletedClusters }) {
            tagsResult.append(deletedTag)
        } else {
            let deletedClustersTag = VTag()
            deletedClustersTag.title = AppText.Tags.deletedClusters
            tagsResult.append(deletedClustersTag)
        }
        
        if let manditoryTagIds = self.manditoryTagIds, let index = tagsResult.firstIndex(where: { $0.id == manditoryTagIds.first }) {
            indexToScrollTo = IndexPath(row: index, section: 0)
        }
        
        self.filteredClusters = pClustersFiltered
        self.tags = tagsResult
        if reloadData {
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
        if let index = indexToScrollTo {
            self.collectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func deleteMusic(indexPath: IndexPath, song: VCluster) {
        let alert = UIAlertController(title: AppText.Songs.deleteMusicTitle, message: AppText.Songs.deleteMusicBody(songName: song.title ?? ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppText.Actions.delete, style: .destructive, handler: { _ in
            // Delete Local CONTENT
            song.hasInstruments.compactMap({ $0.resourcePath }).compactMap({ FileManager.getURLfor(name: $0) }).forEach { (url) in
                do {
                    try FileManager.default.removeItem(at: url)
                    song.hasInstruments.forEach({ $0.resourcePath = nil })
                    song.getManagedObject(context: moc)
                    try moc.save()
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                } catch {
                    self.show(message: error.localizedDescription)
                }
            }
        }))
        self.present(alert, animated: true)
    }
    
    private func deleteSong(indexPath: IndexPath, song: VCluster) {
        let alert = UIAlertController(title: AppText.Songs.deleteTitle(songName: song.title ?? ""), message: AppText.Songs.deleteBody(songName: song.title ?? ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppText.Actions.delete, style: .destructive, handler: { _ in
            if uploadSecret == nil {
                self.filteredClusters[indexPath.row].deleteDate = NSDate()
                ClusterSubmitter.submit([self.filteredClusters[indexPath.row].vEntity], requestMethod: .delete)
            } else {
                self.filteredClusters[indexPath.row].deleteDate = NSDate()
                self.filteredClusters[indexPath.row].rootDeleteDate = NSDate()
                UniversalClusterSubmitter.submit([self.filteredClusters[indexPath.row].vEntity], requestMethod: .delete)
            }
        }))
        self.present(alert, animated: true)
    }
    
    private func restoreSong(indexPath: IndexPath, song: VCluster) {
        let alert = UIAlertController(title: AppText.Songs.restoreTitle + " " + (song.title ?? ""), message: AppText.Songs.restoreBody(songName: song.title ?? ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: AppText.Actions.restore, style: .default, handler: { _ in
            if uploadSecret == nil {
                self.filteredClusters.first(where: { $0.id == song.id })?.deleteDate = nil
                song.deleteDate = nil
                ClusterSubmitter.submit([song], requestMethod: .put)
            } else {
                self.filteredClusters.first(where: { $0.id == song.id })?.deleteDate = nil
                self.filteredClusters.first(where: { $0.id == song.id })?.rootDeleteDate = nil
                song.rootDeleteDate = nil
                UniversalClusterSubmitter.submit([song], requestMethod: .put)
            }
        }))
        self.present(alert, animated: true)
    }
    
    private func downloadSongFilesFor(song: VCluster) {
        guard !downloadingSongs.contains(where: { $0.id == song.id }) else { return }
        if song.musicDownloadObjects.count > 0 {
            let tm: MusicDownloadManager = MusicDownloadManager(cluster: song)
            downloadingSongs.append(tm)
            _ = tm.$progress.sink(receiveValue: { [weak self] progress in
                guard let self = self else { return }
                if let cell = self.tableView.visibleCells.compactMap({ $0 as? BasicCell }).first(where: { ($0.data as? VCluster) == song }) {
                    Queues.main.async {
                        cell.setProgress(progres: progress)
                    }
                }
            })
            
            _ = tm.$result.sink(receiveValue: { [weak self] result in
                Queues.main.async {
                    switch result {
                    case .failed(error: let error):
                        guard let `self` = self else { return }
                        self.show(message: error.localizedDescription)
                    case .success, .none:
                        Queues.main.async {
                            song.setDownloadValues(tm.downloadObjects)
                            song.getManagedObject(context: moc)
                            moc.perform {
                                do {
                                    try moc.save()
                                    guard let `self` = self else { return }
                                    if let cell = self.tableView.visibleCells.compactMap({ $0 as? BasicCell }).first(where: { ($0.data as? VCluster) == song }) {
                                        cell.finishProgress()
                                    }
                                } catch {
                                    guard let `self` = self else { return }
                                    self.show(message: error.localizedDescription)
                                }
                            }
                        }
                    }
                    self?.downloadingSongs.removeAll(where: { $0.id == song.id })
                }
            })
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        if let model = tempClusterModel {
            presentingViewController?.unwrap()?.viewWillAppear(true)
            delegate?.finishedSelection(model)
        }
        dismiss(animated: true)
    }
    
    @IBAction func didPressedAdd(_ sender: UIBarButtonItem) {
        guard SubscriptionsSettings.hasLimitedAccess else {
            performSegue(withIdentifier: "customSheetsControllerSegue", sender: nil)
            return
        }

        guard let user = VUser.first(moc: moc) else {
            show(message: AppText.Songs.errorNoUserFound)
            return
        }

        if user.hasActiveSongContract || user.hasActiveBeamContract {
            performSegue(withIdentifier: "customSheetsController", sender: nil)
        } else {

            var predicates: [NSPredicate] = []

            if let user = VUser.first(moc: moc), !user.hasActiveSongContract {
                var songPreds: [NSPredicate] = []
                if !user.hasActiveSongContract {
                    songPreds.append(NSPredicate(format: "instrumentIds == nil"))
                    songPreds.append(NSPredicate(format: "instrumentIds == %@", ""))
                    let comp = NSCompoundPredicate(orPredicateWithSubpredicates: songPreds)
                    predicates.append(and: [comp])
                }
            }

            let songs: [Cluster] = DataFetcher().getEntities(moc: moc, predicates: predicates, sort: nil)

            if songs.count > 10 {
                SubscriptionsSettings.showSubscriptionsViewController(presentingViewController: self)
            } else {
                performSegue(withIdentifier: "customSheetsControllerSegue", sender: nil)
            }

        }
    }
    
}

private extension Cluster {
    
    var vEntity: VCluster {
        return VCluster(cluster: self, context: self.managedObjectContext ?? moc)
    }
}

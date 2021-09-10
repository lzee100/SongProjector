//
//  NewSongServiceIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import MessageUI

class NewSongServiceIphoneController: ChurchBeamViewController, UIGestureRecognizerDelegate, SongsControllerDelegate {
	

	@IBOutlet var done: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    
    
	// MARK: - Private Properties
    
	private var clustersFetched = false
	private var songserviceFetched = false
    
    
    
	// MARK: - Properties

	var delegate: SongsControllerDelegate?
	var clusterModel: TempClustersModel!
    override var requesters: [RequesterBase] {
        return [SongServiceSettingsFetcher]
    }
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	
	
	// MARK: - ViewController Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SongServiceSettingsFetcher.fetch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let songServiceSetting: SongServiceSettings? = DataFetcher().getEntities(moc: moc).first
        
        let needsPopUpShakeIphone = PopUpTimeManager(key: .shakeToGenerateSongService, numberOfTimes: 0, showAgainAfterHours: 24 * 30).needsTrigger { () -> Bool in
            if let lastGeneratedSongService = UserDefaults.standard.value(forKey: "lastGeneratedSongService") as? Date {
                return lastGeneratedSongService.daysFrom(Date()) < 30
            }
            return true
        }
        let needsPopupCreateSongService = PopUpTimeManager(key: PopUpTimeManager.Keys.createSongServiceSettings, numberOfTimes: 0, showAgainAfterHours: 24 * 7).needsTrigger()
        
        if songServiceSetting == nil, needsPopupCreateSongService {
            let vc = Storyboard.MainStoryboard.instantiateViewController(identifier: PopupGenerateSongServiceSettings.identifier)
            present(vc, animated: true)
        } else if needsPopUpShakeIphone {
            PopUpManager.present(AppText.NewSongService.shakeToGenerate, backgroundColor: .softBlueGrey, origin: .view(source: view, sourceRect: CGRect(x: 0, y: view.bounds.height / 2, width: 1, height: 1)), viewController: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
	
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if(event?.subtype == UIEvent.EventSubtype.motionShake) {
            [ClusterFetcher, SongServiceSettingsFetcher].compactMap({ $0 as? RequesterBase }).forEach({ $0.addObserver(self) })
            let settings: [SongServiceSettings] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "updatedAt", ascending: false))
            if !clustersFetched {
                showLoader()
                ClusterFetcher.fetch()
            } else if !songserviceFetched {
                showLoader()
                SongServiceSettingsFetcher.fetch()
            } else if let settings = settings.first {
                UserDefaults.standard.setValue(Date(), forKey: "lastGeneratedSongService")
                Queues.main.async {
                    self.set(VSongServiceSettings(entity: settings, context: moc))
                }
            }
        }
	}
    
    override func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        if requester.id == ClusterFetcher.id {
            clustersFetched = true
            SongServiceSettingsFetcher.fetch()
        }
        if requester.id == SongServiceSettingsFetcher.id {
            songserviceFetched = true
            updateBarButtons()
        }
        if clustersFetched && songserviceFetched {
            let settings: [SongServiceSettings] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "updatedAt", ascending: false))
            if let settings = settings.first {
                Queues.main.async {
                    self.set(VSongServiceSettings(songserviceSettings: settings, context: moc))
                }
            }
        }
        super.requesterDidFinish(requester: requester, result: result, isPartial: isPartial)
    }
	
	
    
	// MARK: - Custom Functions

	func finishedSelection(_ model: TempClustersModel) {
		update()
	}
	
	
	
	// MARK: - Requester Functions
	
	override func handleRequestFinish(requesterId: String, result: Any?) {
		DispatchQueue.main.async {
            if requesterId == SongServiceSettingsFetcher.id {
                self.hideLoader()
            }
			self.update()
		}
	}
	
	
	
	// MARK: - Private Functions

	private func setup() {
		becomeFirstResponder()
		tableView.register(cell: Cells.basicCellid)
		tableView.register(cell: TextCell.identifier)
        tableView.register(header: BasicHeaderView.identifier)
		done.title = AppText.Actions.done
        done.tintColor = themeHighlighted
        title = AppText.NewSongService.title
        
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
        
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
		
        clusterModel = TempClustersModel.load() ?? TempClustersModel()
        
		update()
	}
	
    override func update() {
        super.update()
        updateBarButtons()
		tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.clipsToBounds = true
        tableView.setCornerRadius(corners: .allCorners, frame: CGRect(x: 0, y: 0, width: tableView.contentSize.width, height: tableView.contentSize.height), radius: 10)
	}
	
	@objc private func editTableView(_ gestureRecognizer: UIGestureRecognizer) {
		if let gestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
			if gestureRecognizer.state == UIGestureRecognizer.State.began {
				changeEditingState()
			}
		} // for double tab
		else if let _ = gestureRecognizer as? UITapGestureRecognizer, tableView.isEditing {
			changeEditingState()
		}
	}
	
	private func changeEditingState(_ onlyIfEditing: Bool? = nil) {
		if let _ = onlyIfEditing {
			if tableView.isEditing {
				tableView.setEditing(false, animated: false)
			}
		} else {
			tableView.setEditing(tableView.isEditing ? false : true, animated: false)
		}
	}
	
    @objc private func createRandomSongService() {
        let pSettings: [SongServiceSettings] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "updatedAt", ascending: false))
        guard let settings = pSettings.first else {
            return
        }
        let persitentClusters: [Cluster] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted, .skipRootDeleted], sort: NSSortDescriptor(key: "lastShownAt", ascending: true))
        let allClusters = persitentClusters.compactMap({ VCluster(cluster: $0, context: moc) })
        clusterModel.clusters = []
        clusterModel.songServiceSettings = VSongServiceSettings(songserviceSettings: settings, context: moc)
        var sectionedClusterOrComments: [[ClusterOrComment]] = []
        for (position, section) in (clusterModel.songServiceSettings?.sections ?? []).enumerated() {
            sectionedClusterOrComments.append([])
            for songNumber in 1...section.numberOfSongs {
                let allSelectedClusters = sectionedClusterOrComments.flatMap({ $0 }).compactMap({ $0.cluster })
                let candidateSongs = allClusters.filter({ !allSelectedClusters.contains(entity: $0) }).filter({ cluster in
                    var contains = false
                    for tag in cluster.hasTags(moc: moc) {
                        if section.tagIds.contains(tag.id) {
                            contains = true
                            break
                        }
                    }
                    return contains
                }).sorted(by: { ($0.lastShownAt ?? Date().dateByAddingYears(-1)) < ($1.lastShownAt ?? Date().dateByAddingYears(-1)) })
                if candidateSongs.count > 0 {
                    let random = section.numberOfSongs - songNumber > 0 ? Int.random(in: 0..<Int(section.numberOfSongs - songNumber)) : 0
                    if let sameNameAsSection = candidateSongs.first(where: { $0.title == section.title }) {
                        sectionedClusterOrComments[position].append(ClusterOrComment(cluster: sameNameAsSection))
                    } else {
                        sectionedClusterOrComments[position].append(ClusterOrComment(cluster: candidateSongs[random]))
                    }
                } else if sectionedClusterOrComments[position].filter({ $0.cluster == nil }).count == 0 {
                    sectionedClusterOrComments[position].append(ClusterOrComment(cluster: nil))
                }
            }
        }
        clusterModel.sectionedClusterOrComment = sectionedClusterOrComments
    }
	
    private func set(_ songServiceSettings: VSongServiceSettings) {
        Queues.main.async {
            self.clusterModel.songServiceSettings = songServiceSettings
            self.clusterModel.clusters = []
            self.createRandomSongService()
            self.update()
        }
    }
    
	private func canMoveRow(from: IndexPath, to: IndexPath) -> Bool {
		if clusterModel.songServiceSettings == nil {
			return true
		}
		let toRow = min(clusterModel.sectionedClusterOrComment[to.section].count - 1, to.row)
		if clusterModel.sectionedClusterOrComment[to.section][toRow].cluster == nil {
			return false
		}
		
		let clusterToMoveTagIds = clusterModel.sectionedClusterOrComment[from.section][from.row].cluster?.tagIds
		let sectionTo = clusterModel.songServiceSettings!.sections[to.section]
		if sectionTo.hasTags(moc: moc).contains(where: { (tag) -> Bool in
			clusterToMoveTagIds?.contains(where: { $0 == tag.id }) ?? false
		}) {
			return true
		}
		return false
	}
	
	private func isTextCell(indexPath: IndexPath) -> Bool {
		if clusterModel.songServiceSettings != nil {
			if clusterModel.sectionedClusterOrComment.count == 0 {
				return true
			}
			if clusterModel.sectionedClusterOrComment[indexPath.section][indexPath.row].cluster != nil {
				return false
			} else {
				return true
			}
		}
		if clusterModel.clusters.count == 0 {
			return true
		} else {
			return false
		}
	}
    
    private func removeObservers() {
        [ClusterFetcher, SongServiceSettingsFetcher].compactMap({ $0 as? RequesterBase }).forEach({ $0.removeObserver(self) })
    }
    
    private func updateBarButtons() {
        let share: UIBarButtonItem?
        let hasContent = clusterModel.sectionedClusterOrComment.flatMap({ $0 }).count > 0 || clusterModel.clusters.count > 0
        if hasContent {
            share = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareSongServicePressed(_:)))
            share?.tintColor = themeHighlighted
        } else {
            share = nil
        }
        let generate: UIBarButtonItem?
        let songServiceSettings: [SongServiceSettings] = DataFetcher().getEntities(moc: moc)
        if !hasContent, songServiceSettings.count > 0 {
            generate = UIBarButtonItem(image: UIImage(named: "MagicWand"), landscapeImagePhone: UIImage(named: "MagicWand"), style: .plain, target: self, action: #selector(generateSongService))
            generate?.tintColor = themeHighlighted
        } else {
            generate = nil
        }
        
        let type = clusterModel.songServiceSettings == nil ? UIBarButtonItem.SystemItem.add : UIBarButtonItem.SystemItem.cancel
        let addOrCancel = UIBarButtonItem(barButtonSystemItem: type, target: self, action: #selector(addPressed(_:)))
        addOrCancel.tag = clusterModel.songServiceSettings == nil ? 0 : 1
        addOrCancel.tintColor = themeHighlighted
        navigationItem.rightBarButtonItems = [addOrCancel, share, generate].compactMap({ $0 })

    }
    
    @objc private func generateSongService(barbutton: UIBarButtonItem) {
        if let songService: SongServiceSettings = DataFetcher().getEntity(moc: moc) {
            set(VSongServiceSettings(entity: songService, context: moc))
        }
    }
    
    private func generateShareInfo(withLyrics: Bool) -> String {
        
        let formatter = DateFormatter()
        formatter.locale =  (Locale.current.regionCode?.lowercased().contains("nl") ?? true) ? Locale(identifier: "nl_NL") : Locale.current
        formatter.dateFormat = "EEEE"
        let fullDay = formatter.string(from: Date())
        formatter.dateFormat = "d MMMM"
        let dateString = formatter.string(from: Date())
        let morningEvening = Date().hour < 12 ? AppText.NewSongService.morning : AppText.NewSongService.evening
        
        let fullDateString = fullDay + morningEvening + " " + dateString
        
        var message = AppText.NewSongService.shareSongServiceText(date: fullDateString)
        
        if clusterModel.clusters.count > 0 {
            message.append("\n\n")
            message += clusterModel.clusters.filter({ $0.cluster?.time == 0 }).compactMap({
                                                                                           
                var text = [($0.cluster?.title ?? "No title")]
                let startTime: String
                if let st = $0.cluster?.startTime.stringValue, $0.cluster?.hasRemoteMusic ?? false {
                    startTime = "\(AppText.NewSongService.shareSingFrom + st)"
                } else {
                    startTime = ""
                }
                text += [startTime, "\n---------------------------"]
                
                if withLyrics {
                    if let lyrics = $0.cluster?.hasSheets.compactMap({ sheet in (sheet as? VSheetTitleContent)?.content }).joined(separator: "\n\n") {
                        text.append(lyrics)
                    }
                }
                return text.compactMap({ $0 }).joined(separator: "\n")
            }).joined(separator: "\n\n\n")
        } else if let songserviceSettings = clusterModel.songServiceSettings, clusterModel.sectionedClusterOrComment.count > 0 {
            
            message.append("\n\n")
            
            for (index, coc) in clusterModel.sectionedClusterOrComment.enumerated() {
                if index > 0 {
                    message.append("\n\n")
                }
                let sectionTitle = "---------------------------\n\((songserviceSettings.sections[index].title ?? ""))\n---------------------------\n"
                let sectionTitles = songserviceSettings.sections.compactMap({ $0.title })
                let songs: [(String, String?)] = coc.map({
                    
                    var title = ($0.cluster?.title ?? "No title")
                    let startTime: String
                    if let st = $0.cluster?.startTime.stringValue, $0.cluster?.hasRemoteMusic ?? false {
                        startTime = "\n\(AppText.NewSongService.shareSingFrom + st)"
                    } else {
                        startTime = ""
                    }
                    title += startTime
                    title += "\n---------------------------"

                    let lyrics: String?
                    if withLyrics {
                        lyrics = $0.cluster?.hasSheets.compactMap({ sheet in (sheet as? VSheetTitleContent)?.content }).joined(separator: "\n\n")
                    } else {
                        lyrics = nil
                    }
                    return (title, lyrics)
                })
                
                let allInfo = songs.filter({ titleLyrics in !sectionTitles.contains(where: { $0 == titleLyrics.0 }) }).map({ [$0.0, $0.1].compactMap({ $0 }).joined(separator: "\n") }).joined(separator: "\n\n\n")
                message.append([sectionTitle, allInfo].joined(separator: "\n"))
            }
            
        }
        return message
    }
	
	@IBAction func addPressed(_ sender: UIBarButtonItem) {
        if self.navigationItem.rightBarButtonItem?.tag == 0 || clusterModel.clusterToChange != nil {
            let nav = Storyboard.MainStoryboard.instantiateViewController(withIdentifier: Feature.songs.identifier)
            let vc = (nav.unwrap() as? SongsController)
			vc?.delegate = self
			vc?.tempClusterModel = clusterModel
            removeObservers()
            present(nav, animated: true)
		} else {
            self.navigationItem.rightBarButtonItem?.tintColor = themeHighlighted
            self.navigationItem.rightBarButtonItem?.tag = 0
			clusterModel.songServiceSettings = nil
			clusterModel.sectionedClusterOrComment = []
            clusterModel.save()
            update()
		}
	}
	
    @IBAction func shareSongServicePressed(_ sender: UIBarButtonItem) {
        
        let hasSections = clusterModel.clusters.count == 0
        let actionOnlyTitles = hasSections ? AppText.NewSongService.shareOptionTitlesWithSections : AppText.NewSongService.shareOptionTitles
        let actionLyrics = hasSections ? AppText.NewSongService.shareOptionLyricsWithSections : AppText.NewSongService.shareOptionLyrics
        
        let alertController = UIAlertController(title: nil, message: AppText.NewSongService.shareOptionsTitle, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: actionOnlyTitles, style: .default, handler: { _ in
            let message = self.generateShareInfo(withLyrics: false)
            let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sender
            self.present(activityViewController, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: actionLyrics, style: .default, handler: { _ in
            let message = self.generateShareInfo(withLyrics: true)
            let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            activityViewController.popoverPresentationController?.barButtonItem = sender
            self.present(activityViewController, animated: true, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel, handler: nil))
        alertController.popoverPresentationController?.barButtonItem = sender
        present(alertController, animated: true)
    }
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
        // if contains comment (not enough soungs)
        if clusterModel.sectionedClusterOrComment.filter({ $0.filter({ $0.cluster == nil }).count > 0 }).count > 0 {
            let controller = UIAlertController(title: nil, message: AppText.NewSongService.notEnoughSongsForTagSectionAlertBody, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel, handler: nil))
            controller.addAction(UIAlertAction(title: AppText.Actions.continue, style: .destructive, handler: { (_) in
                self.clusterModel.sectionedClusterOrComment = []
                self.clusterModel.songServiceSettings = nil
                self.delegate?.finishedSelection(self.clusterModel)
                self.dismiss(animated: true)
            }))
            present(controller, animated: true)
        } else {
            clusterModel.save()
            delegate?.finishedSelection(clusterModel)
            self.dismiss(animated: true)
        }
	}
}

extension NewSongServiceIphoneController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return clusterModel.songServiceSettings?.sections.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if clusterModel.songServiceSettings != nil {
            return clusterModel.sectionedClusterOrComment[section].count
        }
        let noSelection = clusterModel.hasNoSongs ? 1 : 0
        return clusterModel.clusters.count + noSelection
    }
    
}


extension NewSongServiceIphoneController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard clusterModel.clusters.count > 0 || (clusterModel.songServiceSettings != nil && clusterModel.sectionedClusterOrComment.count > 0) else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
            cell.setupWith(text: AppText.NewSongService.noSelectedSongs)
            return cell
        }
        if clusterModel.songServiceSettings != nil {
            if let cluster = clusterModel.sectionedClusterOrComment[indexPath.section][indexPath.row].cluster {
                let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
                cell.setup(title: cluster.title)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
                cell.setupWith(text: AppText.NewSongService.notEnoughSongsForTagSection)
                cell.descriptionLabel.textColor = .red1
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
        cell.setup(title: clusterModel.clusters[indexPath.row].cluster?.title ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard clusterModel.clusters.count > 0 || (clusterModel.sectionedClusterOrComment.flatMap({ $0 }).count > 0 && clusterModel.songServiceSettings != nil) else { return }
        if tableView.cellForRow(at: indexPath) is BasicCell {
            if clusterModel.songServiceSettings != nil {
                clusterModel.clusterToChange = clusterModel.sectionedClusterOrComment[indexPath.section][indexPath.row]
            } else {
                clusterModel.clusterToChange = clusterModel.clusters[indexPath.row]
            }
            guard let item = navigationItem.rightBarButtonItem else { return }
            addPressed(item)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isTextCell(indexPath: indexPath) {
            return UITableView.automaticDimension
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if clusterModel.songServiceSettings == nil && clusterModel.clusters.count > 0 {
            let deleteView = tableView.subviews.compactMap({ $0.subviews }).first(where: { $0.contains(where: { $0 is BasicCell }) })?.first
            deleteView?.style(tableView: tableView, forRowAt: indexPath)
            return .delete
        }
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            clusterModel.clusters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if clusterModel.clusters.count == 0 {
                tableView.insertRows(at: [indexPath], with: .top)
            }
            tableView.endUpdates()
            tableView.setNeedsDisplay()
            if tableView.numberOfRows(inSection: 0) == 0 {
                tableView.reloadData()
            }
        }
        updateBarButtons()
    }

    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        if canMoveRow(from: fromIndexPath, to: to) {
            if clusterModel.songServiceSettings == nil {
                let itemToMove = clusterModel.clusters[fromIndexPath.row]
                clusterModel.changePosition(itemToMove, to: to)
            } else {
                let itemToMove = clusterModel.sectionedClusterOrComment[fromIndexPath.section][fromIndexPath.row]
                clusterModel.changePosition(itemToMove, to: to)
            }
            tableView.reloadData()
        } else {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return isTextCell(indexPath: indexPath) ? false : true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.basicHeaderView
        view?.descriptionLabel.text = clusterModel.songServiceSettings?.sections[section].title
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if clusterModel.songServiceSettings == nil {
            return 30
        }
        return HeaderView.height
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
    
    
}


extension NewSongServiceIphoneController: UINavigationControllerDelegate {
	
}

extension NewSongServiceIphoneController: MFMailComposeViewControllerDelegate {
	
	func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith didFinishWithResult:MFMailComposeResult, error:Error?) {
		presentedViewController?.dismiss(animated: true)
	}

}

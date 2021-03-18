//
//  SaveNewSongTitleTimeVC.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol SaveNewSongTitleTimeVCDelegate {
	func didSaveClusterWith(title: String, time: Double, tagIds: [Int64])
}

class SaveNewSongTitleTimeVC: ChurchBeamViewController {
	
	
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
	enum Section {
		case song
		case custom
		case tags
		static let all = [song, custom, tags]
	}
	
	
	enum Row {
		case title
		case time // loop time
        case startTime
		case tag
        
        static func `for`(indexPath: IndexPath, hasMusic: Bool) -> Row {
			switch Section.all[indexPath.section] {
			case .song: return title
            case .custom: return uploadSecret != nil && hasMusic ? .startTime : .time
			case .tags: return tag
			}
		}
		
		var identifier: String {
			switch self {
			case .title: return TextFieldCell.identifier
			case .time: return PickerCell.identifier
            case .startTime: return TextFieldCell.identifier
			case .tag: return BasicCell.identifier
			}
		}
		
	}
	
	private var tags: [VTag] = []
	private var selectedTags: [VTag] = []
	
	weak var cluster: VCluster?
	weak var selectedTheme: VTheme?
	
	override var requesters: [RequesterBase] {
		return [TagFetcher]
	}
	
	var timeValues: [Int] {
		var values: [Int] = []
		for int in 0...60 {
			values.append(int)
		}
		return values
	}
	var selectedIndex: Int {
        if let index = timeValues.firstIndex(where: { $0 == Int(cluster?.time ?? 0) }) {
			return index
		}
		return 0
	}
	var clusterTitle: String?
	var clusterTime: Double = 0

	var didSave: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        clusterTitle = clusterTitle ?? cluster?.title
		TagFetcher.fetch()
	}
	
	override func handleRequestFinish(requesterId: String, result: Any?) {
		update()
	}

    override func update() {
        let pTags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
        self.tags = pTags.map({ VTag(tag: $0, context: moc) })
        self.tableView.reloadData()
    }
	
	func textFieldDidChange(text: String?) {
		clusterTitle = text ?? ""
	}
	
	func pickerDidChange(value: Any) {
		if let value = value as? Int {
			clusterTime = Double(value)
		}
	}
	
	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		if hasName() {
			
			cluster?.tagIds = selectedTags.compactMap({ $0.id })
			cluster?.title = clusterTitle
			cluster?.time = clusterTime
			
			self.dismiss(animated: true) {
				self.didSave?()
			}
		}
		
	}
    
    private func setup() {
        cancelButton.title = AppText.Actions.cancel
        saveButton.title = AppText.Actions.save
        cancelButton.tintColor = themeHighlighted
        saveButton.tintColor = themeHighlighted
        tableView.register(cells: [TextFieldCell.identifier, PickerCell.identifier, BasicCell.identifier])
        tableView.register(header: BasicHeaderView.identifier)
        title = cluster?.title ?? AppText.NewSong.title
        clusterTitle = cluster?.title ?? ""
        clusterTime = cluster?.time ?? 0
        let pTags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
        let tags = pTags.map({ VTag(tag: $0, context: moc) })
        selectedTags = tags.filter({ tag in cluster?.tagIds.contains(where: { tag.id == $0 }) ?? false })
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        update()
    }
    	
	private func hasName() -> Bool {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
		let cellName = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldCell
		if clusterTitle != "" {
			cellName.textField.layer.borderColor = nil
			cellName.textField.layer.borderWidth = 0
			cellName.textField.layer.cornerRadius = 0
			cellName.setNeedsLayout()
			return true
		} else {
			cellName.textField.layer.borderColor = UIColor.red.cgColor
			cellName.textField.layer.borderWidth = 2
			cellName.textField.layer.cornerRadius = 5
			cellName.setNeedsLayout()
			cellName.shake()
			return false
		}
	}
}

extension SaveNewSongTitleTimeVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.all[section] {
        case .song:
            return 1
        case .custom:
            if cluster?.isTypeSong ?? false {
                return uploadSecret != nil && (cluster?.hasRemoteMusic ?? false) ? 1 : 0
            } else {
                return 1
            }
        case .tags:
            return tags.count
        }
    }
    
}

extension SaveNewSongTitleTimeVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath: indexPath, hasMusic: cluster?.hasRemoteMusic ?? false).identifier)!
        
        switch Row.for(indexPath: indexPath, hasMusic: cluster?.hasRemoteMusic ?? false) {
        case .title:
            (cell as! TextFieldCell).setup(description: nil, content: clusterTitle ?? cluster?.title ?? "", textFieldDidChange: textFieldDidChange(text:))
        case .time:
            (cell as! PickerCell).setupWith(description: AppText.CustomSheets.descriptionTime, values: timeValues, selectedIndex: selectedIndex, didSelectValue: pickerDidChange(value:))
        case .startTime:
            (cell as! TextFieldCell).setup(description: AppText.UploadUniversalSong.startTime, content: cluster?.startTime.stringValue) { text in
                if let text = text, text.isNumber, let startTime = Double(text) {
                    self.cluster?.startTime = startTime
                } else {
                    cell.shake()
                }
            }
        case .tag:
            (cell as! BasicCell).setup(title: tags[indexPath.row].title, textColor: .blackColor)
            (cell as! BasicCell).selectedCell = selectedTags.contains(entity: tags[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if Section.all[indexPath.section] == .tags {
            if selectedTags.contains(entity: tags[indexPath.row]) {
                selectedTags.delete(entity: tags[indexPath.row])
            } else {
                selectedTags.append(tags[indexPath.row])
            }
            if let cell = tableView.cellForRow(at: indexPath) as? BasicCell {
                cell.selectedCell = selectedTags.contains(entity: tags[indexPath.row])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section.all[indexPath.section] == .tags {
            return 60
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch Section.all[section] {
        case .song:
            let view = tableView.basicHeaderView
            view?.descriptionLabel.text = AppText.NewSong.SongTitle
            return view
        case .custom:
            return nil
        case .tags:
            let view = tableView.basicHeaderView
            view?.descriptionLabel.text = AppText.Tags.title
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch Section.all[section] {
        case .song: return BasicHeaderView.height
        case .tags: return BasicHeaderView.height
        case .custom: return CGFloat.leastNormalMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}

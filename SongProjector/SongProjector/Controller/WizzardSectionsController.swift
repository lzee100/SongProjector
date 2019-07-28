//
//  WizzardSectionsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class WizzardSectionsController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, LabelNumerCellDelegate {
	

	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var nextButton: UIBarButtonItem!
	@IBOutlet var tableView: UITableView!
	
	
	var songServiceObject: SongServiceSettings? {
		didSet {
			numberOfSections = songServiceObject?.sections.count ?? 1
		}
	}
	private var songServiceObjectTemp: SongServiceSettings? = nil
	private var numberOfSections = 1
	
	
	// MARK: - UIView Functions

	override func viewDidLoad() {
        super.viewDidLoad()
		nextButton.title = Text.Actions.next
		tableView.register(cell: LabelNumberCell.identifier)
		tableView.rowHeight = 60
		NotificationCenter.default.addObserver(self, selector: #selector(didSubmitSongServiceSettings), name: NotificationNames.didSubmitSongServiceSettings, object: nil)
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let tagsController = segue.destination.unwrap() as? WizzardSectionTagsController {
			if let songServiceObject = songServiceObject {
				tagsController.songServiceObject = songServiceObject
				if numberOfSections > songServiceObject.sections.count {
					for position in songServiceObject.sections.count..<numberOfSections {
						let section = CoreSongServiceSection.createEntityNOTsave()
						section.position = Int16(position)
						section.title = nil
						songServiceObject.addToHasSongServiceSections(section)
					}
				} else if numberOfSections < songServiceObject.sections.count {
					for _ in 1...(songServiceObject.sections.count - numberOfSections) {
						if let section = songServiceObject.sections.last {
							songServiceObject.removeFromHasSongServiceSections(section)
						}
					}
				}
			} else {
				songServiceObjectTemp = CoreSongServiceSettings.createEntityNOTsave()
				for position in 0..<numberOfSections {
					let section = CoreSongServiceSection.createEntityNOTsave()
					section.position = Int16(position)
					section.title = nil
					songServiceObjectTemp!.addToHasSongServiceSections(section)
				}
				tagsController.songServiceObject = songServiceObjectTemp
			}
		}
	}
	
	
	
	// MARK: - UITableView Functions
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: LabelNumberCell.identifier) as! LabelNumberCell
		let value = songServiceObject?.hasSongServiceSections?.count ?? 1
		cell.setup(initialValue: value, minLimit: 1, maxLimit: 15, positive: true)
		cell.descriptionTitle.text = Text.SongServiceManagement.numberOfSections
		cell.delegate = self
		return cell
	}
	
	// MARK: - Private Functions

	@objc private func didSubmitSongServiceSettings() {
		Queues.main.async {
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	
	// MARK: - LabelNumerCellDelegate Functions
	
	func numberChangedForCell(cell: LabelNumberCell) {
		numberOfSections = cell.value
	}

	
	
	// MARK: - IBAction Functions

	@IBAction func didPressCancel(_ sender: UIBarButtonItem) {
		if songServiceObject != nil {
			moc.rollback()
			mocBackground.rollback()
		}
		self.dismiss(animated: true)
	}
	
}

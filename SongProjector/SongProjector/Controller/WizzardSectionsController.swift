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
	
	
	private var songServiceObject: SongServiceSettings? = nil
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		numberOfSections = tableView.visibleCells.compactMap({ $0 as? LabelNumberCell }).first?.value ?? 1
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let tagsController = segue.destination.unwrap() as? WizzardSectionTagsController {
			songServiceObjectTemp = CoreSongServiceSettings.createEntityNOTsave()
			for position in 0..<numberOfSections {
				let section = CoreSongServiceSection.createEntityNOTsave()
				section.position = Int16(position)
				section.title = "Section \(position + 1)"
				songServiceObjectTemp!.addToHasSongServiceSections(section)
				section.hasTags = NSSet(array: CoreTag.getEntities())
			}
			tagsController.songServiceObject = songServiceObjectTemp
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
		self.dismiss(animated: true)
	}
	
}

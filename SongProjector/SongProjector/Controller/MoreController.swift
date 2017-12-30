//
//  MoreController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class MoreController: UITableViewController, UISplitViewControllerDelegate {
	
	
	// MARK: - Constants
	
	// MARK: - Properties
	
	/// De huidig geselecteerde feature in het meermenu.
	private(set) var selected : Feature?
	
	var features: [(feature: Feature, controller: UIViewController)] = []
	{
		didSet {
			update()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		splitViewController?.preferredDisplayMode = .allVisible
		features.forEach({ (arg) in
			let (_, controller) = arg
			splitViewController?.viewControllers.append(controller)
		})
		
		splitViewController?.delegate = self

		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setup()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table View
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return features.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		if let cell = cell as? BasicCell {
			let feature = features[indexPath.row].feature
			cell.setup(title: feature.titleForDisplay, icon: feature.image.normal)
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let controller = features[indexPath.row].controller
		controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		controller.navigationItem.leftItemsSupplementBackButton = true
		
		controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		controller.navigationItem.leftItemsSupplementBackButton = true
		
		let navController = UINavigationController.init(rootViewController: controller)
		showDetailViewController(navController, sender: self)
		
		UIView.animate(withDuration: 0.2) {
			self.splitViewController?.preferredDisplayMode = .primaryHidden
		}
		
	}

	
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		return true
	}
	
	private func setup() {
		tableView.register(cell: Cells.basicCellid)
	}
	
	private func update() {
		tableView.reloadData()
	}
}


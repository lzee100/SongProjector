//
//  MoreController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class MoreController: UISplitViewController {
	
	
	// MARK: - Constants
	
	private struct Constants {
		static let meerCell = "meerCell"
	}
	
	// MARK: - Properties
	
	/// De huidig geselecteerde feature in het meermenu.
	private(set) var selected : Feature?
	
	private var controllers : [Feature: UIViewController] = [:]
	
	var features: [(feature: Feature, controller: UIViewController)] = []
	{
		didSet {
			update()
		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		viewControllers = features.map({ $0.controller })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: UIViewController Functions
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		if let selection = tableView.indexPathForSelectedRow {
//			tableView.deselectRow(at: selection, animated: true)
//		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		selected = nil
		
	}
	
	
	
//	// MARK: - Table view data source
//	override func numberOfSections(in tableView: UITableView) -> Int {
//		// #warning Incomplete implementation, return the number of sections
//		return 1
//	}
//
//	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		// #warning Incomplete implementation, return the number of rows
//		return features.count
//	}
//
//	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		return getMenuCellFor(indexPath: indexPath)
//	}
//
//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		select(feature: features[indexPath.row].feature)
//	}
//
//	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//		if let cell = cell as? MeerCell {
//			cell.icon.tintColor = EduArteColors.tabbarGreyColor
//		}
//	}
//
//	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		return 60
//	}
	
	
	
	// MARK: - Private Functions
	
	private func update() {
//		tableView.reloadData()
	}
	
//	private func getMenuCellFor(indexPath: IndexPath) -> UITableViewCell {
//		let cell = tableView.dequeueReusableCell(withIdentifier: Constants.meerCell, for: indexPath)
//
//		if let cell = cell as? MeerCell {
//
//			let feature = features[indexPath.row].feature
//			cell.icon.image = feature.image.normal
//			cell.icon.highlightedImage = feature.image.selected
//			cell.titel.text = feature.titel
//		}
//		return cell
//	}
//
//	private func select(feature: Feature, animated: Bool = true) {
//		let feature = features.first{$0.feature == feature}
//
//		if
//			let feature = feature,
//			let navigationController = navigationController {
//			navigationController.pushViewController(feature.controller, animated: animated)
//		}
//
//		selected = feature?.feature
//
//	}
	
}

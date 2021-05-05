//
//  CalendarIdExplainController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class CalendarIdExplainController: ChurchBeamViewController, UITableViewDataSource, UITableViewDelegate {

    static let nav = "CalendarIdExplainControllerNav"

    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
        
    
    // MARK: - Types
    
    enum Row: String {
        case explainCalendarId
        case explainCalendarIdIV
        case hoverForDots
        case hoverForDotsIV
        case goToSettingsAndSharing
        case goToSettingsAndSharingIV
        case goToIntegrate
        case goToIntegrateIV
        case topShowsCalendarId
        case topShowsCalendarIdIV
        
        static let all = [explainCalendarId, explainCalendarIdIV, hoverForDots, hoverForDotsIV, goToSettingsAndSharing, goToSettingsAndSharingIV, goToIntegrate, goToIntegrateIV, topShowsCalendarId, topShowsCalendarIdIV]
        
        static func `for`(_ indexPath: IndexPath) -> Row {
            return all[indexPath.row]
        }
        
        var identifier: String {
            if self.rawValue.contains("IV") {
                return ExplainImageViewCell.identifier
            }
            return TextCell.identifier
        }
        
        var text: String {
            switch self {
            case .explainCalendarId: return AppText.Intro.explainCalendarId
            case .hoverForDots: return AppText.Intro.hoverForDots
            case .goToSettingsAndSharing: return AppText.Intro.goToSettingsAndSharing
            case .goToIntegrate: return AppText.Intro.goToIntegrate
            case .topShowsCalendarId: return AppText.Intro.topShowsCalendarId
            default: return ""
            }
        }
        
        var image: UIImage? {
            switch self {
            case .explainCalendarIdIV: return UIImage(named: "explainCalendarId")
            case .hoverForDotsIV: return UIImage(named: "hoverForDots")
            case .goToSettingsAndSharingIV: return UIImage(named: "goToSettingsAndSharing")
            case .goToIntegrateIV: return UIImage(named: "goToIntegrate")
            case .topShowsCalendarIdIV: return UIImage(named: "topShowsCalendarId")
            default: return nil
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    
    
    // MARK: - UITableViewDataSource Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath).identifier)
        (cell as? TextCell)?.setupWith(text: Row.for(indexPath).text)
        (cell as? TextCell)?.descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 18)
        if let image = Row.for(indexPath).image {
            (cell as? ExplainImageViewCell)?.setup(image: image)
        }
        return cell
    }
    
    private func setup() {
        title = AppText.Intro.titleFindCalendarId
        closeButton.title = AppText.Actions.close
        closeButton.tintColor = .orange
        tableView.register(cell: TextCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    override func update() {
        tableView.reloadData()
    }
    
    @IBAction func didPressClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
}


class ExplainImageViewCell: UITableViewCell {
    
    static let identifier = "ExplainImageViewCell"
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var explainImageView: UIImageView!
    
    func setup(image: UIImage) {
        explainImageView.image = image
        let ratio = image.size.height / image.size.width
        heightConstraint.constant = explainImageView.bounds.width * ratio
    }
    
}

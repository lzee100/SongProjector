//
//  AboutController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import MessageUI

class AboutController: ChurchBeamViewController {
        
    @IBOutlet var tableView: UITableView!
    
    
    // MARK: - Types
    
    enum Section {
        case about
        case contactInfo
        case contact
        
        static let all = [about, contactInfo, contact]
        
        static func `for`(_ section: Int) -> Section {
            return all[section]
        }
        
        static func nameFor(section: Int) -> String {
            switch Section.for(section) {
            case .about: return AppText.AboutController.sectionAbout
            case .contactInfo: return AppText.AboutController.sectionStartContact
            case .contact: return ""
            }
        }
        
        var height: CGFloat {
            switch self {
            case .contact: return 20
            default: return BasicHeaderView.height
            }
        }
        
    }
    
    enum Row: CaseIterable {
        case aboutTheApp
        case contactInfo
        case contact
        
                
        static func `for`(_ indexPath: IndexPath) -> Row {
            switch Section.for(indexPath.section) {
            case .about: return aboutTheApp
            case .contactInfo: return contactInfo
            case .contact: return contact
            }
        }
        
        var identifier: String {
            switch self {
            case .aboutTheApp, .contactInfo: return TextCell.identifier
            case .contact: return AddButtonCell.identifier
            }
        }
        
    }
    
    
    
    // MARK: - UIViewController Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    override func update() {
        tableView.reloadData()
    }
    
    
    
    // MARK: - Private Functions
    
    private func setup() {
        title = AppText.AboutController.title
        tableView.register(header: BasicHeaderView.identifier)
        tableView.register(cells: Row.allCases.map({ $0.identifier }))
    }
    
    fileprivate func openContactMail() {
        
        let device = SystemInfo.sharedInstance.device.name
        let version = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        let systemInfo = [device, version, appVersion].compactMap({ $0 }).joined(separator: "\n")
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["churchbeamnetherlands@gmail.com"])
            mail.setMessageBody("<p>\n\n\n\n\n" + systemInfo + "</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            show(message: AppText.AboutController.errorNoMail)
        }
        
        
    }
    
    
    // MARK: - Functions
    
    
    
    // MARK: - IBAction Functions
    
    
}

extension AboutController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
    }
    
}


extension AboutController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath).identifier)
        
        switch Row.for(indexPath) {
        case .aboutTheApp: (cell as? TextCell)?.descriptionLabel.text = AppText.AboutController.infoText
        case .contactInfo: (cell as? TextCell)?.descriptionLabel.text = AppText.AboutController.contactInfo
        case .contact: (cell as? AddButtonCell)?.apply(title: AppText.AboutController.contact)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let deleteView = tableView.subviews.compactMap({ $0.subviews }).first(where: { $0.contains(where: { $0 is BasicCell }) })?.first
        deleteView?.style(tableView: tableView, forRowAt: indexPath)
        return .none
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Row.for(indexPath) {
        case .contact: openContactMail()
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.basicHeaderView
        view?.descriptionLabel.text = Section.nameFor(section: section)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Section.for(section).height
    }
    
}


extension AboutController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith didFinishWithResult:MFMailComposeResult, error:Error?) {
        presentedViewController?.dismiss(animated: true)
    }

}

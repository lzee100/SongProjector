//
//  IntroAdminController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import FirebaseAuth

class IntroAdminController: PageController, UITableViewDataSource, UITableViewDelegate {
    
    static let identifier = "IntroAdminController"
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Types

    enum Section {
        case intro
        case newAdminCode
        case enterAdminCode
        case submitUser
        
        static let newAdminCodeSections = [intro, newAdminCode, submitUser]
        static let enterAdminCodeSections = [intro, enterAdminCode, submitUser]
        
        static func `for`(_ section: Int, enterAdminCode: Bool) -> Section {
            return enterAdminCode ? enterAdminCodeSections[section] : newAdminCodeSections[section]
        }
        
    }
    
    enum Row {
        case intro
        case calendarId
        case enterAdminCode
        case newAdminCode
        case submitUser
        
        static let sectionIntro = [intro, calendarId]
        
        static func `for`(_ indexPath: IndexPath, enterAdminCode: Bool) -> Row {
            switch Section.for(indexPath.section, enterAdminCode: enterAdminCode) {
            case .intro: return Row.sectionIntro[indexPath.row]
            case .newAdminCode: return newAdminCode
            case .enterAdminCode: return self.enterAdminCode
            case .submitUser: return submitUser
            }
        }
        
        var identifier: String {
            switch self {
            case .intro: return TextCell.identifier
            case .calendarId: return TextTextFieldCell.identifierExplain
            case .enterAdminCode: return TextTextFieldCell.identifier
            case .newAdminCode: return NewAdminCodeCell.identifier
            case .submitUser: return AddButtonCell.identifier
            }
        }
        
    }
    
    enum AdminCodeError: LocalizedError {
        case wrongCode
        
        var errorDescription: String? {
            return AppText.Intro.adminCodeWrong
        }
       
    }
    
    override var requesters: [RequesterBase] {
        return [UserSubmitter, AdminFetcher]
    }
    
    var user: VUser? = nil
    var hasUser = false
    var enteredAdminCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let user: User? = DataFetcher().getEntity(moc: moc)
//        self.user = [user].compactMap({ $0 }).compactMap({ VUser(user: $0, context: moc) }).first
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        tableView.register(cells: [TextCell.identifier, AddButtonCell.identifier])
    }
    
    
    // MARK: - UITableViewDataSource Functions
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.enterAdminCodeSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.for(section, enterAdminCode: hasUser) {
        case .intro: return Row.sectionIntro.count
        default: return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath, enterAdminCode: hasUser).identifier)
        
        switch Row.for(indexPath, enterAdminCode: hasUser) {
            
        case .intro:
            (cell as? TextCell)?.setupWith(text: AppText.Intro.loginWithChurchGoogle)
            (cell as? TextCell)?.descriptionLabel.font = UIFont(name: "AvenirNext-Regular", size: 18)
        case .calendarId:
            let explain = AppText.Intro.calendarIdExplain
            let find = AppText.Intro.calendarIdFindId
            (cell as? TextTextFieldCell)?.setup(description: explain, explainLabelText: find, textfieldDidChange: { [weak self] (calendarId) in
                self?.user?.googleCalendarId = calendarId
            }, didPressExplain: { [weak self] in
                self?.performSegue(withIdentifier: "explainCalendarId", sender: nil)
            })
            (cell as? TextTextFieldCell)?.textField.text = self.user?.googleCalendarId
            (cell as? TextTextFieldCell)?.explainLabel.attributedText = NSAttributedString(string: find, attributes: [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font : UIFont(name: "AvenirNext-Regular", size: 18) ?? UIFont(), NSAttributedString.Key.foregroundColor: UIColor.link])
        case .newAdminCode:
            (cell as? NewAdminCodeCell)?.setup(description: AppText.Intro.thisIsYourAdminCode, code: user?.adminCode ?? "")
            
        case .enterAdminCode:
            if user?.userUID == "IesLAdkvl6Q56HbP4IM7yzeq8Jx1" || user?.userUID == "q6sML4WtXrX3gP90UfyaIBUwQvH2" {
                (cell as? TextTextFieldCell)?.textField.text = user?.adminCode
            }
            (cell as? TextTextFieldCell)?.setup(description: AppText.Intro.adminEnterCode, explainLabelText: nil, textfieldDidChange: { [weak self] (adminCode) in
                self?.enteredAdminCode = adminCode
            })
            
        case .submitUser:
            (cell as? AddButtonCell)?.apply(title: AppText.Actions.done)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Row.for(indexPath, enterAdminCode: hasUser) {
        case .submitUser:
            guard let user = user else {
                show(message: AppText.Intro.couldNotFindUser)
                return
            }
            if enteredAdminCode != nil && enteredAdminCode != "", user.adminCode != enteredAdminCode {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                let textField = tableView.visibleCells.compactMap({ $0 as? TextTextFieldCell }).first?.textField
                textField?.shake()
                textField?.layer.borderColor = UIColor.red1.cgColor
                textField?.layer.borderWidth = 1
                show(message: AdminCodeError.wrongCode.localizedDescription)
            } else if enteredAdminCode != nil && enteredAdminCode != "", user.adminCode == enteredAdminCode {
                user.adminInstallTokenId = UserDefaults.standard.string(forKey: ApplicationIdentifier)!
                tableView.isUserInteractionEnabled = false
                UserSubmitter.submit([user], requestMethod: .put)
            } else {
                tableView.isUserInteractionEnabled = false
                UserSubmitter.submit([user], requestMethod: .post)
            }
        default: return
        }
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        tableView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInset
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
//        self.user = [user].compactMap({ $0 }).map({ VUser(user: $0, context: moc) }).first
        hasUser = user != nil
        if user == nil {
            let user = VUser()
            user.appInstallTokens = [UserDefaults.standard.string(forKey: ApplicationIdentifier)!]
            user.pilotStartDate = Date()
            user.userUID = Auth.auth().currentUser?.uid ?? ""
            var code = ""
            repeat {
                code += "\(Int.random(in: 0...9))"
            } while code.length < 6
            user.adminCode = code
            user.adminInstallTokenId = user.appInstallTokens.first
            self.user = user
        }
        tableView.reloadData()
    }
    
    override func handleRequestFinish(requesterId: String, result: Any?) {
        if requesterId == AdminFetcher.id {
            NotificationCenter.default.post(name: .newUserCompletion, object: nil)
            AdminFetcher.removeObserver(self)
        } else {
            AdminFetcher.fetch()
        }
    }
    
    override func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        Queues.main.async {
            self.tableView.isUserInteractionEnabled = true
            self.hideLoader()
            switch result {
            case .failed(let error):
                if requester.id == AdminFetcher.id {
                    self.handleRequestFinish(requesterId: requester.id, result: result)
                } else {
                    self.show(error)
                }
            case .success(let result):
                if requester.id == AdminFetcher.id, (result as? [VAdmin])?.count ?? 0 > 0 {
                    UserDefaults.standard.set("true", forKey: secretKey)
                }
                self.handleRequestFinish(requesterId: requester.id, result: result)
            }
        }
    }
    
}


class TextTextFieldCell: ChurchBeamCell {
    
    static let identifier = "TextTextFieldCell"
    static let identifierExplain = "TextExplainTextFieldCell"
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var explainLabel: UILabel!
    @IBOutlet var textField: UITextField!

    private var textfieldDidChange: ((String?) -> Void)?
    private var didPressExplain: (() -> Void)?
   
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    func setup(description: String, explainLabelText: String?, textfieldDidChange: @escaping ((String?) -> Void), didPressExplain: (() -> Void)? = nil) {
        descriptionLabel.text = description
        explainLabel?.text = explainLabelText
        self.textfieldDidChange = textfieldDidChange
        self.didPressExplain = didPressExplain
    }
    
    @objc private func textFieldDidChange() {
        textfieldDidChange?(textField.text)
    }
    
    @IBAction func didPressExplain(_ sender: UIButton) {
        didPressExplain?()
    }
    
}

class NewAdminCodeCell: ChurchBeamCell {
    
    static let identifier = "NewAdminCodeCell"
    
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var codeLabel: UILabel!
    
    func setup(description: String, code: String) {
        descriptionLabel.text = description
        codeLabel.text = code
    }

}

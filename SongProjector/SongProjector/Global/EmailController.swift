//
//  EmailController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import MessageUI
class EmailController: NSObject, MFMailComposeViewControllerDelegate {
    public static let shared = EmailController()
    private override init() { }
    
    func sendEmail(subject:String, body:String, to:String? = nil){
        // Check if the device is able to send emails
        if !MFMailComposeViewController.canSendMail() {
           print("This device cannot send emails.")
           return
        }
        // Create the email composer
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients([to].compactMap { $0 })
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(body, isHTML: false)
        EmailController.getRootViewController()?.present(mailComposer, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        EmailController.getRootViewController()?.dismiss(animated: true, completion: nil)
    }
    
    static func getRootViewController() -> UIViewController? {
        // In SwiftUI 2.0
        UIApplication.shared.windows.first?.rootViewController
    }
}

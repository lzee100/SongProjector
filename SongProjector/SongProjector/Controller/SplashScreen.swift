//
//  SplashScreen.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseAuth

// authentication proces

// 1: check for user in local storage
// 2: if user found, update data and start app
// 3: if not found, check usertoken and appId
// 4: if correct: fetch user and start app
// 5: if incorrect: show message has install other phone

class SplashScreen: ChurchBeamViewController {
    
    
    var introNav: UIViewController? = nil
    var viewDidAppearIsCalled = false
        
    override var shouldRemoveObserversOnDissappear: Bool {
        return false
    }
    
    private var user: User? {
        let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
        return user
    }
    
    private var isRegistered: Bool {
        if user == nil {
            return false
        }
        return Auth.auth().currentUser != nil && (Auth.auth().currentUser?.uid == user?.userUID)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(checkAccountStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAccountStatus), name: .authenticated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAccountStatus), name: .signedOut, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .newUserCompletion, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearIsCalled = true
        checkAccountStatus()
    }
    
    @objc func checkAccountStatus(){
        guard viewDidAppearIsCalled else { return }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound])
        { (_,_) in
        }
        Queues.main.async {
            if self.isRegistered {
                self.update()
            } else {
                self.showIntro()
            }
        }
    }
    
    @objc override func update() {
        if isRegistered {
            func after() {
                introNav = nil
                if Thread.isMainThread {
                    self.performSegue(withIdentifier: "showApp", sender: nil)
                } else {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showApp", sender: nil)
                    }
                }
            }
            if let introNav = introNav {
                introNav.dismiss(animated: true, completion: {
                    after()
                })
            } else {
                after()
            }
        } else {
            let entities: [Entity] = DataFetcher().getEntities(moc: moc)
            entities.forEach({ moc.delete($0) })
            do {
                try moc.save()
            } catch {
                print(error)
            }
            
            showIntro()
            
        }
    }
    
    func showIntro() {
        guard presentedViewController == nil else { return }
        introNav = Storyboard.Intro.instantiateViewController(withIdentifier: "IntroPageViewContainerNav")
        guard let introNav = introNav else { return }
        let controller = introNav.unwrap() as? IntroPageViewContainer
        controller?.setup(controllers: IntroPageViewContainer.introControllers())
        introNav.modalPresentationStyle = .fullScreen
        self.present(introNav, animated: true, completion: nil)
    }
    
}

extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
    
    var intValue: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded()) // in miliseconds
    }
}

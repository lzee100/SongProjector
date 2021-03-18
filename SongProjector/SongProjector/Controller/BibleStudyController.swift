//
//  BibleStudyController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol BibleStudyGeneratorDelegate {
	func didFinishBibleStudyGeneratorWith(sheets: [Sheet])
}

class BibleStudyController: ChurchBeamViewController, BibleStudyGeneratorDelegate {
	
	
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "bibleStudyMenuSegue" {
			let controller = segue.destination as! SheetPickerMenuController
			controller.bibleStudyGeneratorDelegate = self
		}
		
    }
	
	
	
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
        }
    }
    
	
	
	func didFinishBibleStudyGeneratorWith(sheets: [Sheet]) {
		
		
	}
	
	
	

}

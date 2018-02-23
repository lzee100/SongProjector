//
//  BibleStudyController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol BibleStudyGeneratorDelegate {
	func didFinishBibleStudyGeneratorWith(sheets: [Sheet])
}

class BibleStudyController: UIViewController, BibleStudyGeneratorDelegate {
	
	
	
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "bibleStudyMenuSegue" {
			let controller = segue.destination as! SheetPickerMenuController
			controller.bibleStudyGeneratorDelegate = self
		}
		
    }
	
	
	
	
	
	func didFinishBibleStudyGeneratorWith(sheets: [Sheet]) {
		
		
	}
	
	
	

}

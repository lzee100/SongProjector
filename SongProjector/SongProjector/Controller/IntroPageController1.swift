//
//  IntroController1.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class IntroPageController1: PageController {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var ContentLabel: UILabel!
		
	static let identifier = "IntroPageController1"
	
	override func viewDidLoad() {
        super.viewDidLoad()
		titleLabel.text = AppText.Intro.IntroHalloTitle
		ContentLabel.text = AppText.Intro.IntroHalloContent
		titleLabel.textColor = .whiteColor
		ContentLabel.textColor = .whiteColor
		view.backgroundColor = .blackColor
        
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if(event?.subtype == UIEvent.EventSubtype.motionShake) {
            let alert = UIAlertController(title: nil, message: "Selecteer omgeving:", preferredStyle: .actionSheet)
            let actions = Environment.allValues.map({ environment in
                UIAlertAction(title: environment.name, style: .default) { (_) in
                    Queues.main.async {
                        ChurchBeamConfiguration.environment = environment
                        environment.loadGoogleFile()
                    }
                }
            })
            actions.forEach({ alert.addAction($0) })
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
            alert.popoverPresentationController?.permittedArrowDirections = []
            present(alert, animated: true)
        }
    }
    
}

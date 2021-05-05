//
//  UploadUniTimesController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/01/2021.
//  Copyright © 2021 iozee. All rights reserved.
//

import UIKit

class UploadUniTimesController: ChurchBeamViewController {

    @IBOutlet var textView: UITextView!
    @IBOutlet var closeButton: UIBarButtonItem!
    
    var cluster: VCluster?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.title = AppText.Actions.done
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textView.text = cluster?.hasSheets.filter({ $0.time != 0.0 }).compactMap({ $0.time.stringValue }).joined(separator: "\n") ?? ""
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let times = textView.text.split(separator: "\n").compactMap({ Double($0) })
        guard times.count == (cluster?.hasSheets ?? []).count else {
            show(message: "Het aantal tijden zijn niet geljjk aan het aantal sheets.")
            return
        }
        for (index, sheet) in (cluster?.hasSheets ?? [] ).enumerated() {
            sheet.time = times[index]
        }
        
    }

    @IBAction func didPressClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

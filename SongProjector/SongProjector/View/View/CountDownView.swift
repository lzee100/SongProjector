//
//  CountDownView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26/08/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class CountDownView : UIView {
    
    @IBOutlet private var contentView:UIView?
    @IBOutlet weak var countDownLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        countDownLabel?.textColor = UIColor(hex: "000000")
        countDownLabel?.shadowColor = UIColor(hex: "FFFFFF")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CountDownView", owner: self, options: nil)
        guard let content = contentView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
        countDownLabel?.textColor = UIColor(hex: "000000")
        countDownLabel?.shadowColor = UIColor(hex: "FFFFFF")
    }
}

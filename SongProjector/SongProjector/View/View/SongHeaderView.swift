//
//  SongHeaderView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 12-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit


class SongHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "SongHeaderView"
    
    static func preferredHeight(hasSection: Bool) -> CGFloat {
        let sectionHeight: CGFloat = 40 + 10
        let basic: CGFloat = 16 + 25 + 10 + (hasSection ? 0 : 8)
        return hasSection ? (sectionHeight + basic) : basic
    }

    @IBOutlet var sectionLabelBackgroundView: UIView!
    @IBOutlet var sectionLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var sectionButton: ActionButton!
    @IBOutlet var actionContainerView: UIView!
    @IBOutlet var pianoImageView: UIImageView!
    @IBOutlet var mixerView: MixerAnimationView!
    @IBOutlet var actionButton: ActionButton!
    
    @IBOutlet var sectionLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var sectionLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var titleLabelToSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var titleLabelToActionViewConstraint: NSLayoutConstraint!
    @IBOutlet var titleLabelTopToSectionLabelConstraint: NSLayoutConstraint!

    enum RightConstraint {
        case superView
        case actionContainer
    }
    
	private var isSelected = false
    
    var hasHeader = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sectionLabel.isHidden = true
        hasHeader = false
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func style() {
        sectionLabelBackgroundView.backgroundColor = .grey0
        sectionLabel.font = .xxNormalBold
        titleLabel.font = .normalBold
        actionContainerView.backgroundColor = .softBlueGrey
        actionContainerView.layer.cornerRadius = 4
        actionContainerView.clipsToBounds = true
        pianoImageView.tintColor = .whiteColor
        sectionLabel.isHidden = true
        sectionLabel.textColor = .blackColor
        sectionLabelHeightConstraint.constant = 0
        sectionLabelTopConstraint.constant = 0
        titleLabelTopToSectionLabelConstraint.constant = 18
    }
	
	func setup(title: String?, isSelected: Bool = false, hasPianoSolo: Bool) {
		self.isSelected = isSelected
		self.titleLabel.text = title
		self.actionButton.isEnabled = hasPianoSolo
		self.actionContainerView.isHidden = !hasPianoSolo
		self.pianoImageView.isHidden = !hasPianoSolo
        setTitleRightConstraint(to: hasPianoSolo ? .actionContainer : .superView)        
		update()
	}
	
	func update() {
        mixerView.mixerColor = .white
        titleLabel.textColor = isSelected ? .white : .blackColor
        sectionLabelBackgroundView.backgroundColor = isSelected ? .softBlueGrey : .grey0
        actionContainerView.backgroundColor = isSelected ? .white : .softBlueGrey
        self.pianoImageView.tintColor = isSelected ? .black : .white
	}
	
    func setPianoAction(isPlaying: Bool) {
        if isPlaying {
            pianoImageView.isHidden = true
            mixerView.isHidden = false
            mixerView.play()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.pianoImageView.isHidden = false
                self?.mixerView.isHidden = true
            }
            mixerView.stop()
        }
    }
    
    private func setTitleRightConstraint(to: RightConstraint) {
        titleLabelToSuperViewConstraint.priority = UILayoutPriority(rawValue: 250)
        titleLabelToActionViewConstraint.priority = UILayoutPriority(rawValue: 250)
        
        switch to {
        case .superView: titleLabelToSuperViewConstraint.priority = UILayoutPriority(rawValue: 999)
        case .actionContainer: titleLabelToActionViewConstraint.priority = UILayoutPriority(rawValue: 999)
        }
    }
	
	func set(sectionHeader: String) {
        hasHeader = true
        sectionLabelTopConstraint.constant = 10
        sectionLabelHeightConstraint.constant = 30
        titleLabelTopToSectionLabelConstraint.constant = 10
		sectionLabel.isHidden = false
		sectionLabel.text = sectionHeader
	}
	
}

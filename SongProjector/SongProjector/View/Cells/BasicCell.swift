//
//  BasicCell.swift
//  SongViewer
//
//  Created by Leo van der Zee on 04-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

class BasicCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var seperator: UIView!
    @IBOutlet var actionContainer: UIView!
    @IBOutlet var optionImageView: UIImageView!
    @IBOutlet var selectionView: UIView!
    
    @IBOutlet var titleLeftConstraint: NSLayoutConstraint!
    @IBOutlet var titleToOptionImageViewConstraint: NSLayoutConstraint!
    @IBOutlet var optionImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var optionImageViewRightConstraint: NSLayoutConstraint!
    
    @IBOutlet var actionContainerWidthConstraint: NSLayoutConstraint!
    
    var iconImage: UIImage?
    var iconSelected: UIImage?
    var selectionColor: UIColor? = nil
    var selectedCell = false { didSet { update() } }
    var isInnerCell = false { didSet { update() } }
    var customTextColor: UIColor?
    var data: Any?
    
    static let identifier = "BasicCell"
        
    override func prepareForReuse() {
        super.prepareForReuse()
        data = nil
        actionContainer.isHidden = true
        actionContainer.subviews.forEach({ $0.removeFromSuperview() })
        optionImageViewWidthConstraint.constant = 0
        optionImageViewRightConstraint.constant = 0
        optionImageView.image = nil
        optionImageView.isHidden = true
        titleToOptionImageViewConstraint.constant = 0
        actionContainerWidthConstraint.constant = 0
        actionContainer.isHidden = true
        selectionColor = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        actionContainer.isHidden = true
        actionContainer.layer.cornerRadius = 4
        actionContainer.clipsToBounds = true
        optionImageViewWidthConstraint.constant = 0
        optionImageViewRightConstraint.constant = 0
        optionImageView.image = nil
        optionImageView.isHidden = true
        optionImageView.tintColor = .blackColor
        titleToOptionImageViewConstraint.constant = 0
        actionContainerWidthConstraint.constant = 0
        actionContainer.isHidden = true
        title.font = .xNormal
        selectionView.layer.cornerRadius = selectionView.bounds.width / 2
    }
    
    func setup(data: Any? = nil, title: String?, textColor: UIColor? = nil) {
        self.data = data
        self.customTextColor = textColor
        self.title.text = title
        update()
    }
    
    private func update() {
        seperator.backgroundColor = .clear
        if selectedCell {
            title.textColor = selectionColor ?? .softBlueGrey
        } else {
            title.textColor = customTextColor ?? .blackColor
        }
        title.font = selectedCell ? .xNormalBold : .xNormal
        selectionView.backgroundColor = selectionColor ?? .softBlueGrey
        selectionView.isHidden = !selectedCell
        setOption()
    }
    
    func setAction(icon: UIImage?, buttonBackgroundColor: UIColor?, isUserinteractionEnabled: Bool = true, iconColor: UIColor = .white, action: @escaping (() -> Void)) {
        actionContainerWidthConstraint.constant = 70
        layoutIfNeeded()
        let button = ActionButton(frame: actionContainer.bounds)
        button.add(action: action)
        if let icon = icon {
            button.setImage(icon, for: UIControl.State())
        }
        button.tintColor = iconColor
        actionContainer.isHidden = false
        actionContainer.addSubview(button)
        actionContainer.backgroundColor = buttonBackgroundColor
    }
    
    func animatePlaying() {
        actionContainer.subviews.filter({ !($0 is UIButton) }).forEach({ $0.removeFromSuperview() })
        actionContainer.subviews.filter({ $0 is UIButton }).forEach({ $0.tintColor = .clear })
        let width = actionContainer.bounds.width * 0.4
        let height = actionContainer.bounds.height * 0.6
        let frame = CGRect(x: (actionContainer.bounds.width - width) / 2 , y: (actionContainer.bounds.height - height) / 2, width: width, height: height)
        let mixerView = MixerAnimationView(frame: frame, mixerColor: themeHighlighted)
        mixerView.play()
        actionContainer.addSubview(mixerView)
        actionContainer.sendSubviewToBack(mixerView)
    }
    
    func setProgress(progres: Double) {
        let width: CGFloat = actionContainer.bounds.width * CGFloat(progres)
        guard let progressView = actionContainer.subviews.compactMap({ $0 as? ProgressBackgroundView }).first else {
            let progressView = ProgressBackgroundView(frame: CGRect(x: 0, y: 0, width: width, height: actionContainer.bounds.height))
            progressView.backgroundColor = .grey2
            actionContainer.addSubview(progressView)
            actionContainer.sendSubviewToBack(progressView)
            return
        }
        progressView.frame = CGRect(x: 0, y: 0, width: width, height: actionContainer.bounds.height)
        
    }
    
    func finishProgress() {
        actionContainer.subviews.first(where: { $0 is UIButton })?.removeFromSuperview()
        let check = CheckView(frame: CGRect(x: (actionContainer.bounds.width / 2) - 12.5, y: (actionContainer.bounds.height / 2) - 12.5, width: 25, height: 25))
        
        actionContainer.addSubview(check)
        if let progresView = actionContainer.subviews.first(where: { $0 is ProgressBackgroundView }) {
            actionContainer.sendSubviewToBack(progresView)
        }
        check.drawLine(skipAnimation: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.removeAction()
            self?.tableView?.reloadData()
        }
    }
    
    func removeAction() {
        self.actionContainer.isHidden = true
        self.actionContainer.subviews.forEach({ $0.removeFromSuperview() })
        self.actionContainerWidthConstraint.constant = 0
        setOption()
    }
    
    func setOption() {
        if let cluster = data as? VCluster, cluster.hasLocalMusic {
            titleToOptionImageViewConstraint.constant = 8
            optionImageViewWidthConstraint.constant = 25
            optionImageViewRightConstraint.constant = 8
            optionImageView.isHidden = false
            let iconName = cluster.hasInstruments.contains(where: {
                if case .pianoSolo = $0.type { return true } else { return false}
            }) ? "Piano" : "Drumsss"
            optionImageView.image = UIImage(named: iconName)
        } else if let cluster = data as? VCluster, cluster.time > 0.0 {
            titleToOptionImageViewConstraint.constant = 8
            optionImageViewWidthConstraint.constant = 25
            optionImageViewRightConstraint.constant = 8
            optionImageView.isHidden = false
            optionImageView.image = UIImage(named: "Repeat")
        } else {
            optionImageViewWidthConstraint.constant = 0
            optionImageViewRightConstraint.constant = 8
            optionImageView.image = nil
            optionImageView.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    }
    
    func flash() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.contentView.backgroundColor = .blackColor
        }) { (_) in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.contentView.backgroundColor = themeWhiteBlackBackground
            })
        }
    }
    
}

private class ProgressBackgroundView: UIView {
    
}

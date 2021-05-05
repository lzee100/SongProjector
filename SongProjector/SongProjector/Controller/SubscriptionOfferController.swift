//
//  SubscriptionOfferController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionOfferController: ChurchBeamViewController {
    
    static let identifier = "SubscriptionOfferController"

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var buttonLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var actionButton: ActionButton!
    @IBOutlet var tableView: UITableView!
    
    private var intro = ""
    private var features: [(UIImage, String)] = []
    
    
    enum Section: CaseIterable {
        case intro
        case features
        case additionalInfo
        
        static func `for`(_ section: Int) -> Section {
            return allCases[section]
        }
        
        var identifier: String {
            switch self {
            case .intro, .additionalInfo: return FeatureDescriptionCell.identifier
            case .features: return FeatureCell.identifier
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setCornerRadius(corners: .allCorners, radius: 10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cells: [FeatureCell.identifier])
        tableView.backgroundColor = .clear
        titleLabel.font = .xxxLargeBold
        buttonLabel.font = .xNormalBold
        buttonView.layer.cornerRadius = 8
        buttonView.backgroundColor = themeHighlighted
        [titleLabel, buttonLabel].forEach({ $0?.textColor = .white })
        backgroundImageView.alpha = 0.5
        view.backgroundColor = .clear
        view.clipsToBounds = true
    }
    
    func apply(product: SKProduct, action: @escaping ActionButton.Action) {
        titleLabel.text = product.localizedTitle
        features = []
        if product.productIdentifier == "beam" {
            intro = AppText.Intro.featureIntro(price: (product.priceLocale.currencySymbol ?? "€") + " " + product.price.stringValue + " ")
            backgroundImageView.image = UIImage(named: "BeamSubscriptionBackgroundImage")
            let icons = [UIImage(named: "Theme-1"), UIImage(named: "Sheet"), UIImage(named: "Automatic"), UIImage(named: "Google-1")].compactMap({ $0 })
            for (index, description) in AppText.Intro.featuresBeam.enumerated() {
                features.append((icons[index], description))
            }
        } else {
            intro = AppText.Intro.featureIntro(price: (product.priceLocale.currencySymbol ?? "€") + " " + product.price.stringValue + " ")
            backgroundImageView.image = UIImage(named: "SongSubscriptionBackgroundImage")
            let icons = [UIImage(named: "Theme-1"), UIImage(named: "Sheet"), UIImage(named: "Automatic"), UIImage(named: "Music"), UIImage(named: "Mixer"), UIImage(named: "Google-1")].compactMap({ $0 })
            for (index, description) in AppText.Intro.featuresSong.enumerated() {
                features.append((icons[index], description))
            }
        }
        tableView.reloadData()
        buttonLabel.text = AppText.Intro.subscribe
        actionButton.add(action: action)
    }
    
    func addVisualEffectView(container: UIView) {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.frame = container.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = 1
        container.clipsToBounds = true
        container.addSubview(effectView)
    }
    
}

extension SubscriptionOfferController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.for(section) {
        case .intro: return 1
        case .features: return features.count
        case .additionalInfo: return 1
        }
    }
    
}

extension SubscriptionOfferController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: Section.for(indexPath.section).identifier)
        switch Section.for(indexPath.section) {
        case .intro:
            (cell as? FeatureDescriptionCell)?.apply(text: intro)
            return cell
        case .features:
            (cell as? FeatureCell)?.apply(description: features[indexPath.row].1, icon: features[indexPath.row].0)
            return cell
        case .additionalInfo:
            (cell as? FeatureDescriptionCell)?.apply(text: AppText.Intro.cancelMonthly)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
}

extension SubscriptionOfferController {
    class func SubscriptionsControllers(products: [SKProduct]) -> [SubscriptionOfferController] {
        let controller1 = Storyboard.MainStoryboard.instantiateViewController(identifier: "SubscriptionOfferController") as! SubscriptionOfferController
        let controller2 = Storyboard.MainStoryboard.instantiateViewController(identifier: "SubscriptionOfferController") as! SubscriptionOfferController
        
        let controllers = [controller1, controller2]
        for (index, product) in products.enumerated() {
            controllers[index].apply(product: product, action: {
                print("did select action: \(product.productIdentifier)")
            })
        }
        return controllers
    }
}


class FeatureDescriptionCell: ChurchBeamCell {
    
    static let identifier = "FeatureDescriptionCell"
   
    @IBOutlet var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.font = .normal
        descriptionLabel.textColor = .white
        backgroundColor = .clear
    }
    
    func apply(text: String) {
        descriptionLabel.text = text
    }
    
}

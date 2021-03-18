//
//  IntroController2.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class IntroPageController2: PageController, UICollectionViewDataSource, UICollectionViewDelegate {

	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!
	@IBOutlet var collectionView: UICollectionView!
	
	@IBOutlet var titleRightConstraint: NSLayoutConstraint!
	@IBOutlet var contentLeftConstraint: NSLayoutConstraint!
	
	
	static let identifier = "IntroPageController2"
	
    var hasContracts: [VContract] = {
        let contracts: [Contract] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "id", ascending: true))
        return contracts.compactMap({ VContract(contract: $0, context: moc) })
    }()
    
//    override var requesters: [RequesterBase] {
//        return [ContractFetcher]
//    }
	
	override func viewDidLoad() {
        super.viewDidLoad()
//		ContractFetcher.addObserver(self)
		titleRightConstraint.constant = view.bounds.width
		contentLeftConstraint.constant = -view.bounds.width
		titleLabel.alpha = 0
		contentLabel.alpha = 0
		collectionView.alpha = 0
		if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
			flowLayout.estimatedItemSize = CGSize(width: 200,height: 300)
			flowLayout.minimumLineSpacing = 20
			flowLayout.minimumInteritemSpacing = 0
			flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		}
		titleLabel.textColor = .blackColor
		contentLabel.textColor = .blackColor
		view.backgroundColor = .blackColor
		collectionView.backgroundColor = .blackColor
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
//		ContractFetcher.fetch(locale: "NL")
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		titleLabel.alpha = 1
		contentLabel.alpha = 1
		titleRightConstraint.constant = 40
		
		UIView.animate(withDuration: 0.7, animations: {
			self.view.layoutIfNeeded()
		}) { _ in
			self.contentLeftConstraint.constant = 40
			UIView.animate(withDuration: 0.7, animations: {
				self.view.layoutIfNeeded()
			}, completion: { _ in
				UIView.animate(withDuration: 0.7, animations: {
					self.collectionView.alpha = 1
				})
			})
		}

	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return hasContracts.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AboOptionCell.identifier, for: indexPath) as! AboOptionCell
		cell.apply(contract: hasContracts[indexPath.row])
		cell.backgroundWidthConstraint.constant = collectionView.bounds.width
		cell.buttonWidthConstraint.constant = collectionView.bounds.width * 0.7
		cell.layoutIfNeeded()
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let contract = hasContracts[indexPath.row]

        signInContractSelection.contract = contract
		performSegue(withIdentifier: "showSignUpController", sender: contract)
	}
	
	override func handleRequestFinish(requesterId: String, result: Any?) {
		Queues.main.async {
			self.collectionView.reloadData()
		}
	}
}

class AboOptionCell: UICollectionViewCell {
	
	@IBOutlet var backgroundColorView: UIView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var features: UILabel!
	@IBOutlet var buttonLabel: UILabel!
	@IBOutlet var buttonWidthConstraint: NSLayoutConstraint!
	@IBOutlet var backgroundWidthConstraint: NSLayoutConstraint!
	
	static let identifier = "AboOptionCell"
	
	private var contract: VContract?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		translatesAutoresizingMaskIntoConstraints = true
		backgroundColorView.layer.cornerRadius = 10
		backgroundColorView.layer.cornerRadius = 10
		backgroundColorView.backgroundColor = themeHighlighted
		titleLabel.textColor = .blackColor
		features.textColor = .blackColor
		buttonLabel.textColor = .blackColor
		buttonLabel.backgroundColor = UIColor.blue
		buttonLabel.layer.cornerRadius = 10
		buttonLabel.clipsToBounds = true
	}
	
	fileprivate func apply(contract: VContract) {
		self.contract = contract
		titleLabel.text = contract.name
//		if let cfeatures = contract.hasRcontractFeaturesOrdered {
//			features.text = cfeatures.compactMap{ $0.content }.joined(separator: "\n")
//		}
		buttonLabel.text = contract.buttonContent
	}
	
}

//enum ContractType: String, CaseIterable {
//	case free
//	case beam
//	case song
//	
//	var title: String {
//		switch self {
//		case .free: return AppText.Intro.FreeTitle
//		case .beam: return AppText.Intro.BeamTitle
//		case .song: return AppText.Intro.SongTitle
//		}
//	}
//	
//	var features: String {
//		switch self {
//		case .free: return AppText.Intro.FreeFeatures
//		case .beam: return AppText.Intro.BeamFeatures
//		case .song: return AppText.Intro.SongFeatures
//		}
//	}
//	
//	var buttonText: String {
//		switch self {
//		case .free: return AppText.Intro.FreeButton
//		case .beam: return AppText.Intro.BeamButton
//		case .song: return AppText.Intro.SongButton
//		}
//	}
//    
//    init(string: String?) {
//        if let contractType = ContractType.allCases.first(where: { $0.rawValue == string }) {
//            self = contractType
//        } else {
//            self = .free
//        }
//    }
//}

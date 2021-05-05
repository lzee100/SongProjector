//
//  SubscriptionOffersContainerController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionOffersContainerController: ChurchBeamViewController {

    static let identifier = "SubscriptionOffersContainerController"
    
    @IBOutlet var collectionView: UICollectionView!
    
    fileprivate var beamController: SubscriptionOfferController = {
        let vc = Storyboard.MainStoryboard.instantiateViewController(identifier: SubscriptionOfferController.identifier) as! SubscriptionOfferController
        return vc
    }()
    fileprivate var songController: SubscriptionOfferController = {
        let vc = Storyboard.MainStoryboard.instantiateViewController(identifier: SubscriptionOfferController.identifier) as! SubscriptionOfferController
        return vc
    }()
    fileprivate var controllers: [SubscriptionOfferController] {
        return [songController, beamController]
    }
    fileprivate var products: [SKProduct] = []
    fileprivate var manager: IAPManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = IAPManager(delegate: self, sharedSecret: "0269d507736f44638d69284ad77f2ba7")
        self.showLoader()
        view.backgroundColor = UIColor(hex: "#141414")
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = view.bounds.size
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = view.bounds.width * 0.05
        collectionView.collectionViewLayout = makeLayout()
    }
    
    func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            return self.buildGallerySectionLayout(size: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .fractionalHeight(1.0)))
        }
        return layout
    }

    
    func buildGallerySectionLayout(size: NSCollectionLayoutSize, itemInset:NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 0.0, leading: 0, bottom: 0.0, trailing: 12.0), sectionInset: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 20.0, leading: 20.0, bottom: 20.0, trailing: 0.0)) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = itemInset
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = sectionInset
        section.orthogonalScrollingBehavior = .paging
        return section
    }

}

extension SubscriptionOffersContainerController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubscriptionCell.identifier, for: indexPath) as! SubscriptionCell
        cell.subviews.first?.removeFromSuperview()
        return cell
    }
    
}

extension SubscriptionOffersContainerController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let controller = controllers[indexPath.row]
        controller.view.frame = cell.bounds
        cell.addSubview(controller.view)
        controller.view.layer.cornerRadius = 10
        self.addChild(controller)
        controller.didMove(toParent: self)
        controller.apply(product: products[indexPath.row]) {
            self.manager.purchaseProduct(product: self.products[indexPath.row])
        }
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: cell.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            controller.view.leftAnchor.constraint(equalTo: cell.leftAnchor),
            controller.view.widthAnchor.constraint(equalToConstant: cell.bounds.width)
        ])
        controller.view.layoutIfNeeded()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        controllers[indexPath.row].view.removeFromSuperview()
        controllers[indexPath.row].willMove(toParent: nil)
        controllers[indexPath.row].removeFromParent()
    }
    
}

extension SubscriptionOffersContainerController: IAPManagerDelegate {
    
    func didFetchProducts(products: [SKProduct]) {
        hideLoader()
        self.products = products
        collectionView.reloadData()
    }
    
    func didRefreshReceipt(products: [(IAPProduct, Date)]) {
        if let product = products.first, product.1.isAfter(Date()) {
            self.dismiss(animated: true)
        }
    }
    
    func failure(_ error: IAPError) {
        show(message: error.localizedDescription)        
    }
    
}



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
    private(set) var sectionTitle: String?
    private(set) var title: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 8
    }
    
    func buildHeader(sectionTitle: String?, title: String?, cluster: VCluster, isSelected: Bool, onSectionClick: @escaping ActionButton.Action, onPianoSoloClick: @escaping ActionButton.Action, isPianoSoloPlaying: Bool) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        let headerView = SongServiceHeaderView(sectionTitle: sectionTitle, title: title, cluster: cluster, isSelected: isSelected, onSectionClick: onSectionClick, onPianoSoloClick: onPianoSoloClick, isPianoSoloPlaying: isPianoSoloPlaying)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        headerView.anchorToSuperView()
        clipsToBounds = true
        layer.masksToBounds = true
        self.sectionTitle = sectionTitle
        self.title = title
    }
}

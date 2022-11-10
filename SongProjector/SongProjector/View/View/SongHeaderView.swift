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
    
    private let songServiceHeaderView = SongServiceHeaderView(frame: .zero)
    var isPianoOnlyEnabled = false
    var sectionTitle: String? {
        songServiceHeaderView.sectionText
    }
    var sectionHeaderText: String? {
        songServiceHeaderView.sectionHeaderText
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        songServiceHeaderView.reset()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(title: String?, isSelected: Bool = false, hasPianoSolo: Bool, sectionAction: @escaping ActionButton.Action, pianoButtonAction: @escaping ActionButton.Action) {
        if hasPianoSolo {
            songServiceHeaderView.showPianoOption()
            if isSelected {
                songServiceHeaderView.stopPlaying()
            }
        }
        isPianoOnlyEnabled = hasPianoSolo
        songServiceHeaderView.setup(title: title ?? "", sectionAction: sectionAction, pianoButtonAction: pianoButtonAction)
        songServiceHeaderView.updateSelected(isSongPlaying: isSelected)
    }
    
    func set(sectionHeader: String) {
        songServiceHeaderView.setHeader(title: sectionHeader)
    }
    
    func set(cluster: VCluster) {
        if cluster.hasLocalMusic {
            songServiceHeaderView.setInstruments(cluster.hasInstruments)
        }
    }
    
    func setPianoAction(isPlaying: Bool) {
        if isPlaying {
            songServiceHeaderView.startPlay()
        } else {
            songServiceHeaderView.stopPlaying()
        }
    }

    private func setup() {
        contentView.addSubview(songServiceHeaderView)
        songServiceHeaderView.translatesAutoresizingMaskIntoConstraints = false
        songServiceHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        songServiceHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        songServiceHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        songServiceHeaderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }


}

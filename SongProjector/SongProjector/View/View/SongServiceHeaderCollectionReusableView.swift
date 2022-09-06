//
//  SongServiceHeaderCollectionReusableView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class SongServiceHeaderCollectionReusableView: UICollectionReusableView {

    static let identifier = "SongServiceHeaderCollectionReusableView"
    
    @IBOutlet var sectionBackgroundView: UIView!
    @IBOutlet var sectionLabel: UILabel!
    @IBOutlet var actionButton: ActionButton!
    
    var pianoButton: ActionButton!
    private var pianoPlayView: UIImageView!
    private var pianoAnimationView: MixerAnimationView!
    
    private var buttonLeadingAnchor = NSLayoutConstraint()
    private var buttonTrailingAnchor = NSLayoutConstraint()
    private var buttonBottomAnchor = NSLayoutConstraint()
    private var buttonTopAnchor = NSLayoutConstraint()
    private var buttonHeightAnchor = NSLayoutConstraint()
    private var buttonWidthAnchor = NSLayoutConstraint()
    private var labelBottomConstraint = NSLayoutConstraint()
    private var labelTrailingConstraint = NSLayoutConstraint()
    private var instrumentButtonsView: InstrumentsButtonsView?
    
    var data: AnyObject? {
        didSet {
            if let cluster = data as? VCluster, cluster.hasLocalMusic  {
                setInstruments(cluster.hasInstruments)
            }
        }
    }
    var isPlaying = false
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pianoButton.isHidden = true
        setSelected(isSelected: false)
        instrumentButtonsView?.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sectionBackgroundView.layer.cornerRadius = 5
        pianoButton.layer.cornerRadius = 5
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sectionLabel.textColor = .blackColor
        pianoButton = ActionButton()
        pianoPlayView = UIImageView(image: UIImage(named: "Piano"))
        pianoPlayView.tintColor = .white
        pianoAnimationView = MixerAnimationView(frame: CGRect.zero, mixerColor: .white)
        addSubview(pianoButton)
        pianoButton.addSubview(pianoPlayView)
        pianoButton.addSubview(pianoAnimationView)
        [pianoPlayView, pianoAnimationView, pianoButton].forEach({ $0?.translatesAutoresizingMaskIntoConstraints = false })
        pianoPlayView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        pianoPlayView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        pianoPlayView.centerXAnchor.constraint(equalTo: pianoButton.centerXAnchor).isActive = true
        pianoPlayView.centerYAnchor.constraint(equalTo: pianoButton.centerYAnchor).isActive = true
        pianoButton.isHidden = true
        pianoButton.backgroundColor = .softBlueGrey
        pianoAnimationView.isHidden = true
        buttonLeadingAnchor = pianoButton.leadingAnchor.constraint(equalTo: leadingAnchor)
        buttonTopAnchor = pianoButton.topAnchor.constraint(equalTo: topAnchor)
        buttonWidthAnchor = pianoButton.widthAnchor.constraint(equalToConstant: 80)
        buttonHeightAnchor = pianoButton.heightAnchor.constraint(equalToConstant: 40)
        buttonBottomAnchor = pianoButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        buttonTrailingAnchor = pianoButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        [buttonBottomAnchor, buttonTrailingAnchor].forEach({ $0.isActive = true })
        
        pianoAnimationView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        pianoAnimationView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        pianoAnimationView.centerXAnchor.constraint(equalTo: pianoButton.centerXAnchor).isActive = true
        pianoAnimationView.centerYAnchor.constraint(equalTo: pianoButton.centerYAnchor).isActive = true
        
        updatePianoButtonConstraints()
    }
    
    func setup(title: String, action: @escaping ActionButton.Action) {
        sectionLabel.text = title
        actionButton.add(action: action)
    }
    
    func setInstruments(_ instruments: [VInstrument]) {
        guard !instruments.contains(where: { $0.type == .pianoSolo }) else { return }
        let instrumentButtonsView = InstrumentsButtonsView(instruments: instruments)
        instrumentButtonsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(instrumentButtonsView)
        bringSubviewToFront(instrumentButtonsView)
        instrumentButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2).isActive = true
        instrumentButtonsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 2).isActive = true
        instrumentButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2).isActive = true
        instrumentButtonsView.heightAnchor.constraint(equalToConstant: bounds.height / 3).isActive = true
        self.instrumentButtonsView = instrumentButtonsView
    }
    
    func updatePianoButtonConstraints() {
        labelTrailingConstraint.isActive = false
        labelBottomConstraint.isActive = false
        if UIDevice.current.orientation.isPortrait {
            labelTrailingConstraint = sectionLabel.trailingAnchor.constraint(equalTo: pianoButton.leadingAnchor, constant: -10)
            labelBottomConstraint = sectionLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -10)
        } else {
            labelTrailingConstraint = sectionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            labelBottomConstraint = sectionLabel.bottomAnchor.constraint(equalTo: pianoButton.topAnchor, constant: -10)
        }
        labelTrailingConstraint.isActive = true
        labelBottomConstraint.isActive = true

        buttonLeadingAnchor.isActive = !UIDevice.current.orientation.isPortrait
        buttonTopAnchor.isActive = UIDevice.current.orientation.isPortrait
        buttonWidthAnchor.isActive = UIDevice.current.orientation.isPortrait
        buttonHeightAnchor.isActive = !UIDevice.current.orientation.isPortrait
    }
    
    func setSelected(isSelected: Bool) {
        sectionBackgroundView.backgroundColor = isSelected ? .softBlueGrey : .grey1
        pianoButton.backgroundColor = isSelected ? .white : .softBlueGrey
        pianoPlayView.tintColor = isSelected ? .softBlueGrey : .white
    }
    
    func showPianoOption() {
        pianoButton.isHidden = false
    }
    
    func startPlay() {
        isPlaying = true
        updatePlayer()
    }
    
    func stopPlaying() {
        isPlaying = false
        updatePlayer()
    }
    
    private func updatePlayer() {
        pianoAnimationView.isHidden = !isPlaying
        pianoPlayView.isHidden = isPlaying
        if isPlaying {
            pianoAnimationView.play()
        } else {
            pianoAnimationView.stop()
        }
    }
    

}

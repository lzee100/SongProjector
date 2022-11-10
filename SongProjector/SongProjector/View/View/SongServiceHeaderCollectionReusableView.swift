//
//  SongServiceHeaderCollectionReusableView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class SongServiceHeaderView: UIView {
    
    private let stackView = UIStackView()
    private let sectionBackgroundView = UIView(frame: .zero)
    private let sectionHeaderLabel = UILabel()
    
    private lazy var sectionHeaderLabelContainer: UIView = {
        let view = UIView()
        view.addSubview(sectionHeaderLabel)
        sectionHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionHeaderLabel.anchorToSuperView(insets: UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 10))
        view.isHidden = true
        return view
    }()
    private let sectionLabel = UILabel()
    private let selectSectionButton: ActionButton = ActionButton()
    private lazy var selectionLabel: UIView = {
        let view = UIView()
        [sectionLabel, selectSectionButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
            if $0 == sectionLabel {
                $0.anchorToSuperView(insets: UIEdgeInsets(top: 0, left: UIDevice.current.userInterfaceIdiom == .pad ? 10 : 30, bottom: 0, right: 10))
            } else {
                $0.anchorToSuperView(insets: .zero)
            }
        }
        return view
    }()
    private let pianoButton = ActionButton()
    private let pianoImageView = UIImageView(image: UIImage(named: "Piano"))
    private let pianoAnimationView = MixerAnimationView(frame: .zero, mixerColor: .white)
    private lazy var instrumentsButtonsViewContainer: UIStackView = {
        let stackview = UIStackView(frame: .zero)
        stackview.axis = .vertical
        stackview.distribution = .fill
        let spacerView = UIView(frame: .zero)
        spacerView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        let spacerView2 = UIView(frame: .zero)
        spacerView2.heightAnchor.constraint(equalToConstant: 10).isActive = true
        [spacerView, instrumentButtonsView, spacerView2].forEach { stackview.addArrangedSubview($0) }
        return stackview
    }()
    private lazy var pianoContainerView: UIView = {
        let view = UIView()
        [pianoButton, pianoImageView, pianoAnimationView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        pianoButton.anchorToSuperView(insets: .zero)
        pianoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        pianoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pianoPlayViewBottomConstraint = pianoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        pianoPlayViewTopConstraint = pianoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
        pianoPlayViewLeadingConstraint = pianoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        pianoPlayViewTrailingConstraint = pianoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        pianoImageView.widthAnchor.constraint(equalTo: pianoImageView.heightAnchor).isActive = true
        pianoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true

        pianoAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pianoAnimationViewTopConstraint = pianoAnimationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
        pianoAnimationViewBottomConstraint = pianoAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        pianoAnimationViewLeadingConstraint = pianoAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
        pianoAnimationViewTrailingConstraint = pianoAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        pianoAnimationView.widthAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
        pianoAnimationView.heightAnchor.constraint(equalTo: pianoAnimationView.widthAnchor).isActive = true

        return view
    }()
    private var instrumentButtonsView = InstrumentsButtonsView(instruments: [])
    private var stackViewBottomConstraint = NSLayoutConstraint()
    private var pianoPlayViewLeadingConstraint = NSLayoutConstraint()
    private var pianoPlayViewTrailingConstraint = NSLayoutConstraint()
    private var pianoAnimationViewLeadingConstraint = NSLayoutConstraint()
    private var pianoAnimationViewTrailingConstraint = NSLayoutConstraint()
    private var pianoPlayViewTopConstraint = NSLayoutConstraint()
    private var pianoPlayViewBottomConstraint = NSLayoutConstraint()
    private var pianoAnimationViewTopConstraint = NSLayoutConstraint()
    private var pianoAnimationViewBottomConstraint = NSLayoutConstraint()
    private var sectionHeaderLabelContainerHeightConstraint = NSLayoutConstraint()
    private var isPad = UIDevice.current.userInterfaceIdiom == .pad
    var data: AnyObject? {
        didSet {
            if let cluster = data as? VCluster, cluster.hasLocalMusic  {
                setInstruments(cluster.hasInstruments)
            }
        }
    }
    var isPlaying = false
    var isPortrait: Bool { UIDevice.current.orientation.isPortrait }
    var sectionHeaderText: String? {
        get {
            return sectionHeaderLabel.text
        }
        set {
            sectionHeaderLabelContainer.isHidden = newValue == nil
            sectionHeaderLabel.text = newValue
        }
    }
    var sectionText: String? {
        return sectionLabel.text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
        sectionBackgroundView.layer.cornerRadius = 5
        pianoButton.layer.cornerRadius = 5
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(sectionBackgroundView)
        addSubview(sectionHeaderLabelContainer)
        addSubview(stackView)
        clipsToBounds = true
        [sectionHeaderLabelContainer, sectionBackgroundView, stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.axis = isPortrait ? .horizontal : .vertical
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: isPad ? 0 : 2).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: sectionHeaderLabelContainer.bottomAnchor, constant: isPad ? 0 : 10).isActive = true
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: isPortrait ? -10 : 0)
        stackViewBottomConstraint.isActive = true
        pianoAnimationView.isUserInteractionEnabled = false
        sectionBackgroundView.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        sectionBackgroundView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        sectionBackgroundView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0).isActive = true
        sectionBackgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
        sectionHeaderLabelContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        sectionHeaderLabelContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        sectionHeaderLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sectionHeaderLabelContainerHeightConstraint = sectionHeaderLabelContainer.heightAnchor.constraint(equalToConstant: 0)
        sectionHeaderLabelContainerHeightConstraint.isActive = true
        [selectionLabel].forEach { stackView.addArrangedSubview($0) }
        [instrumentsButtonsViewContainer, pianoContainerView].forEach { $0.isHidden = true }
        
        selectionLabel.setContentHuggingPriority(UILayoutPriority(200), for: .horizontal)
        instrumentsButtonsViewContainer.setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)
        pianoContainerView.setContentHuggingPriority(UILayoutPriority(400), for: .horizontal)
        selectionLabel.setContentHuggingPriority(UILayoutPriority(200), for: .vertical)
        instrumentsButtonsViewContainer.setContentHuggingPriority(UILayoutPriority(300), for: .vertical)
        pianoContainerView.setContentHuggingPriority(UILayoutPriority(400), for: .vertical)
        
        sectionHeaderLabel.numberOfLines = 0
        sectionHeaderLabel.textColor = .blackColor
        sectionHeaderLabel.font = .xxNormalBold
        sectionLabel.textColor = .blackColor
        sectionLabel.numberOfLines = 0
        sectionLabel.font = .normalBold
        sectionLabel.textAlignment = UIDevice.current.userInterfaceIdiom == .pad ? .center : .left
        pianoImageView.tintColor = .white
        pianoButton.backgroundColor = .softBlueGrey
        
        updateConstraintsActivation()

    }
    
    func reset() {
        let isPorTrait = UIDevice.current.orientation.isPortrait
        stackView.axis = isPorTrait ? .horizontal : .vertical
        stackViewBottomConstraint.constant = isPorTrait ? -10 : 0
        instrumentsButtonsViewContainer.isHidden = true
        pianoContainerView.isHidden = true
        pianoImageView.isHidden = false
        updateSelected(isSongPlaying: false)
        updateConstraintsActivation()
        sectionHeaderLabelContainer.isHidden = true
        sectionHeaderLabelContainerHeightConstraint.constant = 0
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
        stackView.subviews.forEach { $0.removeFromSuperview() }
        [selectionLabel].forEach { stackView.addArrangedSubview($0) }
    }
    
    func setup(title: String, sectionAction: @escaping ActionButton.Action, pianoButtonAction: @escaping ActionButton.Action) {
        sectionLabel.text = title
        selectSectionButton.add(action: sectionAction)
        pianoButton.add(action: pianoButtonAction)
    }
    
    func setInstruments(_ instruments: [VInstrument]) {
        guard !instruments.contains(where: { $0.type == .pianoSolo }) else {
            instrumentsButtonsViewContainer.isHidden = true
            return
        }
        stackView.addArrangedSubview(instrumentsButtonsViewContainer)
        instrumentsButtonsViewContainer.arrangedSubviews.forEach { view in
            if view !== instrumentButtonsView {
                view.isHidden = !isPortrait
            }
        }
        instrumentButtonsView.apply(instruments: instruments)
        instrumentsButtonsViewContainer.isHidden = false
    }
    
    func updateSelected(isSongPlaying: Bool) {
        sectionBackgroundView.backgroundColor = isSongPlaying ? .softBlueGrey : .grey1
        pianoButton.backgroundColor = isSongPlaying ? .white : .softBlueGrey
        pianoImageView.tintColor = isSongPlaying ? .softBlueGrey : .white
    }
    
    func showPianoOption() {
        stackView.removeArrangedSubview(instrumentsButtonsViewContainer)
        stackView.addArrangedSubview(pianoContainerView)
        stackViewBottomConstraint.constant = isPortrait ? -10 : -2
        pianoContainerView.isHidden = false
    }
    
    func startPlay() {
        isPlaying = true
        updatePlayer()
    }
    
    func stopPlaying() {
        isPlaying = false
        updatePlayer()
    }
    
    func setHeader(title: String?) {
        sectionHeaderLabelContainer.isHidden = title == nil
        sectionHeaderLabelContainer.subviews.forEach { $0.isHidden = title == nil }
        sectionHeaderLabel.text = title
        
        var height: CGFloat = 0
        if let sectionHeight = title?.height(withConstrainedWidth: sectionHeaderLabel.bounds.width, font: sectionLabel.font) {
            height = sectionHeight + 10 + 10
        }
        sectionHeaderLabelContainerHeightConstraint.constant = height
    }
    
    private func updatePlayer() {
        pianoAnimationView.isHidden = !isPlaying
        pianoImageView.isHidden = isPlaying
        if isPlaying {
            pianoAnimationView.play()
        } else {
            pianoAnimationView.stop()
        }
        updateSelected(isSongPlaying: false)
    }
    
    private func updateConstraintsActivation() {
        pianoPlayViewLeadingConstraint.isActive = isPortrait
        pianoPlayViewTrailingConstraint.isActive = isPortrait
        pianoAnimationViewLeadingConstraint.isActive = isPortrait
        pianoAnimationViewTrailingConstraint.isActive = isPortrait
        pianoPlayViewTopConstraint.isActive = isPortrait
        pianoPlayViewBottomConstraint.isActive = isPortrait
        pianoAnimationViewTopConstraint.isActive = !isPortrait
        pianoAnimationViewBottomConstraint.isActive = true
    }

}

class SongServiceHeaderCollectionReusableViewOne: UICollectionReusableView {
    
    static let identifier = "SongServiceHeaderCollectionReusableViewOne"
    
    private let songServiceHeaderView = SongServiceHeaderView(frame: .zero)
    
    var data: AnyObject? {
        didSet {
            songServiceHeaderView.data = data
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        songServiceHeaderView.reset()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(songServiceHeaderView)
        songServiceHeaderView.translatesAutoresizingMaskIntoConstraints = false
        songServiceHeaderView.anchorToSuperView()
    }
    
    func setup(title: String, sectionAction: @escaping ActionButton.Action, pianoButtonAction: @escaping ActionButton.Action) {
        songServiceHeaderView.setup(title: title, sectionAction: sectionAction, pianoButtonAction: pianoButtonAction)
    }
    
    func setInstruments(_ instruments: [VInstrument]) {
        songServiceHeaderView.setInstruments(instruments)
    }
    
    func updateSelected(isSongPlaying: Bool) {
        songServiceHeaderView.updateSelected(isSongPlaying: isSongPlaying)
    }
    
    func showPianoOption() {
        songServiceHeaderView.showPianoOption()
    }
    
    func startPlay() {
        songServiceHeaderView.startPlay()
    }
    
    func stopPlaying() {
        songServiceHeaderView.stopPlaying()
    }
}

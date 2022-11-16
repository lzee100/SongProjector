//
//  SongServiceHeaderCollectionReusableView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class SongServiceHeaderView: UIStackView {

    private let backgroundView = UIView(frame: .zero)
    private let sectionAndTitleView: SongServiceSectionHeaderTitleStackView
    private lazy var pianosoloButton: PianoSoloButtonView = {
        PianoSoloButtonView(iconInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), equalizerInsets: UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5), action: pianoSoloAction, isPianoSoloPlaying: isPianoSoloPlaying)
    }()
    private let instrumentButtonsView: InstrumentsButtonsViewContainer
    
    private lazy var verticalInstrumentButtonsViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = UIDevice.current.userInterfaceIdiom == .pad ? .zero : NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 15
        return stackView
    }()
    
    private lazy var vertDemo: UIView = {
        let container = UIView(frame: .zero)
        [container, instrumentButtonsView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        container.addSubview(instrumentButtonsView)
        instrumentButtonsView.anchorTo(container, insets: UIEdgeInsets(top: sectionAndTitleView.getHeightForTitleFont() + 15, left: 0, bottom: 0, right: 0))
        return container
    }()
    
    private let sectionTitleSpacerInstrumentsButtonsView = UIView()
    private var isPortrait: Bool { UIDevice.current.orientation.isPortrait }
    private let isPad = UIDevice.current.userInterfaceIdiom == .pad
    private let cluster: VCluster
    private let pianoSoloAction: ActionButton.Action
    private let isPianoSoloPlaying: Bool
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
    }

    init(sectionTitle: String?, title: String?, cluster: VCluster, isSelected: Bool, onSectionClick: @escaping ActionButton.Action, onPianoSoloClick: @escaping ActionButton.Action, isPianoSoloPlaying: Bool) {
        self.cluster = cluster
        self.pianoSoloAction = onPianoSoloClick
        let rightInset: CGFloat = UIDevice.current.orientation.isPortrait ? 10 : -2
        let leftInset: CGFloat = UIDevice.current.orientation.isPortrait ? 0 : -2
        let sectionTitleInsets: UIEdgeInsets = UIDevice.current.userInterfaceIdiom == .pad ? .zero : UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 20)
        sectionAndTitleView = SongServiceSectionHeaderTitleStackView(sectionTitle: sectionTitle, title: title, action: onSectionClick, insets: sectionTitleInsets)
        instrumentButtonsView = InstrumentsButtonsViewContainer(insets: UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset), instruments: cluster.hasInstruments)
        self.isPianoSoloPlaying = isPianoSoloPlaying
        super.init(frame: .zero)
        updateHeader(isSelected: isSelected)
        let hasPianoSolo = cluster.hasPianoSolo && cluster.hasLocalMusic
        pianosoloButton.isHidden = !hasPianoSolo || UIDevice.current.userInterfaceIdiom != .pad
        let hasInstruments = cluster.hasLocalMusic && !cluster.hasPianoSolo
        instrumentButtonsView.isHidden = !hasInstruments
        sectionTitleSpacerInstrumentsButtonsView.isHidden = sectionTitle == nil
        
        [sectionAndTitleView, pianosoloButton].filter { !$0.isHidden }.forEach { view in
            addArrangedSubview(view)
        }
        
        if UIDevice.current.userInterfaceIdiom != .pad, hasPianoSolo {
            addSubview(pianosoloButton)
            pianosoloButton.translatesAutoresizingMaskIntoConstraints = false
            pianosoloButton.topAnchor.constraint(equalTo: sectionAndTitleView.titleLabel.topAnchor).isActive = true
            pianosoloButton.trailingAnchor.constraint(equalTo: sectionAndTitleView.titleLabel.trailingAnchor).isActive = true
            pianosoloButton.bottomAnchor.constraint(equalTo: sectionAndTitleView.titleLabel.bottomAnchor).isActive = true
            pianosoloButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            pianosoloButton.isHidden = false
            pianosoloButton.clipsToBounds = true
            pianosoloButton.layer.masksToBounds = true
            pianosoloButton.layer.cornerRadius = 8
        }
        
        if !instrumentButtonsView.isHidden {
            if sectionTitle == nil {
                addArrangedSubview(instrumentButtonsView)
            } else {
                addArrangedSubview(vertDemo)
            }
        }

        //        if sectionTitle != nil {
//            sectionTitleSpacerInstrumentsButtonsView.translatesAutoresizingMaskIntoConstraints = false
//            verticalInstrumentButtonsViewContainer.addArrangedSubview(sectionTitleSpacerInstrumentsButtonsView)
//            sectionTitleSpacerInstrumentsButtonsView.heightAnchor.constraint(equalToConstant: sectionAndTitleView.getHeightForTitleFont()).isActive = true
//        }
//        verticalInstrumentButtonsViewContainer.addArrangedSubview(instrumentButtonsView)
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        
        sectionAndTitleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        sectionAndTitleView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        pianosoloButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        pianosoloButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        verticalInstrumentButtonsViewContainer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        verticalInstrumentButtonsViewContainer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        sectionAndTitleView.setContentHuggingPriority(UILayoutPriority(100), for: .horizontal)
        pianosoloButton.setContentHuggingPriority(UILayoutPriority(800), for: .horizontal)
        verticalInstrumentButtonsViewContainer.setContentHuggingPriority(UILayoutPriority(900), for: .horizontal)
        sectionAndTitleView.setContentHuggingPriority(UILayoutPriority(100), for: .vertical)
        pianosoloButton.setContentHuggingPriority(UILayoutPriority(800), for: .vertical)
        verticalInstrumentButtonsViewContainer.setContentHuggingPriority(UILayoutPriority(900), for: .vertical)
        
        axis = isPortrait ? .horizontal : .vertical
        distribution = .fill
        alignment = .fill
        spacing = 10
        
        addSubview(backgroundView)
        backgroundView.layer.cornerRadius = 8
        sendSubviewToBack(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        if !sectionAndTitleView.isHidden {
            backgroundView.topAnchor.constraint(equalTo: sectionAndTitleView.titleLabel.topAnchor, constant: -10).isActive = true
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: sectionAndTitleView.titleLabel.bottomAnchor, constant: 10).isActive = true
        } else {
            backgroundView.anchorToSuperView(insets: .zero)
        }
    }
    
    func updateHeader(isSelected: Bool) {
        backgroundView.backgroundColor = isSelected ? .softBlueGrey : .grey1
        pianosoloButton.isColorInverted(isSelected)
    }
}


//class SongServiceHeaderView: UIView {
//
//    private let stackView = UIStackView()
//    private let sectionBackgroundView = UIView(frame: .zero)
//    private let sectionHeaderLabel = UILabel()
//
//    private lazy var sectionHeaderLabelContainer: UIView = {
//        let view = UIView()
//        view.addSubview(sectionHeaderLabel)
//        sectionHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
//        sectionHeaderLabel.anchorToSuperView(insets: UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 10))
//        view.isHidden = true
//        return view
//    }()
//    private let sectionLabel = UILabel()
//    private let selectSectionButton: ActionButton = ActionButton()
//    private lazy var selectionLabel: UIView = {
//        let view = UIView()
//        [sectionLabel, selectSectionButton].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview($0)
//            if $0 == sectionLabel {
//                $0.anchorToSuperView(insets: UIEdgeInsets(top: 0, left: UIDevice.current.userInterfaceIdiom == .pad ? 10 : 30, bottom: 0, right: 10))
//            } else {
//                $0.anchorToSuperView(insets: .zero)
//            }
//        }
//        return view
//    }()
//    private let pianoButton = ActionButton()
//    private let pianoImageView = UIImageView(image: UIImage(named: "Piano"))
//    private let pianoAnimationView = MixerAnimationView(frame: .zero, mixerColor: .white)
//    private lazy var pianoContainerView: UIView = {
//        let view = UIView()
//        [pianoButton, pianoImageView, pianoAnimationView].forEach {
//            view.addSubview($0)
//            $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//        pianoButton.anchorToSuperView(insets: .zero)
//        pianoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        pianoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        pianoPlayViewBottomConstraint = pianoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
//        pianoPlayViewTopConstraint = pianoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
//        pianoPlayViewLeadingConstraint = pianoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
//        pianoPlayViewTrailingConstraint = pianoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
//        pianoImageView.widthAnchor.constraint(equalTo: pianoImageView.heightAnchor).isActive = true
//        pianoImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
//
//        pianoAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        pianoAnimationViewTopConstraint = pianoAnimationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10)
//        pianoAnimationViewBottomConstraint = pianoAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
//        pianoAnimationViewLeadingConstraint = pianoAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
//        pianoAnimationViewTrailingConstraint = pianoAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
//        pianoAnimationView.widthAnchor.constraint(lessThanOrEqualToConstant: 40).isActive = true
//        pianoAnimationView.heightAnchor.constraint(equalTo: pianoAnimationView.widthAnchor).isActive = true
//
//        return view
//    }()
//    private var instrumentButtonsView = InstrumentsButtonsView(instruments: [])
//    private var stackViewBottomConstraint = NSLayoutConstraint()
//    private var pianoPlayViewLeadingConstraint = NSLayoutConstraint()
//    private var pianoPlayViewTrailingConstraint = NSLayoutConstraint()
//    private var pianoAnimationViewLeadingConstraint = NSLayoutConstraint()
//    private var pianoAnimationViewTrailingConstraint = NSLayoutConstraint()
//    private var pianoPlayViewTopConstraint = NSLayoutConstraint()
//    private var pianoPlayViewBottomConstraint = NSLayoutConstraint()
//    private var pianoAnimationViewTopConstraint = NSLayoutConstraint()
//    private var pianoAnimationViewBottomConstraint = NSLayoutConstraint()
//    private var sectionHeaderLabelContainerHeightConstraint = NSLayoutConstraint()
//    private var instrumentButtonsViewWidth = NSLayoutConstraint()
//    private var isPad = UIDevice.current.userInterfaceIdiom == .pad
//    var data: AnyObject? {
//        didSet {
//            if let cluster = data as? VCluster, cluster.hasLocalMusic  {
//                setInstruments(cluster.hasInstruments)
//            }
//        }
//    }
//    var isPlaying = false
//    var isPortrait: Bool { UIDevice.current.orientation.isPortrait }
//    var sectionHeaderText: String? {
//        get {
//            return sectionHeaderLabel.text
//        }
//        set {
//            sectionHeaderLabelContainer.isHidden = newValue == nil
//            sectionHeaderLabel.text = newValue
//        }
//    }
//    var sectionText: String? {
//        return sectionLabel.text
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        layer.cornerRadius = 5
//        sectionBackgroundView.layer.cornerRadius = 5
//        pianoButton.layer.cornerRadius = 5
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: .zero)
//        setup()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func setup() {
//        addSubview(sectionBackgroundView)
//        addSubview(sectionHeaderLabelContainer)
//        addSubview(stackView)
//        clipsToBounds = true
//        [sectionHeaderLabelContainer, sectionBackgroundView, stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
//        stackView.distribution = .fill
//        stackView.alignment = .fill
//        stackView.spacing = 10
//        stackView.axis = isPortrait ? .horizontal : .vertical
//        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: isPad ? 0 : 2).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        stackView.topAnchor.constraint(equalTo: sectionHeaderLabelContainer.bottomAnchor, constant: isPad ? 0 : 10).isActive = true
//        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: isPortrait ? -10 : 0)
//        stackViewBottomConstraint.isActive = true
//        pianoAnimationView.isUserInteractionEnabled = false
//        sectionBackgroundView.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
//        sectionBackgroundView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
//        sectionBackgroundView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 0).isActive = true
//        sectionBackgroundView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
//        sectionHeaderLabelContainer.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        sectionHeaderLabelContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
//        sectionHeaderLabelContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        sectionHeaderLabelContainerHeightConstraint = sectionHeaderLabelContainer.heightAnchor.constraint(equalToConstant: 0)
//        sectionHeaderLabelContainerHeightConstraint.isActive = true
//        [selectionLabel].forEach { stackView.addArrangedSubview($0) }
//        [instrumentButtonsView, pianoContainerView].forEach { $0.isHidden = true }
//        instrumentButtonsViewWidth = instrumentButtonsView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4)
//        selectionLabel.setContentHuggingPriority(UILayoutPriority(200), for: .horizontal)
//        pianoContainerView.setContentHuggingPriority(UILayoutPriority(400), for: .horizontal)
//        selectionLabel.setContentHuggingPriority(UILayoutPriority(200), for: .vertical)
//        pianoContainerView.setContentHuggingPriority(UILayoutPriority(400), for: .vertical)
//
//        sectionHeaderLabel.numberOfLines = 0
//        sectionHeaderLabel.textColor = .blackColor
//        sectionHeaderLabel.font = .xxNormalBold
//        sectionLabel.textColor = .blackColor
//        sectionLabel.numberOfLines = 0
//        sectionLabel.font = .normalBold
//        sectionLabel.textAlignment = UIDevice.current.userInterfaceIdiom == .pad ? .center : .left
//        pianoImageView.tintColor = .white
//        pianoButton.backgroundColor = .softBlueGrey
//
//        updateConstraintsActivation()
//
//    }
//
//    func reset() {
//        let isPorTrait = UIDevice.current.orientation.isPortrait
//        stackView.axis = isPorTrait ? .horizontal : .vertical
//        stackViewBottomConstraint.constant = isPorTrait ? -10 : 0
//        instrumentButtonsView.isHidden = true
//        pianoContainerView.isHidden = true
//        pianoImageView.isHidden = false
//        updateSelected(isSongPlaying: false)
//        updateConstraintsActivation()
//        sectionHeaderLabelContainer.isHidden = true
//        instrumentButtonsViewWidth.isActive = false
//        sectionHeaderLabelContainerHeightConstraint.constant = 0
//        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }
//        stackView.subviews.forEach { $0.removeFromSuperview() }
//        [selectionLabel].forEach { stackView.addArrangedSubview($0) }
//    }
//
//    func setup(title: String, sectionAction: @escaping ActionButton.Action, pianoButtonAction: @escaping ActionButton.Action) {
//        sectionLabel.text = title
//        selectSectionButton.add(action: sectionAction)
//        pianoButton.add(action: pianoButtonAction)
//    }
//
//    func setInstruments(_ instruments: [VInstrument]) {
//        guard !instruments.contains(where: { $0.type == .pianoSolo }) else {
//            instrumentButtonsView.isHidden = true
//            return
//        }
//        stackView.addArrangedSubview(instrumentButtonsView)
//        instrumentButtonsViewWidth.isActive = !isPad
//        instrumentButtonsView.apply(instruments: instruments)
//        instrumentButtonsView.isHidden = false
//    }
//
//    func updateSelected(isSongPlaying: Bool) {
//        sectionBackgroundView.backgroundColor = isSongPlaying ? .softBlueGrey : .grey1
//        pianoButton.backgroundColor = isSongPlaying ? .white : .softBlueGrey
//        pianoImageView.tintColor = isSongPlaying ? .softBlueGrey : .white
//    }
//
//    func showPianoOption() {
//        stackView.removeArrangedSubview(instrumentButtonsView)
//        stackView.addArrangedSubview(pianoContainerView)
//        instrumentButtonsViewWidth.isActive = false
//        stackViewBottomConstraint.constant = isPortrait ? -10 : -2
//        pianoContainerView.isHidden = false
//    }
//
//    func startPlay() {
//        isPlaying = true
//        updatePlayer()
//    }
//
//    func stopPlaying() {
//        isPlaying = false
//        updatePlayer()
//    }
//
//    func setHeader(title: String?) {
//        sectionHeaderLabelContainer.isHidden = title == nil
//        sectionHeaderLabelContainer.subviews.forEach { $0.isHidden = title == nil }
//        sectionHeaderLabel.text = title
//
//        var height: CGFloat = 0
//        if let sectionHeight = title?.height(withConstrainedWidth: sectionHeaderLabel.bounds.width, font: sectionLabel.font) {
//            height = sectionHeight + 10 + 10
//        }
//        sectionHeaderLabelContainerHeightConstraint.constant = height
//    }
//
//    private func updatePlayer() {
//        pianoAnimationView.isHidden = !isPlaying
//        pianoImageView.isHidden = isPlaying
//        if isPlaying {
//            pianoAnimationView.play()
//        } else {
//            pianoAnimationView.stop()
//        }
//        updateSelected(isSongPlaying: false)
//    }
//
//    private func updateConstraintsActivation() {
//        pianoPlayViewLeadingConstraint.isActive = isPortrait
//        pianoPlayViewTrailingConstraint.isActive = isPortrait
//        pianoAnimationViewLeadingConstraint.isActive = isPortrait
//        pianoAnimationViewTrailingConstraint.isActive = isPortrait
//        pianoPlayViewTopConstraint.isActive = isPortrait
//        pianoPlayViewBottomConstraint.isActive = isPortrait
//        pianoAnimationViewTopConstraint.isActive = !isPortrait
//        pianoAnimationViewBottomConstraint.isActive = true
//    }
//
//}

class SongServiceHeaderCollectionReusableViewOne: UICollectionReusableView {
    
    static let identifier = "SongServiceHeaderCollectionReusableViewOne"
    
    private var songServiceHeaderView: SongServiceHeaderView?
    
    var data: AnyObject?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 8
    }
    
    func buildHeader(sectionTitle: String?, title: String?, cluster: VCluster, isSelected: Bool, onSectionClick: @escaping ActionButton.Action, onPianoSoloClick: @escaping ActionButton.Action, isPianoSoloPlaying: Bool) {
        subviews.forEach { $0.removeFromSuperview() }
        clipsToBounds = true
        layer.masksToBounds = true
        let headerView = SongServiceHeaderView(sectionTitle: sectionTitle, title: title, cluster: cluster, isSelected: isSelected, onSectionClick: onSectionClick, onPianoSoloClick: onPianoSoloClick, isPianoSoloPlaying: isPianoSoloPlaying)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerView)
        self.songServiceHeaderView = headerView
        headerView.anchorToSuperView()
    }
    
    func updateHeader(isSelected: Bool) {
        songServiceHeaderView?.updateHeader(isSelected: isSelected)
    }
}

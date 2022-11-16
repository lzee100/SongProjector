//
//  SongServiceSectionHeaderTitleStackView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

class DemoInstrumentsButtonsViewContainer: UIView {
    private let instrumentButtonsView: DemoInstrumentsButtonsView
    private let insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets) {
        instrumentButtonsView = DemoInstrumentsButtonsView()
        self.insets = insets
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        instrumentButtonsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(instrumentButtonsView)
        
        applyConstraintsToInstrumentButtonsView()
    }
    
    private func applyConstraintsToInstrumentButtonsView() {
        instrumentButtonsView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        instrumentButtonsView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        instrumentButtonsView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: insets.top).isActive = true
        instrumentButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        instrumentButtonsView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -insets.right).isActive = true
        instrumentButtonsView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -insets.bottom).isActive = true
        
    }
    
}



class InstrumentsButtonsViewContainer: UIView {
    private let instrumentButtonsView: InstrumentsButtonsView
    private let insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets, instruments: [VInstrument]) {
        instrumentButtonsView = InstrumentsButtonsView(instruments: instruments)
        self.insets = insets
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        instrumentButtonsView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(instrumentButtonsView)
        
        applyConstraintsToInstrumentButtonsView()
    }
    
    private func applyConstraintsToInstrumentButtonsView() {
        instrumentButtonsView.removeConstraints(instrumentButtonsView.constraints)
//        instrumentButtonsView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        instrumentButtonsView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        instrumentButtonsView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: insets.top).isActive = true
        instrumentButtonsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        instrumentButtonsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right).isActive = true
//        if UIDevice.current.orientation.isLandscape {
//            instrumentButtonsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom).isActive = true
//        } else {
//            instrumentButtonsView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -insets.bottom).isActive = true
//        }
    }
    
}

class LeoPreview: UIView {
    
    private let previewSongServiceSectionHeaderTitleStackView = PreviewSongServiceSectionHeaderTitleStackView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(previewSongServiceSectionHeaderTitleStackView)
        previewSongServiceSectionHeaderTitleStackView.translatesAutoresizingMaskIntoConstraints = false
        previewSongServiceSectionHeaderTitleStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        previewSongServiceSectionHeaderTitleStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        previewSongServiceSectionHeaderTitleStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class PreviewSongServiceSectionHeaderTitleStackView: UIStackView {
//    lazy var pianoSoloButtonView: DemoInstrumentsButtonsViewContainer = {
//        let container = DemoInstrumentsButtonsViewContainer(insets: .zero)
//        container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        container.backgroundColor = .green
//        return container
//    }()
    lazy var pianoSoloButtonView: PianoSoloButtonView = {
        let container = PianoSoloButtonView(iconInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), equalizerInsets: .zero, action: {
            
        }, isPianoSoloPlaying: false)
        container.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        container.backgroundColor = .green
        return container
    }()

    lazy var label: SongServiceSectionHeaderTitleStackView = {
        let header = SongServiceSectionHeaderTitleStackView(sectionTitle: nil, title: "Title and", action: {
        }, insets: .zero)
        header.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return header
    }()
//    lazy var pianoSoloButtonView: UILabel = {
//        let label = UILabel()
//        label.text = "Second"
//        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        label.backgroundColor = .orange
//        return label
//    }()
//    lazy var label: UILabel = {
//        let label = UILabel()
//        label.text = "First"
//        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        label.backgroundColor = .green
//        return label
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addArrangedSubview(label)
        addArrangedSubview(pianoSoloButtonView)
        axis = .horizontal
        distribution = .fill
        alignment = .fill
        spacing = 10
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func blaAction() {
        
    }
}

class SongServiceSectionHeaderTitleStackView: UIStackView {

    private let actionButton = ActionButton(frame: .zero)
    private let sectionTitleLabel = UILabel()
    private let action: ActionButton.Action
    let titleLabel = UILabel()

    init(sectionTitle: String?, title: String?, action: @escaping ActionButton.Action, insets: UIEdgeInsets) {
        self.action = action
        super.init(frame: .zero)
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
        setup()
        set(sectionTitle: sectionTitle, title: title)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        axis = .vertical
        spacing = 15
        distribution = .fill
        alignment = .fill
        [sectionTitleLabel, titleLabel].forEach {
            addArrangedSubview($0)
            $0.textColor = .blackColor
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.setContentHuggingPriority(UILayoutPriority(100), for: .horizontal)
            $0.setContentHuggingPriority(UILayoutPriority(100), for: .vertical)
        }
        sectionTitleLabel.font = .xxNormalBold
        sectionTitleLabel.numberOfLines = 1
        actionButton.add(action: action)
        actionButton.setContentHuggingPriority(UILayoutPriority(100), for: .horizontal)
        actionButton.setContentHuggingPriority(UILayoutPriority(100), for: .vertical)
        titleLabel.textAlignment = UIDevice.current.orientation.isLandscape ? .center : .left
        titleLabel.font = .normalBold
        titleLabel.numberOfLines = 0
        titleLabel.setContentHuggingPriority(UILayoutPriority(300), for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        sectionTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(actionButton)
        actionButton.anchorToSuperView()
    }
    
    func set(sectionTitle: String?, title: String?) {
        sectionTitleLabel.text = sectionTitle
        sectionTitleLabel.isHidden = sectionTitle == nil
        titleLabel.text = title
        titleLabel.isHidden = title == nil
    }
    
    func getHeightForTitleFont() -> CGFloat {
        sectionTitleLabel.font.lineHeight
    }
}


import SwiftUI
struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View
    
    init(_ builder: @escaping () -> View) {
        view = builder()
    }
    
    // MARK: UIViewRepresentable
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}

struct BestInClassPreviews_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreview {
            // Return whatever controller you want to preview
            let vc = LeoPreview(frame: CGRect(x: 0, y: 0, width: 400, height: 200))
            return vc
        }
        .previewDevice("iPhone 13 Pro Max")
    }
}


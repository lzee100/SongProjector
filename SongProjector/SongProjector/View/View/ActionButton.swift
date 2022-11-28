//
//  ActionButton.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit

class ActionButton: UIButton {

    typealias Action = (() -> Void)
    
    private var action: Action? = nil
    
    func add(action: @escaping Action) {
        self.action = action
        addTarget(self, action: #selector(performAction), for: .touchUpInside)
    }
    
    @objc private func performAction() {
        action?()
    }
    
    func stylePrimary() {
        backgroundColor = .orange
        setTitleColor(.whiteColor, for: UIControl.State())
    }
    
    func syleSecundary() {
        backgroundColor = .grey1
        setTitleColor(.grey3, for: UIControl.State())
    }
}

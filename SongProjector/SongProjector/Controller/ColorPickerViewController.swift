//
//  ColorPickerViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
    
    var didSelectBack: (() -> Void)?
    var didSelectColor: ((UIColor) -> Void)?

    var selectedColor: UIColor = .whiteColor
    
//    lazy var colorPickerViewController: DefaultColorPickerViewController = {
//        let vc = DefaultColorPickerViewController()
//        view.addSubview(vc.view)
//        vc.view.frame = view.bounds.insetBy(dx: 0, dy: 44)
//        vc.didMove(toParent: self)
//        return vc
//    }()
    
    private lazy var navBar: UINavigationBar = {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)

        let navItem = UINavigationItem(title: "Kies kleur")
        let backButton = UIBarButtonItem(title: "Terug", style: .done, target: self, action: #selector(back))
        navItem.leftBarButtonItem = backButton

        navBar.setItems([navItem], animated: false)
        return navBar
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

//        colorPickerViewController.delegate = self
        navBar.items?.first?.title = "Kies kleur"
    }
    
    @objc func back() {
        didSelectBack?()
    }
    
    func setTitleNavigationBar(_ title: String) {
        navBar.items?.first?.title = title
    }
    
}

//extension ColorPickerViewController: ColorPickerDelegate {
//    
//    func colorPicker(_ colorPicker: ColorPickerController, selectedColor: UIColor, usingControl: ColorControl) {
//        self.selectedColor = selectedColor
//        self.didSelectColor?(selectedColor)
//    }
//}

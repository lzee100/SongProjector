//
//  TextFieldCell.swift
//  Leerling
//
//  Created by Thomas Dekker on 15-09-16.
//  Copyright © 2016 SOMtoday. All rights reserved.
//

import UIKit

protocol TextFieldCellDelegate : AnyObject {
    
    func textFieldCellShouldReturn(_ cell: TextFieldCell) -> Bool
    
}

class TextFieldCell : UITableViewCell, UITextFieldDelegate {
    
    // MARK: - Private Properties
    
    private let placeholderLabel = UILabel()
    
    
    
    // MARK: - Properties
    
    weak var delegate : TextFieldCellDelegate?
    
    @IBOutlet weak var textField : UITextField! {
        didSet { textField.delegate = self }
    }
    
    var placeholder : String = "" {
        didSet { update() }
    }
    
    var placeholderColor : UIColor = .placeholderColor {
        didSet { update() }
    }
	
	var placeholderFont : UIFont = .xNormalLight {
		didSet { update() }
	}
    
    var isSecure : Bool {
        get { return textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
    
    var value : String {
        get { return textField.text ?? "" }
        set {
            textField.text = newValue
            update()
        }
    }
	
	var valueColor : UIColor = .textColorNormal {
		didSet { update() }
	}
	
	var valueFont : UIFont = .xNormal {
		didSet { update() }
	}
	
    
    var returnKeyType : UIReturnKeyType {
        get { return textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    
    
    // MARK: - Functions
	
    
	func setup() {
		
        placeholderLabel.isUserInteractionEnabled = false
		textField.addTarget(self, action: #selector(update), for: .editingChanged)
		placeholderLabel.backgroundColor = .clear
		
        update()
        
    }
    
	@objc func update() {
		
		textField.font = valueFont
		textField.textColor = valueColor
		textField.placeholder = ""
		
		placeholderLabel.backgroundColor = .clear
        placeholderLabel.font = placeholderFont
        placeholderLabel.textColor = .textColorNormal
        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = !value.isEmpty
		
		
    }
    
    // MARK: UIView Functions
    
	override func didMoveToSuperview() {
		
        if placeholderLabel.superview == nil, let superview = textField.superview {
            superview.addSubview(placeholderLabel)
			layoutIfNeeded()
		}
        
    }
    
	override func layoutSubviews() {
        layoutSubviews()
        textField.layoutIfNeeded()
        placeholderLabel.frame = textField.frame
		
    }
	
    
    // MARK: UITextFieldDelegate Functions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        update()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        update()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldCellShouldReturn(self) ?? false
    }
    
}

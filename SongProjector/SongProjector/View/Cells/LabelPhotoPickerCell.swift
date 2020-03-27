//
//  LabelPhotoPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import Photos

class LabelPhotoPickerCell: ChurchBeamCell, ThemeImplementation, SheetImplementation, DynamicHeightCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	

	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var descriptionLastBeamerResolution: UILabel!
	@IBOutlet var imageThumbnail: UIImageView!
	@IBOutlet var button: UIButton!
	@IBOutlet var buttonContainer: UIView!
	
	@IBOutlet var buttonBottomConstraint: NSLayoutConstraint!
	@IBOutlet var buttonHeightConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionBeamerHeightConstraint: NSLayoutConstraint!
	
	
	
	var id = ""
	
	var sheetTheme: VTheme?
	var themeAttribute: ThemeAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?
	var imageError: ((Error?) -> Void)?
	var sheet: VSheet?
	var sheetAttribute: SheetAttribute?
	
	var isActive = false { didSet { showImage() } }
	let imagePicker = UIImagePickerController()
	var pickedImage: UIImage?
	var sender: UIViewController?
	var preferredHeight: CGFloat {
		return isActive ? 162 : 60
	}
	
	override func prepareForReuse() {
		sheetAttribute = nil
		themeAttribute = nil
		valueDidChange = nil
		sheet = nil
		let beamerResolution = "\(Int(externalDisplayWindowWidth)) x \(Int(externalDisplayWindowHeight))"
		descriptionLastBeamerResolution.text = Text.NewTheme.descriptionLastBeamerResolution + beamerResolution
	}
	
	static let identifier = "LabelPhotoPickerCell"
	
	override func awakeFromNib() {
		imagePicker.delegate = self
		descriptionLastBeamerResolution.textColor = themeWhiteBlackBackground
		buttonContainer.isHidden = true
		imageThumbnail.contentMode = .scaleAspectFill
		imageThumbnail.clipsToBounds = true
		imageThumbnail.layer.cornerRadius = CGFloat(5)
		let beamerResolution = "\(Int(externalDisplayWindowWidth)) x \(Int(externalDisplayWindowHeight))"
		descriptionLastBeamerResolution.text = Text.NewTheme.descriptionLastBeamerResolution + beamerResolution
		descriptionLastBeamerResolution.textColor = isThemeLight ? UIColor(red: 0, green: 0, blue: 0, alpha: 0.5) : UIColor(red: 255, green: 255, blue: 255, alpha: 0.4)
		button.isEnabled = false
		buttonContainer.backgroundColor = themeWhiteBlackBackground
		button.backgroundColor = themeHighlighted
		button.layer.cornerRadius = 5.0
		button.setTitleColor(.white, for: .normal)
	}
	
	static func create(id: String, description: String, sender: UIViewController) -> LabelPhotoPickerCell {
		let view : LabelPhotoPickerCell! = UIView.create(nib: "LabelPhotoPickerCell")
		view.id = id
		view.descriptionTitle.text = description
		view.descriptionLastBeamerResolution.textColor = themeWhiteBlackBackground
		view.buttonContainer.isHidden = true
		view.imageThumbnail.layer.cornerRadius = CGFloat(5)
		let beamerResolution = "\(Int(externalDisplayWindowWidth)) x \(Int(externalDisplayWindowHeight))"
		view.descriptionLastBeamerResolution.text = Text.NewTheme.descriptionLastBeamerResolution + beamerResolution
		view.descriptionLastBeamerResolution.textColor = isThemeLight ? UIColor(red: 0, green: 0, blue: 0, alpha: 0.5) : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
		view.button.isEnabled = false
		view.buttonContainer.backgroundColor = themeWhiteBlackBackground
		view.button.backgroundColor = themeHighlighted
		view.button.layer.cornerRadius = 5.0
		view.button.setTitleColor(.white, for: .normal)
		view.sender = sender
		return view
	}
	
	func setImage(image: UIImage?) {
		button.setTitle(image == nil ? Text.NewTheme.buttonBackgroundImagePick : Text.NewTheme.buttonBackgroundImageChange, for: .normal)
		imageThumbnail.image = image
		pickedImage = image
	}
	
	func showImage() {
		button.setTitle(pickedImage == nil ? Text.NewTheme.buttonBackgroundImagePick : Text.NewTheme.buttonBackgroundImageChange, for: .normal)
		if isActive {
			buttonContainer.isHidden = false
			button.isEnabled = true
			descriptionBeamerHeightConstraint.constant = 42
			buttonHeightConstraint.constant = 50
			buttonBottomConstraint.constant = 10
		} else {
			buttonContainer.isHidden = true
			button.isEnabled = false
			descriptionBeamerHeightConstraint.constant = 1
			buttonHeightConstraint.constant = 1
			buttonBottomConstraint.constant = 0
		}
		
	}
	
	func apply(theme: VTheme, themeAttribute: ThemeAttribute) {
		self.sheetTheme = theme
		self.themeAttribute = themeAttribute
		self.descriptionTitle.text = themeAttribute.description
		applyValueToCell()
	}
	
	func apply(sheet: VSheet, sheetAttribute: SheetAttribute) {
		self.sheet = sheet
		self.sheetAttribute = sheetAttribute
		self.descriptionTitle.text = sheetAttribute.description
		if sheetAttribute.additionalDescription != nil {
			self.descriptionLastBeamerResolution?.text = sheetAttribute.additionalDescription
		}
		applyValueToCell()
	}
	
	func applyValueToCell() {
		if let theme = sheetTheme, let themeAttribute = themeAttribute {
			switch themeAttribute {
			case .backgroundImage:
				if theme.isBackgroundImageDeleted {
					setImage(image: nil)
				} else {
					setImage(image: theme.backgroundImage)
				}
			default: return
			}
		}
		if let sheet = sheet as? VSheetTitleImage {
			setImage(image: sheet.thumbnail)
		}
		if let sheet = sheet as? VSheetPastors {
			setImage(image: sheet.thumbnail)
		}
	}
	
	func applyCellValueToTheme() throws {
		if let theme = sheetTheme, let themeAttribute = themeAttribute {
			switch themeAttribute {
			case .backgroundImage:
				if pickedImage != nil {
					try theme.setBackgroundImage(image: pickedImage)
					theme.isBackgroundImageDeleted = false
				} else {
					theme.isBackgroundImageDeleted = true
				}
			default: return
			}
		}
		if let sheet = sheet as? VSheetTitleImage {
			try sheet.set(image: pickedImage)
		} else if let sheet = sheet as? VSheetPastors {
			try sheet.set(image: pickedImage)
		}
	}
	
	func set(value: Any?) {
		if value == nil {
			setImage(image: nil)
		} else if let value = value as? UIImage {
			setImage(image: value)
		}
		do {
			try applyCellValueToTheme()
		} catch {
			imageError?(error)
		}
		self.valueDidChange?(self)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let pickedImage = info[.originalImage] as? UIImage {
			DispatchQueue.main.async {
				let scaledImage = pickedImage.resizeImage(self.imageThumbnail.frame.size.width, opaque: false)
				self.imageThumbnail.image = scaledImage
				self.imageThumbnail.contentMode = .scaleAspectFill
				self.imageThumbnail.clipsToBounds = true
				self.setNeedsDisplay()
				
				self.pickedImage = pickedImage
				do {
					try self.applyCellValueToTheme()
				} catch {
					self.imageError?(error)
				}
				self.valueDidChange?(self)
				if let sender = self.sender {
					sender.dismiss(animated: true)
				}
			}
		}
	}
	
	@IBAction func changeImage(_ sender: UIButton) {
		if !canUsePhotos {
			PHPhotoLibrary.requestAuthorization({ (status) in
				if status == PHAuthorizationStatus.authorized {
					canUsePhotos = true
				} else {
					canUsePhotos = false
				}
			})
		}
		imagePicker.allowsEditing = false
		imagePicker.sourceType = .photoLibrary
		if let sender = self.sender {
			DispatchQueue.main.async {
				sender.present(self.imagePicker, animated: true, completion: nil)
			}
		}
	}
	
}


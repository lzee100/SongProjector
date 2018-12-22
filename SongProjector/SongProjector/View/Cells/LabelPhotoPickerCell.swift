//
//  LabelPhotoPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import Photos

class LabelPhotoPickerCell: ChurchBeamCell, TagImplementation, SheetImplementation, DynamicHeightCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	

	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var descriptionLastBeamerResolution: UILabel!
	@IBOutlet var imageThumbnail: UIImageView!
	@IBOutlet var button: UIButton!
	@IBOutlet var buttonContainer: UIView!
	
	@IBOutlet var buttonBottomConstraint: NSLayoutConstraint!
	@IBOutlet var buttonHeightConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionBeamerHeightConstraint: NSLayoutConstraint!
	
	
	
	var id = ""
	
	var sheetTag: Tag?
	var tagAttribute: TagAttribute?
	var valueDidChange: ((ChurchBeamCell) -> Void)?

	var sheet: Sheet?
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
		tagAttribute = nil
		valueDidChange = nil
		sheet = nil
		let beamerResolution = "\(Int(externalDisplayWindowWidth)) x \(Int(externalDisplayWindowHeight))"
		descriptionLastBeamerResolution.text = Text.NewTag.descriptionLastBeamerResolution + beamerResolution
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
		descriptionLastBeamerResolution.text = Text.NewTag.descriptionLastBeamerResolution + beamerResolution
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
		view.descriptionLastBeamerResolution.text = Text.NewTag.descriptionLastBeamerResolution + beamerResolution
		view.descriptionLastBeamerResolution.textColor = isThemeLight ? UIColor(red: 0, green: 0, blue: 0, alpha: 0.5) : UIColor(red: 255, green: 255, blue: 255, alpha: 0.4)
		view.button.isEnabled = false
		view.buttonContainer.backgroundColor = themeWhiteBlackBackground
		view.button.backgroundColor = themeHighlighted
		view.button.layer.cornerRadius = 5.0
		view.button.setTitleColor(.white, for: .normal)
		view.sender = sender
		return view
	}
	
	func setImage(image: UIImage?) {
		button.setTitle(image == nil ? Text.NewTag.buttonBackgroundImagePick : Text.NewTag.buttonBackgroundImageChange, for: .normal)
		imageThumbnail.image = image
		pickedImage = image
	}
	
	func showImage() {
		button.setTitle(pickedImage == nil ? Text.NewTag.buttonBackgroundImagePick : Text.NewTag.buttonBackgroundImageChange, for: .normal)
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
	
	func apply(tag: Tag, tagAttribute: TagAttribute) {
		self.sheetTag = tag
		self.tagAttribute = tagAttribute
		self.descriptionTitle.text = tagAttribute.description
		applyValueToCell()
	}
	
	func apply(sheet: Sheet, sheetAttribute: SheetAttribute) {
		self.sheet = sheet
		self.sheetAttribute = sheetAttribute
		self.descriptionTitle.text = sheetAttribute.description
		if sheetAttribute.additionalDescription != nil {
			self.descriptionLastBeamerResolution?.text = sheetAttribute.additionalDescription
		}
		applyValueToCell()
	}
	
	func applyValueToCell() {
		if let tag = sheetTag, let tagAttribute = tagAttribute {
			switch tagAttribute {
			case .backgroundImage:
				if tag.isBackgroundImageDeleted {
					setImage(image: nil)
				} else {
					setImage(image: tag.backgroundImage)
				}
			default: return
			}
		}
		if let sheet = sheet as? SheetTitleImageEntity {
			setImage(image: sheet.thumbnail)
		}
		if let sheet = sheet as? SheetPastorsEntity {
			setImage(image: sheet.thumbnail)
		}
	}
	
	func applyCellValueToTag() {
		if let tag = sheetTag, let tagAttribute = tagAttribute {
			switch tagAttribute {
			case .backgroundImage:
				if pickedImage != nil {
					tag.backgroundImage = pickedImage
					tag.isBackgroundImageDeleted = false
				} else {
					tag.isBackgroundImageDeleted = true
				}
			default: return
			}
		}
		if let sheet = sheet as? SheetTitleImageEntity {
			sheet.image = pickedImage
		} else if let sheet = sheet as? SheetPastorsEntity {
			sheet.image = pickedImage
		}
	}
	
	func set(value: Any?) {
		if value == nil {
			setImage(image: nil)
		} else if let value = value as? UIImage {
			setImage(image: value)
		}
		applyCellValueToTag()
		self.valueDidChange?(self)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			DispatchQueue.main.async {
				let scaledImage = pickedImage.resizeImage(self.imageThumbnail.frame.size.width, opaque: false)
				self.imageThumbnail.image = scaledImage
				self.imageThumbnail.contentMode = .scaleAspectFill
				self.imageThumbnail.clipsToBounds = true
				self.setNeedsDisplay()
				
				self.pickedImage = pickedImage
				self.applyCellValueToTag()
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


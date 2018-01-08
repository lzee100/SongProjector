//
//  LabelPhotoPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol LabelPhotoPickerCellDelegate {
	func didSelectImage(cell: LabelPhotoPickerCell)
}

class LabelPhotoPickerCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var descriptionLastBeamerResolution: UILabel!
	@IBOutlet var imageThumbnail: UIImageView!
	@IBOutlet var imageContainer: UIView!
	@IBOutlet var button: UIButton!
		
	@IBOutlet var buttonBottomConstraint: NSLayoutConstraint!
	@IBOutlet var buttonHeightConstraint: NSLayoutConstraint!
	@IBOutlet var descriptionBeamerHeightConstraint: NSLayoutConstraint!
	
	
	
	var id = ""
	
		var delegate: LabelPhotoPickerCellDelegate?
		var isActive = false { didSet { showImage() } }
		let imagePicker = UIImagePickerController()
		var pickedImage: UIImage?
		var sender: UIViewController?
		var preferredHeight: CGFloat {
			return isActive ? 162 : 60
		}
		
		static func create(id: String, description: String, sender: UIViewController) -> LabelPhotoPickerCell {
			let view : LabelPhotoPickerCell! = UIView.create(nib: "LabelPhotoPickerCell")
			view.id = id
			view.descriptionTitle.text = description
			view.imageContainer.isHidden = true
			view.imageThumbnail.layer.cornerRadius = CGFloat(5)
			let beamerResolution = "\(Int(externalDisplayWindowWidth)) x \(Int(externalDisplayWindowHeight))"
			view.descriptionLastBeamerResolution.text = Text.NewTag.descriptionLastBeamerResolution + beamerResolution
			view.descriptionLastBeamerResolution.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
			view.button.isEnabled = false
			view.button.backgroundColor = .primary
			view.button.layer.cornerRadius = 5.0
			view.button.setTitleColor(.white, for: .normal)
			view.sender = sender
			return view
		}
		
		func setup() {
			imagePicker.delegate = self
		}
		
		func setImage(image: UIImage?) {
			button.setTitle(image == nil ? Text.NewTag.buttonBackgroundImagePick : Text.NewTag.buttonBackgroundImageChange, for: .normal)
			let imageView = UIImageView(frame: imageThumbnail.frame)
			imageView.image = image
			imageThumbnail.image = imageView.asImage()
			pickedImage = image
			delegate?.didSelectImage(cell: self)
			layoutIfNeeded()
		}
		
		func showImage() {
			button.setTitle(pickedImage == nil ? Text.NewTag.buttonBackgroundImagePick : Text.NewTag.buttonBackgroundImageChange, for: .normal)
			if isActive {
				imageContainer.isHidden = false
				button.isEnabled = true
				descriptionBeamerHeightConstraint.constant = 42
				buttonHeightConstraint.constant = 50
				buttonBottomConstraint.constant = 10
			} else {
				imageContainer.isHidden = true
				button.isEnabled = false
				descriptionBeamerHeightConstraint.constant = 1
				buttonHeightConstraint.constant = 1
				buttonBottomConstraint.constant = 0
			}
			
		}
		
		override func setSelected(_ selected: Bool, animated: Bool) {
			
		}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
			if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
				if let scaledImage = UIImage.scaleImageToSize(image: pickedImage, size: imageThumbnail.frame.size) {
					imageThumbnail.image = scaledImage
				}
				self.pickedImage = pickedImage
				delegate?.didSelectImage(cell: self)
			}
			if let sender = sender {
				sender.dismiss(animated: true)
			}
		}
		
		override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		}
		@IBAction func changeImage(_ sender: UIButton) {
			imagePicker.allowsEditing = false
			imagePicker.sourceType = .photoLibrary
			if let sender = self.sender {
				sender.present(imagePicker, animated: true, completion: nil)
			}
		}
		
}


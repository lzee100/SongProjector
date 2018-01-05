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
		@IBOutlet var imageThumbnail: UIImageView!
		@IBOutlet var imagePreview: UIImageView!
		@IBOutlet var imageContainer: UIView!
		@IBOutlet var button: UIButton!
		
		@IBOutlet var buttonHeightConstraint: NSLayoutConstraint!
		
		var id = ""
		var delegate: LabelPhotoPickerCellDelegate?
		var isActive = false { didSet { showImage() } }
		let imagePicker = UIImagePickerController()
		var pickedImage: UIImage?
		var sender: UIViewController?
		var preferredHeight: CGFloat {
			return isActive ? 360 : 60
		}
		
		static func create(id: String, description: String, sender: UIViewController) -> LabelPhotoPickerCell {
			let view : LabelPhotoPickerCell! = UIView.create(nib: "LabelPhotoPickerCell")
			view.id = id
			view.descriptionTitle.text = description
			view.imageContainer.isHidden = true
			view.imageThumbnail.layer.cornerRadius = CGFloat(5)
			view.imagePreview.layer.cornerRadius = CGFloat(10)
			view.button.isEnabled = false
			view.sender = sender
			return view
		}
		
		func setup() {
			imagePicker.delegate = self
		}
		
		func setImage(image: UIImage) {
			imageThumbnail.image = image
			imagePreview.image = image
			pickedImage = image
			delegate?.didSelectImage(cell: self)
			layoutIfNeeded()
		}
		
		func showImage() {
			if isActive {
				imageContainer.isHidden = false
				button.isEnabled = true
				buttonHeightConstraint.constant = 30
				imageThumbnail.isHidden = true
				imagePreview.isHidden = false
			} else {
				imageContainer.isHidden = true
				button.isEnabled = false
				imageThumbnail.isHidden = false
				imagePreview.isHidden = true
				buttonHeightConstraint.constant = 1
			}
			
		}
		
		override func setSelected(_ selected: Bool, animated: Bool) {
			
		}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
			if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
				if let scaledImage = UIImage.scaleImageToSize(image: pickedImage, size: imageThumbnail.frame.size) {
					imageThumbnail.image = scaledImage
				}
				if let scaledImage = UIImage.scaleImageToSize(image: pickedImage, size: imagePreview.frame.size) {
					imagePreview.image = scaledImage
				}
				imagePreview.contentMode = .scaleAspectFill
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


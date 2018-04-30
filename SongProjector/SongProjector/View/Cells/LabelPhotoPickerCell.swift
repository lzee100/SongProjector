//
//  LabelPhotoPickerCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import Photos

protocol LabelPhotoPickerCellDelegate {
	func didSelectImage(cell: LabelPhotoPickerCell, image: UIImage?)
}

class LabelPhotoPickerCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
		
	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var descriptionLastBeamerResolution: UILabel!
	@IBOutlet var imageThumbnail: UIImageView!
	@IBOutlet var button: UIButton!
	@IBOutlet var buttonContainer: UIView!
	
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
		
		func setup() {
			imagePicker.delegate = self
		}
		
		func setImage(image: UIImage?) {
			button.setTitle(image == nil ? Text.NewTag.buttonBackgroundImagePick : Text.NewTag.buttonBackgroundImageChange, for: .normal)
			let imageView = UIImageView(frame: imageThumbnail.frame)
			imageView.image = image
			imageThumbnail.image = imageView.asImage()
			pickedImage = image
			delegate?.didSelectImage(cell: self, image: image)
			layoutIfNeeded()
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
		
		override func setSelected(_ selected: Bool, animated: Bool) {
			
		}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
			if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
				let scaledImage = pickedImage.resizeImage(imageThumbnail.frame.size.width, opaque: false)
					imageThumbnail.image = scaledImage
					imageThumbnail.contentMode = .scaleAspectFill
					imageThumbnail.clipsToBounds = true
				
				self.pickedImage = pickedImage
				delegate?.didSelectImage(cell: self, image: pickedImage)
			}
			if let sender = sender {
				sender.dismiss(animated: true)
			}
		}
		
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
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


//
//  LabelImagePickerCell
//  SongProjector
//
//  Created by Leo van der Zee on 30-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

protocol LabelImagePickerCellDelegate {
	func didSelectImage(cell: LabelImagePickerCell)
}

class LabelImagePickerCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet var descriptionTitle: UILabel!
	@IBOutlet var imageThumbnail: UIImageView!
	@IBOutlet var imagePreview: UIImageView!
	@IBOutlet var imageContainer: UIView!
	@IBOutlet var button: UIButton!
	
	@IBOutlet var buttonHeightConstraint: NSLayoutConstraint!
	
	var id = ""
	var delegate: LabelImagePickerCellDelegate?
	var isActive = false { didSet { showImage() } }
	let imagePicker = UIImagePickerController()
	var sender: UIViewController?
	var preferredHeight: CGFloat {
		return isActive ? 360 : 60
	}

	static func create(id: String, description: String, sender: UIViewController) -> LabelImagePickerCell {
		let view : LabelImagePickerCell! = UIView.create(nib: "LabelImagePickerCell")
		view.id = id
		view.descriptionTitle.text = description
		view.imageContainer.isHidden = true
		view.button.isEnabled = false
		view.sender = sender
		return view
	}
	
	func setup() {
		imagePicker.delegate = self
	}
	
	func setImage(image: UIImage) {
		
	}
	
	func showImage() {
		if isActive {
			imageContainer.isHidden = false
			button.isEnabled = true
			buttonHeightConstraint.constant = 30
			imagePreview.isHidden = true
		} else {
			imageContainer.isHidden = true
			button.isEnabled = false
			imagePreview.isHidden = false
			buttonHeightConstraint.constant = 1
		}
		
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imageThumbnail.contentMode = .scaleAspectFit
			imageThumbnail.image = pickedImage
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

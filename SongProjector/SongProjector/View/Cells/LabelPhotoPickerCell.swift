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
    @IBOutlet var deleteButton: ActionButton!
    
    @IBOutlet var deleteButtonRightConstraint: NSLayoutConstraint!
    @IBOutlet var deleteButtonWidthConstraint: NSLayoutConstraint!
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
	unowned var sender: UIViewController?
	var preferredHeight: CGFloat {
		return isActive ? 162 : 60
	}
    
    private var cell: NewOrEditIphoneController.Cell?
    private var newDelegate: CreateEditThemeSheetCellDelegate?
	
	override func prepareForReuse() {
		sheetAttribute = nil
		themeAttribute = nil
		valueDidChange = nil
		sheet = nil
		let beamerResolution = "\(Int(externalDisplayWindowWidth)) x \(Int(externalDisplayWindowHeight))"
		descriptionLastBeamerResolution.text = AppText.NewTheme.descriptionLastBeamerResolution + beamerResolution
	}
	
	static let identifier = "LabelPhotoPickerCell"
	
	override func awakeFromNib() {
		imagePicker.delegate = self
        descriptionLastBeamerResolution.textColor = .grey3
		buttonContainer.isHidden = true
		imageThumbnail.contentMode = .scaleAspectFill
		imageThumbnail.clipsToBounds = true
		imageThumbnail.layer.cornerRadius = CGFloat(5)
		let beamerResolution = "\(Int(externalDisplayWindowWidth)) x \(Int(externalDisplayWindowHeight))"
		descriptionLastBeamerResolution.text = AppText.NewTheme.descriptionLastBeamerResolution + beamerResolution
		button.isEnabled = false
        buttonContainer.backgroundColor = .clear
		button.backgroundColor = themeHighlighted
		button.layer.cornerRadius = 5.0
		button.setTitleColor(UIColor(hex: "FFFFFF"), for: .normal)
        deleteButton.tintColor = .red2
        deleteButton.setTitle(nil, for: UIControl.State())
        deleteButton.add {
            self.set(value: nil)
        }
	}
	
	static func create(id: String, description: String, sender: UIViewController) -> LabelPhotoPickerCell {
		let view : LabelPhotoPickerCell! = UIView.create(nib: "LabelPhotoPickerCell")
		view.id = id
		view.descriptionTitle.text = description
		view.buttonContainer.isHidden = true
		view.imageThumbnail.layer.cornerRadius = CGFloat(5)
		let beamerResolution = "\(Int(externalDisplayWindowWidth)) x \(Int(externalDisplayWindowHeight))"
		view.descriptionLastBeamerResolution.text = AppText.NewTheme.descriptionLastBeamerResolution + beamerResolution
		view.button.isEnabled = false
        view.buttonContainer.backgroundColor = .clear
		view.button.backgroundColor = themeHighlighted
		view.button.layer.cornerRadius = 5.0
		view.button.setTitleColor(.whiteColor, for: .normal)
		view.sender = sender
		return view
	}
	
	func setImage(image: UIImage?) {
		button.setTitle(image == nil ? AppText.NewTheme.buttonBackgroundImagePick : AppText.NewTheme.buttonBackgroundImageChange, for: .normal)
        setThumbImage(image)
        pickedImage = image
        deleteButton.isEnabled = image != nil
        deleteButtonWidthConstraint.constant = image == nil ? 0 : 40
        deleteButtonRightConstraint.constant = image == nil ? 30 : 20
	}
	
	func showImage() {
		button.setTitle(pickedImage == nil ? AppText.NewTheme.buttonBackgroundImagePick : AppText.NewTheme.buttonBackgroundImageChange, for: .normal)
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
				if theme.isTempSelectedImageDeleted {
					setImage(image: nil)
				} else {
                    setImage(image: theme.tempSelectedImage ?? theme.backgroundImage)
				}
			default: return
			}
		}
//		if let sheet = sheet as? VSheetTitleImage {
//            setImage(image: sheet.tempSelectedImageThumbNail ?? sheet.thumbnail)
//		}
//		if let sheet = sheet as? VSheetPastors {
//			setImage(image: sheet.tempSelectedImageThumbNail ?? sheet.thumbnail)
//		}
	}
	
	func applyCellValueToTheme() throws {
		if let theme = sheetTheme, let themeAttribute = themeAttribute {
			switch themeAttribute {
			case .backgroundImage:
                theme.tempSelectedImage = pickedImage
                theme.isTempSelectedImageDeleted = pickedImage == nil
                if pickedImage == nil {
                    theme.backgroundTransparancy = 100
                }
			default: return
			}
		}
		if let sheet = sheet as? VSheetTitleImage {
            sheet.tempSelectedImage = pickedImage
            sheet.isTempSelectedImageDeleted = pickedImage == nil
		} else if let sheet = sheet as? VSheetPastors {
            sheet.tempSelectedImage = pickedImage
            sheet.isTempSelectedImageDeleted = pickedImage == nil
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
            let url = info[.imageURL] as? URL
            let imageName = url?.lastPathComponent
            try? DeleteFileAtURLUseCase(fileName: imageName)?.delete(location: .temp)
			DispatchQueue.main.async {
                self.setThumbImage(pickedImage)
				
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
                self.handleImageSelection(pickedImage, imageName: imageName)
			}
		}
	}
    
    private func setThumbImage(_ image: UIImage?) {
        let scaledImage = image?.resizeImage(self.imageThumbnail.frame.size.width, opaque: false)
        self.imageThumbnail.image = scaledImage
        self.imageThumbnail.contentMode = .scaleAspectFill
        self.imageThumbnail.clipsToBounds = true
        self.setNeedsDisplay()
    }
    
    private func handleImageSelection(_ image: UIImage, imageName: String?) {
        switch cell {
        case .backgroundImage:
            newDelegate?.handle(cell: .backgroundImage(image: image, imageName: imageName))
        case .image:
            newDelegate?.handle(cell: .image(image: image, imageName: imageName))
        case .pastorImage:
            newDelegate?.handle(cell: .pastorImage(image: image, imageName: imageName))
        default: break
        }
    }
	
	@IBAction func changeImage(_ sender: UIButton) {
        guard !SubscriptionsSettings.hasLimitedAccess else {
            if let sender = self.sender {
                SubscriptionsSettings.showSubscriptionsViewController(presentingViewController: sender)
            }
            return
        }
        
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

extension LabelPhotoPickerCell: CreateEditThemeSheetCellProtocol {
    
    func configure(cell: NewOrEditIphoneController.Cell, delegate: CreateEditThemeSheetCellDelegate) {
        self.cell = cell
        newDelegate = delegate
        descriptionTitle.text = cell.description
        switch cell {
        case .backgroundImage(let value, _):
            setImage(image: value)
        case .image(let value, _):
            setImage(image: value)
        case .pastorImage(let value, _):
            setImage(image: value)
        default: break
        }
    }

}

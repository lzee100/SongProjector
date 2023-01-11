//
//  ImageExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    enum SaveImageError: LocalizedError {
        case couldNotGenerateData
        
        var localizedDescription: String? {
            switch self {
            case .couldNotGenerateData: return AppText.Generic.errorGeneratingDataForImage
            }
        }
    }
	
	struct SavedImage {
		let imagePath: String?
		let thumbPath: String?
	}
	
	static func scaleImageToSize(image: UIImage, size: CGSize) -> UIImage? {
		let hasAlpha = false
		let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
		
		UIGraphicsBeginImageContextWithOptions(size, hasAlpha, scale)
		image.draw(in: CGRect(origin: CGPoint.zero, size: size))
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return scaledImage
	}
	
	func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
		var width: CGFloat
		var height: CGFloat
		var newImage: UIImage
		
		let size = self.size
		let aspectRatio =  size.width/size.height
		
		switch contentMode {
		case .scaleAspectFit:
			if aspectRatio > 1 {                            // Landscape image
				width = dimension
				height = dimension / aspectRatio
			} else {                                        // Portrait image
				height = dimension
				width = dimension * aspectRatio
			}
		default:
			fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
		}
		
		if #available(iOS 10.0, *) {
			let renderFormat = UIGraphicsImageRendererFormat.default()
			renderFormat.opaque = opaque
			let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
			newImage = renderer.image {
				(context) in
				self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
			}
		} else {
			UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
			self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
			newImage = UIGraphicsGetImageFromCurrentImageContext()!
			UIGraphicsEndImageContext()
		}
		
		
		return newImage
	}
	
	func rotateImageByOrientation() -> UIImage {
		// No-op if the orientation is already correct
		guard self.imageOrientation != .up else {
			return self
		}
		
		// We need to calculate the proper transformation to make the image upright.
		// We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
		var transform = CGAffineTransform.identity;
		
		switch (self.imageOrientation) {
		case .down, .downMirrored:
			transform = transform.translatedBy(x: self.size.width, y: self.size.height)
			transform = transform.rotated(by: CGFloat(Double.pi))
			
		case .left, .leftMirrored:
			transform = transform.translatedBy(x: self.size.width, y: 0)
			transform = transform.rotated(by: CGFloat(Double.pi / 2))
			
		case .right, .rightMirrored:
			transform = transform.translatedBy(x: 0, y: self.size.height)
			transform = transform.rotated(by: CGFloat(-(Double.pi / 2)))
			
		default:
			break
		}
		
		switch (self.imageOrientation) {
		case .upMirrored, .downMirrored:
			transform = transform.translatedBy(x: self.size.width, y: 0)
			transform = transform.scaledBy(x: -1, y: 1)
			
		case .leftMirrored, .rightMirrored:
			transform = transform.translatedBy(x: self.size.height, y: 0)
			transform = transform.scaledBy(x: -1, y: 1)
			
		default:
			break
		}
		
		// Now we draw the underlying CGImage into a new context, applying the transform
		// calculated above.
		let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
							bitsPerComponent: (self.cgImage?.bitsPerComponent)!, bytesPerRow: 0,
							space: (self.cgImage?.colorSpace!)!,
							bitmapInfo: (self.cgImage?.bitmapInfo.rawValue)!)
		ctx?.concatenate(transform)
		switch (self.imageOrientation) {
		case .left, .leftMirrored, .right, .rightMirrored:
			ctx?.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width))
			
		default:
			ctx?.draw(self.cgImage!, in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height))
		}
		
		// And now we just create a new UIImage from the drawing context
		if let cgImage = ctx?.makeImage() {
			return UIImage(cgImage: cgImage)
		} else {
			return self
		}
	}
	
	func blurred(usingRadius radius:CGFloat) -> UIImage? {
		
		guard let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur"), let cgImage = self.cgImage else {
			return nil
		}
		gaussianBlurFilter.setValue(CIImage(cgImage: cgImage), forKey:kCIInputImageKey)
		gaussianBlurFilter.setValue(radius as NSNumber, forKey:kCIInputRadiusKey)
		
		let initialImage = CIImage(cgImage: cgImage)
		
		let finalImage = gaussianBlurFilter.outputImage
		let finalImagecontext = CIContext(options: nil)
		
		guard let finalCGImage = finalImagecontext.createCGImage(finalImage!, from: initialImage.extent) else {
			return nil
		}
		return UIImage(cgImage: finalCGImage)
	}

	func resized(withPercentage percentage: CGFloat) -> UIImage? {
		let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
		UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
		defer { UIGraphicsEndImageContext() }
		draw(in: CGRect(origin: .zero, size: canvasSize))
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
	func resized(toWidth width: CGFloat) -> UIImage? {
		let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
		UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
		defer { UIGraphicsEndImageContext() }
		draw(in: CGRect(origin: .zero, size: canvasSize))
		return UIGraphicsGetImageFromCurrentImageContext()
	}
    
    func saveTemp() throws -> String {
        
        let resImage = self.resizeImage(targetSize: CGSize(width: externalDisplayWindowWidth, height: externalDisplayWindowHeight))
        let tempName = try FileManager.getNameFor(fileType: .jpg)
        let imagePath = FileManager.getTempURLFor(name: tempName)
        
        if let image = resImage, let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: imagePath)
            return tempName
        } else {
            throw SaveImageError.couldNotGenerateData
        }
    }
    
    static func deleteTempFile(imageName: String?, thumbNailName: String?) {
        if let imageName = imageName {
            try? FileManager.default.removeItem(at: FileManager.getTempURLFor(name: imageName))
        }
        if let thumbNailName = thumbNailName {
            try? FileManager.default.removeItem(at: FileManager.getTempURLFor(name: thumbNailName))
        }
    }

	@discardableResult
	static func set(image: UIImage?, imageName: String?, thumbNailName: String?) throws -> SavedImage {
                
        let resImage = image?.resizeImage(targetSize: CGSize(width: externalDisplayWindowWidth, height: externalDisplayWindowHeight))
        
        if let image = resImage ?? image, let data = image.jpegData(compressionQuality: 0.9), let resizedImage = image.resized(toWidth: 500), let dataResized = resizedImage.jpegData(compressionQuality: 0.5) {
			
            if let imageName = imageName {
                let imagePath = FileManager.getURLfor(name: imageName)
                if case .isFile = imagePath.filestatus {
                    try FileManager.default.removeItem(at: imagePath)
                }
			}
            
			if let thumbNailName = thumbNailName {
                let imagePath = FileManager.getURLfor(name: thumbNailName)
                if case .isFile = imagePath.filestatus {
                    try FileManager.default.removeItem(at: imagePath)
                }
			}
			
            let defaultName = try FileManager.getNameFor(fileType: .jpg)
            let defaultThumbName = try FileManager.getNameFor(fileType: .jpg)
            let imageURL = FileManager.getURLfor(name: imageName ?? defaultName)
            let thumbURL = FileManager.getURLfor(name: thumbNailName ?? defaultThumbName)
            
			try? data.write(to: imageURL)
			try? dataResized.write(to: thumbURL)
			
			return SavedImage(imagePath: imageName ?? defaultName, thumbPath: thumbNailName ?? defaultThumbName)
			
		} else {
            if let url = try FileManager.getUrlFor(fileName: imageName) {
                try FileManager.default.removeItem(at: url)
            }
            if let url = try FileManager.getUrlFor(fileName: thumbNailName) {
                try FileManager.default.removeItem(at: url)
            }
			return SavedImage(imagePath: nil, thumbPath: nil)
		}
	}
	
	static func get(imagePath: String?) -> UIImage? {
		if let imagePath = imagePath {
            let url = FileManager.getURLfor(name: imagePath)
			do {
				let data = try Data(contentsOf: url)
				return UIImage(data: data)
			} catch {
				return nil
			}
		} else {
			return nil
		}
	}
    
    
    
    
    
    
    private func resizeImage(targetSize: CGSize) -> UIImage? {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

	
}

//
//  SaveImageUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import UIKit

struct SaveImageUseCase {
    
    enum SaveImageError: LocalizedError {
        case failedTransformingImage
        
        var errorDescription: String? {
            return AppText.Generic.errorGeneratingDataForImage
        }
    }
    
    func saveImageTemp(_ image: UIImage) throws -> String {
        
        let imageData = image.resized()?.toData()
        
        if let imageData {
            return try saveImage(data: imageData, location: .temp)
        } else {
            throw SaveImageError.failedTransformingImage
        }
    }
    
    /// Save a image from temp directory to persitent directory. Returns the name of the created thumb image
    ///
    /// Returns an optional string when the temp image was not found
    func createThumbAndSave(fileName: String) throws -> String? {
       
        // load image at temp location
        let image = try LoadImageUseCase(name: fileName)?.loadImage()
        
        // save new thumb nail
        if let image {
            return try saveImage(image: image, isThumb: true)
        }
        return nil
    }
    
    func saveImage(image: UIImage, isThumb: Bool) throws -> String {
        
        let resizedImageData: Data?
        if isThumb {
            resizedImageData = image.strongResized()?.toStrongCompressedData()
        } else {
            resizedImageData = image.resizedToExternalDisplaySize()?.toData()
        }
        
        if let resizedImageData {
            return try saveImage(data: resizedImageData, location: .persitent)
        } else {
            throw SaveImageError.failedTransformingImage
        }
        
    }
    
    private func saveImage(data: Data, location: GetFileURLUseCase.Location) throws -> String {
        let getURLUseCase = GetFileURLUseCase(fileType: .jpg)
        let url = getURLUseCase.getURL(location: location)
        try data.write(to: url)
        return getURLUseCase.fileName
    }
    

    
}

private extension UIImage {
    
    func resized() -> UIImage? {
        resizeImage(targetSize: CGSize(width: externalDisplayWindowWidth, height: externalDisplayWindowHeight))
    }
    
    func resizedToExternalDisplaySize() -> UIImage? {
        resizeImage(targetSize: CGSize(width: externalDisplayWindowWidth, height: externalDisplayWindowHeight))
    }
    
    func strongResized() -> UIImage? {
        resized(toWidth: 500)
    }
    
    func toData() -> Data? {
        jpegData(compressionQuality: 0.9)
    }
    
    func toStrongCompressedData() -> Data? {
        jpegData(compressionQuality: 0.5)
    }
}


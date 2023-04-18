//
//  LabelPhotoPickerViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import PhotosUI

struct LabelPhotoPickerViewUI: View {
    
    let label: String
    @State private var selectedItem: PhotosPickerItem? = nil
    private var imageFromData: UIImage? {
        if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
            return uiImage
        }
        return nil
    }
    @State var selectedImageData: Data? = nil
    @Binding var selectedImage: UIImage?
    var didSelectItem: ((UIImage?) -> Void) = { _ in }
    
    var body: some View {
        
        HStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    HStack() {
                        Text(label)
                            .styleAs(font: .xNormal)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        Spacer()
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        // Retrieve selected asset in the form of Data
                        if let data = try? await
                            newItem?.loadTransferable(type: Data.self) {
                            if let image = UIImage(data: data) {
                                didSelectItem(image)
                                selectedImage = image
                            }
                            selectedImageData = data
                        }
                    }
                }
            
            if let selectedImage = selectedImage ?? imageFromData {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: getSizeWith(height: 40).width, height: 40)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.black.opacity(0.5))
                            .overlay(
                                Image(systemName: "trash")
                                    .foregroundColor(.white)
                                    .padding()
                                    .onTapGesture {
                                        self.selectedItem = nil
                                        self.selectedImageData = nil
                                        self.didSelectItem(nil)
                                    }
                            )
                    )
            }
            
            Image(systemName: "chevron.right").font(Font.system(.footnote).weight(.semibold))
                .padding()
        }
    }
}
struct LabelPhotoPickerViewUI_Previews: PreviewProvider {
    @State static var selectedImage: UIImage? = nil
    static var previews: some View {
        LabelPhotoPickerViewUI(label: AppText.NewTheme.backgroundImage, selectedImage: $selectedImage)
    }
}

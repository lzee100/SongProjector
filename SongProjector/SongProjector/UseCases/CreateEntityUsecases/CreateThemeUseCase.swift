//
//  CreateThemeUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

actor CreateThemeUseCase {
    
    private let context = newMOCBackground
    
    func create(with title: String = AppText.NewTheme.sampleTitle, isHidden: Bool = false) async throws -> ThemeCodable {
        try await ThemeCodable.makeDefault(title: title, isHidden: isHidden)!
    }
    
}

//
//  ErrorExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

enum ForcedLocalizedError: LocalizedError {
    case error(error: Error)
    
    var errorDescription: String {
        switch self {
        case .error(error: let error): return AppText.UnknownError.error(error)
        }
    }
}

extension Error {
    
    var forcedLocalizedError: LocalizedError {
        self as? LocalizedError ?? ForcedLocalizedError.error(error: self)
    }
}

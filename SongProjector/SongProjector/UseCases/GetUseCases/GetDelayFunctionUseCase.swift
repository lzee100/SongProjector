//
//  GetDelayFunctionUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct GetDelayFunctionUseCase {
    
    func delay(seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(((TimeInterval(exactly: seconds) ?? seconds) * 1_000_000_000).rounded()))
    }
    
}

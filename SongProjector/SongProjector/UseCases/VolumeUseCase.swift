//
//  VolumeUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct VolumeUseCase {
    
    private let instrument = "instrument"
    
    func set(volume: Float, instrumentType: InstrumentType) {
        UserDefaults.standard.setValue("1", forKey: instrumentType.rawValue + instrument)
        UserDefaults.standard.setValue(volume, forKey: instrumentType.rawValue)
    }
    
    func getVolumeFor(instrumentType: InstrumentType) -> Float? {
        guard UserDefaults.standard.string(forKey: instrumentType.rawValue + instrument) != nil else { return nil }
        return UserDefaults.standard.float(forKey: instrumentType.rawValue)
    }
}

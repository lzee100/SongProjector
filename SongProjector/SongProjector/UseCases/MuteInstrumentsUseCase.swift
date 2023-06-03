//
//  MuteInstrumentsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct MuteInstrumentsUseCase {
    
    private static let instrumentKey = "instrument"
    private let instrument: InstrumentCodable
    
    var isMuted: Bool {
        UserDefaults.standard.bool(forKey: Self.instrumentKey + instrument.id)
    }
    
    init(instrument: InstrumentCodable) {
        self.instrument = instrument
    }
    
    func update(isMuted: Bool) {
        UserDefaults.standard.setValue(isMuted, forKey: Self.instrumentKey + instrument.id)
    }
    
    static func resetMutes() async {
        let instruments = await GetClustersUseCase().fetch().flatMap { $0.hasInstruments }
        instruments.forEach { instrument in
            UserDefaults.standard.removeObject(forKey: Self.instrumentKey + instrument.id)
        }
    }
}

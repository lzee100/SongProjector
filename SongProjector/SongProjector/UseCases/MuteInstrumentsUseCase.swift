//
//  MuteInstrumentsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct MuteInstrumentsUseCase {
    
    private let instrument = "instrument"
    
    func setMuteFor(instrument: InstrumentCodable, isMuted: Bool) {
        UserDefaults.standard.setValue(isMuted, forKey: self.instrument + instrument.id)
    }
    
    func isMutedFor(instrument: InstrumentCodable) -> Bool {
        UserDefaults.standard.bool(forKey: self.instrument + instrument.id)
    }
    
    func resetMutes(completion: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            let moc = newMOCBackground
            let instruments = DataFetcher<Cluster>().getEntities(moc: moc).flatMap({ $0.hasInstruments(moc: moc) })
            instruments.forEach { instrument in
                UserDefaults.standard.removeObject(forKey: self.instrument + instrument.id)
            }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

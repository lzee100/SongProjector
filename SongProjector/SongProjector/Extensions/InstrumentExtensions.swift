//
//  InstrumentExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation


extension Instrument {
	
	
	
	
	var type : InstrumentType {
			get { return InstrumentType(typeString) }
			set { typeString = newValue.rawValue }
		}
		
}

enum InstrumentType : String {
	
	case pianoSolo
	case piano
	case guitar
	case bassGuitar
	case drums
	case unKnown
	
	// MARK: - Construction
	
	init(_ string: String?) {
		
		
		if let string = string,
			let soort = InstrumentType(rawValue: string) {
			self = soort
		} else {
			self = .unKnown
		}
	}
    
    var position: Int {
        switch self {
        case .piano: return 0
        case .guitar: return 1
        case .bassGuitar: return 2
        case .drums: return 3
        case .pianoSolo: return 4
        case .unKnown: return 5
        }
    }
}

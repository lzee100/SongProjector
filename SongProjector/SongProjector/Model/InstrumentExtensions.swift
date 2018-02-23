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
}

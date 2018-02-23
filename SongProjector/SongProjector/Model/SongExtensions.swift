//
//  SongExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation


extension Song {
	
	public var hasIntrumentsArray: [Instrument] {
		
		if let setHasInstruments = hasIntruments as? Set<Instrument> {
			return Array(setHasInstruments)
		} else {
			return []
		}
	}
	
	
}

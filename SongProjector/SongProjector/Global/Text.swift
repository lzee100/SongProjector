//
//  Text.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation


class Text: NSObject {
	
	struct Actions {
		static let cancel = "Annulleer"
		static let close = "Sluit"
		static let done = "Klaar"
	}
	
	struct SongService {
		static let title = "Zangdienst"
		static let titleTableClusters = "Liedjes"
		static let titleTableSheets = "Dia's"
	}
	
	struct NewSongService {
		static let selectedSongsDescription = "Hieronder staan de geselecteerde liedjes voor de zangdienst"
		static let songsDescription = "Zoek en selecteer hieronder de liedjes voor de zangdienst"
	}
	
	struct NewSongViewController {
		static let SongTitle = "Titel"
		static let Description = "Voer hier de tekst van het nummer in:"
		static let NoTitleForSheet = "Geen titel gevonden"
		static let Sheet = "Dia "
		static let SearchTagPlaceHolder = "Zoek categorie"
	}
	
	struct Songs {
		static let SearchSongPlaceholder = "Zoek dia's"
	}
	
	
	
	
	
	
}

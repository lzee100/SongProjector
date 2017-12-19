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
		static let new = "Nieuw"
		static let add = "Voeg toe"
	}
	
	struct SongService {
		static let title = "Zangdienst"
		static let titleTableClusters = "Liedjes"
		static let titleTableSheets = "Dia's"
	}
	
	struct NewSongService {
		static let title = "Nieuwe zangdienst"
		static let selectedSongsDescription = "Hieronder staan de geselecteerde liedjes voor de zangdienst"
		static let songsDescription = "Zoek en selecteer hieronder de liedjes voor de zangdienst"
		static let noSelectedSongs = "Geen liedjes geselecteerd."
	}
	
	struct NewSongViewController {
		static let title = "Nieuwe liedje"
		static let SongTitle = "Titel"
		static let Description = "Voer hier de tekst van het nummer in:"
		static let NoTitleForSheet = "Geen titel gevonden"
		static let Sheet = "Dia "
		static let SearchTagPlaceHolder = "Zoek categorie"
	}
	
	struct Songs {
		static let title = "Alle liedjes/presentaties"
		static let SearchSongPlaceholder = "Zoek dia's"
	}
	
	
	
	
	
	
}

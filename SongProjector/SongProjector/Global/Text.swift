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
		static let cancel = "Annuleer"
		static let close = "Sluit"
		static let done = "Klaar"
		static let new = "Nieuw"
		static let add = "Voeg toe"
		static let save = "Sla op"
		static let ok = "Ok"
		static let selectImage = "Selecteer afbeelding"
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
		static let noSelectedSongs = "Geen liedjes geselecteerd"
	}
	
	struct Songs {
		static let title = "Alle liedjes/presentaties"
		static let description = "Doorzoek hier alle liedjes of collecties"
		static let SearchSongPlaceholder = "Zoek dia's"
	}
	
	struct NewSong {
		static let title = "Nieuw liedje"
		static let SongTitle = "Titel"
		static let headerTag = "Selecteer hier de categorie"
		static let headerLyrics = "Voer hier de tekst van het nummer in"
		static let NoTitleForSheet = "Geen titel gevonden"
		static let Sheet = "Dia "
		static let SearchTagPlaceHolder = "Zoek categorie"
	}
	
	struct Tags {
		static let title = "Categorien"
		static let searchBarPlaceholderText = "Zoek categorie"
	}
	
	struct Players {
		static let title = "Geanimeerde presentaties"
	}
	
	struct DisplaySettings {
		static let title = "Opmaak"
	}
	
	struct NewTag {
		static let title = "Nieuwe categorie"
		static let descriptionTitle = "Naam nieuwe categorie"
		static let descriptionTitlePlaceholder = "Naam"
		static let pageDescription = "Voer een nieuwe categorie toe"
		static let errorTitle = "Fout"
		static let errorMessage = "Naam nieuwe categorie mag niet leeg zijn"
		
		static let sampleTitel = "Titel"
		static let sampleLyrics = "Lorem Ipsum is slechts een proeftekst uit het drukkerij- en zetterijwezen. Lorem Ipsum is de standaard proeftekst in deze bedrijfstak sinds de 16e eeuw."
		
		static let sectionGeneral = "Categorie"
		static let sectionTitle = "Titel"
		static let sectionLyrics = "Inhoud"
		static let sectionBackground = "Achtergrond"
		static let fontFamilyDescription = "Lettertype"
		static let fontSizeDescription = "Grootte lettertype"
		static let borderSizeDescription = "Dikte rand"
		static let borderColor = "Kleur rand"
		static let textColor = "Kleur lettertype"
		static let underlined = "Onderstreept"
		static let bold = "Vet"
		static let italic = "Cursief"
		static let backgroundImage = "Achtergrond afbeelding"
		static let buttonBackgroundImagePicker = "Kies afbeelding"
	
	}
	
	struct Sheet {
		static let emptySheetTitle = "Lege dia"
	}
	
}

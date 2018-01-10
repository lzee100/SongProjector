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
		static let edit = "Wijzig"
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
		static let title = "Alles"
		static let description = "Doorzoek hier alle liedjes of collecties"
		static let SearchSongPlaceholder = "Zoek dia's"
	}
	
	struct NewSong {
		static let title = "Nieuw liedje"
		static let SongTitle = "Titel"
		static let headerTag = "Selecteer hier de thema"
		static let headerLyrics = "Voer hier de tekst van het nummer in"
		static let NoTitleForSheet = "Geen titel gevonden"
		static let Sheet = "Dia "
		static let SearchTagPlaceHolder = "Zoek thema"
		static let errorTitleNoTag = "Fout"
		static let erorrMessageNoTag = "Selecteer een thema"
		static let segmentTitleText = "Tekst"
		static let segmentTitleSheets = "Dia's"
	}
	
	struct Tags {
		static let title = "Thema's"
		static let searchBarPlaceholderText = "Zoek thema's"
	}
	
	struct Players {
		static let title = "Afspelers"
		
		static let menuEmptySheet = "Lege dia"
		static let menuTextSheet = "Text dia"
		static let menuImageSheet = "Dia met foto"
	}
	
	struct DisplaySettings {
		static let title = "Opmaak"
	}
	
	struct NewTag {
		static let title = "Nieuw thema"
		static let descriptionTitle = "Naam nieuw thema"
		static let descriptionTitlePlaceholder = "Naam"
		static let descriptionAsTag = "Gelijk aan thema"
		static let descriptionTitleBackgroundColor = "Achtergrond kleur"
		static let pageDescription = "Voer een nieuwe thema's toe"
		static let descriptionBackgroundColor = "Kleur achtergrond"
		static let descriptionHasEmptySheet = "Toon lege dia"
		static let descriptionHasEmptySheetDetail = "Aan het einde of begin van een lied een lege dia tonen met ingestelde achtergrond"
		static let descriptionAllTitle = "Titel op elke dia"
		static let descriptionPositionEmptySheet = "Toon lege dia aan begin\n(uit is aan het einde tonen)"
		static let descriptionLastBeamerResolution = "Laast bekende beamer resolutie:\n"
		
		static let descriptionAlignment = "Uitlijning"
		static let errorTitle = "Fout"
		static let errorMessage = "Naam nieuwe thema mag niet leeg zijn"
		
		static let alignLeft = "Links"
		static let alignCenter = "Midden"
		static let alignRight = "Rechts"
		
		static let sampleTitle = "Titel"
		static let sampleLyrics = "Lorem Ipsum is slechts een proeftekst uit het drukkerij- en zetterijwezen. Lorem Ipsum is de standaard proeftekst in deze bedrijfstak sinds de 16e eeuw."
		
		static let sectionGeneral = "Algemeen"
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
		static let buttonBackgroundImagePick = "Kies afbeelding"
		static let buttonBackgroundImageChange = "Wijzig afbeelding"
	
	}
	
	struct Sheet {
		static let emptySheetTitle = "Lege dia"
	}
	
	struct More {
		static let title = "Meer"
	}
	
}

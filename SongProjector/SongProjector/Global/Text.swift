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
		static let `import` = "Importeer"
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
		static let menuTitle = "Toevoegen"
	}
	
	struct NewSong {
		static let title = "Nieuw liedje"
		static let SongTitle = "Titel"
		static let headerTag = "Selecteer hier het thema"
		static let headerLyrics = "Voer hier de tekst van het nummer in"
		static let NoTitleForSheet = "Geen titel gevonden"
		static let Sheet = "Dia "
		static let SearchTagPlaceHolder = "Zoek thema"
		static let errorTitleNoTag = "Fout"
		static let erorrMessageNoTag = "Selecteer een thema"
		static let segmentTitleText = "Tekst"
		static let segmentTitleSheets = "Dia's"
		static let generateSheetsButton = "Genereer dia's"
		static let titlePlaceholder = "Voer hier een titel in"
		static let addSheet = "Voeg dia toe"
		static let changeLyrics = "Wijzig zangtekst"
		static let newLyrics = "Nieuwe zangtekst"
		static let changeTitleTime = "Wijzig titel & tijdsduur"

	}
	
	struct Tags {
		static let title = "Thema's"
		static let searchBarPlaceholderText = "Zoek thema's"
	}
	
	struct CustomSheets {
		static let title = "Speciale dia's"
		static let namePlaceHolder = "Voer titel in (voor zoeken)"
		static let errorTitle = "Fout"
		static let errorNoName = "Geen titel ingevoerd"
		static let segmentInput = "Invoeren"
		static let segmentCheck = "Controle"
		static let segmentSheets = "Dia's"
		static let segmentChange = "Aanpassen"
		static let descriptionName = "Groepnaam"
		static let descriptionTime = "Dia's afspelen om de x seconden"
		static let descriptionTimeAdd = "0: is niet automatisch afspelen"
		
		static let tableViewHeaderGeneral = "Algemeen"
		static let tableViewHeaderSheets = "Dia's"
		
		static let titleMenu = "Dia's toevoegen"
	}
	
	struct Settings {
		static let title = "Instellingen"
		static let descriptionGoogleSub = "Login om activiteiten op te halen"
		static let descriptionCalendarId = "Google agenda ID"
		
		static let descriptionInstructions = "Handleiding"
		static let instructions = """
			Voor het implementeren van Google agenda activiteiten in de app is het nodig
			om de volgende stappen te doorlopen: \n\n
			
			Ten eerste is de ID van de agenda nodig. Een handleiding hiervoor kan je vinden
			op Google door te zoeken op 'Finding Your Google Calendar ID'.
			De ID moet vervolgens ingevuld worden voordat de activiteiten van die kalender
			opgehaald kunnen worden. \n\n
			
			Ga vervolgens naar https://console.developers.google.com/apis/api/calendar/overview.
			Login met het account waarvoor je ook de activiteiten in de app wilt tonen. Ga naar
			Dashboard en klik vervolgens op 'Api's en services inschakelen'. Zoek naar
			"Google Calendar API". Klik daarop en klik daarna op Inschakelen. \n\n

			Het kan een aantal minuten duren voordat de agenda beschikbaar is voor de app.
			
			"""
			
		static let descriptionGoogle = "Google account"
		static let errorTitleGoogleAuth = "Fout in authenticatie"
		static let googleSignOutButton = "Uitloggen"
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
		static let descriptionBackgroundTransparency = "Transparantie achtergrond"
		static let descriptionDisplayTime = "Weergave tijd"
		static let descriptionDarkBlurTitleBackground = "Blur achtergrond"
		
		static let descriptionAlignment = "Uitlijning"
		static let errorTitle = "Fout"
		static let errorMessage = "Naam nieuwe thema mag niet leeg zijn"
		
		static let alignLeft = "Links"
		static let alignCenter = "Midden"
		static let alignRight = "Rechts"
		
		static let sampleTitle = "Titel"
		static let sampleLyrics = "Lorem Ipsum is slechts een proeftekst uit het drukkerij- en zetterijwezen. Lorem Ipsum is de standaard proeftekst in deze bedrijfstak sinds de 16e eeuw."
		
		static let sectionGeneral = "Algemeen"
		static let sectionInput = "Invoer"
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
	
	struct SheetsMenu {
		static let sheetTitleText = "Dia titel met tekst"
		static let sheetTitleImage = "Dia: titel met foto"
		static let sheetPastors = "Dia gebed pastors"
		static let sheetSplit = "Dia 2 segmenten"
		static let sheetEmpty = "Lege dia"
		static let bibleStudyGen = "Bijbelstudie dia generator"
		static let sheetActivity = "Google activiteiten dia"
	}
	
	struct SheetPickerMenu {
		static let pickSong = "Nieuw lied"
		static let pickCustom = "Aangepaste dia's"
	}
	
	struct More {
		static let title = "Meer"
	}
	
	struct Google {
		static let title = "Google agenda"
	}
	
	struct BibleStudy {
		static let title = "Bijbelstudie"
	}
	
	struct NewSheetTitleImage {
		static let title = "Foto opties"
		static let descriptionTitle = "Titel"
		static let descriptionTextLeft = "Tekst links"
		static let descriptionTextRight = "Tekst rechts"
		static let descriptionContent = "Tekst"
		static let descriptionImage = "Foto"
		static let descriptionImageHasBorder = "Foto heeft rand"
		static let descriptionImageBorderSize = "Dikte rand"
		static let descriptionImageBorderColor = "Kleur rand"
		static let descriptionImageContentMode = "Positionering foto"
		
		static let placeholderContent = "tekst"

	}
	
	struct newPastorsSheet {
		static let title = "Pastor John and Jessie Doe"
		static let content = "Mexico city"
		static let photoDescription = "Vierkante foto waarbij de gezichten in het midden zijn"
		
	}
	
	struct ActivitySheet {
		static let titleThisWeek = "Deze week"
		static let titleNextWeek = "Volgende week"
		static let titleUpcomingTime = "Komende tijd"
		static let descriptionNoActivities = "Geen activiteiten gepland"
		static let previewDescription = "Activiteitomschrijving uit de google agenda"
		static let dayActivity = "Hele dag"
	}
	
	struct  Import {
		static let title = "Importeer bijbel"
		static let description = "Voeg hieronder de bijbeltest toe die je wilt importeren."
	}
	
}

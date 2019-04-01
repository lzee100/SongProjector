//
//  Text.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation


class Text: NSObject {
	
	struct environments {
		static let localHost = "Localhost"
		static let development = "Ontwikkel"
		static let production = "Productie"
	}
	
	struct Generic {
		static let from = "van"
		static let to = "tot"
	}
	
	struct Actions {
		static let cancel = "Annuleer"
		static let close = "Sluit"
		static let done = "Klaar"
		static let new = "Nieuw"
		static let add = "Voeg toe"
		static let next = "Volgende"
		static let save = "Sla op"
		static let ok = "Ok"
		static let edit = "Wijzig"
		static let send = "Verstuur"
		static let selectImage = "Selecteer afbeelding"
		static let `import` = "Importeer"
	}
	
	struct Intro {
		
		static let IntroHalloTitle = "Hallo"
		static let IntroHalloContent = "Welkom bij Churchbeam. Deze app ondersteund de gehele voordienst in jouw kerk. "
		static let IntroNewTitle = "Nieuw"
		static let IntroNewContent = "Er zijn drie verschillende versies die je kan afnemen. Bij de betaalde versies krijg je 2 maanden gratis om te proberen. Daarna zal je gevraagd worden of je verder wilt gaan."
		
		static let FreeTitle = "Gratis"
		static let FreeFeatures = """
		• Maximaal 10 eigen nummers opslaan\n
		• Onbeperkt aantal eigen thema's opslaan\n
		• Onbeperkt bijbelteksten dia's genereren en opslaan\n
		• Maximaal 1 apparaat
		"""
		static let FreeButton = "Gratis"
		
		static let BeamTitle = "Beam"
		static let BeamFeatures = """
		• Onbeperkt aantal eigen nummers opslaan\n
		• Onbeperkt aantal eigen thema's opslaan\n
		• Meerdere gebruikers mogelijk: 3 euro per gebruiker
		"""
		static let BeamButton = "€6,- per maand"

		static let SongTitle = "Song"
		static let SongFeatures = """
		• Onbeperkt aantal eigen nummers opslaan\n
		• Onbeperkt bijbelteksten dia's genereren en opslaan\n
		• Maximaal 1 apparaat\n
		• 60 nummers met tekst en muziek
		"""
		static let SongButton = "€10 per maand"

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
		static let headerTheme = "Selecteer hier het thema"
		static let headerLyrics = "Voer hier de tekst van het nummer in"
		static let NoTitleForSheet = "Geen titel gevonden"
		static let Sheet = "Dia "
		static let SearchThemePlaceHolder = "Zoek thema"
		static let errorTitleNoTheme = "Fout"
		static let erorrMessageNoTheme = "Selecteer een thema"
		static let segmentTitleText = "Tekst"
		static let segmentTitleSheets = "Dia's"
		static let generateSheetsButton = "Genereer dia's"
		static let titlePlaceholder = "Voer hier een titel in"
		static let addSheet = "Voeg dia toe"
		static let changeLyrics = "Wijzig zangtekst"
		static let newLyrics = "Nieuwe zangtekst"
		static let changeTitleTime = "Wijzig titel & tijdsduur"

	}
	
	struct Themes {
		static let title = "Thema's"
		static let searchBarPlaceholderText = "Zoek thema's"
	}
	
	struct Tags {
		static let title = "Tags"
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
	
	struct Users {
		static let title = "Gebruikersbeheer"
		static let ActiveUsers = "Actieve gebruikers"
		static let InactiveUsers = "Inactieve gebruikers"
		static let sendCode = "Verstuur code"
		static let months = "maanden"
		static let month = "maand"
		static let noEmail = "Je hebt geen email account ingesteld op je iPhone."
		static let noInviteToken = "Deze gebruiker heeft geen uitnodigingscode. Creeër een nieuwe gebruiker"
		
		static let inviteConformationTitle = "E-mail gebruiker"
		static let inviteEmailSubject = "ChurchBeam uitnodigingscode"
		static func inviteTextBodyEmail(code: String) -> String {
			return """
				Hallo,

				Je bent uitgenodigd om gebruik te gaan maken van de ChurchBeam app. De app is te downloaden in de AppStore. In de app kan je een koppelcode invoeren om deel te worden van een kerk. Gebruik hiervoor onderstaande koppelcode:
			

			""" + code +
			"""
			\n
			Met vriendelijke groet,
			
			ChurchBeam
			"""
		}
		static func inviteTextBody(code: String) -> String {
			return "Om de gebruiker uit te nodigen hebben we een email adres nodig. De gebruiker ontvangt een email de koppelcode: " + code
		}

	}
	
	struct SongServiceManagement {
		static let title = "Beheer zangdienst"
		static let numberOfSections = "Aantal secties"
		static let section = "Sectie"
		static let nameSection = "Naam sectie"
		static let addTags = "Voeg tags toe"
		static let name = "Naam"
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
	
	struct NewTheme {
		static let title = "Nieuw thema"
		static let descriptionTitle = "Naam nieuw thema"
		static let descriptionTitlePlaceholder = "Naam"
		static let descriptionAsTheme = "Gelijk aan thema"
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

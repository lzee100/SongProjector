//
//  Text.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation


class AppText: NSObject {
	
	struct environments {
		static let localHost = "Localhost"
		static let development = "Ontwikkel"
		static let production = "Productie"
	}
	
	struct Generic {
		static let from = "van"
		static let to = "tot"
        static let vandaag = "Vandaag"
        static let morgen = "Morgen"
        
        static let errorGeneratingDataForImage = "Kon geen data genereren van de foto"
	}
	
	struct Actions {
		static let cancel = "Annuleer"
		static let close = "Sluit"
		static let done = "Klaar"
        static let delete = "Verwijder"
		static let new = "Nieuw"
		static let add = "Voeg toe"
		static let next = "Volgende"
		static let save = "Sla op"
		static let ok = "Ok"
		static let edit = "Wijzig"
        static let `continue` = "Doorgaan"
		static let send = "Verstuur"
		static let selectImage = "Selecteer afbeelding"
		static let `import` = "Importeer"
		static let upload = "Upload"
        static let restore = "Herstel"
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
		
        static func featureIntro(price: String) -> String {
            return "Voor \(price) per maand krijg je onbeperkt toegang tot:"
        }
        static var featuresSong: [String] {
            return ["Onbeperkt aantal nummers, thema's en labels opslaan", "Automatische generatie van dia's voor bijbelteksten", "Automatisch genererende diensten", "Automatisch downloaden van nummers met tekst en muziek", "Instrumenten individueel mengbaar", "Google agenda integratie" ]
        }
        static var featuresBeam: [String] {
            return ["Onbeperkt aantal nummers, thema's en labels opslaan", "Automatische generatie van dia's voor bijbelteksten", "Automatisch genererende diensten", "Google agenda integratie" ]
        }
        static let cancelMonthly = "(Maandelijks opzegbaar)"
        
        static let subscribe = "Abonneer"
		
		static let GoogleSignIn = "Sign-In"
		static let GoogleSignInDescription = "Bij deze app kan je inloggen met je google account. Heb je al een account aangemaakt bij Churchbeam?"
		static let ClickOnButtonToLogin = "Klik op onderstaande knop om in te loggen met je Google account."
		static let NewAccountOnGoogleAccount = "Klik op onderstaande knop om een nieuw account aan te maken op basis van je Google account."
        
        static let loginWithChurchGoogle = "Churchbeam zou gebruik kunnen maken van je Google agenda om jouw kerkactiviteiten automatisch te tonen voordat of nadat de dienst begint. Om die reden is het handig om in te loggen met het Google account van je kerk (of die eerst aan te maken bij Google). Je kan ook inloggen met je Apple account, in dat geval moet je nog apart inloggen met je Google account om je kerk activiteiten op te halen uit je Google agenda."
        
        static let calendarIdExplain = "Voer hieronder je Google agenda id in. ChurchBeam kan dan automatisch je kerkactiviteiten tonen in een slider."
        static let calendarIdFindId = "Hoe vind ik die?"
        
        static let thisIsYourAdminCode = "Dit is jouw Admin code. Bewaar deze goed. Deze is voor het toegang krijgen van je admin account wanneer je de app opnieuw wil gaan installeren."
        static let adminEnterCode = "Wil je inloggen als admin, voer dan je admin code hieronder in. Anders klik op " + AppText.Actions.done

        static let adminCodeWrong = "De ingevoerde code is niet juist."
        static let couldNotFindUser = "Kon geen gebruiker vinden. Installeer de app opnieuw en probeer het nogmaals."
        
        static let seeExample = "(Zie voorbeeld hieronder)."
        static let explainCalendarId = "Om je kerkactiviteiten automatisch weer te geven wil deze app verbinding maken met jouw agenda. Daarvoor is een agenda id nodig. Om deze te vinden moet je de volgende stappen doorlopen. Ga in een webbrowser naar calendar.google.com om je agenda te zien. Log eventueel eerst in met je kerk gmail account. Aan de linkerkant vind je jouw agenda's. \(seeExample)"
        static let hoverForDots = "Hou de muis op de agenda die je wilt delen zodat er een optie (3 stippeltjes) icoontje aan de rechterkant verschijnt. Klik hierop.  \(seeExample)"
        static let goToSettingsAndSharing = "Klik daarna op Instellingen en Delen. \(seeExample)"
        static let goToIntegrate = "In het menu aan de linker kant klik op Agenda integreren. \(seeExample)"
        static let topShowsCalendarId = "Bovenaan dit artikel staat jouw Agenda-ID. \(seeExample)"
        static let titleFindCalendarId = "Vind Agenda-ID"
        static func errorLoginApple(error: Error) -> String {
            return "Er ging iets mis bij het inloggen met Apple: \(error.localizedDescription)"
        }

	}
	
	struct SongService {
		static let title = "Zangdienst"
		static let titleTableClusters = "Liedjes"
		static let titleTableSheets = "Dia's"
        static let warnCannotPlay = "Het lijkt erop dat een andere gebruiker de zangdienst gestart is met dit account. Er kunnen geen twee zangdiensten tegelijk actief zijn. Je kan de zangdienst eventueel starten vanaf het admin account."
	}
	
	struct NewSongService {
		static let title = "Nieuwe zangdienst"
		static let selectedSongsDescription = "Hieronder staan de geselecteerde liedjes voor de zangdienst"
		static let songsDescription = "Zoek en selecteer hieronder de liedjes voor de zangdienst"
		static let noSelectedSongs = "Geen liedjes geselecteerd"
		static let notEnoughSongsForTagSection = "Niet genoeg liedjes in deze categorie."
        static let notEnoughSongsForTagSectionAlertBody = "Er zijn niet genoeg liedjes voor elke categorie. Maak liedjes aan voor de categorie die nu geen liedjes heeft. Klik op \(Actions.continue) om af te sluiten zonder gekozen liedjes of op \(Actions.cancel) om hier te blijven."
        
        static func shareSongServiceText(date: String) -> String {
            return "Zangdienst \(date)"
        }
        static let morning = "morgen"
        static let evening = "avond"
        
        static let popupGenerateSongServiceTitle = "Genereer (zang)dienst automatisch"
        static let popupGenerateSongServiceDescription = """
            Je kan automatisch je (zang)dienst laten genereren door je telefoon te schudden op dit scherm. Hiervoor moet je eerst een dienst volgorde maken. Dit werkt als volgt:

            Maak eerst labels aan. Ga hiervoor naar het "Meer" tabje en maak labels aan. Labels gebruik je om presentaties (zangdienstnummers en meer) te labelen.

            Ga naar "Zangdienst instellingen" onder het tabje "Meer". Maak jouw zangdienst volgorde aan. Hierbij stel je in uit welke secties jouw dienst bestaat, zoals bijvoorbeeld snelle nummers, aanbiddingnummers, collecte nummers of nummers bij een oproep of einde van de dienst, gebedsverlangens of bijbelteksten bij de preek enz. Oftewel alles waar jij dia's bij wil hebben. Onder deze secties vallen dan een of meerdere labels. Jouw nummers kan je labelen waardoor deze automatisch in deze sectie geplaats zullen worden. Dus een presentatie heeft labels en labels vallen onder een sectie van jouw dienst.

            Nadat je de volgorde hebt bepaald moet je de presentaties (zangdienstnummers) labelen onder het tabje "Collecties". Geef je presentaties een of meerdere labels en bij het schudden van je mobiel op dit scherm maakt de app een (zang)dienst aan jouw secties en pakt hij automatisch de nummers die bij de labels van de desbetreffende sectie horen.

            Probeer het nu!
            """
        static let dontShowAgain = "Toon niet meer"
        static let showMeLater = "Toon later"
        static let swipeToDeleteHint = "Verwijder door naar links te swipen"
        static let shakeToGenerate = "Schud je iPhone om een zangdienst te genereren."
        static let shareOptionsTitle = "Wat wil je van de zangdienst delen?"
        static let shareOptionTitles = "Alleen de titels"
        static let shareOptionTitlesWithSections = "Alleen de secties en titels"
        static let shareOptionLyrics = "Titels en tekst"
        static let shareOptionLyricsWithSections = "Secties, titels en tekst"
	}
	
	struct Songs {
		static let title = "Collecties"
		static let description = "Doorzoek hier alle liedjes of collecties"
		static let SearchSongPlaceholder = "Zoek dia's"
		static let menuTitle = "Toevoegen"
        static func deleteTitle(songName: String) -> String {
            return "Verwijder \(songName)"
        }
        static func deleteBody(songName: String) -> String {
            return "Weet je zeker dat je \(songName) wilt verwijderen? Verwijderde liedjes kan je eventueel weer terug terug krijgen onder het tabje \"Verwijderde liedjes\"."
        }
        static let deleteMusicTitle = "Verwijder muziek"
        static func deleteMusicBody(songName: String) -> String {
            return "Weet je zeker dat je de muziek van \(songName) wilt verwijderen? Verwijderde muziek kan je eventueel weer terug terug krijgen door op de downloadknop te klikken van dit liedje."
        }
        static let restoreTitle = "Herstel"
        static func restoreBody(songName: String) -> String {
            return "Weet je zeker dat je \(songName) wilt herstellen? Je ziet dit nummer dan opnieuw in de lijst met jouw nummers."
        }
        static let errorNoUserFound = "We konden je identiteit niet bevestigen. Log opnieuw in onder instellingen."
	}
	
	struct NewSong {
		static let title = "Titel"
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
    
    struct Lyrics {
        static let titleBibleText = "Voer bijbelteksten in"
        static let titleLyrics = "Voer tekst in"
        static let placeholderBibleText = "1In het begin maakte God de hemelen en de aarde. 2De aarde was woest en leeg en over de watermassa lag een diepe duisternis. Maar de Geest van God zweefde boven de watermassa.\nGenesis 1:1\n\n16 Want God heeft zoveel liefde voor de wereld dat Hij zijn enige Zoon heeft gegeven, zodat ieder die in Hem gelooft, niet verloren gaat maar eeuwig leven heeft.\nJohannes 3:16"
        static let placeholderLyrics = "Schrijf of plak hier de tekst van het nummer"
    }
	
	struct Themes {
		static let title = "Thema's"
		static let searchBarPlaceholderText = "Zoek thema's"
	}
	
	struct Tags {
		static let title = "Tags"
        static let placeholder = "Zoek tags"
        static let newTag = "Nieuwe tag"
        static let name = "Naam"
        static let deletedClusters = "Verwijderde items"
        
	}
	
	struct CustomSheets {
		static let title = "Wijzig dia's"
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
        static let errorSelectTheme = "Selecteer een thema"
        static let errorLoseOtherSheets = "Je hebt andere sheets tussen de bijbelteksten staan. Deze gaan verloren wanneer je de bijbelteksten aanpast en opnieuw laat genereren"

        static let universalSongEditErrorTitle = "Kon tekst niet aanpassen"
        static let universalSongEditErrorMessage = "Dit nummer heeft muziek en heeft een weergave tijdsduur bij elke dia. Het aanpassen van het AANTAL dia's zorgt ervoor dat de tijden niet meer kloppen. Je wijzigingen zijn ongedaan gemaakt."
        
        
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
		static let numberOfSongs = "Aantal liedjes: "
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
			De ID moet vervolgens ingevuld worden voordat de activiteiten van die agenda
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
		static let sheetTimeOffsetError = "De ingevoerde waarde kan niet gebruikt worden."
		static let sheetTimeOffset = "Correctie van de tijd waarop de sheets verplaatsen."
		static let sheetTimeOffsetPlaceholder = "Seconden als 0.34 of 2"
		static let SectionSongServiceSettings = "Zangdienst instellingen"
		static let SectionGmailAccount = "Gmail account"
        static let SectionCalendarId = "Google agenda ID"
        static let CalendarIdPlaceHolder = "Google agenda id"
        static let Appversion = "Versie: "

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
        static let sectionSongs = "Liedjes"
        static let sectionOther = "Andere dia's"
        static let sectionBibleStudy = "Bijbelstudie"
        
        static let lyrics = "Tekst liedje"
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
        static let whichSheet = "Welke type dia(s) wil je aanmaken?"
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
		static let photoDescription = "Kies een vierkante foto waarbij de gezichten in het midden zijn."
		
	}
	
	struct ActivitySheet {
		static let titleThisWeek = "Deze week"
		static let titleNextWeek = "Komende week"
		static let titleUpcomingTime = "Komende tijd"
		static let descriptionNoActivities = "Geen activiteiten gepland"
		static let previewDescription = "Activiteitomschrijving uit de google agenda"
		static let dayActivity = "Hele dag"
	}
	
	struct Import {
		static let title = "Importeer bijbel"
		static let description = "Voeg hieronder de bijbeltest toe die je wilt importeren."
	}
	
	struct UploadUniversalSong {
		static let previewButtonTitle = "Preview"
		static let title = "Upload universal liedje"
		static let selecteerSheet = "Creeer/bewerk dia's"
		static let showPreview = "Toon preview"
		static let noSheets = " (Nog geen sheets)"
		static let titlePlaceholder = "Niet voor zangdienst nummer"
		static let noThemeWarning = "Geen thema beschikbaar. Maak eerst een theme aan."
		static let new = "Nieuw"
        static let selectChurch = "Selecteer kerk"
        static let startTime = "Start tijd" // for countdown
        static let defaultTheme = "Basis thema"
        static let shareSheetTimes = "Deel sheettijden"

	}
    
    struct AboutController {
        static let title = "Contactinformatie"

        static let sectionAbout = "Over de ontwikkelaar"
        static let infoText = "Hey, mijn naam is Leo van der Zee. Voor een aantal jaren heb ik naast mijn baan deze app ontwikkeld. Mijn visie is om de diensten van kleine kerken te verbeteren zodat zij:\n- grotere mate van aanbidding kunnen ervaren zodat er een vergroting van het werk van God in het hart zal plaatsvinden.\n- een betere aansluiting bij de verwachtingen die bezoekers hebben van vandaag de dag\n- een vergroting van de betrokkenheid van de kerk krijgen\n- meer ruimte voor de voorganger krijgt zodat hij met mensen bezig kan zijn\n\nHopelijk helpt de app jou en de kerk verder."
        static let sectionStartContact = "Neem contact op"
        static let contactInfo = "Mocht je vragen of problemen hebben, neem dan gerust contact op."
        static let contact = "Contact"
        
        static let errorNoMail = "Je hebt geen mail account op je telefoon ingesteld. Stel een mail account in onder settings."

    }
    
    struct SingInGoogleController {
        static let title = "Inloggen Agenda"
        static let infoText = "Om de activiteiten op te halen uit je kerk agenda is het nodig om in te loggen bij Google agenda. Klik hieronder om (opnieuw) in te loggen bij Google."
    }
    
    struct RequesterErrors {
        static func failedSavingImageLocallyBeforeSubmit(requester: String, error: Error) -> String {
            return "Kon media niet op apparaat opslaan voor \(requester): \(error.localizedDescription)"
        }
        static func failedDownloadingMedia(requester: String, error: Error) -> String {
            return "Kon media niet downloaden voor \(requester): \(error.localizedDescription)"
        }
        static func failedUploadingMedia(requester: String, error: Error) -> String {
            return "Kon media niet uploaden voor \(requester): \(error.localizedDescription)"
        }
        static func wrongMethodForSubmitting(requester: String) -> String {
            return "Onjuiste methode voor indienen van request voor \(requester)"
        }
        static func unAuthorizedNoUser(requester: String) -> String {
            return "Niet geauthoriseerd om dit te doen. Kon geen gebruiker vinden voor \(requester)"
        }
        static func allreadyHasAnUser(requester: String) -> String {
            return "Fout: er is al een gebruiker voor \(requester)"
        }
        static func hasNoThemeForUniversalCluster(requester: String) -> String {
            return "Er is geen thema gevonden voor universeel nummer voor \(requester)"
        }
        static func hasNoChurchForUniversalCluster(requester: String) -> String {
            return "Er is geen kerk gevonden voor universeel nummer voor \(requester)"
        }
        static func failedFetchingSavingCoreData(requester: String, error: Error) -> String {
            return "Fout in opslaan data voor \(requester), error: \(error.localizedDescription)"
        }
        static func failedDecoding(requester: String) -> String {
            return "Fout in decoden data: \(requester)"
        }
        static func failedEncoding(requester: String) -> String {
            return "Fout in encoden data: \(requester)"
        }
        static func errorOnFireBase(requester: String, error: Error) -> String {
            return "Fout op google cloud voor \(requester): \(error)"
        }
        static func errorSavingTempImage(requester: String, error: Error) -> String {
            return "Fout in het lokaal opslaan van image voor versturen \(requester): \(error)"
        }
        static func notConnectedToNetwork() -> String {
            return "Geen verbinding met internet"
        }
        static func unknown(requester: String, error: Error) -> String {
            return "Onbekende fout voor \(requester): \(error.localizedDescription)"
        }
    }
    
    struct IAPErrors {
        static let paymentNotAllowed = "Je hebt geen toestemming om betalingen te doen"
        static let busyPurchasing = "Er is al een transactie gaande."
        static func unableToReadReceipt(error: Error?) -> String {
            return ["Kon transactie niet lezen", error?.localizedDescription].compactMap({ $0 }).joined(separator: ": ")
        }
        static func unableToGetReceipt(error: Error?) -> String {
            return ["Kon transactie niet ophalen", error?.localizedDescription].compactMap({ $0 }).joined(separator: ": ")
        }
        static func unableToPurchage(error: Error?) -> String {
            return ["Fout in het verwerken van je aanschaf", error?.localizedDescription].compactMap({ $0 }).joined(separator: ": ")
            
        }
        static func unableToReachStore(error: Error?) -> String {
            return ["Fout in de data van de appstore", error?.underlyingErrorDescription ?? error?.localizedDescription].compactMap({ $0 }).joined(separator: ": ")
        }
    }


}

private extension Error {
    var underlyingErrorDescription: String? {
        return ((self as NSError).userInfo["NSUnderlyingError"] as? Error)?.localizedDescription
    }
}

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
		static let localHost = NSLocalizedString("Environments-localHost", comment: "")
		static let development = NSLocalizedString("Environments-development", comment: "")
		static let production = NSLocalizedString("Environments-production", comment: "")
	}
	
	struct Generic {
		static let from = NSLocalizedString("Generic-from", comment: "")
		static let to = NSLocalizedString("Generic-to", comment: "")
        static let vandaag = NSLocalizedString("Generic-vandaag", comment: "")
        static let morgen = NSLocalizedString("Generic-morgen", comment: "")
        static let loginError = NSLocalizedString("Generic-loginError", comment: "")

        static let errorGeneratingDataForImage = NSLocalizedString("Generic-errorGeneratingDataForImage", comment: "")
	}
	
	struct Actions {
		static let cancel = NSLocalizedString("Actions-cancel", comment: "")
		static let close = NSLocalizedString("Actions-close", comment: "")
		static let done = NSLocalizedString("Actions-done", comment: "")
        static let delete = NSLocalizedString("Actions-delete", comment: "")
		static let new = NSLocalizedString("Actions-new", comment: "")
		static let add = NSLocalizedString("Actions-add", comment: "")
		static let next = NSLocalizedString("Actions-next", comment: "")
		static let save = NSLocalizedString("Actions-save", comment: "")
		static let ok = NSLocalizedString("Actions-ok", comment: "")
		static let edit = NSLocalizedString("Actions-edit", comment: "")
        static let `continue` = NSLocalizedString("Actions-continue", comment: "")
		static let send = NSLocalizedString("Actions-send", comment: "")
		static let selectImage = NSLocalizedString("Actions-selectImage", comment: "")
		static let `import` = NSLocalizedString("Actions-import", comment: "")
		static let upload = NSLocalizedString("Actions-upload", comment: "")
        static let uploading = NSLocalizedString("Actions-uploading", comment: "")
        static let restore = NSLocalizedString("Actions-restore", comment: "")
        static let generateSongService = NSLocalizedString("Actions-generateSongService", comment: "")
        static let share = NSLocalizedString("Actions-share", comment: "")
        static let change = NSLocalizedString("Actions-change", comment: "")
	}
	
	struct Intro {
		
		static let introHalloTitle = NSLocalizedString("Intro-introHalloTitle", comment: "")
		static let introHalloContent = NSLocalizedString("Intro-introHalloContent", comment: "")
        
        static func featureIntro(price: String) -> String {
            let formatString = NSLocalizedString("Intro-featureIntro",
                                     comment: "")
            return String.localizedStringWithFormat(formatString, price)
        }
        static var featuresSong: [String] {
            var features: [String] = []
            for index in 1...7 {
                features.append(NSLocalizedString("Intro-featuresSong\(index)", comment: ""))
            }
            return features
        }
        static var featuresBeam: [String] {
            var features: [String] = []
            for index in 1...5 {
                features.append(NSLocalizedString("Intro-featuresBeam\(index)", comment: ""))
            }
            return features
        }
        static let cancelMonthly = NSLocalizedString("Intro-cancelMonthly", comment: "")
        
        static let subscribe = NSLocalizedString("Intro-subscribe", comment: "")
		
		static let googleSignIn = NSLocalizedString("Intro-googleSignIn", comment: "")
		static let googleSignInDescription = NSLocalizedString("Intro-googleSignInDescription", comment: "")
		static let clickOnButtonToLogin = NSLocalizedString("Intro-clickOnButtonToLogin", comment: "")
		static let newAccountOnGoogleAccount = NSLocalizedString("Intro-newAccountOnGoogleAccount", comment: "")
        
        static let loginWithChurchGoogle = NSLocalizedString("Intro-loginWithChurchGoogle", comment: "")
        
        static let calendarIdExplain = NSLocalizedString("Intro-calendarIdExplain", comment: "")
        static let calendarIdFindId = NSLocalizedString("Intro-calendarIdFindId", comment: "")
        
        static let thisIsYourAdminCode = NSLocalizedString("Intro-thisIsYourAdminCode", comment: "")
        static var adminEnterCode: String {
            return String(format: NSLocalizedString("Intro-adminEnterCode", comment: ""), AppText.Actions.done)
        }
        static let adminCodeWrong = NSLocalizedString("Intro-adminCodeWrong", comment: "")
        static let couldNotFindUser = NSLocalizedString("Intro-couldNotFindUser", comment: "")
        
        static let seeExample = NSLocalizedString("Intro-seeExample", comment: "")
        static var explainCalendarId: String {
            return String(format: NSLocalizedString("Intro-explainCalendarId", comment: ""), seeExample)
        }
        static var hoverForDots: String {
            return String(format: NSLocalizedString("Intro-hoverForDots", comment: ""), seeExample)
        }
        static var goToSettingsAndSharing: String {
            return String(format: NSLocalizedString("Intro-goToSettingsAndSharing", comment: ""), seeExample)
        }
        static var goToIntegrate: String {
            return String(format: NSLocalizedString("Intro-goToIntegrate", comment: ""), seeExample)
        }
        static var topShowsCalendarId: String {
            return String(format: NSLocalizedString("Intro-topShowsCalendarId", comment: ""), seeExample)
        }
        static let titleFindCalendarId = NSLocalizedString("Intro-titleFindCalendarId", comment: "")
        static func errorLoginApple(error: Error) -> String {
            return NSLocalizedString("Intro-errorLoginApple", comment: "") + " \(error.localizedDescription)"
        }

	}
	
	struct SongService {
		static let title = NSLocalizedString("SongService-title", comment: "")
		static let titleTableClusters = NSLocalizedString("SongService-titleTableClusters", comment: "")
		static let titleTableSheets = NSLocalizedString("SongService-titleTableSheets", comment: "")
        static let warnCannotPlay = NSLocalizedString("SongService-warnCannotPlay", comment: "")
        static let startNew = NSLocalizedString("SongService-startNew", comment: "")
	}
	
	struct NewSongService {
		static let title = NSLocalizedString("NewSongService-title", comment: "")
		static let selectedSongsDescription = NSLocalizedString("NewSongService-selectedSongsDescription", comment: "")
		static let songsDescription = NSLocalizedString("NewSongService-songsDescription", comment: "")
		static let noSelectedSongs = NSLocalizedString("NewSongService-noSelectedSongs", comment: "")
		static let notEnoughSongsForTagSection = NSLocalizedString("NewSongService-notEnoughSongsForTagSection", comment: "")
//        static let notEnoughSongsForTagSectionAlertBody = "Er zijn niet genoeg liedjes voor elke categorie. Maak liedjes aan voor de categorie die nu geen liedjes heeft. Klik op \(Actions.continue) om af te sluiten zonder gekozen liedjes of op \(Actions.cancel) om hier te blijven."
        static var notEnoughSongsForTagSectionAlertBody: String {
            return String(format: NSLocalizedString("NewSongService-notEnoughSongsForTagSectionAlertBody", comment: ""), Actions.continue, Actions.cancel)
        }
        
        static func shareSongServiceText(date: String) -> String {
            return String(format: NSLocalizedString("NewSongService-shareSongServiceText", comment: ""), date)
        }
        static let morning = NSLocalizedString("NewSongService-morning", comment: "")
        static let evening = NSLocalizedString("NewSongService-evening", comment: "")
        
        static let popupGenerateSongServiceTitle = NSLocalizedString("NewSongService-popupGenerateSongServiceTitle", comment: "")
        static let popupGenerateSongServiceDescription = NSLocalizedString("NewSongService-popupGenerateSongServiceDescription", comment: "")
        static let dontShowAgain = NSLocalizedString("NewSongService-dontShowAgain", comment: "")
        static let showMeLater = NSLocalizedString("NewSongService-showMeLater", comment: "")
        static let swipeToDeleteHint = NSLocalizedString("NewSongService-swipeToDeleteHint", comment: "")
        static let shakeToGenerate = NSLocalizedString("NewSongService-shakeToGenerate", comment: "")
        static let shareOptionsTitle = NSLocalizedString("NewSongService-shareOptionsTitle", comment: "")
        static let shareOptionTitles = NSLocalizedString("NewSongService-shareOptionTitles", comment: "")
        static let shareOptionTitlesWithSections = NSLocalizedString("NewSongService-shareOptionTitlesWithSections", comment: "")
        static let shareOptionLyrics = NSLocalizedString("NewSongService-shareOptionLyrics", comment: "")
        static let shareOptionLyricsWithSections = NSLocalizedString("NewSongService-shareOptionLyricsWithSections", comment: "")
        static let shareSingFrom = NSLocalizedString("NewSongService-shareSingFrom", comment: "")
	}
	
	struct Songs {
		static let title = NSLocalizedString("Songs-title", comment: "")
		static let description = NSLocalizedString("Songs-description", comment: "")
		static let SearchSongPlaceholder = NSLocalizedString("Songs-SearchSongPlaceholder", comment: "")
        static let NewTag = NSLocalizedString("Songs-NewTag", comment: "")
		static let menuTitle = NSLocalizedString("Songs-menuTitle", comment: "")
        static func deleteTitle(songName: String) -> String {
            return String(format: NSLocalizedString("Songs-deleteTitle", comment: ""), songName)
        }
        static func deleteBody(songName: String) -> String {
            return String(format: NSLocalizedString("Songs-deleteBody", comment: ""), songName)
        }
        static let deleteMusicTitle = NSLocalizedString("Songs-deleteMusicTitle", comment: "")
        static func deleteMusicBody(songName: String) -> String {
            return String(format: NSLocalizedString("Songs-deleteMusicBody", comment: ""), songName)
        }
        static let restoreTitle = NSLocalizedString("Songs-restoreTitle", comment: "")
        static func restoreBody(songName: String) -> String {
            return String(format: NSLocalizedString("Songs-restoreBody", comment: ""), songName)
        }
        static let errorNoUserFound = NSLocalizedString("Songs-errorNoUserFound", comment: "")
        static func errorDeletingLocalMusic(error: String) -> String {
            return String(format: NSLocalizedString("Songs-errorDeletingLocalMusic", comment: ""), error)
        }
        static func errorDeletingSongRemotely(title: String, errorMessage: String) -> String {
            return String(format: NSLocalizedString("Songs-errorDeletingSongRemotely", comment: ""), title, errorMessage)
        }
	}
	
	struct NewSong {
		static let title = NSLocalizedString("NewSong-title", comment: "")
		static let songTitle = NSLocalizedString("NewSong-songTitle", comment: "")
		static let headerTheme = NSLocalizedString("NewSong-headerTheme", comment: "")
		static let headerLyrics = NSLocalizedString("NewSong-headerLyrics", comment: "")
		static let noTitleForSheet = NSLocalizedString("NewSong-noTitleForSheet", comment: "")
		static let sheet = NSLocalizedString("NewSong-sheet", comment: "")
		static let searchThemePlaceHolder = NSLocalizedString("NewSong-searchThemePlaceHolder", comment: "")
        static let errorTitleNoTheme = NSLocalizedString("NewSong-errorTitleNoTheme", comment: "")
        static let errorNoTitle = NSLocalizedString("NewSong-errorNoTitle", comment: "")
		static let erorrMessageNoTheme = NSLocalizedString("NewSong-erorrMessageNoTheme", comment: "")
		static let segmentTitleText = NSLocalizedString("NewSong-segmentTitleText", comment: "")
		static let segmentTitleSheets = NSLocalizedString("NewSong-segmentTitleSheets", comment: "")
		static let generateSheetsButton = NSLocalizedString("NewSong-generateSheetsButton", comment: "")
		static let titlePlaceholder = NSLocalizedString("NewSong-titlePlaceholder", comment: "")
		static let addSheet = NSLocalizedString("NewSong-addSheet", comment: "")
		static let changeLyrics = NSLocalizedString("NewSong-changeLyrics", comment: "")
		static let newLyrics = NSLocalizedString("NewSong-newLyrics", comment: "")
		static let changeTitleTime = NSLocalizedString("NewSong-changeTitleTime", comment: "")
        static let timeExplained = NSLocalizedString("NewSong-timeExplained", comment: "")
        static let tagsExplained = NSLocalizedString("NewSong-tagsExplained", comment: "")
	}
    
    struct Lyrics {
        static let titleBibleText = NSLocalizedString("Lyrics-titleBibleText", comment: "")
        static let titleLyrics = NSLocalizedString("Lyrics-titleLyrics", comment: "")
        static let placeholderBibleText = NSLocalizedString("Lyrics-placeholderBibleText", comment: "")
        static let placeholderLyrics = NSLocalizedString("Lyrics-placeholderLyrics", comment: "")
    }
	
	struct Themes {
		static let title = NSLocalizedString("Themes-title", comment: "")
		static let searchBarPlaceholderText = NSLocalizedString("Themes-searchBarPlaceholderText", comment: "")
        static func deleteThemeError(error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-deleteThemeError", comment: ""), error.localizedDescription)
        }
	}
	
	struct Tags {
		static let title = NSLocalizedString("Tags-title", comment: "")
        static let placeholder = NSLocalizedString("Tags-placeholder", comment: "")
        static let newTag = NSLocalizedString("Tags-newTag", comment: "")
        static let name = NSLocalizedString("Tags-name", comment: "")
        static let deletedClusters = NSLocalizedString("Tags-deletedClusters", comment: "")
        static let errorEmptyTitle = NSLocalizedString("Tags-errorEmptyTitle", comment: "")
        static let editTag = NSLocalizedString("Tags-editTag", comment: "")
	}
	
    struct CustomSheets {
        static let title = NSLocalizedString("CustomSheets-title", comment: "")
        static let namePlaceHolder = NSLocalizedString("CustomSheets-namePlaceHolder", comment: "")
        static let errorTitle = NSLocalizedString("CustomSheets-errorTitle", comment: "")
        static let errorNoName = NSLocalizedString("CustomSheets-errorNoName", comment: "")
        static let segmentInput = NSLocalizedString("CustomSheets-segmentInput", comment: "")
        static let segmentCheck = NSLocalizedString("CustomSheets-segmentCheck", comment: "")
        static let segmentSheets = NSLocalizedString("CustomSheets-segmentSheets", comment: "")
        static let segmentChange = NSLocalizedString("CustomSheets-segmentChange", comment: "")
        static let descriptionName = NSLocalizedString("CustomSheets-descriptionName", comment: "")
        static let descriptionTime = NSLocalizedString("CustomSheets-descriptionTime", comment: "")
        static let descriptionTimeAdd = NSLocalizedString("CustomSheets-descriptionTimeAdd", comment: "")
        
        static let tableViewHeaderGeneral = NSLocalizedString("CustomSheets-tableViewHeaderGeneral", comment: "")
        static let tableViewHeaderSheets = NSLocalizedString("CustomSheets-tableViewHeaderSheets", comment: "")
        
        static let titleMenu = NSLocalizedString("CustomSheets-titleMenu", comment: "")
        static let errorSelectTheme = NSLocalizedString("CustomSheets-errorSelectTheme", comment: "")
        static let errorLoseOtherSheets = NSLocalizedString("CustomSheets-errorLoseOtherSheets", comment: "")
        
        static let universalSongEditErrorTitle = NSLocalizedString("CustomSheets-universalSongEditErrorTitle", comment: "")
        static let universalSongEditErrorMessage = NSLocalizedString("CustomSheets-universalSongEditErrorMessage", comment: "")
        static let errorChangeSheetGenerator = NSLocalizedString("CustomSheets-errorChangeSheetGenerator", comment: "")
    }
    
	struct SongServiceManagement {
		static let title = NSLocalizedString("SongServiceManagement-title", comment: "")
		static let numberOfSections = NSLocalizedString("SongServiceManagement-numberOfSections", comment: "")
		static let section = NSLocalizedString("SongServiceManagement-section", comment: "")
		static let nameSection = NSLocalizedString("SongServiceManagement-nameSection", comment: "")
		static let addTags = NSLocalizedString("SongServiceManagement-addTags", comment: "")
		static let name = NSLocalizedString("SongServiceManagement-name", comment: "")
		static let numberOfSongs = NSLocalizedString("SongServiceManagement-numberOfSongs", comment: "")
        static let titleNewSongServiceSchema = NSLocalizedString("SongServiceManagement-titleNewSongServiceSchema", comment: "")
        static let titleEditSongServiceSchema = NSLocalizedString("SongServiceManagement-titleEditSongServiceSchema", comment: "")
        static let addSection = NSLocalizedString("SongServiceManagement-addSection", comment: "")
        static let errorAddASection = NSLocalizedString("SongServiceManagement-errorAddASection", comment: "")        
        static func errorInSections(_ sections: [Int]) -> String {
            return String(format: NSLocalizedString("SongServiceManagement-errorInSections", comment: ""),  sections.compactMap { String($0)}.joined(separator: ", "))
        }
        static func errorInSection(_ section: Int) -> String {
            return String(format: NSLocalizedString("SongServiceManagement-errorInSections", comment: ""),  String(section))
        }
	}
	
	struct Settings {
        static let title = NSLocalizedString("Settings-title", comment: "")
        static let descriptionGoogleSub = NSLocalizedString("Settings-descriptionGoogleSub", comment: "")
        static let descriptionCalendarId = NSLocalizedString("Settings-descriptionCalendarId", comment: "")
        static let descriptionInstructions = NSLocalizedString("Settings-descriptionInstructions", comment: "")
        static let instructions = NSLocalizedString("Settings-instructions", comment: "")
        static let descriptionGoogle = NSLocalizedString("Settings-descriptionGoogle", comment: "")
        static let errorTitleGoogleAuth = NSLocalizedString("Settings-errorTitleGoogleAuth", comment: "")
        static let googleSignOutButton = NSLocalizedString("Settings-googleSignOutButton", comment: "")
        static let sheetTimeOffsetError = NSLocalizedString("Settings-sheetTimeOffsetError", comment: "")
        static let sheetTimeOffset = NSLocalizedString("Settings-sheetTimeOffset", comment: "")
        static let sheetTimeOffsetPlaceholder = NSLocalizedString("Settings-sheetTimeOffsetPlaceholder", comment: "")
        static let sectionSongServiceSettings = NSLocalizedString("Settings-sectionSongServiceSettings", comment: "")
        static let sectionGmailAccount = NSLocalizedString("Settings-sectionGmailAccount", comment: "")
        static let sectionCalendarId = NSLocalizedString("Settings-sectionCalendarId", comment: "")
        static let calendarIdPlaceHolder = NSLocalizedString("Settings-calendarIdPlaceHolder", comment: "")
        static let sectionAppSettings = NSLocalizedString("Settings-sectionAppSettings", comment: "")
        static let appversion = NSLocalizedString("Settings-appversion", comment: "")
        static let AppSettings = NSLocalizedString("Settings-sectionAppSettings", comment: "")
        static let ResetMutes = NSLocalizedString("Settings-resetMutes", comment: "")
	}
	
	struct NewTheme {
        static let title = NSLocalizedString("NewTheme-title", comment: "")
        static let descriptionTitle = NSLocalizedString("NewTheme-descriptionTitle", comment: "")
        static let descriptionTitlePlaceholder = NSLocalizedString("NewTheme-descriptionTitlePlaceholder", comment: "")
        static let descriptionAsTheme = NSLocalizedString("NewTheme-descriptionAsTheme", comment: "")
        static let descriptionTitleBackgroundColor = NSLocalizedString("NewTheme-descriptionTitleBackgroundColor", comment: "")
        static let pageDescription = NSLocalizedString("NewTheme-pageDescription", comment: "")
        static let descriptionBackgroundColor = NSLocalizedString("NewTheme-descriptionBackgroundColor", comment: "")
        static let descriptionHasEmptySheet = NSLocalizedString("NewTheme-descriptionHasEmptySheet", comment: "")
        static let descriptionHasEmptySheetDetail = NSLocalizedString("NewTheme-descriptionHasEmptySheetDetail", comment: "")
        static let descriptionAllTitle = NSLocalizedString("NewTheme-descriptionAllTitle", comment: "")
        static let descriptionPositionEmptySheet = NSLocalizedString("NewTheme-descriptionPositionEmptySheet", comment: "")
        static let descriptionLastBeamerResolution = NSLocalizedString("NewTheme-descriptionLastBeamerResolution", comment: "")
        static let descriptionBackgroundTransparency = NSLocalizedString("NewTheme-descriptionBackgroundTransparency", comment: "")
        static let descriptionDisplayTime = NSLocalizedString("NewTheme-descriptionDisplayTime", comment: "")
        static let descriptionDarkBlurTitleBackground = NSLocalizedString("NewTheme-descriptionDarkBlurTitleBackground", comment: "")
        static let descriptionAlignment = NSLocalizedString("NewTheme-descriptionAlignment", comment: "")
        static let errorTitle = NSLocalizedString("NewTheme-errorTitle", comment: "")
        static let errorMessage = NSLocalizedString("NewTheme-errorMessage", comment: "")
        static let alignLeft = NSLocalizedString("NewTheme-alignLeft", comment: "")
        static let alignCenter = NSLocalizedString("NewTheme-alignCenter", comment: "")
        static let alignRight = NSLocalizedString("NewTheme-alignRight", comment: "")
        static let sampleTitle = NSLocalizedString("NewTheme-sampleTitle", comment: "")
        static let sampleLyrics = NSLocalizedString("NewTheme-sampleLyrics", comment: "")
        static let sectionGeneral = NSLocalizedString("NewTheme-sectionGeneral", comment: "")
        static let sectionInput = NSLocalizedString("NewTheme-sectionInput", comment: "")
        static let sectionTitle = NSLocalizedString("NewTheme-sectionTitle", comment: "")
        static let sectionLyrics = NSLocalizedString("NewTheme-sectionLyrics", comment: "")
        static let sectionBackground = NSLocalizedString("NewTheme-sectionBackground", comment: "")
        static let fontFamilyDescription = NSLocalizedString("NewTheme-fontFamilyDescription", comment: "")
        static let fontSizeDescription = NSLocalizedString("NewTheme-fontSizeDescription", comment: "")
        static let borderSizeDescription = NSLocalizedString("NewTheme-borderSizeDescription", comment: "")
        static let borderColor = NSLocalizedString("NewTheme-borderColor", comment: "")
        static let textColor = NSLocalizedString("NewTheme-textColor", comment: "")
        static let underlined = NSLocalizedString("NewTheme-underlined", comment: "")
        static let bold = NSLocalizedString("NewTheme-bold", comment: "")
        static let italic = NSLocalizedString("NewTheme-italic", comment: "")
        static let backgroundImage = NSLocalizedString("NewTheme-backgroundImage", comment: "")
        static let buttonBackgroundImagePick = NSLocalizedString("NewTheme-buttonBackgroundImagePick", comment: "")
        static let buttonBackgroundImageChange = NSLocalizedString("NewTheme-buttonBackgroundImageChange", comment: "")
	}
    
    struct EditTheme {
        static let title = NSLocalizedString("EditTheme-title", comment: "")
    }
	
	struct Sheet {
		static let emptySheetTitle = NSLocalizedString("Sheet-emptySheetTitle", comment: "")
	}
	
	struct SheetsMenu {
        static let sectionSongs = NSLocalizedString("SheetsMenu-sectionSongs", comment: "")
        static let sectionOther = NSLocalizedString("SheetsMenu-sectionOther", comment: "")
        static let sectionBibleStudy = NSLocalizedString("SheetsMenu-sectionBibleStudy", comment: "")
        static let lyrics = NSLocalizedString("SheetsMenu-lyrics", comment: "")
        static let sheetTitleText = NSLocalizedString("SheetsMenu-sheetTitleText", comment: "")
        static let sheetTitleImage = NSLocalizedString("SheetsMenu-sheetTitleImage", comment: "")
        static let sheetPastors = NSLocalizedString("SheetsMenu-sheetPastors", comment: "")
        static let sheetSplit = NSLocalizedString("SheetsMenu-sheetSplit", comment: "")
        static let sheetEmpty = NSLocalizedString("SheetsMenu-sheetEmpty", comment: "")
        static let bibleStudyGen = NSLocalizedString("SheetsMenu-bibleStudyGen", comment: "")
        static let sheetActivity = NSLocalizedString("SheetsMenu-sheetActivity", comment: "")
    }
	
	struct SheetPickerMenu {
		static let pickSong = NSLocalizedString("SheetPickerMenu-pickSong", comment: "")
		static let pickCustom = NSLocalizedString("SheetPickerMenu-pickCustom", comment: "")
        static let whichSheet = NSLocalizedString("SheetPickerMenu-whichSheet", comment: "")
	}
	
	struct More {
		static let title = NSLocalizedString("More-title", comment: "")

	}
	
	struct Google {
		static let title = NSLocalizedString("Google-title", comment: "")

	}
	
	struct BibleStudy {
		static let title = NSLocalizedString("BibleStudy-title", comment: "")

	}
	
	struct NewSheetTitleImage {
        static let title = NSLocalizedString("NewSheetTitleImage-title", comment: "")
        static let sectionContentTitle = NSLocalizedString("NewSheetTitleImage-contentTitle", comment: "")
        static let descriptionTitle = NSLocalizedString("NewSheetTitleImage-descriptionTitle", comment: "")
        static let descriptionTextLeft = NSLocalizedString("NewSheetTitleImage-descriptionTextLeft", comment: "")
        static let descriptionTextRight = NSLocalizedString("NewSheetTitleImage-descriptionTextRight", comment: "")
        static let descriptionContent = NSLocalizedString("NewSheetTitleImage-descriptionContent", comment: "")
        static let descriptionImage = NSLocalizedString("NewSheetTitleImage-descriptionImage", comment: "")
        static let descriptionImageHasBorder = NSLocalizedString("NewSheetTitleImage-descriptionImageHasBorder", comment: "")
        static let descriptionImageBorderSize = NSLocalizedString("NewSheetTitleImage-descriptionImageBorderSize", comment: "")
        static let descriptionImageBorderColor = NSLocalizedString("NewSheetTitleImage-descriptionImageBorderColor", comment: "")
        static let descriptionImageContentMode = NSLocalizedString("NewSheetTitleImage-descriptionImageContentMode", comment: "")
        static let placeholderContent = NSLocalizedString("NewSheetTitleImage-placeholderContent", comment: "")
	}
	
	struct NewPastorsSheet {
		static let title = NSLocalizedString("NewPastorsSheet-placeholderContent", comment: "")
		static let content = NSLocalizedString("NewPastorsSheet-content", comment: "")
		static let photoDescription = NSLocalizedString("NewPastorsSheet-photoDescription", comment: "")
		
	}
	
	struct ActivitySheet {
        static let titleThisWeek = NSLocalizedString("ActivitySheet-titleThisWeek", comment: "")
        static let titleNextWeek = NSLocalizedString("ActivitySheet-titleNextWeek", comment: "")
        static let titleUpcomingTime = NSLocalizedString("ActivitySheet-titleUpcomingTime", comment: "")
        static let descriptionNoActivities = NSLocalizedString("ActivitySheet-descriptionNoActivities", comment: "")
        static let previewDescription = NSLocalizedString("ActivitySheet-previewDescription", comment: "")
        static let dayActivity = NSLocalizedString("ActivitySheet-dayActivity", comment: "")
	}
	
	struct Import {
		static let title = NSLocalizedString("Import-title", comment: "")
		static let description = NSLocalizedString("Import-description", comment: "")
	}
	
	struct UploadUniversalSong {
        static let previewButtonTitle = NSLocalizedString("UploadUniversalSong-previewButtonTitle", comment: "")
        static let title = NSLocalizedString("UploadUniversalSong-title", comment: "")
        static let selecteerSheet = NSLocalizedString("UploadUniversalSong-selecteerSheet", comment: "")
        static let showPreview = NSLocalizedString("UploadUniversalSong-showPreview", comment: "")
        static let noSheets = NSLocalizedString("UploadUniversalSong-noSheets", comment: "")
        static let titlePlaceholder = NSLocalizedString("UploadUniversalSong-titlePlaceholder", comment: "")
        static let noThemeWarning = NSLocalizedString("UploadUniversalSong-noThemeWarning", comment: "")
        static let new = NSLocalizedString("UploadUniversalSong-new", comment: "")
        static let selectChurch = NSLocalizedString("UploadUniversalSong-selectChurch", comment: "")
        static let startTime = NSLocalizedString("UploadUniversalSong-startTime", comment: "")
        static let defaultTheme = NSLocalizedString("UploadUniversalSong-defaultTheme", comment: "")
        static let shareSheetTimes = NSLocalizedString("UploadUniversalSong-shareSheetTimes", comment: "")
	}
    
    struct AboutController {
        static let title = NSLocalizedString("AboutController-title", comment: "")
        static let sectionAbout = NSLocalizedString("AboutController-sectionAbout", comment: "")
        static let infoText = NSLocalizedString("AboutController-infoText", comment: "")
        static let sectionStartContact = NSLocalizedString("AboutController-sectionStartContact", comment: "")
        static let contactInfo = NSLocalizedString("AboutController-contactInfo", comment: "")
        static let contact = NSLocalizedString("AboutController-contact", comment: "")
        static let errorNoMail = NSLocalizedString("AboutController-errorNoMail", comment: "")
    }
    
    struct SingInGoogleController {
        static let title = NSLocalizedString("SingInGoogleController-title", comment: "")
        static let infoText = NSLocalizedString("SingInGoogleController-infoText", comment: "")
    }
    
    struct RequesterErrors {
        static func errorParsing(_ error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-errorParsing", comment: ""),  error.localizedDescription)
        }
        static func failedSavingImageLocallyBeforeSubmit(requester: String, error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester, error.localizedDescription)
        }
        static func failedDownloadingMedia(requester: String, error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester, error.localizedDescription)
        }
        static func failedUploadingMedia(requester: String, error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester, error.localizedDescription)
        }
        static func wrongMethodForSubmitting(requester: String) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester)
        }
        static func unAuthorizedNoUser(requester: String) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester)
        }
        static func allreadyHasAnUser(requester: String) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester)
        }
        static func hasNoThemeForUniversalCluster(requester: String) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester)
        }
        static func hasNoChurchForUniversalCluster(requester: String) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester)
        }
        static func failedFetchingSavingCoreData(requester: String, error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester, error.localizedDescription)
        }
        static func failedDecoding(requester: String) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester)
        }
        static func failedEncoding(requester: String) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester)
        }
        static func errorOnFireBase(requester: String, error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester, error.localizedDescription)
        }
        static func errorSavingTempImage(requester: String, error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-failedSavingImageLocallyBeforeSubmit", comment: ""), requester, error.localizedDescription)
        }
        static func notConnectedToNetwork() -> String {
            return NSLocalizedString("RequesterErrors-notConnectedToNetwork", comment: "")
        }
        static func unknown(requester: String, error: Error) -> String {
            return String(format: NSLocalizedString("RequesterErrors-unknown", comment: ""), requester, error.localizedDescription)
        }
    }
    
    struct IAPErrors {
        static let paymentNotAllowed = NSLocalizedString("IAPErrors-paymentNotAllowed", comment: "")
        static let busyPurchasing = NSLocalizedString("IAPErrors-busyPurchasing", comment: "")
        static func unableToReadReceipt(error: Error?) -> String {
            return String(format: NSLocalizedString("IAPErrors-unableToReadReceipt", comment: ""), error?.localizedDescription ?? "")
        }
        static func unableToGetReceipt(error: Error?) -> String {
            return String(format: NSLocalizedString("IAPErrors-unableToGetReceipt", comment: ""), error?.localizedDescription ?? "")
        }
        static func unableToPurchage(error: Error?) -> String {
            return String(format: NSLocalizedString("IAPErrors-unableToPurchage", comment: ""), error?.localizedDescription ?? "")
        }
        static func unableToReachStore(error: Error?) -> String {
            return String(format: NSLocalizedString("IAPErrors-unableToReachStore", comment: ""), error?.localizedDescription ?? "")
        }
    }


}

private extension Error {
    var underlyingErrorDescription: String? {
        return ((self as NSError).userInfo["NSUnderlyingError"] as? Error)?.localizedDescription
    }
}

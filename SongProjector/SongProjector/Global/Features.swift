//
//  Features.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import Foundation
import UIKit

let secretKey = "secretKey"
var uploadSecret: String? {
	UserDefaults.standard.string(forKey: secretKey)
}

enum Feature : String {
	
	case songService = "SongService"
	case songs = "Songs"
	case bibleStudy = "BibleStudy"
	case more = "More"
	case themes = "Themes"
	case tags = "Tags"
	case songServiceManagement = "SongServiceManagement"
	case settings = "Settings"
	case uploadUniversalSong = "UploadUniversalSong"
    case about = "About"
	
	
	
	// MARK: - Properties
	
    static let all = [songService, songs, themes, more, tags, songServiceManagement, settings, uploadUniversalSong, about]

	var titel : String {
		return rawValue
	}
	
	var titleForDisplay : String {
		switch self {
		case .songService:
			return AppText.SongService.title
		case .songs:
			return AppText.Songs.title
		case .bibleStudy:
			return AppText.BibleStudy.title
		case .themes:
			return AppText.Themes.title
		case .tags:
			return AppText.Tags.title
		case .songServiceManagement:
			return AppText.SongServiceManagement.title
		case .settings:
			return AppText.Settings.title
		case .more:
			return AppText.More.title
		case .uploadUniversalSong: return AppText.UploadUniversalSong.title
        case .about:
            return AppText.AboutController.title
		}
	}
	
	var storyBoard: UIStoryboard {
		switch self {
		case .songService, .more:
			return UIDevice.current.userInterfaceIdiom == .pad ? Storyboard.Ipad : Storyboard.MainStoryboard
        case .themes, .tags, .songs, .bibleStudy, .songServiceManagement, .uploadUniversalSong, .settings, .about:
			return Storyboard.MainStoryboard
		}
	}
	
	var identifier : String {
		switch self {
        case .more: return "MoreSplitController"
		default: return titel + "NavController"
		}
	}
	
	/// Een indicator die aangeeft of de feature standaard is.
	/// Dergelijke features zijn altijd actief.
	var isStandaard : Bool {
		
		switch self {
        case .songService, .songs, .more, .themes, .settings, .tags, .about:
			return true
        case .bibleStudy, .songServiceManagement, .uploadUniversalSong:
			return false
		}
	}
	
	/// Een indicator die aangeeft of de feature actief is.
	/// Actieve features worden getoond aan de gebruiker.
	var isActief : Bool {
		
		switch self {
        case .bibleStudy, .uploadUniversalSong: return uploadSecret != nil
		default: return true
		}
		
	}
	
	var image : (normal: UIImage, selected: UIImage, large: UIImage) {
		
		switch self {
			
		case .songService:
			return (#imageLiteral(resourceName: "SongService"), #imageLiteral(resourceName: "SongService"), #imageLiteral(resourceName: "SongService"))
		case .songs:
			return (UIImage(named: "Collections")!, UIImage(named: "Collections")!, UIImage(named: "Collections")!)
		case .bibleStudy:
			return (#imageLiteral(resourceName: "Bullet"), #imageLiteral(resourceName: "BulletSelected"), #imageLiteral(resourceName: "Bullet"))
		case .more:
			return (#imageLiteral(resourceName: "More"), #imageLiteral(resourceName: "More"), #imageLiteral(resourceName: "More"))
		case .themes:
			return (UIImage(named: "Theme")!, UIImage(named: "Theme")!, UIImage(named: "Theme")!)
		case .tags:
			return (#imageLiteral(resourceName: "Tags"), #imageLiteral(resourceName: "Tags"), #imageLiteral(resourceName: "Tags"))
		case .songServiceManagement:
			return (UIImage(named: "SongServiceSettings")!, UIImage(named: "SongServiceSettings")!, UIImage(named: "SongServiceSettings")!)
		case .settings:
            return (UIImage(named: "Settings")!, UIImage(named: "Settings")!, UIImage(named: "Settings")!)
		case .uploadUniversalSong:
			return (#imageLiteral(resourceName: "Bullet"), #imageLiteral(resourceName: "BulletSelected"), #imageLiteral(resourceName: "Bullet"))
        case .about:
            return (UIImage(named: "Contact")!, UIImage(named: "Contact")!, UIImage(named: "Contact")!)
		}
		
	}
	
}

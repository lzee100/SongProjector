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
	case users = "Users"
	case settings = "Settings"
	case `import` = "ImportBible"
	case uploadUniversalSong = "UploadUniversalSong"
	
	
	
	// MARK: - Properties
	
	static let all = [songService, songs, bibleStudy, themes, tags, users, settings, songServiceManagement, `import`, uploadUniversalSong, more]
	
	var titel : String {
		return rawValue
	}
	
	var titleForDisplay : String {
		switch self {
		case .songService:
			return Text.SongService.title
		case .songs:
			return Text.Songs.title
		case .bibleStudy:
			return Text.BibleStudy.title
		case .themes:
			return Text.Themes.title
		case .tags:
			return Text.Tags.title
		case .users:
			return Text.Users.title
		case .songServiceManagement:
			return Text.SongServiceManagement.title
		case .settings:
			return Text.Settings.title
		case .more:
			return Text.More.title
		case .import:
			return Text.Import.title
		case .uploadUniversalSong: return Text.UploadUniversalSong.title
		}
	}
	
	var storyBoard: UIStoryboard {
		switch self {
		case .songService, .songs, .bibleStudy, .settings, .more, .import:
			return UIDevice.current.userInterfaceIdiom == .pad ? Storyboard.Ipad : Storyboard.MainStoryboard
		case .themes, .tags, .users, .songServiceManagement, .uploadUniversalSong:
			return Storyboard.MainStoryboard
		}
	}
	
	var identifier : String {
		switch self {
		case .tags, .users, .songServiceManagement: return titel + "NavController"
		default: return titel + "Controller"
		}
	}
	
	/// Een indicator die aangeeft of de feature standaard is.
	/// Dergelijke features zijn altijd actief.
	var isStandaard : Bool {
		
		switch self {
		case .songService, .songs, .bibleStudy, .more, .themes, .settings, .import:
			return true
		case .tags, .users, .songServiceManagement, .uploadUniversalSong:
			return false
		}
	}
	
	/// Een indicator die aangeeft of de feature actief is.
	/// Actieve features worden getoond aan de gebruiker.
	var isActief : Bool {
		
		switch self {
		case .tags, .users, .songServiceManagement: return CoreUser.getEntities().filter({ $0.isMe }).first?.inviteToken == nil
		case .uploadUniversalSong: return uploadSecret != nil
		default: return true
		}
		
	}
	
	var image : (normal: UIImage, selected: UIImage, large: UIImage) {
		
		switch self {
			
		case .songService:
			return (#imageLiteral(resourceName: "SongService"), #imageLiteral(resourceName: "SongService"), #imageLiteral(resourceName: "SongService"))
		case .songs:
			return (#imageLiteral(resourceName: "Song"), #imageLiteral(resourceName: "Song"), #imageLiteral(resourceName: "Song"))
		case .bibleStudy:
			return (#imageLiteral(resourceName: "Bullet"), #imageLiteral(resourceName: "BulletSelected"), #imageLiteral(resourceName: "Bullet"))
		case .more:
			return (#imageLiteral(resourceName: "More"), #imageLiteral(resourceName: "More"), #imageLiteral(resourceName: "More"))
		case .themes:
			return (#imageLiteral(resourceName: "Tags"), #imageLiteral(resourceName: "Tags"), #imageLiteral(resourceName: "Tags"))
		case .tags:
			return (#imageLiteral(resourceName: "Tags"), #imageLiteral(resourceName: "Tags"), #imageLiteral(resourceName: "Tags"))
		case .users:
			return (#imageLiteral(resourceName: "More"), #imageLiteral(resourceName: "More"), #imageLiteral(resourceName: "More"))
		case .songServiceManagement:
			return (#imageLiteral(resourceName: "More"), #imageLiteral(resourceName: "More"), #imageLiteral(resourceName: "More"))
		case .settings:
			return (#imageLiteral(resourceName: "Bullet"), #imageLiteral(resourceName: "BulletSelected"), #imageLiteral(resourceName: "Bullet"))
		case .import:
			return (#imageLiteral(resourceName: "Bullet"), #imageLiteral(resourceName: "BulletSelected"), #imageLiteral(resourceName: "Bullet"))
		case .uploadUniversalSong:
			return (#imageLiteral(resourceName: "Bullet"), #imageLiteral(resourceName: "BulletSelected"), #imageLiteral(resourceName: "Bullet"))
		}
		
	}
	
}

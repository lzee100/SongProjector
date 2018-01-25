//
//  Features.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import Foundation
import UIKit

enum Feature : String {
	
	case songService = "SongService"
	case songs = "Songs"
	case bibleStudy = "BibleStudyIphone"
	case more = "More"
	case tags = "Tags"
	case displaySettings = "DisplaySettings"
	
	
	
	// MARK: - Properties
	
	static let all = [songService, songs, bibleStudy, tags, displaySettings, more]
	
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
		case .tags:
			return Text.Tags.title
		case .displaySettings:
			return Text.DisplaySettings.title
		case .more:
			return Text.More.title

		}
	}
	
	var identifier : String {
		return titel + "Controller"
	}
	
	/// Een indicator die aangeeft of de feature standaard is.
	/// Dergelijke features zijn altijd actief.
	var isStandaard : Bool {
		
		switch self {
		case .songService, .songs, .bibleStudy, .more, .tags, .displaySettings:
			return true
		}
	}
	
	/// Een indicator die aangeeft of de feature actief is.
	/// Actieve features worden getoond aan de gebruiker.
	var isActief : Bool {
		
		var isActief = isStandaard
		
		if
			!isActief {
				isActief = false
		}
		
		return isActief
		
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
		case .tags:
			return (#imageLiteral(resourceName: "Tags"), #imageLiteral(resourceName: "Tags"), #imageLiteral(resourceName: "Tags"))
		case .displaySettings:
			return (#imageLiteral(resourceName: "Bullet"), #imageLiteral(resourceName: "BulletSelected"), #imageLiteral(resourceName: "Bullet"))
		}
		
	}
	
}

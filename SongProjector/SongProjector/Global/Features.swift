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
	case players = "Players"
	case more = "More"
	case tags = "Tags"
	
	
	
	// MARK: - Properties
	
	static let all = [songService, songs, players, tags,  more]
	
	var titel : String {
		return rawValue
	}
	
	var titleForDisplay : String {
		switch self {
		case .songService:
			return Text.SongService.title
		case .songs:
			return Text.Songs.title
		case .players:
			return Text.Players.title
		case .tags:
			return Text.Tags.title
		default:
			return ""
		}
	}
	
	var identifier : String {
		return titel + "Controller"
	}
	
	/// Een indicator die aangeeft of de feature standaard is.
	/// Dergelijke features zijn altijd actief.
	var isStandaard : Bool {
		
		switch self {
		case .songService, .songs, .players, .tags, .more:
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
		case .tags:
			return (#imageLiteral(resourceName: "Bullet"), #imageLiteral(resourceName: "BulletSelected"), #imageLiteral(resourceName: "Bullet"))
		case .players:
			return (#imageLiteral(resourceName: "Play"), #imageLiteral(resourceName: "PlaySelected"), #imageLiteral(resourceName: "Play"))
		case .more:
			return (#imageLiteral(resourceName: "Sheet"), #imageLiteral(resourceName: "Sheet"), #imageLiteral(resourceName: "Sheet"))
		}
		
	}
	
}

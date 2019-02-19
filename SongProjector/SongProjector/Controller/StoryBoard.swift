//
//  StoryBoard.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit

protocol StoryboardController {
	
	associatedtype T: UIViewController
	
	static func create() -> T
	static var identifier: String { get }
	static var residingStoryboard: UIStoryboard { get }
	
}

extension StoryboardController {
	static func create() -> T { return residingStoryboard.instantiateViewController(withIdentifier: identifier) as! T }
}

struct Storyboard {
	
	static var MainStoryboard: UIStoryboard = {
		return UIStoryboard(name: "Main", bundle: Bundle.main)
	}()
	
	static var Ipad: UIStoryboard = {
		return UIStoryboard(name: "StoryboardiPad", bundle: Bundle.main)
	}()
	
	static var Intro: UIStoryboard = {
		return UIStoryboard(name: "Intro", bundle: Bundle.main)
	}()

}

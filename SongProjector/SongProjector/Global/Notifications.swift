//
//  Notifications.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import Foundation

struct NotificationIdentifier {
	static let databaseDataChanged = "databaseDataChanged"
	static let noContract = "noContract"
	
}

struct NotificationNames {
	static let externalDisplayDidChange = Notification.Name("externalDisplayDidChange")
	static let dataBaseDidChange = Notification.Name("databaseDidChange")
	static let environmentChanged = Notification.Name("environmentChanged")
	static let didSignUpSuccessfully = Notification.Name("didSignUpSuccessfully")
	static let didSubmitSongServiceSettings = Notification.Name("didSubmitSongServiceSettings")
	static let applicationDidBecomeActive = Notification.Name("applicationDidBecomeActive")

}

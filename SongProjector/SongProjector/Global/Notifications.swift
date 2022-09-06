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

extension NSNotification.Name {
    static let externalDisplayDidChange = Notification.Name("externalDisplayDidChange")
    static let dataBaseDidChange = Notification.Name("databaseDidChange")
    static let environmentChanged = Notification.Name("environmentChanged")
    static let didSubmitSongServiceSettings = Notification.Name("didSubmitSongServiceSettings")
    static let applicationDidBecomeActive = Notification.Name("applicationDidBecomeActive")
    static let secretChanged = Notification.Name("secretChanged")
    static let newContentAvailable = Notification.Name("newContentAvailable")
    static let authenticated = Notification.Name("authenticated")
    static let authenticatedGoogle = Notification.Name("authenticatedGoogle")
    static let checkAuthentication = Notification.Name("checkAuthentication")
    static let signedOut = Notification.Name("signedOut")
    static let newUser = Notification.Name("newUser")
    static let newUserCompletion = Notification.Name("newUserCompletion")
    static let googleCalendarNotAuthenticated = Notification.Name("googleCalendarNotAuthenticated")
    static let closeSheetPickerMenuPopUp = Notification.Name("closeSheetPickerMenuPopUp")
    static let autoRenewableSubscriptionDidChange = Notification.Name("autoRenewableSubscriptionDidChange")
    static let hasSongSubscription = Notification.Name("hasSongSubscription")
    static let hasBeamSubscription = Notification.Name("hasBeamSubscription")
    static let didFinishRequester = Notification.Name("didFinishRequester")
    static let universalClusterSubmitterDidFinish = Notification.Name("universalClusterSubmitterDidFinish")
    static let universalClusterSubmitterFailed = Notification.Name("universalClusterSubmitterFailed")
    static let soundPlayerPlayedOrStopped = Notification.Name("soundPlayerPlayedOrStopped")
    static let soundPlayerDidUpdateVolume = Notification.Name("soundPlayerDidUpdateVolume")
    static let didResetInstrumentMutes = Notification.Name("didResetInstrumentMutes")

}

//
//  GoogleActivityFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//


import Foundation
import GoogleAPIClientForREST
import GoogleSignIn



let GoogleActivityFetcher = GoogleActivityFetch()

protocol GoogleFetcherLoginDelegate {
	func loginDidFailWithError(message: String)
	func presentLoginViewController(vc: UIViewController)
}

class GoogleActivityFetch: NSObject {

//	var loginDelegate: GoogleFetcherLoginDelegate?
	
	fileprivate lazy var calendarService: GTLRCalendarService? = {
		let service = GTLRCalendarService()
		// Have the service object set tickets to fetch consecutive pages
		// of the feed so we do not need to manually fetch them
		service.shouldFetchNextPages = true
		// Have the service object set tickets to retry temporary error conditions
		// automatically
		service.isRetryEnabled = true
		service.maxRetryInterval = 15

		guard let currentUser = GIDSignIn.sharedInstance().currentUser,
			let authentication = currentUser.authentication else {
				return nil
		}
		service.authorizer = authentication.fetcherAuthorizer()
		return service
	}()

	override init() {
		super.init()
		

//		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/calendar.readonly"]

		if GIDSignIn.sharedInstance().currentUser != nil {
			GIDSignIn.sharedInstance()?.restorePreviousSignIn()
		}
	}

//	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//		if let error = error {
//			self.loginDelegate?.loginDidFailWithError(message: error.localizedDescription)
//		} else {
//			let userDefaults = UserDefaults.standard
//			userDefaults.set(user.profile.email, forKey: "googleEmail")
////			fetchFinished(result: .OK(.updated))
//		}
//	}


	func fetch(_ force: Bool) {
		if GIDSignIn.sharedInstance().currentUser != nil {
			GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/calendar.readonly"]
			fetchEvents()
		}
	}

	func fetchEvents() {
		let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "doic7liuceeq33trub6klcb8qs@group.calendar.google.com")
		query.maxResults = 8
		query.timeMin = GTLRDateTime(date: Date())
		query.timeMax = GTLRDateTime(date: Date().addingTimeInterval(.days(60)))
		query.singleEvents = true
		query.orderBy = kGTLRCalendarOrderByStartTime
		calendarService?.executeQuery(
			query,
			delegate: self,
			didFinish: #selector(mapResultForTicket(ticket:finishedWithObject:error:)))
	}


	@objc func mapResultForTicket(
		ticket: GTLRServiceTicket,
		finishedWithObject response : GTLRCalendar_Events,
		error : NSError?) {

		if error != nil {
//			fetchFinished(result: .error(error?.localizedDescription ?? ""))
			return
		}

		if let events = response.items, !events.isEmpty {
			for event in events {
				let activity = CoreGoogleActivities.createEntity()
				activity.startDate = event.start?.dateTime?.date as NSDate?
				activity.endDate = event.end?.dateTime?.date as NSDate?
				activity.eventDescription = event.summary
			}
		}

		_ = CoreGoogleActivities.saveContext()
//		fetchFinished(result: .OK(.updated))
	}

}

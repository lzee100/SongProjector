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
import GGLSignIn



let GoogleActivityFetcher = GoogleActivityFetch()

protocol GoogleFetcherLoginDelegate {
	func loginDidFailWithError(message: String)
	func presentLoginViewController(vc: UIViewController)
}

class GoogleActivityFetch: NSObject, GIDSignInDelegate, GIDSignInUIDelegate {

	var loginDelegate: GoogleFetcherLoginDelegate?

	var needsUpdating: Bool {
		return true
		if let date = UserDefaults.standard.object(forKey: "GoogleFetchDate") as? Date {
			if date < Date().addingTimeInterval(.days(1)) {
				return true
			} else {
				return false
			}
		} else {
			return true
		}

	}

	private let scopes = [kGTLRAuthScopeCalendarReadonly]

	private let service = GTLRCalendarService()

	override init() {
		super.init()
		
		// Initialize sign-in
		var configureError: NSError?
		GGLContext.sharedInstance().configureWithError(&configureError)
		assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")

		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().delegate = self
		GIDSignIn.sharedInstance().scopes = scopes
		GIDSignIn.sharedInstance().signInSilently()

		if GIDSignIn.sharedInstance().currentUser != nil {
			self.service.authorizer = GIDSignIn.sharedInstance().currentUser.authentication.fetcherAuthorizer()
		} else {

		}
	}

	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		if let error = error {
			self.loginDelegate?.loginDidFailWithError(message: error.localizedDescription)
			self.service.authorizer = nil
		} else {
			self.service.authorizer = user.authentication.fetcherAuthorizer()
			let userDefaults = UserDefaults.standard
			userDefaults.set(user.profile.name, forKey: "GoogleUserName")
//			fetchFinished(result: .OK(.updated))
		}
	}


	func fetch(_ force: Bool) {
		if GIDSignIn.sharedInstance().currentUser != nil {
			GIDSignIn.sharedInstance().scopes = scopes
			GIDSignIn.sharedInstance().signInSilently()

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
		service.executeQuery(
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

		let activities = CoreGoogleActivities.getEntities()
		for act in activities {
			act.delete()
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



	func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		loginDelegate?.presentLoginViewController(vc: viewController)
	}

	func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		viewController.dismiss(animated: true)
	}



}

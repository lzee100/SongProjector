//
//  GoogleActivityFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//


import Foundation
import GoogleAPIClientForREST
import FirebaseAuth

let GoogleActivityFetcher = GoogleActivityFetch()

protocol GoogleFetcherLoginDelegate {
	func loginDidFailWithError(message: String)
	func presentLoginViewController(vc: UIViewController)
}

class GoogleActivityFetch: NSObject {

//	var loginDelegate: GoogleFetcherLoginDelegate?
    private var numberOfTries = 0
	
//	fileprivate lazy var calendarService: GTLRCalendarService? = {
//		let service = GTLRCalendarService()
//		// Have the service object set tickets to fetch consecutive pages
//		// of the feed so we do not need to manually fetch them
//		service.shouldFetchNextPages = true
//		// Have the service object set tickets to retry temporary error conditions
//		// automatically
//		service.isRetryEnabled = true
//		service.maxRetryInterval = 15
//
//		guard let currentUser = GIDSignIn.sharedInstance().currentUser,
//			let authentication = currentUser.authentication else {
//				return nil
//		}
//		service.authorizer = authentication.fetcherAuthorizer()
//		return service
//	}()

	override init() {
		super.init()
//        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/calendar.events.public.readonly"]
	}



	func fetch(force: Bool) {
//        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
//		if GIDSignIn.sharedInstance().currentUser != nil {
//            GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/calendar.events.public.readonly"]
//		fetchEvents()
//        } else {
//            if numberOfTries == 1 {
//                NotificationCenter.default.post(name: .googleCalendarNotAuthenticated, object: nil)
//            }
//            numberOfTries += 1
//        }
	}
    
	func fetchEvents() {
//        let users: [User] = DataFetcher().getEntities(moc: moc)
//        guard let calendarId = users.first?.googleCalendarId else { return }
//        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: calendarId)
//		query.maxResults = 200
//		query.timeMin = GTLRDateTime(date: Date())
//		query.timeMax = GTLRDateTime(date: Date().addingTimeInterval(.days(21)))
//		query.singleEvents = true
//		query.orderBy = kGTLRCalendarOrderByStartTime
//		calendarService?.executeQuery(
//			query,
//			delegate: self,
//			didFinish: #selector(mapResultForTicket(ticket:finishedWithObject:error:)))
	}


	@objc func mapResultForTicket(
		ticket: GTLRServiceTicket,
		finishedWithObject response : GTLRCalendar_Events,
		error : NSError?) {

		if let error = error {
            print(error)
			return
		}
        
//        let mocBackground = newMOCBackground
//        mocBackground.performAndWait {
//            let activities: [GoogleActivity] = DataFetcher().getEntities(moc: mocBackground)
//            activities.forEach({ mocBackground.delete($0) })
//
//            if let events = response.items, !events.isEmpty {
//                for event in events {
//                    let activity: GoogleActivity = DataFetcher().createEntity(moc: mocBackground)
//                    activity.id = UUID().uuidString
//                    activity.startDate = event.start?.dateTime?.date as NSDate?
//                    activity.endDate = event.end?.dateTime?.date as NSDate?
//                    activity.eventDescription = event.summary
//                    activity.createdAt = NSDate()
//                    activity.userUID = Auth.auth().currentUser?.uid ?? "-"
//                }
//            }
//            do {
//                try mocBackground.save()
//            } catch { }
//
//        }
//        do {
//            try moc.save()
//        } catch { }
	}

}

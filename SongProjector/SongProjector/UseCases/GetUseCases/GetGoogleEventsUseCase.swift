//
//  GetGoogleEventsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 03/11/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import GoogleAPIClientForREST_Calendar
import FirebaseAuth
import GoogleSignIn


class GetGoogleEventsUseCase {

    private let calendarService = GTLRCalendarService()
    private var calendarList: GTLRCollectionObject?
    private var calendarListFetchError: Error?
    private var calendarListTicket: GTLRServiceTicket?

    init() {
        calendarService.isRetryEnabled = true
        calendarService.shouldFetchNextPages = true
        let authorizer = GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
        let scopes = GIDSignIn.sharedInstance.currentUser?.grantedScopes
        calendarService.authorizer = authorizer
    }

    func fetch() {

        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "158rpq1n5tdn68f57nb0oip118@group.calendar.google.com")
        query.maxResults = 40
        query.timeMin = GTLRDateTime(date: Date())
        query.timeMax = GTLRDateTime(date: Date().dateByAddingDays(60))

        let bla = calendarService.executeQuery(query) { callbackTicket, calendarList, callbackError in
            // Callback
            self.calendarList = calendarList as? GTLRCollectionObject
            self.calendarListFetchError = callbackError
            self.calendarListTicket = nil

            let something = self.calendarList?.json as? Dictionary<String,Any>
            let items = something?.first( where: { $0.key == "items" })?.value as? [Dictionary<String,Any>]
            let summaries = items?.map { GoogleCalendarEventDictionary(dic: $0) } ?? []
            print(summaries)
            print(summaries)

        }


    }
}

struct GoogleCalendarEventDictionary {

    let startDate: Date
    let endDate: Date
    let summary: String

    init(dic: Dictionary<String,Any>) {
        let start = dic.filter{ $0.key == "start" }.first?.value as? [String: String]
        let end = dic.filter{ $0.key == "end" }.first?.value as? [String: String]
        let startDateString = start?.first(where: { $0.key == "dateTime" })?.value
        let startTimeZoneString = start?.first(where: { $0.key == "timeZone" })?.value
        let endDateString = end?.first(where: { $0.key == "dateTime" })?.value
        let endTimeZoneString = end?.first(where: { $0.key == "timeZone" })?.value


        if let startTimeZoneString, let startDateString {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: startTimeZoneString)
            dateFormatter.locale = .current
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            startDate = dateFormatter.date(from: startDateString) ?? Date()
        } else {
            startDate = Date()
        }

        if let endTimeZoneString, let endDateString {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: endTimeZoneString)
            dateFormatter.locale = .current
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            endDate = dateFormatter.date(from: endDateString) ?? Date()
        } else {
            endDate = Date()
        }
        summary = dic.filter { $0.key == "summary" }.first?.value as? String ?? ""
    }

}

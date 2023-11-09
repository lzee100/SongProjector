//
//  GoogleEventsFetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//
import Foundation
import GoogleAPIClientForREST_Calendar
import FirebaseAuth
import GoogleSignIn


class GoogleEventsFetcher {

    private let calendarService = GTLRCalendarService()
    private var calendarList: GTLRCollectionObject?
    private var calendarListFetchError: Error?
    private var calendarListTicket: GTLRServiceTicket?

    init() {
        calendarService.isRetryEnabled = true
        calendarService.shouldFetchNextPages = true
        let authorizer = GIDSignIn.sharedInstance.currentUser?.fetcherAuthorizer
        calendarService.authorizer = authorizer
    }

    func fetch() async throws {
        let user = await GetUserUseCase().get()
        guard let googleCalendarId = user?.googleCalendarId else { return }
        let result = await withCheckedContinuation { continuation in
            fetch(googleCalendarId: googleCalendarId) { activities in
                continuation.resume(returning: activities)
            }
        }
        try await SaveGoogleActivitiesUseCase().save(entities: result)
    }

    private func fetch(googleCalendarId: String, completion: @escaping (([GoogleCalendarEventDictionary]) -> Void)) {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: googleCalendarId)
        query.maxResults = 40
        query.timeMin = GTLRDateTime(date: Date())
        query.timeMax = GTLRDateTime(date: Date().dateByAddingDays(60))

        _ = calendarService.executeQuery(query) { callbackTicket, calendarList, callbackError in
            // Callback
            self.calendarList = calendarList as? GTLRCollectionObject
            self.calendarListFetchError = callbackError
            self.calendarListTicket = nil

            let something = self.calendarList?.json as? Dictionary<String,Any>
            let items = something?.first( where: { $0.key == "items" })?.value as? [Dictionary<String,Any>]
            completion(items?.map { GoogleCalendarEventDictionary(dic: $0) } ?? [])
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

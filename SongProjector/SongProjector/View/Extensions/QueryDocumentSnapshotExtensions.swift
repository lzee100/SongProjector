//
//  QueryDocumentSnapshotExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 31/05/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum DocumentSnapshotExtensionError:Error {
    case decodingError
}

extension ISO8601DateFormatter {
    class func localDate(from: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        let myDate = formatter.date(from: from)
        return myDate
    }
}

extension Array where Element: QuerySnapshot {
    
    func decoded<Type: Decodable>() throws -> [Type] {
        try map { try $0.decoded() }.flatMap { $0 }
    }

}

extension DocumentSnapshot {
    
    
    func decoded<Type: Decodable>() throws -> Type {
        var documentJson = self.data() ?? [:]
        documentJson["id"] = self.documentID
        let jsonData = try JSONSerialization.data(withJSONObject: documentJson, options: [])
        let object = try JSONDecoder().decode(Type.self, from: jsonData)
        return object
    }

}

extension QuerySnapshot {
    func decoded<Type: Decodable>() throws -> [Type] {
        let objects: [Type] = try documents.map({ try $0.decoded() })
        return objects
    }
}

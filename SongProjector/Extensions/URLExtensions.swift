//
//  URLExtensions.swift
//  Ouder
//
//  Created by Thomas Dekker on 26-07-16.
//  Copyright © 2016 ParnasSys. All rights reserved.
//

import Foundation

extension URL {
    
    public init?(string: String?) {
        
        if let string = string, let url = URL(string: string) {
            self = url
        } else {
            return nil
        }
        
    }
    
    public mutating func append(_ queryItem: URLQueryItem) {
        
        append([queryItem])
        
    }
    
    public mutating func append(_ queryItems: [URLQueryItem]) {
        
        if
            !queryItems.isEmpty,
            var components = URLComponents(url: self, resolvingAgainstBaseURL: false) {
            
            var items = components.queryItems ?? []
            items.append(contentsOf: queryItems)
            components.queryItems = items
            
            if let url = components.url {
                self = url
            }
            
        }
        
    }
    
}

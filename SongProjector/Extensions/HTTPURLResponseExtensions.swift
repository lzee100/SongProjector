//
//  URLResponseExtensions.swift
//  Ouder
//
//  Created by Thomas Dekker on 02-08-16.
//  Copyright © 2016 ParnasSys. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    
    // MARK: - Properties
    
    public var httpStatus : HTTPStatus {
        
        return HTTPStatus.from(statusCode) ?? .serviceUnavailable
        
    }
    
    public var isPartial : Bool {
        
        if let range = allHeaderFields["Content-Range"] as? String {
            
            return httpStatus == .partialContent && !rangeComplete(range: range)
            
        }
        
        return false
        
    }
    
    
    
    // MARK: - Private Functions
    
    private func rangeComplete(range : String) -> Bool{
        
		let parts = range.split(separator: "/")
        
		if let t = parts.last, let total = Int(t), let f = parts.first?.split(separator: "-").last, let end = Int(f) {
            
            return end + 1 >= total
            
        }
        return true
    }
    
}

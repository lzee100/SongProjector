//
//  RequesterType.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/05/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation


protocol RequesterType {
    
    var requesterId: String { get }
    var observers: [RequestObserver] { get set }
    
    func requesterDidStart()
    func addObserver(_ controller: RequestObserver)
    func removeObserver(_ controller: RequestObserver)
    func request(isSuperRequester: Bool)
    func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?)

}

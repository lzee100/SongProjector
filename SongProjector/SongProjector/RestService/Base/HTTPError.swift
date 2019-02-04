//
//  HttpError.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

public enum HTTPStatus: Int {
	
	struct Ranges {
		static let informational = 100..<200
		static let success = 200..<300
		static let redirectional = 300..<400
		static let clientError = 400..<500
		static let serverError = 500..<600
	}
	
	// 100
	case `continue` = 100
	case switchingProtocols = 101
	case processing = 102
	
	// 200 - Succes
	case ok = 200
	case created = 201
	case accepted = 202
	case nonAuthoritativeInformation = 203
	case noContent = 204
	case resetContent = 205
	case partialContent = 206
	case multiStatus = 207
	case alreadyReported = 208
	case imUsed = 226
	
	// 300 - Redirection
	case multipleChoices = 300
	case movedPermanently = 301
	case found = 302
	case seeOther = 303
	case notModified = 304
	case useProxy = 305
	case switchProxy = 306
	case temporaryRedirect = 307
	case permanentRedirect = 308
	
	// 400 - Client Error
	case badRequest = 400
	case unauthorized = 401
	case paymentRequired = 402
	case forbidden = 403
	case notFound = 404
	case methodNotAllowed = 405
	case notAcceptable = 406
	case proxyAuthenticationRequired = 407
	case requestTimeout = 408
	case conflict = 409
	case gone = 410
	case lengthRequired = 411
	case preconditionFailed = 412
	case requestEntityTooLarge = 413
	case requestURITooLong = 414
	case unsupportedMediaType = 415
	case requestedRangeNotSatisfiable = 416
	case expectationFailed = 417
	case imaTeapot = 418
	case authenticationTimeout = 419
	case unprocessableEntity = 422
	case locked = 423
	case failedDependency = 424
	case upgradeRequired = 426
	case preconditionRequired = 428
	case tooManyRequests = 429
	case requestHeaderFieldsTooLarge = 431
	case loginTimeout = 440
	case noResponse = 444
	case retryWith = 449
	case unavailableForLegalReasons = 451
	case requestHeaderTooLarge = 494
	case certificateError = 495
	case noCert = 496
	case httpToHTTPS = 497
	case tokenExpired = 498
	case clientClosedRequest = 499
	
	// 500 - Server Error
	case internalServerError = 500
	case notImplemented = 501
	case badGateway = 502
	case serviceUnavailable = 503
	case gatewayTimeout = 504
	case httpVersionNotSupported = 505
	case variantAlsoNegotiates = 506
	case insufficientStorage = 507
	case loopDetected = 508
	case bandwidthLimitExceeded = 509
	case notExtended = 510
	case networkAuthenticationRequired = 511
	case networkTimeoutError = 599
	
	public var isInformational:Bool { return inRange(Ranges.informational) }
	public var isSuccess:Bool { return inRange(Ranges.success) }
	public var isRedirection:Bool { return inRange(Ranges.redirectional) }
	public var isClientError:Bool { return inRange(Ranges.clientError) }
	public var isServerError:Bool { return inRange(Ranges.serverError) }
	
	public static func from(_ code:Int) -> HTTPStatus? {
		
		if let result = HTTPStatus(rawValue: code) {
			return result
		}
		
		let first = String(describing: "\(code)".first)
		
		switch first {
		case "1":
			return .continue
		case "2":
			return .ok
		case "3":
			return .multipleChoices
		case "4":
			return .badRequest
		case "5":
			return .internalServerError
		default:
			return nil
		}
	}
	
	public var localizedString:String {
		return HTTPURLResponse.localizedString(forStatusCode: self.rawValue)
	}
	
	private func inRange(_ range: CountableRange<Int>) -> Bool {
		return range.contains(rawValue)
	}
}

public enum HTTPError {
	
	case noInternet(error:NSError?)
	case status(status:HTTPStatus, error:NSError?)
	case unknown(error:NSError?)
}

//
//  Fetcher.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation

import Foundation
import UIKit

protocol LogoFetcherObserver {
	func logoFetcherDidStart()
	func logoFetcherDidFinish(result: ResultTypes)
}



class LogoFetcher: NSObject {

	struct Constants {
		static let iddinkId = "logoLastUpdatedIddink"
		static let organizationId = "logoLastUpdateOrganization"
	}

	enum LogoOwner {
		case iddink
		case organization
	}

	private var observers: [LogoFetcherObserver] = []

	var url: URL
	var logoOwner: LogoOwner

	var needsUpdating : Bool {
		return needsRefresh()
	}

	init(url: URL, logoOwner: LogoOwner) {
		self.url = url
		self.logoOwner = logoOwner
	}

	func addObserver(_ controller: LogoFetcherObserver) {
		observers.append(controller)
	}

	func fetch(_ force: Bool = false) {
		if needsUpdating || force {
			downloadImage(url: url)
		} else {
			observers.forEach { $0.logoFetcherDidFinish(result: .OK) }
		}
	}

	private func downloadImage(url: URL) {
		observers.forEach { $0.logoFetcherDidStart() }

		getDataFromUrl(url: url) { data, response, error in
			if error != nil {
				DispatchQueue.main.async {
					self.observers.forEach { $0.logoFetcherDidFinish(result: ResultTypes.error) }
				}
			} else if let data = data {
				DispatchQueue.main.async {
					if let image = UIImage(data: data) {
						self.saveImageLocaly(image: image)
						self.observers.forEach { $0.logoFetcherDidFinish(result: .OK) }
					} else {
						self.observers.forEach { $0.logoFetcherDidFinish(result: .imageError) }
					}
				}
			} else {
				self.observers.forEach { $0.logoFetcherDidFinish(result: .error) }
			}
		}
	}

	private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
		URLSession.shared.dataTask(with: url) { data, response, error in
			completion(data, response, error)
			}.resume()
	}

	private func needsRefresh() -> Bool {
		// get local saved last changed date
		if let lastUpdatedLocal = logoOwner == .iddink ? BrandingQuery().selectFirst()?.localiddinkLogoLaatstGewijzigd?.date : BrandingQuery().selectFirst()?.localOrganisatieLogoLaatstGewijzigd?.date {
			// get server last changed date
			let lastUpdatedServer = logoOwner == .iddink ? BrandingQuery().selectFirst()?.iddinkLogoLaatstGewijzigd : BrandingQuery().selectFirst()?.organisatieLogoLaatstGewijzigd
			if let lastUpdatedServer = lastUpdatedServer?.date {
				return lastUpdatedLocal.isBefore(lastUpdatedServer)
			} else {
				return true
			}
		}
		return true
	}

	private func saveImageLocaly(image: UIImage) {
		let branding = BrandingQuery().selectFirst()
		if logoOwner == .iddink {
			branding?.logoIddink = image
			branding?.localiddinkLogoLaatstGewijzigd = branding?.iddinkLogoLaatstGewijzigd
		} else {
			branding?.logoOrganization = image
			branding?.localOrganisatieLogoLaatstGewijzigd = branding?.organisatieLogoLaatstGewijzigd
		}
	}

}


//
//  LoadingIndicator.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

let Loader = LoadingIndicator()

class LoadingIndicator{
	
	fileprivate var lastError : NSError?
	
	fileprivate struct Constants{
		static let messageTime = TimeInterval.seconds(2.0)
	}
	
	fileprivate var loader : LoadingViewController?
	
	fileprivate func createLoader() -> LoadingViewController?{
		if let window = UIApplication.shared.keyWindow{
			let loader = window.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "") as? LoadingViewController
			loader?.view?.frame = window.frame
			if let view = loader?.view{
				window.addSubview(view)
			}
			return loader
		}
		return nil
	}
	
	fileprivate func getLoader() -> LoadingViewController?{
		if loader == nil{
			loader = createLoader()
		}
		return loader
	}
	
	func showLoader(){
		DispatchQueue.main.async  {
			if let loader = self.getLoader(){
				loader.view.isHidden = false
				loader.activityIndicator.isHidden = false
			}
		}
	}
	
	func hideLoader(){
		DispatchQueue.main.async  {
			if let loader = self.loader{
				loader.activityIndicator.isHidden = true
				if loader.messageView.isHidden == true{
					loader.view.isHidden = true
				}
			}
		}
	}
	
	func message(_ title: String, message: String){
		DispatchQueue.main.async {
			if let loader = self.getLoader() {
				loader.view.isHidden = false
				loader.messageView.isHidden = true
				loader.message.text = message
				loader.messageTitle.text = title
				loader.showMessage(Constants.messageTime)
				self.lastError = nil
			}
		}
	}
	
//	fileprivate func messageTitle(_ title : String) -> String{
//		var suffix = ""
//		if let errorCode = lastError?.code{
//			suffix = " (\(errorCode))"
//		}
//		switch ReleaseMode.current{
//		case .appStore: return title
//		case .testFlight: return title + suffix
//		}
//	}
//
//	fileprivate func messageText(_ message : String) -> String{
//		var suffix = ""
//		if let errorDescription = lastError?.localizedDescription{
//			suffix = " (\n\(errorDescription))"
//		}
//		switch ReleaseMode.current{
//		case .appStore: return message
//		case .testFlight: return message + suffix
//		}
//	}
//
//	func reportError(_ error : NSError?){
//		if ReleaseMode.current == .testFlight{
//			self.lastError = error
//		}
//	}
	
	fileprivate init(){
	}
}

//
//  IntroPageViewContainer.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit


class IntroPageViewContainer: ChurchBeamViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	
	static let identifier = "IntroPageViewContainer"
	
	var currentIndex: Int = 0
	var nextIndex: Int?
	
	var pageControllers: [PageController] = []
	
	var currentViewController: PageController {
		return self.pageViewController.viewControllers![0] as! PageController
	}
	
	var pageViewController: UIPageViewController {
		return self.childViewControllers[0] as! UIPageViewController
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.pageViewController.delegate = self
		self.pageViewController.dataSource = self

		guard let pageController = pageControllers.first else {
			return
		}
		pageViewController.setViewControllers([pageController], direction: .forward, animated: true, completion: nil)
	}
	
	
	func setup(controllers: [PageController]) {
		self.pageControllers = controllers
	}
	
	
	
	// UIPageViewController Functions
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if currentIndex == 0 {
			return nil
		}
		return pageControllers[currentIndex - 1]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if currentIndex == (self.pageControllers.count - 1) {
			return nil
		}
		return pageControllers[currentIndex + 1]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		guard let nextVC = pendingViewControllers.first as? PageController, let index = pageControllers.firstIndex(of: nextVC) else {
			return
		}
		self.nextIndex = index
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if (completed && self.nextIndex != nil) {
			self.currentIndex = self.nextIndex!
		}
		self.nextIndex = nil
	}
	
	
	
	class func introControllers() -> [PageController] {
		let page1 = Storyboard.Intro.instantiateViewController(withIdentifier: IntroPageController1.identifier) as! IntroPageController1
		let page2 = Storyboard.Intro.instantiateViewController(withIdentifier: IntroPageController2.identifier) as! IntroPageController2
		return [page1, page2]
	}
	
}

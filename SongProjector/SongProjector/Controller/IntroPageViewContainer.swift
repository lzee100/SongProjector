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
	
    @IBOutlet weak var pageControl: UIPageControl!
    
	static let identifier = "IntroPageViewContainer"
	
	var currentIndex: Int = 0
	var nextIndex: Int?
	
	var pageControllers: [PageController] = []
	
	var currentViewController: PageController {
		return self.pageViewController.viewControllers![0] as! PageController
	}
	
	var pageViewController: UIPageViewController {
		return self.children[0] as! UIPageViewController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		guard let pageController = pageControllers.first else {
			return
		}
		pageViewController.setViewControllers([pageController], direction: .forward, animated: true, completion: nil)
        
        NotificationCenter.default.addObserver(forName: .newUser, object: nil, queue: .main) { [weak self] (_) in
            Queues.main.async {
                if let last = self?.pageControllers.last {
                    self?.pageViewController.setViewControllers([last], direction: .forward, animated: true, completion: nil)
                }
            }
        }
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
		self.pageViewController.delegate = self
		self.pageViewController.dataSource = self

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
		if currentIndex == (pageControllers.count - 1) || currentIndex == 1 {
			return nil
		}
		return pageControllers[currentIndex + 1]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
		guard let nextVC = pendingViewControllers.first as? PageController, let index = pageControllers.firstIndex(of: nextVC) else {
			return
		}
		nextIndex = index
        pageControl.currentPage = index
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if (completed && nextIndex != nil) {
			currentIndex = nextIndex!
		}
        pageControl.currentPage = currentIndex
		nextIndex = nil
	}
	
	
	
	class func introControllers() -> [PageController] {
		let page1 = Storyboard.Intro.instantiateViewController(withIdentifier: IntroPageController1.identifier) as! IntroPageController1
        let page2 = Storyboard.Intro.instantiateViewController(withIdentifier: IntroPageController22.identifier) as! IntroPageController22
        let page3 = Storyboard.Intro.instantiateViewController(withIdentifier: IntroAdminController.identifier) as! IntroAdminController
		return [page1, page2, page3]
	}
	
}

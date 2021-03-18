//
//  SongProjector
//
//  Created by Leo van der Zee on 05/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

class Queues: NSObject {
    static var background: DispatchQueue {
        return DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    }
    static var main: DispatchQueue {
        return DispatchQueue.main
    }
}

open class Operation : Foundation.Operation {
	
	public static let GlobalQueue: OperationQueue = {
		let queue = OperationQueue()
		queue.name = "GlobalQueue"
		queue.maxConcurrentOperationCount = 1
		return queue
	}()
	
	public static let Queue : OperationQueue = {
		
		let queue = OperationQueue()
		queue.name = "OperationQueue"
		return queue
		
	}()
	
	
	
	// MARK: - Construction
	
	public override init() {
		
		super.init()
		
	}
	
	
	
	// MARK: - Public Functions
	
	public static func dependenciesInOrder(_ operations: [Foundation.Operation]) {
		
		var previous : Foundation.Operation?
		
		for current in operations {
			
			if let previous = previous {
				
				previous.addDependency(current)
				
			}
			
			previous = current
			
		}
		
	}
	
	
	open override func main() {
		
		
		
	}
	
}

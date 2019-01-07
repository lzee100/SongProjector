//
//  ManagedObjectCodable.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//


import Foundation

open class Operation : Foundation.Operation {
    
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
        
        for current in operations.reversed() {
            
            if let previous = previous {
                
                previous.addDependency(current)
                
            }
            
            previous = current
            
        }
        
    }
    
    
    open override func main() {
        
        
        
    }
    
}

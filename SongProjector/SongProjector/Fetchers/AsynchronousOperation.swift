//
//  RequestOperation.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation

public enum OperationState{
    case unstarted, running, finished, failed
    
    var method : String{
        switch self {
        case .unstarted: return "isReady"
        case .running: return "isExecuting"
        case .failed: return "isFinished"
        case .finished: return "isFinished"
        }
    }
}

open class AsynchronousOperation : Operation{
    
    // MARK: - Private Properties
    
    private var state = OperationState.unstarted
        {
        willSet{
            willChangeValue(forKey: newValue.method)
            willChangeValue(forKey: state.method)
        }
        didSet{
            didChangeValue(forKey: oldValue.method)
            didChangeValue(forKey: state.method)
        }
    }
    
    
    
    // MARK: - Public Properties
    
    // NSOperation Properties
    
    override open var isAsynchronous: Bool{
        return true
    }
    
    override open var isFinished: Bool{
        return state == .finished || state == .failed
    }
    
    override open var isExecuting: Bool{
        return state == .running
    }
    
    override open var isReady: Bool{
        return super.isReady && state == .unstarted
    }
    
    
    
    // MARK: - Public Functions
    
    public func didStart(){
        if state == .unstarted{
            state = .running
        }
    }
    
    public func didFail(){
        state = .failed
    }
    
    public func didFinish(){
        if state != .failed{
            state = .finished
        }
    }
    
    // NSOperation Functions
    
    override open func start() {
        
        if ( isCancelled ) {
            
            didFinish()
            
        } else {
            
            didStart()
            main()
            
        }
        
    }
    
}

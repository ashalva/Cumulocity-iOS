//
//  AsyncOperation.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 27/09/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation

public class AsyncOperation : Operation {
    private let stateLock_ = NSLock()
    private var executing_ = false
    private var finished_ = false
    
    override public var isAsynchronous: Bool {
        return true
    }
    
    //property indicating if current operation is executed or not
    override private(set) public var isExecuting: Bool {
        get {
            return stateLock_.withCriticalScope { executing_ }
        }
        set{
            willChangeValue(forKey: "isExecuting")
            stateLock_.withCriticalScope { executing_ = newValue }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    //property indicating if current operation has finished or not
    override private(set) public var isFinished: Bool {
        get {
            return stateLock_.withCriticalScope { finished_ }
        }
        set {
            willChangeValue(forKey: "isFinished")
            stateLock_.withCriticalScope { finished_ = newValue }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    //callback function called when the execution is finished
    public func completeOperation() {
        if isExecuting {
            isExecuting = false
        }
        
        if !isFinished {
            isFinished = true
        }
    }
    
    //starting executing the operation
    override public func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        main()
    }
    
    override public func main() {
        fatalError("override `main`")
    }
}

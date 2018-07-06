//
//  NSLock+Extensions.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 27/09/2017.
//  Copyright © 2017 Shalva Avanashvili. All rights reserved.
//

import Foundation
extension NSLock {
    func withCriticalScope<T>(_ block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

extension NSRecursiveLock {
    func withCriticalScope<T>(_ block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

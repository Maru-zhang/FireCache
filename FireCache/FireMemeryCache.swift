//
//  FireMemeryCache.swift
//  FireCache
//
//  Created by Maru on 2018/6/5.
//  Copyright © 2018 souche. All rights reserved.
//

import Foundation

public class FireMemeryCache<Element>: FireCachable {

    typealias T = Element

    let coreMap = LinkedNodeMap<T>(k: 1)

    var historyQueueLength: Int64 = Int64(1e5) {
        didSet {
            coreMap.flushToHistoryCountLimit(historyQueueLength)
        }
    }

    var countCapacity: Int64 = Int64.max {
        didSet {
            coreMap.flushToCountLimit(countCapacity)
        }
    }

    var costCapacity: Int64 = Int64.max {
        didSet {
            coreMap.flushToCostLimit(costCapacity)
        }
    }

    func get(for key: String) -> Element? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        return coreMap.get(for: key)
    }

    func put(_ value: Element?, key: String) {
        put(value, key: key, cost: 0)
    }

    func put(_ value: Element?, key: String, cost: Int64 = 0) {
        lockedWork {
            if let value = value {
                coreMap.put(value, key: key, cost: cost)
                coreMap.flushToHistoryCountLimit(historyQueueLength)
                coreMap.flushToCostLimit(costCapacity)
                coreMap.flushToCountLimit(countCapacity)
            }
        }
    }

    func clear() {
        lockedWork {
            coreMap.removeAll()
        }
    }
}

extension FireMemeryCache {

    subscript(key: String) -> Element? {
        get {
            return get(for: key)
        }
    }

    func lockedWork(_ work:() -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        work()
    }
}

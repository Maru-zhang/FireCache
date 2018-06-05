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
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if let value = value {
            coreMap.put(value, key: key, cost: cost)
        }
    }

    func clear() {

    }
}

extension FireMemeryCache {

    subscript(key: String) -> Element? {
        get {
            return get(for: key)
        }
    }
}

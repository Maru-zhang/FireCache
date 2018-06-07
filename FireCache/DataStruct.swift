//
//  DataStruct.swift
//  FireCache
//
//  Created by Maru on 2018/6/5.
//  Copyright © 2018 souche. All rights reserved.
//

import Foundation

public class LinkNode<T> {

    var parent: LinkNode<T>?
    var next: LinkNode<T>?
    let key: String
    var value: T
    var count: Int
    let cost: Int64
    let timeInterval: CFTimeInterval

    init(parent: LinkNode<T>?, next: LinkNode<T>?, key: String, value: T, cost: Int64 = 0) {
        self.parent = parent
        self.next = next
        self.key = key
        self.value = value
        self.count = 1
        self.cost = cost
        self.timeInterval = CACurrentMediaTime()
    }

    public var head: LinkNode<T>? {
        return findHead(self)
    }

    func findHead(_ node: LinkNode<T>?) -> LinkNode<T>? {
        guard let _node = node else { return nil }
        return _node.next == nil ? node : findHead(_node.next)
    }
}

public class LinkedNodeMap<T> {

    var head: LinkNode<T>?
    var tail: LinkNode<T>?

    var historyHead: LinkNode<T>?
    var historyTail: LinkNode<T>?

    private var map = [String: LinkNode<T>]()
    private let k: Int8

    private var totailCost: Int64 = 0
    private var totailCount: Int64 = 0
    private var totailHistoryCount: Int64 = 0

    init(k: Int8 = 1) {
        self.k = k;
    }

    func put(_ value: T, key: String, cost: Int64 = 0) {
        if (k > 1) {
            if let oldNode = map[key] {
                if oldNode.count >= k {
                    // on the cached queue
                    bringToHead(for: oldNode)
                    oldNode.value = value
                } else {
                    // on the history queue
                    oldNode.count += 1
                    oldNode.value = value
                    if (oldNode.count >= k) {
                        // move from history queue to cached queue
                        let preNode = oldNode.parent
                        let nextNode = oldNode.next
                        preNode?.next = nextNode
                        oldNode.next = head
                        head = oldNode
                    }
                }
                map[key] = oldNode
            } else {
                let node = LinkNode<T>(parent: nil, next: historyHead, key: key, value: value)
                historyHead = node
                if (historyTail == nil) {
                    historyTail = node
                }
                map[key] = node
            }
            return
        }
        // move node to head of queue
        if let oldNode = map[key] {
            bringToHead(for: oldNode)
            oldNode.value = value
        } else {
            let node = LinkNode<T>(parent: nil, next: head, key: key, value: value)
            head = node
        }
        updateTail()
        map[key] = head
        // increase cost and count ...
        totailCount += 1
        totailCost += cost
    }

    func get(for key: String) -> T? {
        return map[key]?.value
    }

    @discardableResult
    func removeTail() -> LinkNode<T>? {
        let popedNode = tail
        if let node = popedNode {
            let preNode = node.parent
            preNode?.next = nil
            tail = preNode
            totailCount -= 1
            totailCost -= node.cost
            map.removeValue(forKey: node.key)
        }
        return popedNode
    }

    @discardableResult
    func removeHistoryTail() -> LinkNode<T>? {
        guard k > 1 else { return nil }
        let popedNode = historyTail
        if let node = popedNode {
            let preNode = node.parent
            preNode?.next = nil
            historyTail = preNode
            totailCount -= 1
            map.removeValue(forKey: node.key)
        }
        return popedNode
    }

    func removeAll() {
        historyHead = nil
        historyTail = nil
        head = nil
        tail = nil
        map.removeAll()
    }

    func updateTail() {
        var loopNode = head
        while let node = loopNode {
            if (node.next == nil) {
                tail = node
            }
            loopNode = node.next
        }
    }

    func updateHistoryTail() {
        var loopNode = historyHead
        while let node = loopNode {
            if (node.next == nil) {
                historyTail = node
            }
            loopNode = node.next
        }
    }

    func bringToHead(for node: LinkNode<T>) {
        let preNode = node.parent
        let nextNode = node.next
        let preHead = head
        preNode?.next = nextNode
        tail = node
        tail?.next = preHead
    }

    /// flush history item unitl under the maximumCount
    ///
    /// - Parameter maximumCount: the maximum of history item count
    func flushToHistoryCountLimit(_ maximumCount: Int64) {
        guard maximumCount > 0 else { return }
        while totailHistoryCount > maximumCount {
            removeHistoryTail()
        }
    }

    /// flush item unitl under the maximumCost
    ///
    /// - Parameter maximumCost: the maximum of item cost
    func flushToCostLimit(_ maximumCost: Int64) {
        guard maximumCost > 0 else { return }
        while totailCost > maximumCost {
            removeTail()
        }
    }

    /// flush item until under the maximumCount
    ///
    /// - Parameter maximumCount: the maximum of item count
    func flushToCountLimit(_ maximumCount: Int64) {
        guard maximumCount > 0 else { return }
        while totailCount > maximumCount {
            removeTail()
        }
    }
}

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

    var costCapacity: Int64 = Int64.max
    var countCapacity: Int64 = Int64.max

    init(k: Int8 = 1) {
        self.k = k;
    }

    var needAdjust: Bool {
        return (totailCost > costCapacity) || (totailCount > countCapacity)
    }

    func put(_ value: T, key: String, cost: Int64 = 0) {
        if (k > 1) { return }
        // move node to head of queue
        if let oldNode = map[key] {
            if (oldNode.count <= k) {
                // on the history queue
                oldNode.count += 1
                if (oldNode.count > k) {
                    let preNode = oldNode.parent
                    let nextNode = oldNode.next
                    preNode?.next = nextNode
                    oldNode.next = head
                    head = oldNode
                }
            } else {
                // on the cache queue
            }
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
        if (needAdjust) { adjustForLimit() }
    }

    func get(for key: String) -> T? {
        return map[key]?.value
    }

    @discardableResult
    func popTail() -> LinkNode<T>? {
        let popedNode = tail
        if let node = popedNode {
            let preNode = tail?.parent
            preNode?.next = nil
            tail = preNode
            totailCount -= 1
            totailCost -= node.cost
            map.removeValue(forKey: node.key)
        }
        return popedNode
    }

    func updateTail() {
        /// if we loop up from head, it will loop up the whole linkmap,
        /// but if we loop up from other node, the performence will be
        /// better.
        var loopNode = head
        while let node = loopNode {
            if (node.next == nil) {
                tail = node
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

    func flushToCostLimit(_ costLimit: Int64) {

    }

    func flushToCountLimit(_ countLimit: Int64) {

    }

    func adjustForLimit() {
        guard needAdjust else { return }
        popTail()
        adjustForLimit()
    }
}

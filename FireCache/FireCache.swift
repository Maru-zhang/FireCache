//
//  FireCache.swift
//  FireCache
//
//  Created by Maru on 2018/6/5.
//  Copyright © 2018 souche. All rights reserved.
//

import Foundation

protocol FireCachable {
    associatedtype T
    func get(for key: String) -> T?
    func put(_ value: T?, key: String)
    func clear()
}

//
//  FireCacheTests.swift
//  FireCacheTests
//
//  Created by Maru on 2018/6/5.
//  Copyright © 2018 souche. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import FireCache

class FireCacheTests: QuickSpec {

    override func spec() {
        describe("FireMemery Cache Test") {
            describe("put in Integer value", {
                it("get Integer value as result", closure: {
                    let cache = FireMemeryCache<Int>()
                    cache.put(100, key: "foo")
                    expect(cache.get(for: "foo")).to(equal(100))
                })
                describe("cache two number", {
                    context("when count capacity only one", {
                        it("get nil value", closure: {
                            let cache = FireMemeryCache<Int>()
                            cache.coreMap.countCapacity = 1
                            cache.put(100, key: "foo")
                            cache.put(200, key: "bar")
                            expect(cache.get(for: "foo")).to(beNil())
                            expect(cache.get(for: "bar")).to(equal(200))
                        })
                    })
                })
            })
            describe("subscript way to get value", {
                it("get Integer value as result", closure: {
                    let cache = FireMemeryCache<Int>()
                    cache.put(100, key: "foo")
                    expect(cache["foo"]).to(equal(100))
                })
            })
        }
    }
}

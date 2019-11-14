//
//  FoundationWrappers.swift
//  SampleApp
//
//  Created by makoto on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

protocol LiteralWrapper {
    associatedtype Value
    var value: Value? { get set}
    init(_ value: Value?)
    init()
}

extension LiteralWrapper {
    init(_ value: Value?) {
        self.init()
        self.value = value
    }
}

struct 文字列: LiteralWrapper {
    typealias Value = String
    var value: String?
    init() {
    }
}

struct 整数: LiteralWrapper {
    typealias Value = Int
    var value: Int?
    init() {
    }
}

struct 正誤: LiteralWrapper {
    typealias Value = Bool
    var value: Bool?
    init() {
    }
}

struct セクションと行数: LiteralWrapper {
    typealias Value = IndexPath
    var value: IndexPath?
    init() {
    }
    init(セクション: 整数, 行数: 整数) {
        value = .init(row: 行数.value ?? 0, section: セクション.value ?? 0)
    }
    var セクション: 整数 {
        set {
            value?.section = newValue.value ?? 0
        }
        get {
            let num = value?.section ?? 0
            return 整数(num)
        }
    }
    
    var 行数: 整数 {
        set {
            value?.row = newValue.value ?? 0
        }
        get {
            let num = value?.row ?? 0
            return 整数(num)
        }
    }
}

extension URL {
    init?(文字列: 文字列) {
        self.init(string: 文字列.value ?? "")
    }
}

//
//  FoundationWrappers.swift
//  SampleApp
//
//  Created by makoto on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

protocol ValueWrapper {
    associatedtype Value
    var value: Value? { get set}
    init(_ value: Value?)
    init()
}

extension ValueWrapper {
    init(_ value: Value?) {
        self.init()
        self.value = value
    }
}

protocol EquatableValueWrapper: ValueWrapper, Equatable {
}

struct 文字列: EquatableValueWrapper {
    typealias Value = String
    var value: String?
    init() {
    }
    
    var 空である: 正誤 {
        return 正誤(value?.isEmpty)
    }
}

func + (lhs: 文字列, rhs: 文字列) -> 文字列 {
    if let lhsText = lhs.value, let rhsText = rhs.value {
        return 文字列(lhsText + rhsText)
    }
    if let lhsText = lhs.value {
        return 文字列(lhsText)
    }
    return 文字列(rhs.value)
}

struct 整数: EquatableValueWrapper {
    typealias Value = Int
    var value: Int?
    init() {
    }
}

struct 正誤: EquatableValueWrapper {
    typealias Value = Bool
    var value: Bool?
    init() {
    }
}

struct セクションと行数: EquatableValueWrapper {
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

struct エラー: ValueWrapper {
    typealias Value = Error
    var value: Error?
    init() {
    }
    var エラー内容: 文字列 {
        return 文字列(value?.localizedDescription)
    }
}

class URLセッション: URLSession {
    
    let session: URLSession?
    init(_ session: URLSession) {
        self.session = session
    }
    class var 共通のやつ: URLセッション {
        return URLセッション(URLSession.shared)
    }
    
    func 通信処理を作成する(URL: URL, 完了時の処理: @escaping (データ?, URLレスポンス?, エラー?) -> Void) -> 通信処理 {
        if let session = session {
            return 通信処理(session.dataTask(with: URL, completionHandler: { (data, response, error) in
                完了時の処理(data.flatMap { データ($0) }, response.flatMap { URLレスポンス($0) }, error.flatMap { エラー($0) })
            }))
        }
        return 通信処理(dataTask(with: URL, completionHandler: { (data, response, error) in
            完了時の処理(data.flatMap { データ($0) }, response.flatMap { URLレスポンス($0) }, error.flatMap { エラー($0) })
        }))
    }
}

class 通信処理: URLSessionTask {
    
    let task: URLSessionTask?
    init(_ task: URLSessionTask) {
        self.task = task
    }
    
    func 開始する() {
        if let task = task {
            task.resume()
            return
        }
        resume()
    }
}

struct データ: ValueWrapper {
    typealias Value = Data
    var value: Data?
    init() {
    }
}

class URLレスポンス: URLResponse {
    
    let response: URLResponse?
    init(_ response: URLResponse) {
        self.response = response
        super.init(url: response.url!, mimeType: response.mimeType!, expectedContentLength: Int(response.expectedContentLength), textEncodingName: response.textEncodingName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var HTTPステータスコード: 整数? {
        if let response = response,
            let httpResponse = response as? HTTPURLResponse  {
            return 整数(httpResponse.statusCode)
        }
        return nil
    }
}

class JSONデコーダー: JSONDecoder {
    func デコードする<型>(_ 型: 型.Type, デコードするデータ: データ) throws -> 型 where 型 : Decodable {
        guard let data = デコードするデータ.value else {
            throw JSONデコードエラー.データが空
        }
        return try decode(型, from: data)
    }
}

enum JSONデコードエラー: Error {
    case データが空
}

func メインスレッドで処理する(処理: @escaping() -> Void) {
    DispatchQueue.main.async {
         処理()
    }
}

struct 配列<要素>: ValueWrapper {
    typealias Value = [要素]
    var value: [要素]?
    init() {
    }
    
    var 空である: 正誤 {
        return 正誤(value?.isEmpty == true)
    }
    
    var 要素数: 整数 {
        return 整数(value?.count ?? 0)
    }
    
    func 指定の番号の要素を取り出す(番号: 整数) -> 要素? {
        guard let index =  番号.value else {
            return nil
        }
        return value?[index]
    }
}

//
//  FoundationWrappers.swift
//  SampleApp
//
//  Created by makoto on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

protocol ValueWrapper {
    associatedtype 値の型
    var 値: 値の型 { get set}
    init?(_ 値: 値の型?)
    init(_ 値: 値の型)
    init()
}

extension ValueWrapper {
    init(_ 値: 値の型) {
        self.init()
        self.値 = 値
    }
    
    init?(_ 値: 値の型?) {
        guard let 値 = 値 else {
            return nil
        }
        self.init()
        self.値 = 値
    }
}

protocol EquatableValueWrapper: ValueWrapper, Equatable {
}

struct 文字列: EquatableValueWrapper {
    typealias 値の型 = String
    var 値: String = ""
    init() {
    }
    
    var 空である: 正誤 {
        return 正誤(値.isEmpty)
    }
}

func + (lhs: 文字列, rhs: 文字列) -> 文字列 {
    return 文字列(lhs.値 + rhs.値)
}

struct 整数: EquatableValueWrapper {
    typealias 値の型 = Int
    var 値: Int = 0
    init() {
    }
}

struct 正誤: EquatableValueWrapper {
    typealias 値の型 = Bool
    var 値: Bool = true
    init() {
    }
}

struct セクションと行数: EquatableValueWrapper {
    typealias 値の型 = IndexPath
    var 値: IndexPath = .init()
    init() {
    }

    init(セクション: 整数, 行数: 整数) {
        値 = .init(row: 行数.値, section: セクション.値)
    }

    var セクション: 整数 {
        set {
            値.section = newValue.値
        }
        get {
            return 整数(値.section)
        }
    }

    var 行数: 整数 {
        set {
            値.row = newValue.値
        }
        get {
            return 整数(値.row)
        }
    }
}

extension URL {
    init?(文字列: 文字列) {
        self.init(string: 文字列.値)
    }
}

struct エラー {

    let 値: Error?

    init?(_ 値: Error?) {
        guard let 値 = 値 else {
            return nil
        }
        self.値 = 値
    }

    var エラー内容: 文字列 {
        return 文字列(値?.localizedDescription ?? "")
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
    typealias 値の型 = Data
    var 値: Data = .init()
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
        return try decode(型, from: デコードするデータ.値)
    }
}

func メインスレッドで処理する(処理: @escaping() -> Void) {
    DispatchQueue.main.async {
         処理()
    }
}

struct 配列<要素>: ValueWrapper {
    typealias 値の型 = [要素]
    var 値: [要素] = []
    init() {
    }
    
    var 空である: 正誤 {
        return 正誤(値.isEmpty)
    }
    
    var 要素数: 整数 {
        return 整数(値.count)
    }
    
    func 指定の番号の要素を取り出す(番号: 整数) -> 要素? {
        return 値[番号.値]
    }
}

func ログを表示する(_ ログ一覧: Any..., 区切り: 文字列 = 文字列(" "), 終端: 文字列 = 文字列("\n")) {
    print(ログ一覧, separator: 区切り.値, terminator: 終端.値)
}

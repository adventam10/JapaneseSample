//
//  記事一覧モデル.swift
//  SampleApp
//
//  Created by am10 on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

protocol 記事一覧モデル通知: AnyObject {
    func モデル(_ モデル: 記事一覧モデル, 記事一覧を更新した 記事一覧: [記事])
}

final class 記事一覧モデル {

    weak var 記事一覧モデル通知: 記事一覧モデル通知?
    var 記事一覧 = [記事]() {
        didSet {
            記事一覧モデル通知?.モデル(self, 記事一覧を更新した: 記事一覧)
        }
    }
    var 検索ワード = 文字列("")
    var 記事一覧がある: Bool {
        return !記事一覧.isEmpty
    }
    
    private let 記事検索URL = 文字列("https://qiita.com/api/v2/items?page=1&per_page=20&query=body:")
    
    func 記事のタイトル(行数: 整数) -> 文字列? {
        return 記事一覧[行数.value ?? 0].タイトル
    }
    
    func 記事のURL(行数: 整数) -> URL? {
        if let url = 記事一覧[行数.value ?? 0].URL {
            return URL(文字列: url)
        }
        return nil
    }
    
    func 検索する(検索ワード: 文字列?,
                完了時の処理: @escaping (SearchResult) -> Void) {
        guard let 検索ワード = 検索ワード, 検索ワード.value?.isEmpty == false else {
            完了時の処理(.success(word: "", articles: []))
            return
        }
        guard let url = URL(文字列: 文字列(記事検索URL.value ?? "" + (検索ワード.value?.urlEncode() ?? ""))) else {
            完了時の処理(.failure(error: .invalidURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                完了時の処理(.failure(error: .server(error)))
                return
            }
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode != 200 {
                完了時の処理(.failure(error: .network))
                return
            }
            guard let data = data,
                let articles = try? JSONDecoder().decode([記事].self, from: data) else {
                    完了時の処理(.failure(error: .invalidJSON))
                    return
            }
            完了時の処理(.success(word: 検索ワード.value ?? "", articles: articles))
        }
        task.resume()
    }
}

//
//  記事一覧モデル.swift
//  SampleApp
//
//  Created by am10 on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

protocol 記事一覧モデル通知: AnyObject {
    func モデル(_ モデル: 記事一覧モデル, 記事一覧を更新した 記事一覧: 配列<記事>)
}

final class 記事一覧モデル {
    weak var 記事一覧モデル通知: 記事一覧モデル通知?
    var 記事一覧 = 配列([記事]()) {
        didSet {
            記事一覧モデル通知?.モデル(self, 記事一覧を更新した: 記事一覧)
        }
    }
    var 検索ワード = 文字列("")
    var 記事一覧がある: 正誤 {
        return 正誤(記事一覧.空である != 正誤(true))
    }
    
    private let 記事検索URL = 文字列("https://qiita.com/api/v2/items?page=1&per_page=20&query=body:")
    
    func 記事のタイトル(行数: 整数) -> 文字列? {
        return 記事一覧.指定の番号の要素を取り出す(番号: 行数)?.タイトル
    }
    
    func 記事のURL(行数: 整数) -> URL? {
        if let url = 記事一覧.指定の番号の要素を取り出す(番号: 行数)?.URL {
            return URL(文字列: url)
        }
        return nil
    }
    
    func 検索する(検索ワード: 文字列?,
                完了時の処理: @escaping (検索結果) -> Void) {
        guard let 検索ワード = 検索ワード, 検索ワード.value?.isEmpty == false else {
            完了時の処理(.成功した(検索ワード: 文字列(""), 記事一覧: 配列([])))
            return
        }
        guard let url = URL(文字列: 記事検索URL + 検索ワード.URLエンコードする()) else {
            完了時の処理(.失敗した(エラー: .URL不正))
            return
        }
        let 通信処理 = URLセッション.共通のやつ.通信処理を作成する(URL: url) {(データ, レスポンス, エラー) in
            if let エラー = エラー {
                完了時の処理(.失敗した(エラー: .サーバー(エラー)))
                return
            }
            if let HTTPステータスコード = レスポンス?.HTTPステータスコード,
                HTTPステータスコード != 整数(200) {
                完了時の処理(.失敗した(エラー: .通信環境))
                return
            }
            guard let データ = データ,
                let 記事一覧 = try? JSONデコーダー().デコードする([記事].self, デコードするデータ: データ) else {
                    完了時の処理(.失敗した(エラー: .JSON不正))
                    return
            }
            完了時の処理(.成功した(検索ワード: 検索ワード, 記事一覧: 配列(記事一覧)))
        }
        通信処理.開始する()
    }
}

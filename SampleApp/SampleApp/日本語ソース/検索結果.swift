//
//  検索結果.swift
//  SampleApp
//
//  Created by am10 on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

enum 検索結果 {
    case 成功した(検索ワード: 文字列, 記事一覧: 配列<記事>)
    case 失敗した(エラー: 検索エラー)
}

enum 検索エラー: Error {
    case URL不正
    case 通信環境
    case サーバー(エラー)
    case JSON不正
    
    var エラー内容: 文字列? {
        switch self {
        case .URL不正:
            return 文字列("不正なURLです。")
        case .通信環境:
            return 文字列("通信に失敗しました。ネットワークの接続を確認してください。")
        case .サーバー(let エラー):
            return エラー.エラー内容
        case .JSON不正:
            return 文字列("JSONパースに失敗しました。")
        }
    }
}

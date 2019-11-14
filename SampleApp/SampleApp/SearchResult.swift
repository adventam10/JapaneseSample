//
//  SearchResult.swift
//  SampleApp
//
//  Created by am10 on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

enum SearchResult {
    case success(word: String, articles: [Article])
    case failure(error: SearchError)
}

enum SearchError: Error {
    case invalidURL
    case network
    case server(Error)
    case invalidJSON
}

extension SearchError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "不正なURLです。"
        case .network:
            return "通信に失敗しました。ネットワークの接続を確認してください。"
        case .server(let error):
            return error.localizedDescription
        case .invalidJSON:
            return "JSONパースに失敗しました。"
        }
    }
}

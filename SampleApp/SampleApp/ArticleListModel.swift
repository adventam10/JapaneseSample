//
//  ArticleListModel.swift
//  SampleApp
//
//  Created by am10 on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

protocol ArticleListModelDelegate: AnyObject {
    func model(_ model: ArticleListModel, didUpdateArticles articles: [記事])
}

final class ArticleListModel {

    weak var delegate: ArticleListModelDelegate?
    var articles = [記事]() {
        didSet {
            delegate?.model(self, didUpdateArticles: articles)
        }
    }
    var searchWord = ""
    var hasArticles: Bool {
        return !articles.isEmpty
    }
    
    private let baseURL = "https://qiita.com/api/v2/items?page=1&per_page=20&query=body:"
    
    func title(forRow row: Int) -> 文字列? {
        return articles[row].タイトル
    }
    
    func url(forRow row: Int) -> URL? {
        if let url = articles[row].URL {
            return URL(文字列: url)
        }
        return nil
    }
    
    func search(with word: String?,
                completion: @escaping (SearchResult) -> Void) {
        guard let word = word, !word.isEmpty else {
            completion(.success(word: "", articles: []))
            return
        }
        guard let url = URL(string: baseURL + word.urlEncode()) else {
            completion(.failure(error: .invalidURL))
            return
        }
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion(.failure(error: .server(error)))
                return
            }
            if let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode != 200 {
                completion(.failure(error: .network))
                return
            }
            guard let data = data,
                let articles = try? JSONDecoder().decode([記事].self, from: data) else {
                    completion(.failure(error: .invalidJSON))
                    return
            }
            completion(.success(word: word, articles: articles))
        }
        task.resume()
    }
}

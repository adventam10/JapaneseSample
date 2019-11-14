//
//  ArticleListModel.swift
//  SampleApp
//
//  Created by am10 on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

protocol ArticleListModelDelegate: AnyObject {
    func model(_ model: ArticleListModel, didUpdateArticles articles: [Article])
}

final class ArticleListModel {

    weak var delegate: ArticleListModelDelegate?
    var articles = [Article]() {
        didSet {
            delegate?.model(self, didUpdateArticles: articles)
        }
    }
    var searchWord = ""
    var hasArticles: Bool {
        return !articles.isEmpty
    }
    
    private let baseURL = "https://qiita.com/api/v2/items?page=1&per_page=20&query=body:"
    
    func title(forRow row: Int) -> String? {
        return articles[row].title
    }
    
    func url(forRow row: Int) -> URL? {
        if let url = articles[row].url {
            return URL(string: url)
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
                let articles = try? JSONDecoder().decode([Article].self, from: data) else {
                    completion(.failure(error: .invalidJSON))
                    return
            }
            completion(.success(word: word, articles: articles))
        }
        task.resume()
    }
}

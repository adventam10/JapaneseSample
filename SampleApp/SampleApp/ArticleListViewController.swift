//
//  ArticleListViewController.swift
//  SampleApp
//
//  Created by am10 on 2019/11/13.
//  Copyright © 2019 am10. All rights reserved.
//

import UIKit

final class ArticleListViewController: UIViewController {

    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView! {
        didSet {
            indicatorView.hidesWhenStopped = true
        }
    }
    @IBOutlet private weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.showsCancelButton = true
            searchBar.placeholder = "記事検索ワード"
        }
    }
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private let model = ArticleListModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        model.delegate = self
        hideProgress()
        showNoDataLabel()
    }
    
    private func showProgress() {
        indicatorView.startAnimating()
        progressView.isHidden = false
    }
    
    private func hideProgress() {
        indicatorView.stopAnimating()
        progressView.isHidden = true
    }
    
    private func showNoDataLabel() {
        tableView.isHidden = true
    }
    
    private func hideNoDataLabel() {
        tableView.isHidden = false
    }
    
    private func showAlert(title: String, message: String,
                           buttonTitle: String = "OK", buttonAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: buttonTitle,
                                          style: .default) { _ in buttonAction?() }
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ArticleListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let セル = tableView.dequeueReusableCell(withIdentifier: "記事", for: indexPath) as! 記事テーブルセル
        セル.タイトルラベル.テキスト = model.title(forRow: indexPath.row)
        return セル
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = model.url(forRow: indexPath.row) {
            UIApplication.shared.open(url)
        }
    }
}

extension ArticleListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        showProgress()
        model.search(with: searchBar.text, completion: { [weak self] (result) in
            DispatchQueue.main.async {
                self?.hideProgress()
                switch result {
                case .success(let word, let articles):
                    self?.model.searchWord = word
                    self?.model.articles = articles
                case .failure(let error):
                    self?.showAlert(title: "取得失敗", message: error.localizedDescription, buttonAction: {
                        self?.searchBar.text = self?.model.searchWord
                    })
                }
            }
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = model.searchWord
    }
}

extension ArticleListViewController: ArticleListModelDelegate {
    func model(_ model: ArticleListModel, didUpdateArticles articles: [記事]) {
        if model.hasArticles {
            hideNoDataLabel()
        } else {
            showNoDataLabel()
        }
        tableView.setContentOffset(.zero, animated: false)
        tableView.reloadData()
    }
}

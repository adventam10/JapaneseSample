//
//  記事一覧画面.swift
//  SampleApp
//
//  Created by am10 on 2019/11/13.
//  Copyright © 2019 am10. All rights reserved.
//

import UIKit

final class 記事一覧画面: 画面 {

    @IBOutlet private weak var プログレス: 画面表示部品!
    @IBOutlet private weak var インジケーター: インジケーター! {
        didSet {
            インジケーター.停止中は非表示にする = 正誤(true)
        }
    }
    @IBOutlet private weak var 検索バー: 検索バー! {
        didSet {
            検索バー.検索バー操作 = self
            検索バー.キャンセルボタンを表示する = 正誤(true)
            検索バー.テキスト（仮） = 文字列("記事検索ワード")
        }
    }
    @IBOutlet private weak var テーブル: テーブル! {
        didSet {
            テーブル.テーブルに表示するデータ = self
            テーブル.テーブル操作 = self
        }
    }

    private let model = ArticleListModel()
    
    override func 画面表示完了した() {
        super.画面表示完了した()
        model.delegate = self
        プログレスを非表示にする()
        データなしラベルを非表示にする()
    }
    
    private func プログレスを表示する() {
        インジケーター.アニメーションを起動する()
        プログレス.非表示にする = 正誤(false)
    }
    
    private func プログレスを非表示にする() {
        インジケーター.アニメーションを停止する()
        プログレス.非表示にする = 正誤(true)
    }
    
    private func データなしラベルを表示する() {
        テーブル.非表示にする = 正誤(true)
    }
    
    private func データなしラベルを非表示にする() {
        テーブル.非表示にする = 正誤(false)
    }
    
    private func アラートを表示する(タイトル: 文字列, メッセージ: 文字列, ボタンタイトル: 文字列 = 文字列("OK"), ボタン押下時の処理: (() -> Void)? = nil) {
        let 警告 = アラート.アラートを作成する(タイトル: タイトル, メッセージ: メッセージ, スタイル: .アラート)
        let アクション = アラートアクション.アクションを作成する(タイトル: ボタンタイトル, スタイル: .標準, ボタン押下時の処理: ボタン押下時の処理)
        警告.アクションを追加する(アクション)
        画面を表示する(警告, アニメーションさせる: 正誤(true))
    }
}

extension 記事一覧画面: テーブルに表示するデータ {
    func テーブル(_ テーブル: テーブル, セクション内行数 セクション: 整数) -> 整数 {
        return 整数(model.articles.count)
    }
    
    func テーブル(_ テーブル: テーブル, セル セクションと行数: セクションと行数) -> テーブルセル {
        let セル = テーブル.再利用セルを作成する(識別子: 文字列("記事"), セクションと行数: セクションと行数) as! 記事テーブルセル
        セル.タイトルラベル.テキスト = model.title(forRow: セクションと行数.行数.value ?? 0)
        return セル
    }
}

extension 記事一覧画面: テーブル操作 {
    func テーブル(_ テーブル: テーブル, セルを選択した セクションと行数: セクションと行数) {
        if let url = model.url(forRow: セクションと行数.行数.value ?? 0) {
            アプリケーション.共通のやつ.URLを開く(url)
        }
    }
}

extension 記事一覧画面: 検索バー操作 {
    func 検索バーの検索ボタンをクリックした(_ 検索バー: 検索バー) {
        検索バー.キーボードを閉じる()
        プログレスを表示する()
        model.search(with: 検索バー.text, completion: { [weak self] (result) in
            DispatchQueue.main.async {
                self?.プログレスを非表示にする()
                switch result {
                case .success(let word, let articles):
                    self?.model.searchWord = word
                    self?.model.articles = articles
                case .failure(let error):
                    self?.アラートを表示する(タイトル: 文字列("取得失敗"), メッセージ: 文字列(error.localizedDescription), ボタン押下時の処理: {
                        self?.検索バー.テキスト = 文字列(self?.model.searchWord)
                    })
                }
            }
        })
    }
    
    func 検索バーのキャンセルボタンをクリックした(_ 検索バー: 検索バー) {
        検索バー.キーボードを閉じる()
        検索バー.テキスト = 文字列(model.searchWord)
    }
}

extension 記事一覧画面: ArticleListModelDelegate {
    func model(_ model: ArticleListModel, didUpdateArticles articles: [記事]) {
        if model.hasArticles {
            データなしラベルを非表示にする()
        } else {
            データなしラベルを表示する()
        }
        テーブル.スクロール位置を調整する(位置(.zero), アニメーションさせる: 正誤(false))
        テーブル.再描画する()
    }
}

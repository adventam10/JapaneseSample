//
//  UIWrappers.swift
//  SampleApp
//
//  Created by makoto on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import UIKit

class 画面: UIViewController, 画面表示部品の共通機能 {
    
    func 画面表示完了した() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        画面表示完了した()
    }
}

protocol 画面の共通機能: AnyObject {
}

extension 画面表示部品の共通機能 where Self: UIViewController {
    func 画面を表示する(_ 表示する画面: 画面表示部品の共通機能, アニメーションさせる: 正誤, 表示完了時の処理: (() -> Void)? = nil) {
        present(表示する画面 as! UIViewController, animated: アニメーションさせる.value, completion: 表示完了時の処理)
    }
}

class アラート: UIAlertController, 画面表示部品の共通機能 {

    enum スタイル {
        case アクションシート
        case アラート
        var アラートスタイルに変換: UIAlertController.Style {
            switch self {
            case .アクションシート:
                return .actionSheet
            case .アラート:
                return .alert
            }
        }
    }

    class func アラートを作成する(タイトル: 文字列?, メッセージ: 文字列?, スタイル: スタイル) -> アラート {
        return アラート(title: タイトル?.value, message: メッセージ?.value, preferredStyle: スタイル.アラートスタイルに変換)
    }

    func アクションを追加する(_ アクション: アラートアクション) {
        addAction(アクション)
    }
}

class アラートアクション: UIAlertAction {
    
    enum スタイル {
        case 標準
        case キャンセル
        case 不可逆
        var アラートアクションスタイルに変換: UIAlertAction.Style {
            switch self {
            case .標準:
                return .default
            case .キャンセル:
                return .cancel
            case .不可逆:
                return .destructive
            }
        }
    }

    class func アクションを作成する(タイトル: 文字列?, スタイル: スタイル, ボタン押下時の処理: (() -> Void)? = nil) -> アラートアクション {
        return アラートアクション(title: タイトル?.value, style: スタイル.アラートアクションスタイルに変換,
                                           handler: { _ in ボタン押下時の処理?() })
    }
}

protocol 画面表示部品の共通機能: AnyObject {
}

extension 画面表示部品の共通機能 where Self: UIView {
    var 非表示にする: 正誤 {
        set {
            isHidden = newValue.value
        }
        get {
            return 正誤(isHidden)
        }
    }
}

class 画面表示部品: UIView, 画面表示部品の共通機能 {
}

class インジケーター: UIActivityIndicatorView, 画面表示部品の共通機能 {

    var 停止中は非表示にする: 正誤 {
        set {
            hidesWhenStopped = newValue.value
        }
        get {
            return 正誤(hidesWhenStopped)
        }
    }
    
    func アニメーションを起動する() {
        startAnimating()
    }
    
    func アニメーションを停止する() {
        stopAnimating()
    }
}

class ラベル: UILabel, 画面表示部品の共通機能 {

    var テキスト: 文字列? {
        set {
            text = newValue?.value
        }
        get {
            return 文字列(text)
        }
    }
}

protocol テーブル操作: AnyObject {
    func テーブル(_ テーブル: テーブル, セルを選択した セクションと行数: セクションと行数)
}

protocol テーブルに表示するデータ: AnyObject {
    func テーブル(_ テーブル: テーブル, セクション内行数 セクション: 整数) -> 整数
    func テーブル(_ テーブル: テーブル, セル セクションと行数: セクションと行数) -> テーブルセル
}

class テーブル: UITableView, 画面表示部品の共通機能 {
    
    weak var テーブル操作通知を受信するやつ: テーブル操作?
    weak var テーブルに表示するデータを生成するやつ: テーブルに表示するデータ?
    
    func 再描画する() {
        reloadData()
    }
    
    func 再利用セルを作成する(識別子: 文字列, セクションと行数: セクションと行数) -> テーブルセル {
        return dequeueReusableCell(withIdentifier: 識別子.value,
                                   for: セクションと行数.value) as! テーブルセル
    }

    func スクロール位置を調整する(_ 位置: 位置, アニメーションさせる: 正誤) {
        setContentOffset(位置.value, animated: アニメーションさせる.value )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        初期化処理()
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        初期化処理()
    }

    private func 初期化処理() {
        delegate = self
        dataSource = self
    }
}

extension テーブル: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        テーブル操作通知を受信するやつ?.テーブル(self, セルを選択した: セクションと行数(indexPath))
    }
}

extension テーブル: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return テーブルに表示するデータを生成するやつ?.テーブル(self, セクション内行数: 整数(section)).value ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return テーブルに表示するデータを生成するやつ?.テーブル(self, セル: セクションと行数(indexPath)) ?? UITableViewCell()
    }
}

class テーブルセル: UITableViewCell, 画面表示部品の共通機能 {
}

protocol 検索バー操作: AnyObject {
    func 検索バーの検索ボタンをクリックした(_ 検索バー: 検索バー)
    func 検索バーのキャンセルボタンをクリックした(_ 検索バー: 検索バー)
}

class 検索バー: UISearchBar, 画面表示部品の共通機能 {

    weak var 検索バー操作通知を受信するやつ: 検索バー操作?
    
    var キャンセルボタンを表示する: 正誤 {
        set {
            showsCancelButton = newValue.value
        }
        get {
            return 正誤(showsCancelButton)
        }
    }
    
    var テキスト（仮）: 文字列? {
        set {
            placeholder = newValue?.value
        }
        get {
            return 文字列(placeholder)
        }
    }
    
    var テキスト: 文字列? {
        set {
            text = newValue?.value
        }
        get {
            return 文字列(text)
        }
    }
    
    func キーボードを閉じる() {
        resignFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        初期化処理()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        初期化処理()
    }

    private func 初期化処理() {
        delegate = self
    }
}

extension 検索バー: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        検索バー操作通知を受信するやつ?.検索バーの検索ボタンをクリックした(self)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        検索バー操作通知を受信するやつ?.検索バーのキャンセルボタンをクリックした(self)
    }
}

class アプリケーション: UIApplication {
    class var 共通のやつ: UIApplication {
        return UIApplication.shared
    }
}

extension UIApplication {
    func URLを開く(_ URL: URL) {
        open(URL)
    }
}

struct 位置: EquatableValueWrapper {
    typealias Value = CGPoint
    var value: CGPoint = .zero
    init() {
    }
}

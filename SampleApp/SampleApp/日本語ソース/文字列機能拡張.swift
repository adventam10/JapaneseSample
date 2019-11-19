//
//  文字列機能拡張.swift
//  SampleApp
//
//  Created by am10 on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

extension 文字列 {
    func URLエンコードする() -> 文字列 {
        let charset = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
        let removed = self.値.removingPercentEncoding ?? self.値
        let text = removed.addingPercentEncoding(withAllowedCharacters: charset) ?? removed
        return 文字列(text)
    }
}

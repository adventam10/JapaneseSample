//
//  String+urlEncode.swift
//  SampleApp
//
//  Created by am10 on 2019/11/14.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

extension String {
    func urlEncode() -> String {
        let charset = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
        let removed = removingPercentEncoding ?? self
        return removed.addingPercentEncoding(withAllowedCharacters: charset) ?? removed
    }
}

//
//  記事.swift
//  SampleApp
//
//  Created by am10 on 2019/11/13.
//  Copyright © 2019 am10. All rights reserved.
//

import Foundation

struct 記事: Decodable {
    let タイトル: 文字列?
    let URL: 文字列?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case url = "url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let title = try values.decodeIfPresent(String.self, forKey: .title)
        let url = try values.decodeIfPresent(String.self, forKey: .url)
        タイトル = 文字列(title)
        URL = 文字列(url)
    }
}

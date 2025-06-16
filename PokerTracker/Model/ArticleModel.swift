//
//  ArticleModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/16/25.
//

import Foundation

struct Article: Codable, Hashable, Identifiable {
    
    var id = UUID()
    let title: String
    let image: String
    let articleText: String
}

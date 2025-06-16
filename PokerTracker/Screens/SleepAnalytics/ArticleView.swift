//
//  ArticleView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/16/25.
//

import SwiftUI

struct ArticleView: View {
    
    let article: Article
    
    var body: some View {
        
        ScrollView {
            VStack {
                Image(article.image)
                    .centerCropped()
                    .frame(height: 400)
                    .padding(.bottom)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    Text(article.title)
                        .cardTitleStyle()
                    
                    Text(article.articleText)
                        .bodyStyle()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
        }
        .ignoresSafeArea()
        .background(Color.brandBackground)
    }
}

#Preview {
    ArticleView(article: Articles.sleepArticle)
}

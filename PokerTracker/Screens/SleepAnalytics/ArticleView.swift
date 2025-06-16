//
//  ArticleView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/16/25.
//

import SwiftUI

struct ArticleView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    let article: Article
    
    var body: some View {
        
        ScrollView {
            VStack {
                Image(article.image)
                    .centerCropped()
                    .frame(height: 300)
                    .padding(.bottom)
                
                VStack (alignment: .leading, spacing: 20) {
                    
                    Text(article.title)
                        .cardTitleStyle()
                    
                    Text(article.articleText)
                        .bodyStyle()
                    
                    
                    productLink
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .ignoresSafeArea()
        .background(Color.brandBackground)
        .overlay {
            dismissButton
        }
    }
    
    var dismissButton: some View {
        
        VStack {
            HStack {
                Spacer()
                DismissButton()
                    .padding(.trailing, 10)
                    .padding(.top, 10)
                    .onTapGesture {
                        let impact = UIImpactFeedbackGenerator(style: .soft)
                        impact.impactOccurred()
                        dismiss()
                    }
            }
            Spacer()
        }
    }
    
    var productLink: some View {
        
        Button {
            guard let url = URL(string: "https://a.co/d/erWT2tz") else {
                return
            }
            
            openURL(url)
            
        } label: {
            HStack (spacing: 12) {
                
                Image("positive-poker")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                
                VStack (alignment: .leading, spacing: 5) {
                    Text("Positive Poker: A Modern Psychological Approach To Mastering Your Mental Game")
                        .subHeadlineStyle()
                        .bold()
                        .multilineTextAlignment(.leading)
                    
                    Text("by Dr. Patricia Cardner & Jonathan Little")
                        .captionStyle()
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 12))
            .dynamicTypeSize(.large)
            .padding(.top)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ArticleView(article: Articles.sleepArticle)
}

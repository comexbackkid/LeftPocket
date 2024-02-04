//
//  StudyCardView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/3/22.
//

import SwiftUI

//struct StudyCardView: View {
//    
//    @Environment(\.colorScheme) var colorScheme
//    let article: Article
//    
//    var body: some View {
//        
//        ZStack (alignment: .leading) {
//            VStack (alignment: .leading) {
//                                
//                Image(article.image)
//                    .resizable()
//                    .frame(width: 340, height: 240)
//                    .clipped()
//                
//                Spacer()
//                
//                HStack {
//                    VStack (alignment: .leading, spacing: 5) {
//                        Text(article.title)
//                            .font(.title3)
//                            .bold()
//                        Text(article.snippet)
//                            .font(.body)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.leading)
//                            .lineLimit(2)
//                    }
//                    .padding(.horizontal)
//                }
//                Spacer()
//            }
//            .frame(maxWidth: 340)
//        }
//        .frame(width: 340, height: 360)
//        .background(Color(.systemBackground))
//        .cornerRadius(20)
//        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.3),
//                radius: 12, x: 0, y: 5)
//    }
//}
//
//struct StudyCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        StudyCardView(article: DefaultData.sampleArticle)
//            .preferredColorScheme(.dark)
//    }
//}

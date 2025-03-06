//
//  RecentSessionsCellView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct CellView: View {
    
    let pokerSession: PokerSession_v2
    let currency: CurrencyType
    
    @Binding var viewStyle: ViewStyle
    
    var body: some View {
        
        HStack (spacing: 4) {
            
            if viewStyle == .standard {
                Image(systemName: pokerSession.isTournament == true ? "person.2.fill" : "suit.club.fill")
                    .imageRowStyle(isTournament: pokerSession.isTournament)
            }
            
            VStack (alignment: .leading, spacing: 2) {
                
                HStack {
                    Text(pokerSession.location.name)
                        .font(.custom("Asap-Regular", size: 17))
                        .lineSpacing(2.5)
                        .lineLimit(1)
                    
                    if !pokerSession.tags.isEmpty {
                        Image(systemName: "tag.fill")
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                }
                
                if viewStyle == .standard {
                   
                    HStack (alignment: .firstTextBaseline, spacing: 0) {
                      
                        Text("\(pokerSession.date.dateStyle())" + " • ")
                            .captionStyle()
                            .foregroundColor(.secondary)
                        
                        if pokerSession.isTournament == true {
                            
                            Text("\(currency.symbol)" + "\(pokerSession.buyIn) Buy In")
                                .captionStyle()
                                .foregroundColor(.secondary)
                            
                            if let rebuyCount = pokerSession.rebuyCount, rebuyCount > 0 {
                                
                                HStack (spacing: 0) {
                                    Text(" • ")
                                        .captionStyle()
                                        .foregroundStyle(.secondary)
                                    
                                    Image("bullet-pointed-icon")
                                        .resizable()
                                        .foregroundStyle(.secondary)
                                        .frame(width: 10, height: 10)
                                    
                                    Text(" \(rebuyCount + 1)x ")
                                        .captionStyle()
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            if pokerSession.bounties != nil {
                                
                                HStack (spacing: 0) {
                                    Text(" • ")
                                        .captionStyle()
                                        .foregroundStyle(.secondary)
                                    
                                    Image(systemName: "scope")
                                        .resizable()
                                        .foregroundStyle(.secondary)
                                        .frame(width: 12, height: 12)
                                }
                            }
                            
                        } else {
                            Text("\(currency.symbol)" + pokerSession.stakes + " • ")
                                .captionStyle()
                                .foregroundColor(.secondary)
                            
                            Text(pokerSession.game)
                                .captionStyle()
                                .foregroundColor(.secondary)
                        }
                    }
                    .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(pokerSession.profit.axisShortHand(currency))
                .bodyStyle()
                .bold()
                .profitColor(total: pokerSession.profit)
        }
        .padding(.leading, viewStyle == .compact ? 5 : 10)
        .padding(.vertical, viewStyle == .compact ? 0 : 12)
        .background(Color.brandBackground)
        .dynamicTypeSize(...DynamicTypeSize.large)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(pokerSession: MockData.sampleTournament, currency: .USD, viewStyle: .constant(.standard))
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

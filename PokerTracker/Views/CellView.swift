//
//  RecentSessionsCellView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct CellView: View {
    
    let pokerSession: PokerSession
    let currency: CurrencyType
    
    @Binding var viewStyle: ViewStyle
    
    var body: some View {
        
        HStack (spacing: 4) {
            
            if viewStyle == .standard {
                Image(systemName: pokerSession.isTournament == true ? "person.2.fill" : "suit.club.fill")
                    .imageRowStyle(isTournament: pokerSession.isTournament ?? false)
            }
            
            VStack (alignment: .leading, spacing: 2) {
                
                HStack {
                    Text(pokerSession.location.name)
                        .bodyStyle()
                        .lineLimit(1)
                    
                    if pokerSession.tags != nil {
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
                            
                            Text("\(currency.symbol)" + "\(pokerSession.expenses!) Buy In ")
                                .captionStyle()
                                .foregroundColor(.secondary)
                            
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
                .foregroundColor(pokerSession.profit > 0 ? Color.lightGreen : .red)
        }
        .padding(.leading, viewStyle == .compact ? 5 : 10)
        .padding(.vertical, viewStyle == .compact ? 0 : 12)
        .background(Color.brandBackground)
        .dynamicTypeSize(...DynamicTypeSize.large)
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(pokerSession: MockData.sampleSession, currency: .USD, viewStyle: .constant(.standard))
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}

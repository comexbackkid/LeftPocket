//
//  BankrollCellView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/31/25.
//

import SwiftUI

struct BankrollCellView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let bankroll: Bankroll
    let currency: CurrencyType
    
    var body: some View {
        
        HStack {
            
            Image(systemName: "bag.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .foregroundColor(.brandBackground)
                .background(
                    Circle()
                        .foregroundColor(.lightGreen)
                        .frame(width: 33, height: 33, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                )
                .padding(.trailing, 15)
            
            Text(bankroll.name)
                .font(.custom("Asap-Regular", size: 17))
                .lineSpacing(2.5)
                .lineLimit(1)
            
            Spacer()
            
            let bankrollTotal = bankroll.sessions.map({ $0.profit }).reduce(0, +)
            Text("\(bankrollTotal.currencyShortHand(currency))")
                .font(.custom("Asap-Regular", size: 17))
                .bold()
                .profitColor(total: bankrollTotal)
        }
        .padding(.leading, 10)
        .padding(.vertical, 5)
    }
}

#Preview {
    BankrollCellView(bankroll: Bankroll(name: "Default Bankroll", sessions: MockData.allSessions), currency: .USD)
        .preferredColorScheme(.dark)
}

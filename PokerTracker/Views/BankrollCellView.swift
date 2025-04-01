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
    let transactions: [BankrollTransaction]
    
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
                        .frame(width: 33, height: 33, alignment: .center)
                )
                .padding(.trailing, 15)
            
            Text(bankroll.name)
                .font(.custom("Asap-Regular", size: 17))
                .lineSpacing(2.5)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(calculateTotal().currencyShortHand(currency))")
                .font(.custom("Asap-Regular", size: 17))
                .bold()
                .profitColor(total: calculateTotal())
        }
        .padding(.leading, 10)
        .padding(.vertical, 5)
    }
    
    private func calculateTotal() -> Int {
           let bankrollTotal = bankroll.sessions.map(\.profit).reduce(0, +)
           
           let txTotal = transactions
               .filter { $0.tags?.contains(bankroll.name) == true }
               .reduce(0) { total, tx in
                   switch tx.type {
                   case .deposit:
                       return total + tx.amount
                   case .withdrawal, .expense:
                       return total - tx.amount
                   }
               }
           
           return bankrollTotal + txTotal
       }
}

#Preview {
    BankrollCellView(bankroll: Bankroll(name: "Online Bankroll", sessions: MockData.allSessions), currency: .USD, transactions: [MockData.mockTransaction])
        .preferredColorScheme(.dark)
}

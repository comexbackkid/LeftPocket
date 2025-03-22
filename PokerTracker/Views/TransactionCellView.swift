//
//  TransactionCellView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 7/16/24.
//

import SwiftUI

struct TransactionCellView: View {
    
    let transaction: BankrollTransaction
    let currency: CurrencyType
    
    var body: some View {
        
        HStack (spacing: 4) {
            
            Image(systemName: "creditcard.fill")
                .imageRowStyle(isTournament: false)
            
            VStack (alignment: .leading, spacing: 2) {
                
                HStack {
                    Text(transaction.type.description)
                        .font(.custom("Asap-Regular", size: 17))
                        .lineSpacing(2.5)
                        .lineLimit(1)
                    
                    if transaction.tags != nil {
                        Image(systemName: "tag.fill")
                            .resizable()
                            .frame(width: 14, height: 14)
                    }
                }
                
                HStack (alignment: .firstTextBaseline, spacing: 0) {
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .captionStyle()
                        .foregroundStyle(.secondary)
                    
                    if !transaction.notes.isEmpty {
                        Text(" • " + transaction.notes)
                            .captionStyle()
                            .foregroundStyle(.secondary)
                    }
                }
                .lineLimit(1)
            }
            
            Spacer()
            
            Text(transaction.amount, format: .currency(code: currency.rawValue).precision(.fractionLength(0)))
                .font(.custom("Asap-Regular", size: 17))
                .bold()
                .profitColor(total: transaction.amount)
        }
        .padding(.leading, 10)
        .padding(.vertical, 12)
        .background(Color.brandBackground)
    }
}

#Preview {
    TransactionCellView(transaction: MockData.sampleTransactions[1], currency: .USD)
//        .preferredColorScheme(.dark)
}

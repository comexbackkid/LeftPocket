//
//  SocialShareView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 6/16/24.
//

import SwiftUI

struct SocialShareView: View {
    
    let vm: SessionsListViewModel
    let colorScheme: ColorScheme
    let pokerSession: PokerSession
    let background: Image
    
    var body: some View {
        
        VStack {
            
            header
            
            Spacer()
            
            sessionDetails
            
            Spacer()
            
            logo

        }
        .frame(width: 600, height: 400)
        .padding(.vertical, 15)
        .background(.regularMaterial)
        .background(background.resizable().aspectRatio(contentMode: .fill))
        .clipped()
        .environment(\.colorScheme, .dark)
        .edgesIgnoringSafeArea(.all)
    }
    
    var header: some View {
        
        VStack {
            Text(pokerSession.date.formatted(date: .abbreviated, time: .omitted))
                .calloutStyle()
                .foregroundStyle(.secondary)
            
            Text(pokerSession.location.name)
                .cardTitleStyle()
        }
        .padding(.top)
    }
    
    var sessionDetails: some View {
        
        VStack {
            Text("Net Profit")
                .bodyStyle()
            
            Text("\(pokerSession.profit.asCurrency())")
                .font(.custom("Asap-Black", size: 85))
                .profitColor(total: pokerSession.profit)
            
            if let buyIn = pokerSession.buyIn, let cashOut = pokerSession.cashOut {
                Text("In the game for \(buyIn.asCurrency()), out for \(cashOut.asCurrency())")
                    .calloutStyle()
                    .foregroundStyle(.secondary)
                
            } else {
                Text("Played for a total of \(pokerSession.playingTIme)")
                    .calloutStyle()
                    .foregroundStyle(.secondary)
                
            }
        }
        .padding(23)
        .frame(width: UIScreen.main.bounds.width * 0.8)
        .background(colorScheme == .dark ? Color.black.opacity(0.25) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.vertical)
        .padding(.bottom)
    }
    
    var logo: some View {
        
        HStack {
            
            Image(systemName: "suit.club.fill")
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundColor(.white)
                .background(
                    Circle()
                        .foregroundColor(.brandPrimary)
                        .frame(width: 22, height: 22, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                )
                .padding(.trailing, 2)
            
            Text("Left Pocket")
                .calloutStyle()
        }
        .padding(.bottom)
    }
}

#Preview {
    SocialShareView(vm: SessionsListViewModel(),
                    colorScheme: .dark,
                    pokerSession: MockData.sampleSession,
                    background: Image(MockData.sampleSession.location.localImage))
}

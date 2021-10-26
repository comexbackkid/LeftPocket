//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct RecentSessionCardView: View {
    
    var pokerSession: PokerSession
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var viewModel: SessionsListViewModel
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            VStack {
                Image(viewModel.sessions.last?.imageName ?? "default-image")
                    .resizable()
                    .frame(width: 340, height: 240)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        Text(viewModel.sessions.last?.location ?? "No Recent Session")
                            .font(.title3)
                            .bold()

                        Text("View your most recent session to review hand notes & other details.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                Spacer()
            }
            Text("Recent Session")
                .fontWeight(.bold)
                .font(.system(size: 30))
                .foregroundColor(Color("brandWhite"))
                .offset(y: -145)
                .padding()
        }
        .frame(width: 340, height: 360)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.3),
                radius: 12, x: 0, y: 5)
    }
}

struct RecentSessionCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionCardView(pokerSession: MockData.sampleSession).environmentObject(SessionsListViewModel())
    }
}

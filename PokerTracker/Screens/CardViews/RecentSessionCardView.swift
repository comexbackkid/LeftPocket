//
//  MetricsCardView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct RecentSessionCardView: View {
    
    var pokerSession: PokerSession
    @EnvironmentObject var sessionsListViewModel: SessionsListModel
    
    var body: some View {
        
        ZStack (alignment: .leading) {
            VStack {
                Image(sessionsListViewModel.sessions.last.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                HStack {
                    VStack (alignment: .leading, spacing: 5) {
                        Text(sessionsListViewModel.sessions.last.location)
                            .font(.title3)
                            .bold()

                        Text("View your most recent session to review hand notes & other details.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                Spacer()
            }
            Text("Recent Session")
                .fontWeight(.bold)
                .font(.system(size: 30, design: .rounded))
                .foregroundColor(Color("brandWhite"))
                .offset(y: -165)
                .padding()
          
        }
        .frame(width: 350, height: 380)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color(.lightGray).opacity(0.7), radius: 18, x: 0, y: 5)
    }
}

struct RecentSessionCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSessionCardView(pokerSession: MockData.sampleSession).environmentObject(SessionsListModel())
    }
}

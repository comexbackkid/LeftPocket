//
//  SessionDetailView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct SessionDetailView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @Binding var activeSheet: Sheet?
    let pokerSession: PokerSession
    
    var body: some View {
        
        ZStack {
            
            ScrollView (.vertical) {
                
                VStack(spacing: 4) {
                    
                    GraphicHeaderView(location: pokerSession.location, date: pokerSession.date)
                    
                    Divider().frame(width: UIScreen.main.bounds.width * 0.5)
                    
                    if pokerSession.isTournament ?? false {
                        
                        tournamentMetrics
                        
                    } else { cashMetrics }
                    
                    VStack(alignment: .leading) {
                        
                        notes
                        
                        details
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .topLeading)
                    .padding(30)
                    .padding(.bottom, 70)
                }
            }
            .background(.regularMaterial)
            .background(!pokerSession.location.localImage.isEmpty
                        ? Image(pokerSession.location.localImage)
                        : Image("encore-header"))
            .ignoresSafeArea()
            .onAppear {
                AppReviewRequest.requestReviewIfNeeded()
            }
            
            if activeSheet == .recentSession {
                
                VStack {
                    
                    HStack {
                        
                        Spacer()
                        
                        DismissButton()
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                            .onTapGesture {
                                activeSheet = nil
                            }
                    }
                    
                    Spacer()
                }
            }
        }
        .accentColor(.brandPrimary)
        .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
    }
    
    var cashMetrics: some View {
        
        HStack(spacing: 0) {
            
            VStack {
                
                Image(systemName: "stopwatch")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.playingTIme)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "dollarsign")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.profit.asCurrency()).profitColor(total: pokerSession.profit)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "gauge.high")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.hourlyRate.asCurrency()).profitColor(total: pokerSession.hourlyRate)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
        }
        .frame(maxWidth: .infinity)
        .padding()
        
    }
    
    var tournamentMetrics: some View {
        
        HStack(spacing: 0) {
            VStack {
                
                Image(systemName: "stopwatch")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.playingTIme)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "dollarsign")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.profit.asCurrency()).profitColor(total: pokerSession.profit)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "person.2")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text("\(pokerSession.entrants ?? 0)")
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    var notes: some View {
        
        VStack(alignment: .leading) {
            
            Text(pokerSession.isTournament ?? false ? "Tournament Notes" : "Session Notes")
                .subtitleStyle()
                .padding(.bottom, 5)
                .padding(.top, 20)
            
            Text(pokerSession.notes)
                .bodyStyle()
                .padding(.bottom, 30)
                .textSelection(.enabled)
        }
    }
    
    var details: some View {
        
        VStack (alignment: .leading) {
            
            Text("Details")
                .subtitleStyle()
                .padding(.bottom, 5)
            
            HStack {
                Text("Date")
                    .bodyStyle()
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(pokerSession.date.dateStyle())")
                    .bodyStyle()
                    .font(.subheadline)
            }
            
            Divider()
            
            HStack {
                Text("Game")
                    .bodyStyle()
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(pokerSession.game)
                    .bodyStyle()
                    .font(.subheadline)
            }
            
            Divider()
            
            HStack {
                Text(pokerSession.isTournament == true ? "Buy-In" : "Expenses")
                    .bodyStyle()
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(pokerSession.expenses?.asCurrency() ?? "$0")
                    .bodyStyle()
                    .font(.subheadline)
            }
            Divider()
            
            if pokerSession.isTournament == false {
                HStack {
                    Text("Stakes")
                        .bodyStyle()
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(pokerSession.stakes)
                        .bodyStyle()
                        .font(.subheadline)
                }
                Divider()
            }
            
            HStack {
                Text("Visits")
                    .bodyStyle()
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(vm.sessions.filter({$0.location.name == pokerSession.location.name}).count)")
                    .bodyStyle()
                    .font(.subheadline)
            }
            .padding(.bottom)
        }
    }
}

struct GraphicHeaderView: View {
    
    let location: LocationModel
    let date: Date
    
    var body: some View {
        
        VStack {
            
            if location.imageURL != "" {
                
                AsyncImage(url: URL(string: location.imageURL), scale: 1, transaction: Transaction(animation: .easeIn)) { phase in
                    
                    if let image = phase.image {
                        
                        image
                            .resizable()
                            .detailViewStyle()
                        
                    } else if phase.error != nil {
                        
                        FailureView()
                            .frame(height: 290)
                            .clipped()
                            .padding(.bottom)
                        
                    } else {
                        
                        PlaceholderView()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 290)
                            .clipped()
                            .padding(.bottom)
                    }
                }
                
            } else {
                
                Image(location.localImage != "" ? location.localImage : "defaultlocation-header")
                    .resizable()
                    .detailViewStyle()
            }
            
            Text(location.name)
                .signInTitleStyle()
                .fontWeight(.bold)
                .lineLimit(1)
                .padding(.bottom, 0.2)
            
            Text("\(date.dateStyle())")
                .calloutStyle()
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SessionDetailView(activeSheet: .constant(.recentSession), pokerSession: MockData.sampleSession)
            .preferredColorScheme(.dark)
            .environmentObject(SessionsListViewModel())
    }
}

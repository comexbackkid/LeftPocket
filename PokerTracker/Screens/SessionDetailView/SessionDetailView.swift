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
                        .frame(maxWidth: UIScreen.main.bounds.width)
                    
                    Divider().frame(width: 180)
                    
                    if pokerSession.isTournament ?? false {
                        
                        tournamentMetrics
                        
                    } else { cashMetrics }
                    
                    VStack(alignment: .leading) {
                        
                        notes
                        
                        miscellaneous
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, alignment: .topLeading)
                    .padding()
                    .padding(.bottom, 70)
                }
            }
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
    }
    
    var cashMetrics: some View {
        
        HStack(spacing: 50) {
            VStack {
                
                Text("Duration")
                    .font(.headline)
                
                Text(pokerSession.playingTIme)
            }
            
            VStack {
                Text("Profit")
                    .font(.headline)
                
                Text(pokerSession.profit.asCurrency()).profitColor(total: pokerSession.profit)
            }
            
            VStack {
                Text("Hourly")
                    .font(.headline)
                
                Text(pokerSession.hourlyRate.asCurrency()).profitColor(total: pokerSession.hourlyRate)
            }
        }
        .padding()
        
    }
    
    var tournamentMetrics: some View {
        
        HStack(spacing: 50) {
            VStack {
                
                Text("Duration")
                    .font(.headline)
                
                Text(pokerSession.playingTIme)
            }
            
            VStack {
                Text("Profit")
                    .font(.headline)
                
                Text(pokerSession.profit.asCurrency()).profitColor(total: pokerSession.profit)
            }
            
            VStack {
                Text("Entrants")
                    .font(.headline)
                
                Text("\(pokerSession.entrants ?? 0)")
            }
        }
        .padding()
    }
    
    var notes: some View {
        
        VStack(alignment: .leading) {
            
            Text(pokerSession.isTournament ?? false ? "Tournament Notes" : "Session Notes")
                .font(.headline)
                .padding(.bottom, 5)
                .padding(.top, 20)
            
            Text(pokerSession.notes)
                .padding(.bottom, 30)
                .textSelection(.enabled)
        }
    }
    
    var miscellaneous: some View {
        
        VStack (alignment: .leading) {
            
            Text("Miscellaneous")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack {
                Text("Date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(pokerSession.date.dateStyle())")
                    .font(.subheadline)
            }
            Divider()
            HStack {
                Text("Game")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(pokerSession.game)
                    .font(.subheadline)
            }
            Divider()
            HStack {
                Text(pokerSession.isTournament == true ? "Buy-In" : "Expenses")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(pokerSession.expenses?.asCurrency() ?? "$0")
                    .font(.subheadline)
            }
            Divider()
            
            if pokerSession.isTournament == false {
                HStack {
                    Text("Stakes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(pokerSession.stakes)
                        .font(.subheadline)
                }
                Divider()
            }
            
            HStack {
                Text("Visits")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(vm.sessions.filter({$0.location.name == pokerSession.location.name}).count)")
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
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .detailViewStyle()
                        
                    case .failure:
                        FailureView()
                            .frame(height: 290)
                            .clipped()
                            .padding(.bottom)
                        
                    case .empty:
                        PlaceholderView()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 290)
                            .clipped()
                            .padding(.bottom)
                        
                    @unknown default:
                        PlaceholderView()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 290)
                            .clipped()
                            .padding(.bottom)
                    }
                }
                
            } else {
                
                Image(location.localImage != "" ? location.localImage : "default-header")
                    .resizable()
                    .detailViewStyle()
            }
            
            Text(location.name)
                .font(.title)
                .bold()
                .lineLimit(1)
            
            Text("\(date.dateStyle())")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)
        }
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SessionDetailView(activeSheet: .constant(.recentSession), pokerSession: MockData.sampleSession)
            .environmentObject(SessionsListViewModel())
    }
}

//
//  SessionDetailView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct SessionDetailView: View {
    
    @Binding var activeSheet: Sheet?
    let pokerSession: PokerSession
    
    var body: some View {
        
        ZStack {
            ScrollView (.vertical) {
                
                VStack(spacing: 4) {
                    GraphicHeaderView(image: pokerSession.location,
                                      location: pokerSession.location.name,
                                      date: pokerSession.date)
                        .frame(maxWidth: UIScreen.main.bounds.width)
                    
                    Divider().frame(width: 180)
                    
                    KeyMetrics(sessionDuration: pokerSession.dateInterval,
                               sessionProfit: pokerSession.profit,
                               sessionHourlyRate: pokerSession.hourlyRate)
                    
                    VStack(alignment: .leading) {
                        
                        Notes(notes: pokerSession.notes, pokerSession: pokerSession)
                        
                        MiscView(vm: SessionsListViewModel(), pokerSession: pokerSession)
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
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SessionDetailView(activeSheet: .constant(.recentSession), pokerSession: MockData.sampleSession)
    }
}

struct GraphicHeaderView: View {
    
    let image: LocationModel
    let location: String
    let date: Date
    
    var body: some View {
        VStack {
            
            if image.imageURL != "" {
                
                AsyncImage(url: URL(string: image.imageURL), scale: 1, transaction: Transaction(animation: .easeIn)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 290)
                            .clipped()
                            .padding(.bottom)
                        
                    case .failure:
                        PlaceholderView()
                        
                    case .empty:
                        PlaceholderView()
                        
                    @unknown default:
                        PlaceholderView()
                    }
                }
                
            } else {
                
                Image(image.localImage != "" ? image.localImage : "default-header")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 290)
                    .clipped()
                    .padding(.bottom)
            }
            
            Text(location)
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

struct KeyMetrics: View {
    
    let sessionDuration: String
    let sessionProfit: Int
    let sessionHourlyRate: Int
    
    var body: some View {
        HStack(spacing: 50) {
            VStack {
                Text("Duration")
                    .font(.headline)
                Text(sessionDuration)
                
            }
            VStack {
                Text("Profit")
                    .font(.headline)
                Text(sessionProfit.accountingStyle())
                    .modifier(AccountingView(total: sessionProfit))
                
            }
            VStack {
                Text("Hourly")
                    .font(.headline)
                Text(sessionHourlyRate.accountingStyle())
                    .modifier(AccountingView(total: sessionProfit))
            }
        }.padding()
    }
}

struct Notes: View {
    
    let notes: String
    let pokerSession: PokerSession
    
    var body: some View {
        Text("Session Notes")
            .font(.headline)
            .padding(.bottom, 5)
            .padding(.top, 20)
        
        Text(notes)
            .padding(.bottom, 30)
            .textSelection(.enabled)
    }
}

struct MiscView: View {
    
    @ObservedObject var vm: SessionsListViewModel
    
    let pokerSession: PokerSession
    
    var body: some View {
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
            Text("Expenses")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(pokerSession.expenses?.accountingStyle() ?? "$0")
                .font(.subheadline)
        }
        Divider()
        HStack {
            Text("Stakes")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(pokerSession.stakes)
                .font(.subheadline)
        }
        Divider()
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

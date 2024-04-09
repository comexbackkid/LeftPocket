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
                        ? Image(pokerSession.location.localImage).resizable().aspectRatio(contentMode: .fill)
                        : backgroundImage().resizable().aspectRatio(contentMode: .fill))
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
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
    }

    var cashMetrics: some View {
        
        HStack(spacing: 0) {
            
            VStack {
                
                Image(systemName: "clock")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.playingTIme)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "trophy")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.profit, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: pokerSession.profit)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "gauge.high")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.hourlyRate, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0))).profitColor(total: pokerSession.hourlyRate)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .frame(maxWidth: .infinity)
        .padding()
        
    }
    
    var tournamentMetrics: some View {
        
        HStack(spacing: 0) {
            VStack {
                
                Image(systemName: "clock")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.playingTIme)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "trophy")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Text(pokerSession.profit, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: pokerSession.profit)
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
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
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
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(pokerSession.date.dateStyle())")
                    .bodyStyle()
            }
            
            Divider()
            
            HStack {
                Text("Game")
                    .bodyStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(pokerSession.game)
                    .bodyStyle()
            }
            
            Divider()
            
            HStack {
                Text(pokerSession.isTournament == true ? "Buy-In" : "Expenses")
                    .bodyStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(pokerSession.expenses ?? 0, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .bodyStyle()
            }
            Divider()
            
            if pokerSession.isTournament != true {
                
                HStack {
                    Text("Stakes")
                        .bodyStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(pokerSession.stakes)
                        .bodyStyle()
                }
                Divider()
                
                HStack {
                    Text("Big Blinds / Hr")
                        .bodyStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(pokerSession.bigBlindPerHour, specifier: "%.2f")")
                        .bodyStyle()
                }
                Divider()
            }
            
            HStack {
                Text("Visits")
                    .bodyStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(vm.sessions.filter({$0.location.name == pokerSession.location.name}).count)")
                    .bodyStyle()
            }
            .padding(.bottom)
        }
    }
    
    func backgroundImage() -> Image {
        
        if pokerSession.location.imageURL != "" {
            
            return Image("encore-header")
            
        } else {
            
            guard
                let imageData = pokerSession.location.importedImage,
                let uiImage = UIImage(data: imageData)
                    
            else {
                
                return Image("encore-header")
            }
            
            return Image(uiImage: uiImage)
                
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
                
            } else if location.importedImage != nil {
                
                if let photoData = location.importedImage,
                   let uiImage = UIImage(data: photoData) {
                    
                    Image(uiImage: uiImage)
                        .detailViewStyle()
                }
                
            } else {

                Image(location.localImage != "" ? location.localImage : "defaultlocation-header")
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

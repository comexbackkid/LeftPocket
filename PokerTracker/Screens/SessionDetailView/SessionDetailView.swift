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
    @State private var isPressed = false
    @State private var showError = false
    
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
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(30)
                    .padding(.bottom, activeSheet == .recentSession ? 0 : 70)
                }
            }
            .background(.regularMaterial)
            .background(!pokerSession.location.localImage.isEmpty 
                        ? Image(pokerSession.location.localImage).resizable().aspectRatio(contentMode: .fill)
                        : backgroundImage().resizable().aspectRatio(contentMode: .fill)).ignoresSafeArea()
            
            VStack {
                
                if activeSheet == .recentSession {
                    
                    dismissButton
                    shareButton
                    
                    Spacer()
                }
            }
        }
        .accentColor(.brandPrimary)
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .toolbar {
            Button {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isPressed = false
                }
                guard let image = ImageRenderer(content: shareSummary).uiImage else {
                    showError = true
                    return
                }
                
                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: image)
                
            } label: {
                Image(systemName: "arrow.down.to.line")
                    .opacity(isPressed ? 0 : 1)
                    .overlay {
                        if isPressed {
                            ProgressView()
                                .tint(.brandPrimary)
                        }
                    }
            }
            .tint(.brandPrimary)
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Uh oh!"),
                  message: Text("Image could not be saved. Please try again later."),
                  dismissButton: .default(Text("Ok")))
        }
    }

    var cashMetrics: some View {
        
        HStack(spacing: 0) {
            
            VStack {
                
                Image(systemName: "clock")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Spacer()
                
                Text(pokerSession.playingTIme)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Spacer()
                
                Text(pokerSession.profit, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: pokerSession.profit)
                    .fontWeight(.semibold)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "gauge.high")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Spacer()
                
                Text("\(pokerSession.hourlyRate, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0))) / hr").profitColor(total: pokerSession.hourlyRate)
                    .fontWeight(.semibold)
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
                
                Spacer()
                
                Text(pokerSession.playingTIme)
                    .fontWeight(.semibold)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Spacer()
                
                Text(pokerSession.profit, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: pokerSession.profit)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.25)
            
            VStack {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Spacer()
                
                HStack (spacing: 0) {
                    if let finish = pokerSession.finish {
                        Text("\(finish) / ")
                            .fontWeight(.semibold)
                    }
                    Text("\(pokerSession.entrants ?? 0)")
                        .fontWeight(.semibold)
                }
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
            
            HStack (spacing: 0) {
                
                Text("Start / End")
                    .bodyStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(pokerSession.startTime, style: .time)
                    .bodyStyle()
                
                Text(" / ")
                
                Text(pokerSession.endTime, style: .time)
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
            
            if pokerSession.isTournament == true {
                
                if let size = pokerSession.tournamentSize {
                    HStack {
                        Text("Size")
                            .bodyStyle()
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(size)
                            .bodyStyle()
                    }
                    
                    Divider()
                }
                
                if let speed = pokerSession.tournamentSpeed {
                    HStack {
                        Text("Speed")
                            .bodyStyle()
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(speed)
                            .bodyStyle()
                    }
                    
                    Divider()
                }
                
            }
            
            if pokerSession.isTournament != true {
                
                HStack {
                    Text("Stakes")
                        .bodyStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(pokerSession.stakes)
                        .bodyStyle()
                }
                
                if let buyIn = pokerSession.buyIn, let cashOut = pokerSession.cashOut {
                    
                    Divider()
                    
                    HStack {
                        Text("Buy In")
                            .bodyStyle()
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(buyIn, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                            .bodyStyle()
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Cash Out")
                            .bodyStyle()
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(cashOut, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                            .bodyStyle()
                    }
                }
                
                Divider()
            }
            
            HStack {
                
                Text(pokerSession.isTournament == true ? "Buy In" : "Expenses")
                    .bodyStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if pokerSession.isTournament == true {
                    Text(pokerSession.buyIn ?? 0, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                        .bodyStyle()
                } else {
                    Text(pokerSession.expenses ?? 0, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                        .bodyStyle()
                }
            }
            
            if pokerSession.isTournament == true {
                
                Divider()
                
                HStack {
                    
                    Text("Rebuys")
                        .bodyStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(pokerSession.rebuyCount ?? 0)")
                        .bodyStyle()
                }
                
                Divider()
                
                HStack {
                    
                    Text("Total Buy In")
                        .bodyStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(pokerSession.expenses ?? 0, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))")
                        .bodyStyle()
                }
            }
            
            if pokerSession.isTournament != true {
                
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
                
                HStack {
                    Text("High Hand Bonus")
                        .bodyStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(pokerSession.highHandBonus ?? 0, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                        .bodyStyle()
                }
            }
        }
        .padding(.bottom)
    }
    
    var shareSummary: some View {
        SocialShareView(vm: vm, colorScheme: .dark, pokerSession: pokerSession, background: Image(pokerSession.location.localImage != "" ? pokerSession.location.localImage : "defaultlocation-header"))
    }
    
    var shareButton: some View {
        
        HStack {
            Spacer()
            Button {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    isPressed = false
                }
                guard let image = ImageRenderer(content: shareSummary).uiImage else {
                    showError = true
                    return
                }
                
                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: image)
                
            } label: {
                ShareButton()
                    .opacity(isPressed ? 0 : 1)
                    .overlay {
                        if isPressed {
                            ProgressView()
                                .tint(.brandPrimary)
                                .background(
                                    Circle()
                                        .frame(width: 38, height: 38)
                                        .foregroundColor(.white)
                                        .opacity(0.6))
                        }
                    }
                    .padding(.trailing, 20)
            }
            .buttonStyle(.plain)
        }
    }
    
    var dismissButton: some View {
        
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
        NavigationView {
            SessionDetailView(activeSheet: .constant(.recentSession), pokerSession: MockData.sampleTournament)
                .preferredColorScheme(.dark)
                .environmentObject(SessionsListViewModel())
        }
    }
}

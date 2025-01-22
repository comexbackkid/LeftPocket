//
//  SessionDetailView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI

struct SessionDetailView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var activeSheet: Sheet?
    @State private var isPressed = false
    @State private var showError = false
    
    let pokerSession: PokerSession
    
    var body: some View {
        
        ZStack {
            
            // Main Scrolling View
            ScrollView (.vertical) {
                
                headerGraphic
                    
                VStack {
                    
                    headerText
                    
                    if pokerSession.isTournament == true {
                        
                        tournamentMetrics
                        
                    } else {
                        
                        cashMetrics
                    }
                    
                    bottomSection
                }
                .offset(y: -90)
            }
            .background(.regularMaterial)
            .background(locationBackground()).ignoresSafeArea()
            
            // Floating Buttons
            VStack (spacing: 0) {
                
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
    
    var headerGraphic: some View {
        
        GraphicHeaderView(location: pokerSession.location)
            .overlay {
                GraphicHeaderView(location: pokerSession.location)
                    .blur(radius: 12, opaque: true)
                    .mask(
                        LinearGradient(gradient: Gradient(stops: [
                            Gradient.Stop(color: Color(white: 0, opacity: 0), location: 0.75),
                            Gradient.Stop(color: Color(white: 0, opacity: 1), location: 0.85),
                        ]), startPoint: .top, endPoint: .bottom)
                    )
            }
            .overlay(
                LinearGradient(gradient: Gradient(stops: [
                    Gradient.Stop(color: Color(white: 0, opacity: 0), location: 0.6),
                    Gradient.Stop(color: Color(white: 0, opacity: 0.3), location: 1),
                ]), startPoint: .top, endPoint: .bottom)
            )
    }
    
    var headerText: some View {
        
        VStack (spacing: 2) {
            
            Text(pokerSession.location.name)
                .font(.custom("Asap-Black", size: 32))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .padding(.bottom, 0.2)
                .foregroundStyle(.white)
            
            HStack (spacing: 4) {
                
                Text("\(pokerSession.date.dateStyle())")
                    .calloutStyle()
                
                Text("•")
                    .calloutStyle()
                
                Text(pokerSession.game)
                    .calloutStyle()
                
            }
            .foregroundStyle(.white.opacity(0.5))
            
        }
        .padding(.bottom, 25)
    }
    
    var bottomSection: some View {
        
        VStack(alignment: .leading) {

            details
            
            notes
            
            tags
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .padding(.bottom, activeSheet == .recentSession ? 0 : 20)
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
            .frame(maxWidth: UIScreen.main.bounds.width * 0.26)
            .padding(.vertical, 20)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            Spacer()
            
            VStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Spacer()
                
                Text(pokerSession.profit.currencyShortHand(vm.userCurrency))
                    .profitColor(total: pokerSession.profit)
                    .fontWeight(.semibold)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.26)
            .padding(.vertical, 20)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            
            Spacer()
            
            VStack {
                Image(systemName: "gauge.high")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Spacer()
                
                Text(pokerSession.hourlyRate.axisShortHand(vm.userCurrency) + " / Hr")
                    .profitColor(total: pokerSession.hourlyRate)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.26)
            .padding(.vertical, 20)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .body))
        .padding(.horizontal, 30)
        .padding(.top, 12)
        .dynamicTypeSize(.large)
        
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
            .frame(maxWidth: UIScreen.main.bounds.width * 0.26)
            .padding(.vertical, 20)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            Spacer()
            
            VStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .opacity(0.3)
                    .padding(.bottom, 1)
                
                Spacer()
                
                Text(pokerSession.profit.currencyShortHand(vm.userCurrency))
                    .profitColor(total: pokerSession.profit)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.26)
            .padding(.vertical, 20)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            Spacer()
            
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
            .frame(maxWidth: UIScreen.main.bounds.width * 0.26)
            .padding(.vertical, 20)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .body))
        .padding(.horizontal, 30)
        .padding(.top, 12)
        .dynamicTypeSize(.large)
    }
    
    var notes: some View {
        
        VStack(alignment: .leading) {
            
            Text(pokerSession.isTournament ?? false ? "Tournament Notes" : "Session Notes")
                .subtitleStyle()
                .padding(.bottom, 5)
            
            if pokerSession.notes.isEmpty {
                Text("None")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                
            } else {
                
                Text(pokerSession.notes)
                    .bodyStyle()
                    .textSelection(.enabled)
            }
        }
        .padding(.bottom, 30)

    }
    
    var tags: some View {
        
        VStack (alignment: .leading) {
            
            Text("Tags")
                .subtitleStyle()
                .padding(.bottom, 5)
            
            if let tag = pokerSession.tags?.first {
                Text(tag)
                    .bodyStyle()
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.secondary)
                    .clipShape(.capsule)
            } else {
                
                Text("None")
                    .bodyStyle()
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var details: some View {
        
        VStack (alignment: .leading) {
            
            Text("Details")
                .subtitleStyle()
                .padding(.bottom, 5)
            
            HStack (spacing: 0) {
                
                Text("Start / End")
                    .bodyStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let days = pokerSession.tournamentDays, days > 1 {
                    
                    Text(pokerSession.startTime, format: .dateTime.month().day())
                        .bodyStyle()
                    
                    Text(" / ")
                    
                    if let endTimeDayTwo = pokerSession.endTimeDayTwo {
                        Text(endTimeDayTwo, format: .dateTime.month().day())
                            .bodyStyle()
                    }
                    
                } else {
                    Text(pokerSession.startTime, style: .time)
                        .bodyStyle()
                    
                    Text(" / ")
                    
                    Text(pokerSession.endTime, style: .time)
                        .bodyStyle()
                }
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
        .padding(.bottom, 30)
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
                                        .frame(width: 33, height: 33)
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
                        dismiss()
                    }
            }
        }
    }
    
    func locationBackground() -> some View {
        
        guard !pokerSession.location.localImage.isEmpty else {
            return importedBackgroundImage().resizable().aspectRatio(contentMode: .fill)
                    
        }
        
        return Image(pokerSession.location.localImage).resizable().aspectRatio(contentMode: .fill)
            
    }
    
    func importedBackgroundImage() -> Image {
        
        if pokerSession.location.imageURL != "" {
            
            return Image("encore-header2")
            
        } else {
            
            guard
                let imageData = pokerSession.location.importedImage,
                let uiImage = UIImage(data: imageData)
                    
            else {
                
                return Image("encore-header2")
            }
            
            return Image(uiImage: uiImage)
                
        }
    }
}

struct GraphicHeaderView: View {
    
    let location: LocationModel
    
    var body: some View {
        
        VStack {
            
            if location.importedImage != nil {
                
                if let photoData = location.importedImage, let uiImage = UIImage(data: photoData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 430)
                        .clipped()
                }
                
            } else if location.imageURL != "" {
                
                Image("defaultlocation-header")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 430)
                    .clipped()
                
            } else {
                
                Image(location.localImage != "" ? location.localImage : "defaultlocation-header")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 430)
                    .clipped()
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SessionDetailView(activeSheet: .constant(.recentSession), pokerSession: MockData.sampleTournament)
            .preferredColorScheme(.dark)
            .environmentObject(SessionsListViewModel())
    }
}

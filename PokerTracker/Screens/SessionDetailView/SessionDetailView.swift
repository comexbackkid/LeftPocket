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
    @State private var shareButtonisPressed = false
    @State private var showError = false
    @State private var actionDropDownMenuSelected = false
    
    let pokerSession: PokerSession_v2
    
    var body: some View {
        
        ZStack {
            
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
                shareButtonisPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    shareButtonisPressed = false
                }
                guard let image = ImageRenderer(content: shareSummary).uiImage else {
                    showError = true
                    return
                }
                
                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: image)
                
            } label: {
                Image(systemName: "arrow.down.to.line")
                    .opacity(shareButtonisPressed ? 0 : 1)
                    .overlay {
                        if shareButtonisPressed {
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
                .animation(.spring.speed(2), value: actionDropDownMenuSelected)
            
            tags
                .animation(.spring.speed(2), value: actionDropDownMenuSelected)
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
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
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
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
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
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
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
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
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
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
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
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
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
            
            Text(pokerSession.isTournament ? "Tournament Notes" : "Session Notes")
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
            
            if !pokerSession.tags.isEmpty {
                Text(pokerSession.tags.first!)
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
                
                Divider()
            }
            
            HStack {
                let buyIn = pokerSession.buyIn
                
                Text("Buy In")
                    .bodyStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(buyIn, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .bodyStyle()
            }
            
            Divider()
            
            HStack {
                
                let cashOut = pokerSession.cashOut
                Text("Cash Out")
                    .bodyStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(cashOut, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                    .bodyStyle()
            }
            
            if pokerSession.isTournament != true {
                
                Divider()
                
                HStack {
                    
                    Text("Expenses")
                        .bodyStyle()
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(pokerSession.expenses, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
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
                    
                    let totalBuyIn = pokerSession.buyIn + ((pokerSession.rebuyCount ?? 0) * pokerSession.buyIn)
                    Text("\(totalBuyIn, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))")
                        .bodyStyle()
                }
                
                if let stakers = pokerSession.stakers {
                    
                    Divider()
                    
                    VStack {
                        
                        HStack {
                            
                            Image(systemName: "chevron.right")
                                .frame(width: 20)
                                .foregroundStyle(.primary)
                                .onTapGesture {
                                    let impact = UIImpactFeedbackGenerator(style: .soft)
                                    impact.impactOccurred()
                                    actionDropDownMenuSelected.toggle()
                                }
                                .rotationEffect(Angle(degrees: actionDropDownMenuSelected ? 90 : 0))
                                .animation(.default, value: actionDropDownMenuSelected)
                            
                            Text("Action Sold")
                                .bodyStyle()
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            let amountOwed = calculateActionSold()
                            
                            Text(amountOwed, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                                .bodyStyle()
                        }
                        
                        if actionDropDownMenuSelected {
                            
                            HStack {
                                
                                VStack (alignment: .leading, spacing: 10) {
                                    
                                    ForEach(Array(stakers.enumerated()), id: \.element.id) { index, staker in
                                        HStack {
                                            Text("\(index + 1). " + staker.name + " (\((staker.percentage).formatted(.percent)))")
                                                .bodyStyle()
                                                .foregroundStyle(.secondary)
                                            
                                            Spacer()
                                            
                                            let stakersAmountOwed = staker.percentage * Double(pokerSession.cashOut)
                                            
                                            Text(stakersAmountOwed, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                                                .bodyStyle()
                                        }
                                    }
                                }
                            }
                            .padding(.top, 5)
                            .padding(.leading, 30)
                        }
                    }
                    .animation(.spring.speed(2), value: actionDropDownMenuSelected)
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
                    
                    Text(pokerSession.highHandBonus, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                        .bodyStyle()
                }
            }
        }
        .padding(.bottom, 30)
    }
    
    var shareSummary: some View {
        SocialShareView(vm: vm,
                        colorScheme: .dark,
                        pokerSession: pokerSession,
                        background: Image("defaultlocation-header"))
    }
    
    var shareButton: some View {
        
        HStack {
            Spacer()
            Button {
                shareButtonisPressed = true
                print("Profit for this Session: \(pokerSession.profit)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    shareButtonisPressed = false
                }
                guard let image = ImageRenderer(content: shareSummary).uiImage else {
                    showError = true
                    return
                }
                
                let imageSaver = ImageSaver()
                imageSaver.writeToPhotoAlbum(image: image)
                
            } label: {
                ShareButton()
                    .opacity(shareButtonisPressed ? 0 : 1)
                    .overlay {
                        if shareButtonisPressed {
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
    
    private func locationBackground() -> some View {
        
        if let localImage = pokerSession.location.localImage {
            return Image(localImage).resizable().aspectRatio(contentMode: .fill)
                    
        } else if let importedImagePath = pokerSession.location.importedImage {
            if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                return Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill)
            } else {
                return Image("defaultlocation-header").resizable().aspectRatio(contentMode: .fill)
            }
            
        } else {
            return Image("defaultlocation-header").resizable().aspectRatio(contentMode: .fill)
        }
    }
    
    private func calculateActionSold() -> Int {
        guard let stakers = pokerSession.stakers else { return 0 }
        
        let totalPercentage = stakers.reduce(0) { $0 + $1.percentage }
        let amountOwed = (Double(pokerSession.cashOut)) * totalPercentage
        return Int(amountOwed)
    }
}

struct GraphicHeaderView: View {
    
    let location: LocationModel_v2
    
    var body: some View {
        
        VStack {
            
            if let localImage = location.localImage {
                Image(localImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 430)
                    .clipped()
                
            } else if let importedImagePath = location.importedImage {
                if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 430)
                        .clipped()
                    
                } else {
                    Image("defaultlocation-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 430)
                        .clipped()
                }
                
            } else {
                Image("defaultlocation-header")
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

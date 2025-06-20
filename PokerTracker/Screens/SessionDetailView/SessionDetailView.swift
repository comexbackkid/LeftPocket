//
//  SessionDetailView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import SwiftUI
import TipKit

struct SessionDetailView: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Binding var activeSheet: Sheet?
    @State private var shareButtonisPressed = false
    @State private var showEditSessionView = false
    @State private var showError = false
    @State private var actionDropDownMenuSelected = false
    
    let pokerSession: PokerSession_v2
    let shareTip = ShareTip()
    
    var body: some View {
        
        ZStack {
            
            ScrollView (.vertical) {
                
                scrollViewContent
            }
            .background(colorScheme == .dark ? .regularMaterial : .thickMaterial)
            .background(locationBackground())
            .ignoresSafeArea()
            
            VStack (spacing: 0) {
                
                if activeSheet == .recentSession {
                    
                    dismissButton
                    
                    shareButton
                    
                    editButton
                    
                    Spacer()
                }
            }
            
            if activeSheet == .recentSession {
                VStack {
                    TipView(shareTip, arrowEdge: .trailing)
                        .tipViewStyle(CustomTipViewStyle())
                        .padding(.horizontal, 20)
                        .padding(.trailing, 35)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
        .accentColor(.brandPrimary)
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .toolbar {
            ShareLink(item: takeScreenshot(), preview: SharePreview("Shared Session from \(pokerSession.location.name)", image: Image("appicon-tiny"))) {
                Image(systemName: "paperplane.fill")
                    .fontWeight(.medium)
                    .tint(.brandPrimary)
            }
            
            Button {
                showEditSessionView = true
                
            } label: {
                Image(systemName: "pencil")
                    .bold()
            }
            .tint(.brandPrimary)
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Uh oh!"),
                  message: Text("Image could not be saved. Please try again later."),
                  dismissButton: .default(Text("Ok")))
        }
        .sheet(isPresented: $showEditSessionView) {
            EditSession(pokerSession: pokerSession)
                .presentationDragIndicator(.visible)
        }
        .onChange(of: vm.allSessions) { _, _ in
            dismiss()
        }
    }
    
    private var scrollViewContent: some View {
        
        VStack {
            
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
        .frame(maxWidth: UIScreen.main.bounds.width)
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
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, activeSheet == .recentSession ? 0 : 20)
    }

    var cashMetrics: some View {
        
        HStack(spacing: 0) {
            
            VStack (alignment: .leading, spacing: 1) {
                
                Text("Duration")
                    .captionStyle()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(pokerSession.playingTIme)
                    .font(.custom("Asap-Bold", size: 22))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
            .padding(.vertical, 26)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 1) {
                
                Text("Profit")
                    .captionStyle()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(pokerSession.profit.currencyShortHand(vm.userCurrency))
                    .profitColor(total: pokerSession.profit)
                    .font(.custom("Asap-Bold", size: 22))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
            .padding(.vertical, 26)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 1) {

                Text("Hourly")
                    .captionStyle()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(pokerSession.hourlyRate.axisShortHand(vm.userCurrency))
                    .profitColor(total: pokerSession.hourlyRate)
                    .font(.custom("Asap-Bold", size: 22))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
           
            .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
            .padding(.vertical, 26)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .body))
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .dynamicTypeSize(.large)
        
    }
    
    var tournamentMetrics: some View {
        
        HStack(spacing: 0) {
            
            VStack (alignment: .leading, spacing: 1)  {
                
                Text("Duration")
                    .captionStyle()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(pokerSession.playingTIme)
                    .font(.custom("Asap-Bold", size: 22))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
            .padding(.vertical, 26)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 1) {
                
                Text("Profit")
                    .captionStyle()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(pokerSession.profit.currencyShortHand(vm.userCurrency))
                    .profitColor(total: pokerSession.profit)
                    .font(.custom("Asap-Bold", size: 22))
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
            .padding(.vertical, 26)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
            Spacer()
            
            VStack (alignment: .leading, spacing: 1) {
                
                Text("Place")
                    .captionStyle()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                HStack (alignment: .lastTextBaseline, spacing: 0) {
                    if let finish = pokerSession.finish {
                        Text("\(finish) / ")
                    }
                    
                    if let entrants = pokerSession.entrants, entrants > 1000 {
                        Text(pokerSession.entrants ?? 0, format: .number.notation(.compactName).precision(.significantDigits(2)))
                            .font(.custom("Asap-Regular", size: 12))
                    } else {
                        Text("\(pokerSession.entrants ?? 0)")
                    }
                }
                .font(.custom("Asap-Bold", size: 22))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.3)
            .padding(.vertical, 26)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 0.75))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
            
        }
        .font(.custom("Asap-Regular", size: 16, relativeTo: .body))
        .padding(.horizontal, 20)
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
                    .lineLimit(nil)
                
            } else {
                
                Text(pokerSession.notes)
                    .bodyStyle()
                    .textSelection(.enabled)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
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
                    
                    if let computedEndDate = Calendar.current.date(byAdding: .day, value: days - 1, to: pokerSession.startTime) {
                        Text(computedEndDate, format: .dateTime.month().day())
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
            
            if let breakTime = pokerSession.totalPausedTime {
                HStack {
                    Text("Breaks")
                        .bodyStyle()
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(breakTime.abbreviatedTime)
                        .bodyStyle()
                }
                
                Divider()
            }
            
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
                
                if let bounties = pokerSession.bounties {
                    
                    Divider()
                    
                    HStack {
                        
                        Text("Bounties")
                            .bodyStyle()
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(bounties, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))")
                            .bodyStyle()
                    }
                }
                
                if pokerSession.stakers != nil {
                    
                    Divider()
                    
                    HStack {
                        
                        Text("Markup Earned")
                            .bodyStyle()
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(calculateMarkupEarned(), format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))")
                            .bodyStyle()
                    }
                }
            }
            
            Divider()
            
            HStack {
                
                let cashOut = pokerSession.cashOut + (pokerSession.bounties ?? 0)
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
                                                .font(.custom("Asap-Regular", size: 16))
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                            
                                            Spacer()
                                            
                                            let totalWinnings = Double(pokerSession.cashOut) + Double(pokerSession.bounties ?? 0)
                                            let stakersAmountOwed = staker.percentage * totalWinnings
                                            
                                            Text(stakersAmountOwed, format: .currency(code: vm.userCurrency.rawValue).precision(.fractionLength(0)))
                                                .font(.custom("Asap-Regular", size: 16))
                                                .lineLimit(1)
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
    
    var shareButton: some View {
        
        HStack {
            
            Spacer()
            
            ShareLink(item: takeScreenshot(), preview: SharePreview("Shared Session from \(pokerSession.location.name)", image: Image("appicon-tiny"))) {
                ShareButton()
                    .padding(.trailing, 10)
            }
        }
    }
    
    var dismissButton: some View {
        
        HStack {
            
            Spacer()
            
            DismissButton()
                .padding(.trailing, 10)
                .padding(.top, 10)
                .onTapGesture {
                    let impact = UIImpactFeedbackGenerator(style: .soft)
                    impact.impactOccurred()
                    activeSheet = nil
                    dismiss()
                }
        }
        
    }
    
    var editButton: some View {
        
        HStack {
            
            Spacer()
            
            Button {
                showEditSessionView = true
                
            } label: {
                EditButton()
                    .padding(.trailing, 10)
            }
        }
    }
    
    private func locationBackground() -> some View {
        
        if let localImage = pokerSession.location.localImage {
            return Image(localImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                    
        } else if let importedImagePath = pokerSession.location.importedImage {
            if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                return Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
            } else {
                return Image("defaultlocation-header")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            
        } else {
            return Image("defaultlocation-header")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    private func calculateActionSold() -> Int {
        guard let stakers = pokerSession.stakers else { return 0 }
        
        let totalPercentage = stakers.reduce(0) { $0 + $1.percentage }
        let amountOwed = (Double(pokerSession.cashOut) + Double(pokerSession.bounties ?? 0)) * totalPercentage
        return Int(amountOwed)
    }
    
    private func calculateMarkupEarned() -> Int {
        guard let stakers = pokerSession.stakers else { return 0 }
        
        let buyIn = Double(pokerSession.buyIn)
        
        let markupEarned = stakers.reduce(0.0) { total, staker in
            let stakeCostWithoutMarkup = buyIn * staker.percentage
            let stakeCostWithMarkup = stakeCostWithoutMarkup * (staker.markup ?? 1.0)
            return total + (stakeCostWithMarkup - stakeCostWithoutMarkup)
        }
        
        return Int(markupEarned)
    }
    
    @MainActor func takeScreenshot() -> Image {
        let content = scrollViewContent
            .background(colorScheme == .dark ? .regularMaterial : .thickMaterial)
            .background(locationBackground().aspectRatio(contentMode: .fill))
            .environment(\.colorScheme, UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light)
        let renderer = ImageRenderer(content: content)
        return Image(uiImage: renderer.uiImage!)
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
                    .stretchy()
                
            } else if let importedImagePath = location.importedImage {
                if let uiImage = ImageLoader.loadImage(from: importedImagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 430)
                        .clipped()
                        .stretchy()
                    
                } else {
                    Image("defaultlocation-header")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 430)
                        .clipped()
                        .stretchy()
                }
                
            } else {
                Image("defaultlocation-header")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 430)
                    .clipped()
                    .stretchy()
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
    }
}

struct TransferableImage: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.data
        }
    }
}

extension View {
    
    func stretchy() -> some View {
        visualEffect { effect, geometry in
            let currentHeight = geometry.size.height
            let scrollOffset = geometry.frame(in: .scrollView).minY
            let positiveOffset = max(0, scrollOffset)
            
            let newHeight = currentHeight + positiveOffset
            let scaleFactor = newHeight / currentHeight
            
            return effect.scaleEffect(
                x: scaleFactor, y: scaleFactor,
                anchor: .bottom
            )
        }
    }
}

struct SessionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SessionDetailView(activeSheet: .constant(.recentSession), pokerSession: MockData.sampleTournamentTwo)
            .preferredColorScheme(.dark)
            .environmentObject(SessionsListViewModel())
    }
}

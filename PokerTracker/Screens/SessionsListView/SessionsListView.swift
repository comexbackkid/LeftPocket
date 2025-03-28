//
//  SessionsView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI
import RevenueCatUI
import TipKit

struct SessionsListView: View {
    
    @AppStorage("viewStyle") var viewStyle: ViewStyle = .standard
    
    @EnvironmentObject var vm: SessionsListViewModel
    @EnvironmentObject var subManager: SubscriptionManager
    
    @State var activeSheet: Sheet?
    @State var showEditScreen = false
    @State var showPaywall = false
    @State var showTip = false
    @State var showDateFilter = false
    @State var sessionFilter: SessionFilter = .all
    @State var locationFilter: LocationModel_v2?
    @State var gameTypeFilter: String?
    @State var tagsFilter: String?
    @State var stakesFilter: String?
    @State var startDate: Date = Date()
    @State var endDate: Date = .now
    @State var datesInitialized = false
    @State var listFilter: ListFilter = .sessions
    @State var selectedSession: PokerSession_v2?
    @State var tappedSession: PokerSession_v2?
    
    var firstSessionDate: Date {
        vm.sessions.last?.date ?? Date().modifyDays(days: 15000)
    }
    var viewStyles: String {
        switch viewStyle {
        case .compact: "Compact View"
        case .standard: "Standard View"
        }
    }
    var sessionsTitle: String {
        switch sessionFilter {
        case .all: "All Sessions"
        case .cash: "Cash Sessions"
        case .tournaments: "Tournaments"
        }
    }
    var filteredTransactions: [BankrollTransaction] {
        
        var result = vm.transactions
        
        if let tagsFilter = tagsFilter {
            result = result.filter { transaction in
                transaction.tags?.contains(tagsFilter) ?? false
            }
        }
        
        return result
    }
    var filteredSessions: [PokerSession_v2] {
        
        var result = vm.sessions
        
        // Apply Session type filter
        switch sessionFilter {
        case .all: break
        case .cash: result = vm.allCashSessions()
        case .tournaments: result = vm.allTournamentSessions()
        }
        
        // Apply Location filter if selected
        if let locationFilter = locationFilter {
            result = result.filter { $0.location.name == locationFilter.name }
        }
        
        // Apply Game Type filter
        if let gameTypeFilter = gameTypeFilter {
            result = result.filter { $0.game == gameTypeFilter }
        }
        
        // Apply Stakes filter
        if let stakesFilter = stakesFilter {
            result = result.filter { $0.stakes == stakesFilter }
        }
        
        // Apply Date Range filter
        result = result.filter { session in
            let sessionDate = session.date
            return sessionDate >= startDate && sessionDate <= endDate
        }
        
        // Apply Tags filter
        if let tagsFilter = tagsFilter {
            result = result.filter { session in
                session.tags.contains(tagsFilter)
            }
        }
        
        return result
    }
    
    let editTip = SessionsListTip()
    let filterTip = FilterSessionsTip()
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                switch listFilter {
                case .sessions:
                    if vm.sessions.isEmpty {
                        VStack {
                            screenTitle
                            Spacer()
                        }
                        
                    } else {
                        List {
                            screenTitle
                            
                            ForEach(filteredSessions) { session in
                                NavigationLink(destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session).onAppear(perform: {
                                    tappedSession = session
                                })) {
                                    CellView(pokerSession: session, currency: vm.userCurrency, viewStyle: $viewStyle)
                                        .popoverTip(editTip)
                                        .tipViewStyle(CustomTipViewStyle())
                                }
                                .listRowBackground(Color.brandBackground)
                                .listRowInsets(EdgeInsets(top: 3, leading: 12, bottom: 3, trailing: 12))
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    swipeActions(session)
                                }
                            }
                        }
                        .sensoryFeedback(.impact, trigger: tappedSession)
                        .listStyle(.plain)
                        .padding(.bottom, 50)
                        .sheet(item: $selectedSession) { session in
                            EditSession(pokerSession: session)
                        }
                    }
                    
                case .transactions:
                    if vm.transactions.isEmpty {
                        VStack {
                            screenTitle
                            Spacer()
                        }
                        
                    } else {
                        List {
                            screenTitle
                            
                            ForEach(filteredTransactions, id: \.self) { transaction in
                                TransactionCellView(transaction: transaction, currency: vm.userCurrency)
                                    .listRowBackground(Color.brandBackground)
                                    .listRowInsets(EdgeInsets(top: 3, leading: 12, bottom: 3, trailing: 12))
                            }
                            .onDelete(perform: { indexSet in
                                deleteTransaction(at: indexSet)
                            })
                        }
                        .listStyle(.plain)
                        .padding(.bottom, 50)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(.brandPrimary)
            .background(Color.brandBackground)
            .toolbar {
                VStack {
                    switch listFilter {
                    case .sessions:
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            listFilter = .transactions
                        } label: {
                            Image(systemName: "creditcard.fill")
                        }
                        
                    case .transactions:
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            listFilter = .sessions
                        } label: {
                            Image(systemName: "suit.club.fill")
                        }
                    }
                }
                .frame(width: 25)
                
                toolbarFilter
            }
            .onAppear {
                if vm.sessions.count > 1 {
                    SessionsListTip.shouldShow = false
                }
                if !datesInitialized {
                    startDate = firstSessionDate
                    datesInitialized = true
                }
            }
            .onChange(of: vm.sessions) { _ in
                if datesInitialized {
                    startDate = firstSessionDate
                }
            }
        }
        .accentColor(.brandPrimary)
        .overlay {
            switch listFilter {
            case .sessions: if filteredSessions.isEmpty { startingScreen }
            case .transactions: if filteredTransactions.isEmpty { startingScreen }
            }
        }
    }
    
    var toolbarFilter: some View {
        
        Menu {
            Picker("Select View Style", selection: $viewStyle) {
                ForEach(ViewStyle.allCases, id: \.self) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            
            Menu {
                Picker("Select Session Type", selection: $sessionFilter) {
                    ForEach(SessionFilter.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
            } label: {
                Text("Session Type")
                Image(systemName: "suit.club.fill")
            }
            
            Menu {
                Picker("Select Location", selection: $locationFilter) {
                    Text("All").tag(nil as LocationModel_v2?)
                    ForEach(vm.sessions.map({ $0.location }).uniquedByName(), id: \.self) { location in
                        Text(location.name).tag(location as LocationModel_v2?)
                    }
                }
            } label: {
                HStack {
                    Text("Location")
                    Image(systemName: "mappin.and.ellipse")
                }
            }
            
            Menu {
                Picker("Select Game Type", selection: $gameTypeFilter) {
                    Text("All").tag(nil as String?)
                    ForEach(vm.sessions.map { $0.game }.uniqued(), id: \.self) { game in
                        Text(game).tag(game as String?)
                    }
                }
            } label: {
                HStack {
                    Text("Game Type")
                    Image(systemName: "dice")
                }
            }
            
            Menu {
                Picker("Select Stakes", selection: $stakesFilter) {
                    Text("All").tag(nil as String?)
                    ForEach(vm.allCashSessions().map { $0.stakes }.uniqued(), id: \.self) { stakes in
                        Text(stakes).tag(stakes as String?)
                    }
                }
            } label: {
                Text("Stakes")
                Image(systemName: "dollarsign.circle")
            }
            
            Menu {
                Picker("Tags", selection: $tagsFilter) {
                    Text("None").tag(nil as String?)
                    ForEach(vm.sessions.compactMap { $0.tags }.flatMap { $0 }.filter { !$0.isEmpty }.uniqued(), id: \.self) { tag in
                        Text(tag).tag(tag as String?)
                    }
                }
            } label: {
                HStack {
                    Text("Tags")
                    Image(systemName: "tag.fill")
                }
            }
            
            Divider()
            
            Button {
                showDateFilter = true
            } label: {
                Text("Date Range")
                Image(systemName: "calendar")
            }
            
            Divider()
            
            Button {
                resetAllFilters()
            } label: {
                Text("Clear Filters")
                Image(systemName: "x.circle")
            }
            
        } label: {
            Image(systemName: "slider.horizontal.3")
                
        }
        .popoverTip(filterTip)
        .tipViewStyle(CustomTipViewStyle())
        .sheet(isPresented: $showDateFilter, content: {
            DateFilter(startDate: $startDate, endDate: $endDate)
                .presentationDetents([.height(350)])
                .presentationBackground(.ultraThinMaterial)
        })
    }
    
    var startingScreen: some View {
        
        VStack {
            var title: String {
                switch listFilter {
                case .sessions: "No Sessions"
                case .transactions: "No Transactions"
                }
            }
            
            Spacer()
            
            EmptyState(title: title, image: .sessions)
            
            Spacer()
        }
        .padding(.bottom, 50)
    }
    
    var screenTitle: some View {
        
        HStack (alignment: .center) {
            Text(listFilter == .sessions ? sessionsTitle : "All Transactions")
                .titleStyle()
            
            Spacer()
            
            if let tagsFilter {
                if listFilter == .sessions {
                    FilterTag(type: "Tag", filterName: "\(tagsFilter)")
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .padding(.bottom)
                }
            }
            let today = Calendar.current.startOfDay(for: Date.now)
            let normalizedEndDate = Calendar.current.startOfDay(for: endDate)
            if !vm.sessions.isEmpty {
                if startDate != firstSessionDate || normalizedEndDate != today {
                    FilterTag(type: "Dates", filterName: "Custom")
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .padding(.bottom)
                }
            }
        }
        .padding(.horizontal)
        .minimumScaleFactor(0.9)
        .lineLimit(1)
        .listRowBackground(Color.brandBackground)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    private func swipeActions(_ session: PokerSession_v2) -> some View {
        Group {
            Button(role: .destructive) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                deleteSession(session)
                editTip.invalidate(reason: .actionPerformed)
                
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                selectedSession = session
                editTip.invalidate(reason: .actionPerformed)
                
            } label: {
                Image(systemName: "pencil")
            }
            .tint(Color.donutChartOrange)
        }
    }
    
    private func resetAllFilters() {
        sessionFilter = .all
        locationFilter = nil
        gameTypeFilter = nil
        stakesFilter = nil
        tagsFilter = nil
        startDate = firstSessionDate
        endDate = Date.now
    }
    
    private func deleteSession(_ session: PokerSession_v2) {
        if let index = vm.sessions.firstIndex(where: { $0.id == session.id }) {
            vm.sessions.remove(at: index)
        }
    }
    
    private func deleteTransaction(at offsets: IndexSet) {
        vm.transactions.remove(atOffsets: offsets)
    }
    
    private func binding(for session: PokerSession_v2) -> Binding<PokerSession_v2> {
        guard let sessionIndex = vm.sessions.firstIndex(where: { $0.id == session.id }) else {
            fatalError("Can't find session in array")
        }
        return $vm.sessions[sessionIndex]
    }
}

enum ViewStyle: String, CaseIterable {
    case standard, compact
}

enum SessionFilter: String, CaseIterable {
    case all, cash, tournaments
    
    var description: String {
        switch self {
        case .all:
            return "All"
        case .cash:
            return "Cash"
        case .tournaments:
            return "Tournaments"
        }
    }
}

enum ListFilter: String, CaseIterable {
    case sessions, transactions
    
    var description: String {
        switch self {
        case .sessions:
            return "All Sessions"
        case .transactions:
            return "All Transactions"
        }
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsListView()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .preferredColorScheme(.dark)
    }
}

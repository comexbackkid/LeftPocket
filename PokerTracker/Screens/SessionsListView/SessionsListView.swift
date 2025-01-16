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
    @State var locationFilter: LocationModel?
    @State var gameTypeFilter: String?
    @State var tagsFilter: String?
    @State var stakesFilter: String?
    @State var startDate: Date = Date()
    @State var endDate: Date = .now
    @State var datesInitialized = false
    @State var listFilter: ListFilter = .sessions
    @State var selectedSession: PokerSession?
    
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
    var filteredSessions: [PokerSession] {
        
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
                session.tags?.contains(tagsFilter) ?? false
            }
        }
        
        return result
    }
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                if vm.sessions.isEmpty {
                    
                    startingScreen
                    
                } else {
                    
                    switch listFilter {
                    case .sessions:
                        
                        if !filteredSessions.isEmpty {
                            List {
                                screenTitle
                                
                                ForEach(filteredSessions) { session in
                                    NavigationLink(
                                        destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session),
                                        label: {
                                            CellView(pokerSession: session, currency: vm.userCurrency, viewStyle: $viewStyle)
                                        })
                                    .listRowBackground(Color.brandBackground)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 18))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        swipeActions(session)
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .padding(.bottom, 50)
                            .sheet(item: $selectedSession) { session in
                                EditSession(pokerSession: session)
                            }
                            
                            if #available(iOS 17.0, *) { filterTip }
                            
                        } else {
                            
                            emptySessionsView
                        }
                        
                    case .transactions:
                        
                        if !vm.transactions.isEmpty {
                            List {
                                screenTitle
                                
                                ForEach(vm.transactions, id: \.self) { transaction in
                                    TransactionCellView(transaction: transaction, currency: vm.userCurrency)
                                        .listRowBackground(Color.brandBackground)
                                        .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 18))
                                }
                                .onDelete(perform: { indexSet in
                                    deleteTransaction(at: indexSet)
                                })
                            }
                            .listStyle(.plain)
                            .padding(.bottom, 50)
                            
                        } else {
                            emptyTransactionsView
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(.brandPrimary)
            .background(Color.brandBackground)
            .toolbar {
                if !vm.sessions.isEmpty {
                    
                    VStack {
                        switch listFilter {
                        case .sessions:
                            
                            Button {
                                listFilter = .transactions
                            } label: {
                                Image(systemName: "creditcard.fill")
                            }
                            
                        case .transactions:
                            
                            Button {
                                listFilter = .sessions
                            } label: {
                                Image(systemName: "suit.club.fill")
                            }
                        }
                    }
                    .frame(width: 25)
                    
                    toolbarFilter
                }
            }
            .onAppear {
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
                    Text("All").tag(nil as LocationModel?)
                    ForEach(vm.sessions.map({ $0.location }).uniquedByName(), id: \.self) { location in
                        Text(location.name).tag(location as LocationModel?)
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
        .sheet(isPresented: $showDateFilter, content: {
            DateFilter(startDate: $startDate, endDate: $endDate)
                .presentationDetents([.height(350)])
                .presentationBackground(.ultraThinMaterial)
        })
    }
    
    var startingScreen: some View {
        
        VStack {
            Spacer()
            EmptyState(title: "No Sessions", image: .sessions)
            Spacer()
        }
        .padding(.bottom, 50)
    }
    
    var emptySessionsView: some View {
        
        VStack (alignment: .leading) {
            
            screenTitle
            
            Spacer()
            EmptyState(title: "No Sessions", image: .sessions)
            Spacer()
        }
    }
    
    var emptyTransactionsView: some View {
        
        VStack (alignment: .leading) {
            
            screenTitle
            
            Spacer()
            EmptyState(title: "No Transactions", image: .sessions)
            Spacer()
        }
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
            if startDate != firstSessionDate || normalizedEndDate != today {
                FilterTag(type: "Dates", filterName: "Custom")
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .padding(.bottom)
            }
        }
        .padding(.horizontal)
        .minimumScaleFactor(0.9)
        .lineLimit(1)
        .listRowBackground(Color.brandBackground)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
    
    @available(iOS 17.0, *)
    var filterTip: some View {
        
        VStack {
            let filterTip = FilterSessionsTip()
            
            TipView(filterTip)
                .tipViewStyle(CustomTipViewStyle())
                .padding(20)
            
            Spacer()
        }
    }
    
    private func swipeActions(_ session: PokerSession) -> some View {
        Group {
            Button(role: .destructive) {
                deleteSession(session)
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
            
            Button {
                selectedSession = session
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
    
    private func deleteSession(_ session: PokerSession) {
        if let index = vm.sessions.firstIndex(where: { $0.id == session.id }) {
            vm.sessions.remove(at: index)
        }
    }
    
    private func deleteTransaction(at offsets: IndexSet) {
        vm.transactions.remove(atOffsets: offsets)
    }
    
    private func binding(for session: PokerSession) -> Binding<PokerSession> {
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

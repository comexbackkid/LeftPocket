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
    
    @Environment(\.openURL) var openURL
    @AppStorage("viewStyle") var viewStyle: ViewStyle = .standard
    @AppStorage("redchipPromoPresentationCount") private var redchipPromoPresentationCount = 0
    @AppStorage("hasClickedRedChipPromo") private var hasClickedRedChipPromo: Bool = false
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
    @State var bankrollFilter: BankrollSelection = .all
    @State var startDate: Date? = nil
    @State var endDate: Date? = nil
    @State var showDeleteSessionWarning = false
    @State var showDeleteTransactionWarning = false
    @State var sessionToDelete: PokerSession_v2?
    @State var transactionToDelete: BankrollTransaction?
    @State var listFilter: ListFilter = .sessions
    @State var selectedSession: PokerSession_v2?
    @State var tappedSession: PokerSession_v2?
    var filteredTransactions: [BankrollTransaction] {
        let allTransactions: [BankrollTransaction]

        switch bankrollFilter {
        case .all: allTransactions = vm.transactions + vm.bankrolls.flatMap(\.transactions)
        case .default: allTransactions = vm.transactions
        case .custom(let id): allTransactions = vm.bankrolls.first(where: { $0.id == id })?.transactions ?? []
        }

        let filtered = allTransactions.filter { tx in
            if let tag = tagsFilter {
                return tx.tags?.contains(tag) ?? false
            }
            return true
        }

        return filtered.sorted(by: { $0.date > $1.date })
    }
    var filteredSessions: [PokerSession_v2] {
        
        var result: [PokerSession_v2] = vm.sessions + vm.bankrolls.flatMap { $0.sessions }
        
        switch bankrollFilter {
        case .all: result = vm.sessions + vm.bankrolls.flatMap { $0.sessions }
        case .default: result = vm.sessions
        case .custom(let id): result = vm.bankrolls.first(where: { $0.id == id })?.sessions ?? []
        }
        
        switch sessionFilter {
        case .all: break
        case .cash: result = result.filter { !$0.isTournament }
        case .tournaments: result = result.filter { $0.isTournament }
        }
        
        if let locationFilter = locationFilter {
            result = result.filter { $0.location.name == locationFilter.name }
        }
        
        if let gameTypeFilter = gameTypeFilter {
            result = result.filter { $0.game == gameTypeFilter }
        }
        
        if let stakesFilter = stakesFilter {
            result = result.filter { $0.stakes == stakesFilter }
        }
        
        if let start = startDate, let end = endDate {
            result = result.filter { $0.date >= start && $0.date <= end }
        } else if let start = startDate {
            result = result.filter { $0.date >= start }
        } else if let end = endDate {
            result = result.filter { $0.date <= end }
        }
        
        if let tagsFilter = tagsFilter {
            result = result.filter { session in
                session.tags.contains(tagsFilter)
            }
        }
        
        return result.sorted(by: { $0.date > $1.date })
    }
    var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    let editTip = SessionsListTip()
    let filterTip = FilterSessionsTip()
    
    var body: some View {
        
        NavigationSplitView {
            
            ZStack {
                
                switch listFilter {
                case .sessions:
                    if vm.allSessions.isEmpty {
                        VStack {
                            screenTitle
                            Spacer()
                        }
                        
                    } else {
                        List {
                            screenTitle
                            
                            if redchipPromoPresentationCount >= 2, !hasClickedRedChipPromo { promoLink }
                            
                            ForEach(filteredSessions) { session in
                                NavigationLink(destination: SessionDetailView(activeSheet: $activeSheet, pokerSession: session).onAppear(perform: {
                                    tappedSession = session
                                })) {
                                    CellView(pokerSession: session, currency: vm.userCurrency, viewStyle: $viewStyle)
                                }
                                .listRowBackground(Color.brandBackground)
                                .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        let impact = UIImpactFeedbackGenerator(style: .soft)
                                        impact.impactOccurred()
                                        sessionToDelete = session
                                        showDeleteSessionWarning = true
                                        
                                    } label: {
                                        Image(systemName: "trash").tint(.red)
                                    }
                                    
                                    Button {
                                        let impact = UIImpactFeedbackGenerator(style: .soft)
                                        impact.impactOccurred()
                                        selectedSession = session
                                        editTip.invalidate(reason: .actionPerformed)
                                        
                                    } label: {
                                        Image(systemName: "pencil").tint(Color.donutChartOrange)
                                    }
                                }
                            }
                        }
                        .confirmationDialog("Are you sure you want to delete?", isPresented: $showDeleteSessionWarning, titleVisibility: .visible) {
                            Button("Delete Session", role: .destructive) {
                                if let session = sessionToDelete {
                                    withAnimation {
                                        deleteSession(session)
                                    }
                                }
                                sessionToDelete = nil
                            }
                        }
                        .sensoryFeedback(.impact, trigger: tappedSession)
                        .listStyle(.plain)
                        .padding(.bottom, 50)
                        .sheet(item: $selectedSession) { session in
                            EditSession(pokerSession: session)
                                .presentationDragIndicator(.visible)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .background(Color.brandBackground)
                    }
                    
                case .transactions:
                    if vm.allTransactions.isEmpty && vm.bankrolls.flatMap({ $0.transactions }).isEmpty {
                        VStack {
                            screenTitle
                            Spacer()
                        }
                        
                    } else {
                        List {
                            screenTitle
                            
                            ForEach(filteredTransactions, id: \.id) { transaction in
                                TransactionCellView(transaction: transaction, currency: vm.userCurrency)
                                    .listRowBackground(Color.brandBackground)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button {
                                            transactionToDelete = transaction
                                            showDeleteTransactionWarning = true
                                            
                                        } label: {
                                            Image(systemName: "trash").tint(.red)
                                        }
                                    }
                            }
                        }
                        .confirmationDialog("Are you sure you want to delete?", isPresented: $showDeleteTransactionWarning, titleVisibility: .visible) {
                            Button("Delete Transaction", role: .destructive) {
                                if let transaction = transactionToDelete {
                                    withAnimation {
                                        deleteTransaction(transaction)
                                    }
                                }
                                transactionToDelete = nil
                            }
                        }
                        .listStyle(.plain)
                        .padding(.bottom, 50)
                    }
                }
                
                // Show Edit Tip when new user hits 2 Sessions
                if vm.allSessions.count == 2 {
                    VStack {
                        TipView(editTip, arrowEdge: .bottom)
                            .tipViewStyle(CustomTipViewStyle())
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        Spacer()
                    }
                }
            }
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
            .accentColor(.brandPrimary)
            .background(Color.brandBackground)
            .overlay {
                if isPad {
                    switch listFilter {
                    case .sessions: if filteredSessions.isEmpty { startingScreen }
                    case .transactions: if filteredTransactions.isEmpty { startingScreen }
                    }
                }
            }
            
        } detail: {
            if let session = selectedSession {
                SessionDetailView(activeSheet: $activeSheet, pokerSession: session)
                
            } else {
                VStack {
                    Image(systemName: "rectangle.on.rectangle.angled")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("Select a session to view details")
                        .bodyStyle()
                        .foregroundColor(.secondary)
                }
            }
        }
        .accentColor(.brandPrimary)
        .overlay {
            if !isPad {
                switch listFilter {
                case .sessions: if filteredSessions.isEmpty { startingScreen }
                case .transactions: if filteredTransactions.isEmpty { startingScreen }
                }
            }
        }
    }
    
    var promoLink: some View {
        
        Button {
            
            hasClickedRedChipPromo = true
            guard let url = URL(string: "https://redchippoker.com/checkout/?rid=po68r2&coupon=LeftPocket") else {
                return
            }
            
            openURL(url)
            
        } label: {
            HStack {
                
                Spacer()
                
                HStack {
                    
                    Image("rcp-icon")
                        .resizable()
                        .frame(width: 18, height: 18)
                    
                    Text("Try CORE by Red Chip Poker for $1")
                        .captionStyle()
                }
                .padding(8)
                .padding(.horizontal, 12)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 15))
                .padding(.bottom, 6)
                
            }
            
        }
        .listRowBackground(Color.brandBackground)
    }
    
    var toolbarFilter: some View {
        
        Menu {
            Picker("Select View Style", selection: $viewStyle) {
                ForEach(ViewStyle.allCases, id: \.self) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            
            var availableSessionTypes: [SessionFilter] {
                let allSessions = vm.sessions + vm.bankrolls.flatMap(\.sessions)
                var types: Set<SessionFilter> = []
                
                for session in allSessions {
                    if session.isTournament {
                        types.insert(.tournaments)
                    } else {
                        types.insert(.cash)
                    }
                }
                
                // Always allow "All"
                types.insert(.all)
                
                return SessionFilter.allCases.filter { types.contains($0) }
            }
            
            Menu {
                Picker("Select Session Type", selection: $sessionFilter) {
                    ForEach(availableSessionTypes, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }
                
            } label: {
                Text("Session Type")
                Image(systemName: "suit.club.fill")
            }
            
            Menu {
                Picker("Select Bankroll", selection: $bankrollFilter) {
                    Text("All").tag(BankrollSelection.all)
                    Text("Default").tag(BankrollSelection.default)
                    ForEach(vm.bankrolls) { bankroll in
                        Text(bankroll.name).tag(BankrollSelection.custom(bankroll.id))
                    }
                }
                
            } label: {
                HStack {
                    Text("Bankroll")
                    Image(systemName: "bag.fill")
                }
            }
            
            Menu {
                let allLocations: [LocationModel_v2] = {
                    let allSessions = vm.sessions + vm.bankrolls.flatMap(\.sessions)
                    return allSessions
                        .map { $0.location }
                        .filter { !$0.name.isEmpty }
                        .uniquedByName()
                        .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                }()
                Picker("Select Location", selection: $locationFilter) {
                    Text("All").tag(nil as LocationModel_v2?)
                    ForEach(allLocations, id: \.self) { location in
                        Text(location.name).tag(location as LocationModel_v2?)
                    }
                }
                
            } label: {
                HStack {
                    Text("Location")
                    Image(systemName: "mappin.and.ellipse")
                }
            }
            
            var allGameTypes: [String] {
                let allSessions = vm.sessions + vm.bankrolls.flatMap(\.sessions)
                return allSessions
                    .map { $0.game }
                    .filter { !$0.isEmpty }
                    .uniqued()
                    .sorted(by: { $0.lowercased() < $1.lowercased() })
            }
            
            Menu {
                Picker("Select Game Type", selection: $gameTypeFilter) {
                    Text("All").tag(nil as String?)
                    ForEach(allGameTypes, id: \.self) { game in
                        Text(game).tag(game as String?)
                    }
                }
                
            } label: {
                HStack {
                    Text("Game Type")
                    Image(systemName: "dice")
                }
            }
            
            var allStakes: [String] {
                let allCashSessions = (vm.sessions + vm.bankrolls.flatMap(\.sessions))
                    .filter { !$0.isTournament }
                
                return allCashSessions
                    .map { $0.stakes }
                    .filter { !$0.isEmpty }
                    .uniqued()
                    .sorted(by: { $0.lowercased() < $1.lowercased() })
            }
            
            Menu {
                Picker("Select Stakes", selection: $stakesFilter) {
                    Text("All").tag(nil as String?)
                    ForEach(allStakes, id: \.self) { stakes in
                        Text(stakes).tag(stakes as String?)
                    }
                }
                
            } label: {
                Text("Stakes")
                Image(systemName: "dollarsign.circle")
            }
            
            Menu {
                let allTags: [String] = {
                    let sessionTags = (vm.sessions + vm.bankrolls.flatMap(\.sessions))
                        .compactMap { $0.tags }
                        .flatMap { $0 }
                    
                    let transactionTags = (vm.transactions + vm.bankrolls.flatMap(\.transactions))
                        .compactMap { $0.tags }
                        .flatMap { $0 }
                    
                    return (sessionTags + transactionTags)
                        .filter { !$0.isEmpty }
                        .uniqued()
                        .sorted(by: { $0.lowercased() < $1.lowercased() })
                }()
                Picker("Tags", selection: $tagsFilter) {
                    Text("None").tag(nil as String?)
                    ForEach(allTags, id: \.self) { tag in
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
                .presentationDragIndicator(.visible)
        })
    }
    
    var startingScreen: some View {
        
        VStack {
            var title: LocalizedStringResource {
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
            Text(listFilter.description)
                .titleStyle()
            
            Spacer()
            
            if let tagsFilter {
                if listFilter == .sessions {
                    FilterTag(type: "Tag", filterName: " \(tagsFilter)")
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .padding(.bottom)
                }
            }
            
            if let stakesFilter {
                if listFilter == .sessions {
                    FilterTag(type: "Stakes", filterName: " \(stakesFilter)")
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .padding(.bottom)
                }
            }
            
            if let gameTypeFilter {
                if listFilter == .sessions {
                    FilterTag(type: "Game", filterName: " \(gameTypeFilter)")
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .padding(.bottom)
                }
            }
            
            if locationFilter != nil {
                if listFilter == .sessions {
                    FilterTag(type: "Location", filterName: " Custom")
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .padding(.bottom)
                }
            }
            if startDate != nil {
                FilterTag(type: "Dates", filterName: " Custom")
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
        bankrollFilter = .all
        startDate = nil
        endDate = nil
    }
    
    private func deleteSession(_ session: PokerSession_v2) {
        if let index = vm.sessions.firstIndex(where: { $0.id == session.id }) {
            vm.sessions.remove(at: index)
            return
        }
        
        for i in vm.bankrolls.indices {
            if let sessionIndex = vm.bankrolls[i].sessions.firstIndex(where: { $0.id == session.id }) {
                vm.bankrolls[i].sessions.remove(at: sessionIndex)
                return
            }
        }
    }
    
    private func deleteTransaction(_ transaction: BankrollTransaction) {
        // First try to delete from default (legacy) transactions
        if let legacyIndex = vm.transactions.firstIndex(where: { $0.id == transaction.id }) {
            vm.transactions.remove(at: legacyIndex)
            return
        }
        
        // Otherwise, try to delete from any of the bankrolls
        for i in vm.bankrolls.indices {
            if let txIndex = vm.bankrolls[i].transactions.firstIndex(where: { $0.id == transaction.id }) {
                vm.bankrolls[i].transactions.remove(at: txIndex)
                return
            }
        }
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
    
    var titleString: String {
        switch self {
        case .standard: return "Standard View"
        case .compact: return "Compact View"
        }
    }
}

enum SessionFilter: String, CaseIterable {
    case all, cash, tournaments
    
    var description: String {
        switch self {
        case .all: return "All"
        case .cash: return "Cash"
        case .tournaments: return "Tournaments"
        }
    }
    
    var titleString: String {
        switch self {
        case .all: return "All Sessions"
        case .cash: return "Cash Sessions"
        case .tournaments: return "Tournaments"
        }
    }
    
    var lineChartColors: [Color] {
        switch self {
        case .tournaments: return [.donutChartOrange, .orange]
        default: return [.chartAccent, .chartBase]
        }
    }
    
    var lineChartAreaColors: [Color] {
        switch self {
        case .tournaments:
            return [.donutChartOrange.opacity(0.85),
                    .donutChartOrange.opacity(0.25),
                    .clear,
                    .clear]
        default:
            return [Color("lightBlue").opacity(0.85),
                    Color("lightBlue").opacity(0.25),
                    .clear,
                    .clear]
        }
    }
}

enum BankrollSelection: Hashable, RawRepresentable {
    case all
    case `default`
    case custom(UUID)
    
    // 1) Define RawValue as String
    typealias RawValue = String
    
    // 2) Initialize from the raw string
    init?(rawValue: String) {
        switch rawValue {
        case "all": self = .all
        case "default": self = .default
        default:
            guard let uuid = UUID(uuidString: rawValue)
            else { return nil }
            self = .custom(uuid)
        }
    }
    
    // 3) Serialize each case to a string
    var rawValue: String {
        switch self {
        case .all: return "all"
        case .`default`: return "default"
        case .custom(let uuid): return uuid.uuidString
        }
    }
}

enum ListFilter: LocalizedStringResource, CaseIterable {
    case sessions, transactions
    
    var description: LocalizedStringResource {
        switch self {
        case .sessions: return "All Sessions"
        case .transactions: return "All Transactions"
        }
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsListView()
            .environmentObject(SessionsListViewModel())
            .environmentObject(SubscriptionManager())
            .preferredColorScheme(.dark)
//            .environment(\.locale, Locale(identifier: "PT"))
    }
}

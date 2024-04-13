//
//  ProfitByYear.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/4/22.
//

import SwiftUI
import RevenueCat
import RevenueCatUI

struct ProfitByYear: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var subManager: SubscriptionManager
    @EnvironmentObject var viewModel: SessionsListViewModel
    @StateObject var vm: AnnualReportViewModel
    @StateObject var exportUtility = CSVConversion()
    
    @State private var showError: Bool = false
    @State private var showPaywall = false
    
    var body: some View {

        ScrollView {
            
            title
            
            VStack {
                
                lineChart

                CustomPicker(vm: vm)
                    .padding(.bottom, 35)
                    .padding(.top)
                
                incomeReport
                
//                detailedReports
                
                bestPlays
                
                barChart
                
                exportButton
                
                Spacer()
            }
            .padding(.bottom, 50)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
        }
        .background(Color.brandBackground)
        .accentColor(.brandPrimary)
    }
    
    var title: some View {
        
        HStack {
            
            Text("Annual Report")
                .titleStyle()
                .padding(.top, -37)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var lineChart: some View {
        
        VStack {
            
            let year = vm.chartRange(timeline: vm.myNewTimeline)
            
            if year.isEmpty {
                
                VStack {
                    Image("bargraphvector-transparent")
                        .resizable()
                        .frame(width: 125, height: 125)
                    
                    Text("No Sessions")
                        .cardTitleStyle()
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }
                .animation(nil, value: year)
                .frame(height: 250)
                .padding(.vertical)
                
            } else {
                
                SwiftLineChartsPractice(yearSelection: year, showTitle: false, showYAxis: true, showRangeSelector: false, overlayAnnotation: true)
                    .animation(nil, value: year)
                    .padding(.horizontal, 30)
                    .frame(height: 250)
                    .padding(.vertical)
            }
        }
    }
    
    var incomeReport: some View {
        
        VStack (spacing: 12) {
            
            let grossIncome = vm.grossIncome(timeline: vm.myNewTimeline)
            let netProfitTotal = vm.netProfitCalc(timeline: vm.myNewTimeline)
            let hourlyRate = vm.hourlyCalc(timeline: vm.myNewTimeline)
            let profitPerSession = vm.avgProfit(timeline: vm.myNewTimeline)
            let winRate = vm.winRate(timeline: vm.myNewTimeline)
            let totalExpenses = vm.expensesByYear(timeline: vm.myNewTimeline)
            let totalHours = vm.totalHours(timeline: vm.myNewTimeline)
            let totalSessions = vm.sessionsPerYear(timeline: vm.myNewTimeline)
            let bestProfit = vm.bestProfit(timeline: vm.myNewTimeline)
//            let bigBlindPerHr = vm.bigBlindPerHr(timeline: vm.myNewTimeline)
            
            HStack {
                Text("Gross Income")
                
                Spacer()
                Text(grossIncome, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: grossIncome)
            }
            
            HStack {
                Text("Expenses")
                
                Spacer()
                Text(totalExpenses, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .foregroundColor(totalExpenses > 0 ? .red : Color(.systemGray))
            }
            
            HStack {
                Text("(Includes Tournament Buy Ins)")
                    .captionStyle()
                    .foregroundColor(.secondary)
                
                Spacer()
                
            }
            
            HStack {
                Text("Net Profit")
                
                Spacer()
                Text(netProfitTotal, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: netProfitTotal)
            }
            
            Divider().padding(.vertical)
            
            HStack {
                Text("Hourly Rate")
                
                Spacer()
                Text(hourlyRate, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: hourlyRate)
            }
            
            HStack {
                Text("Profit Per Session")
                
                Spacer()
                Text(profitPerSession, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: profitPerSession)
            }
            
            HStack {
                Text("Biggest Session")
                
                Spacer()
                Text(bestProfit, format: .currency(code: viewModel.userCurrency.rawValue).precision(.fractionLength(0)))
                    .profitColor(total: profitPerSession)
            }
            
            HStack {
                Text("Win Rate")
                
                Spacer()
                Text(winRate)
            }
            
            HStack {
                Text("No. of Sessions")
                
                Spacer()
                Text(totalSessions)
            }
            
            HStack {
                Text("Hours Played")
                
                Spacer()
                Text(totalHours)
            }
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .lineSpacing(2.5)
        .animation(nil, value: vm.myNewTimeline)
        .padding(30)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        
    }
    
    var detailedReports: some View {
        
        HStack {
            VStack {
                HStack {
                    Text("Cash Game Report")
                        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                    Spacer()
                    Text("›")
                }
            }
            .padding(30)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
            .padding(.top, 20)
            
            
            VStack {
                HStack {
                    Text("Tournament Report")
                        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
                    Spacer()
                    Text(" ›")
                }
            }
            .padding(30)
            .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
            .padding(.top, 20)

        }
        .frame(width: UIScreen.main.bounds.width * 0.9)
        
    }
    
    var barChart: some View {
        
        VStack {
            
            let dateRange = vm.chartRange(timeline: vm.myNewTimeline)
            
            BarChartWeeklySessionCount(showTitle: true, dateRange: dateRange)
                .padding(30)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 220)
                .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
                .padding(.top, 20)
        }
        
    }
    
    var bestPlays: some View {
        
        VStack (spacing: 30) {
            
            let bestLocation = vm.bestLocation(timeline: vm.myNewTimeline)
            
            BestLocationView(location: bestLocation)

        }
        .animation(nil, value: vm.myNewTimeline)
        .padding(.top, 20)
    }
    
    var exportButton: some View {
        
        Button {
            
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            if subManager.isSubscribed {
                do {
                    
                    let fileURL = try CSVConversion.exportCSV(from: viewModel.allSessionDataByYear(year: vm.lastYear))
                    shareFile(fileURL)
                    
                } catch {
                    
                    exportUtility.errorMsg = "\(error.localizedDescription)"
                    showError.toggle()
                }
            } else {
                
                showPaywall = true
                
            }
            
        } label: {
            PrimaryButton(title: "Export Last Year's Results")
        }
        .padding(.top)
        .alert(isPresented: $showError) {
            Alert(title: Text("Uh oh!"), message: Text(exportUtility.errorMsg ?? ""), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(fonts: CustomPaywallFontProvider(fontName: "Asap"))
        }
        .task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                showPaywall = showPaywall && customerInfo.activeSubscriptions.isEmpty
                await subManager.checkSubscriptionStatus()
            }
        }
    }

    func shareFile(_ fileURL: URL) {
        let activityViewController = UIActivityViewController(
            activityItems: [fileURL],
            applicationActivities: nil
        )
        
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }

}

struct ProfitByYear_Previews: PreviewProvider {
    static var previews: some View {
        ProfitByYear(vm: AnnualReportViewModel())
            .environmentObject(SubscriptionManager())
            .environmentObject(SessionsListViewModel())
            .preferredColorScheme(.dark)
    }
}

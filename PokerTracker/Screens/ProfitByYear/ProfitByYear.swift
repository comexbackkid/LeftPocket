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
                
                let chartRange = vm.chartRange(timeline: vm.myNewTimeline)
                
                if chartRange.isEmpty {
                    
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
                    .animation(nil, value: chartRange)
                    .frame(height: 250)
                    .padding(.vertical)
                    
                    
                } else {
                    
                    SwiftLineChartsPractice(dateRange: chartRange, showTitle: false, showYAxis: true, overlayAnnotation: true)
                        .animation(nil, value: chartRange)
                        .padding(.horizontal, 30)
                        .frame(height: 250)
                        .padding(.vertical)
                }

                CustomPicker(vm: vm)
                    .padding(.bottom, 35)
                    .padding(.top)
                
                incomeReport
                
                bestPlays
                
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
            
            Spacer()
            
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
            
            Spacer()
            
        }
        .font(.custom("Asap-Regular", size: 18, relativeTo: .body))
        .lineSpacing(2.5)
        .animation(nil, value: vm.myNewTimeline)
        .padding(30)
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 350)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
        
    }
    
    var bestPlays: some View {
        
        VStack (spacing: 30) {
            
            let bestLocation = vm.bestLocation(timeline: vm.myNewTimeline)
            let bestProfit = vm.bestProfit(timeline: vm.myNewTimeline)
            
            BestSessionView(profit: bestProfit, currency: viewModel.userCurrency)
            
            BestLocationView(location: bestLocation)
            
            exportButton

        }
        .animation(nil, value: vm.myNewTimeline)
        .padding(.top, 20)
        .padding(.bottom, 50)
        
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

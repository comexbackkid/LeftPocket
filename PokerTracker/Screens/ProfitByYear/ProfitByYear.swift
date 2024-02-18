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
        
        let newTimeline = vm.myNewTimeline
        let grossIncome = vm.grossIncome(timeline: vm.myNewTimeline)
        let netProfitTotal = vm.netProfitCalc(timeline: vm.myNewTimeline)
        let hourlyRate = vm.hourlyCalc(timeline: vm.myNewTimeline)
        let profitPerSession = vm.avgProfit(timeline: vm.myNewTimeline)
        let winRate = vm.winRate(timeline: vm.myNewTimeline)
        let totalExpenses = vm.expensesByYear(timeline: vm.myNewTimeline)
        let totalHours = vm.totalHours(timeline: vm.myNewTimeline)
        let totalSessions = vm.sessionsPerYear(timeline: vm.myNewTimeline)
        let bestLocation = vm.bestLocation(timeline: vm.myNewTimeline)
        let bestProfit = vm.bestProfit(timeline: vm.myNewTimeline)

        ScrollView {
            
            HStack {
                
                Text("Annual Report")
                    .titleStyle()
                    .padding(.top, -37)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            VStack {
                
                CustomChartView(viewModel: viewModel, data: vm.chartData(timeline: newTimeline), background: false)
                    .padding(.bottom)
                    .frame(height: 250)
                
                // MARK: DECIDING IF WE WANT TO ADD MORE CHARTS HERE
                
//                CustomChartView(viewModel: viewModel, data: viewModel.chartCoordinates(), background: false)
//                    .padding()
//                    .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
//                    .cornerRadius(20)
//                    .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
//                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 125)
//                
//                BarChartByYear(showTitle: false)
//                    .chartXAxis(.hidden)
//                    .chartYAxis(.hidden)
//                    .padding(30)
//                    .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
//                    .cornerRadius(20)
//                    .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
//                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 125)
                
                CustomPicker(vm: vm)
                    .padding(.bottom, 35)
                    .padding(.top)
                
                VStack (spacing: 12) {
                    
                    Spacer()
                    
                    HStack {
                        Text("Gross Income")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(grossIncome.asCurrency())").profitColor(total: grossIncome)
                    }
                    
                    HStack {
                        Text("Expenses")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(totalExpenses.asCurrency())")
                            .foregroundColor(totalExpenses > 0 ? .red : Color(.systemGray))
                    }
                    
                    HStack {
                        Text("Net Profit")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(netProfitTotal.asCurrency())").profitColor(total: netProfitTotal)
                    }
                    
                    Divider().padding(.vertical)
                    
                    HStack {
                        Text("Hourly Rate")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(hourlyRate.asCurrency())").profitColor(total: hourlyRate)
                    }
                    
                    HStack {
                        Text("Profit Per Session")
                            .bodyStyle()
                        
                        Spacer()
                        Text("\(profitPerSession.asCurrency())").profitColor(total: profitPerSession)
                    }
                    
                    HStack {
                        Text("Win Rate")
                            .bodyStyle()
                        
                        Spacer()
                        Text(winRate)
                    }
                    
                    HStack {
                        Text("No. of Sessions")
                            .bodyStyle()
                        
                        Spacer()
                        Text(totalSessions)
                    }
                    
                    HStack {
                        Text("Hours Played")
                            .bodyStyle()
                        
                        Spacer()
                        Text(totalHours)
                    }
                    
                    Spacer()
                    
                }
                .animation(nil, value: vm.myNewTimeline)
                .padding(30)
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 350)
                .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
                
                VStack (spacing: 30) {
                    
                    BestSessionView(profit: bestProfit)
                    
                    BestLocationView(location: bestLocation)
                    
                    exportButton

                }
                .animation(nil, value: vm.myNewTimeline)
                .padding(.top, 20)
                .padding(.bottom, 50)
                
                Spacer()
            }
            .padding(.bottom, 50)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
        }
        .background(Color.brandBackground)
        .accentColor(.brandPrimary)
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

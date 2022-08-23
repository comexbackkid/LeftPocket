//
//  StudyView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/3/22.
//

import SwiftUI

struct StudyView: View {
    
    @State var selectedArticle: Article?
    @State var showArticle: Bool = false
    @EnvironmentObject var vm: SessionsListViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let yearToDate: String = String(Calendar.current.component(.year, from: Date()))
    var profit: Int { return vm.bankrollByYear(year: yearToDate) }
    var hourly: Int { return vm.hourlyByYear(year: yearToDate) }
    var games: Int { return vm.sessionsPerYear(year: yearToDate) }
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack (spacing: 20) {

                    header
                    
                    articles
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .sheet(isPresented: $showArticle) {
                    StudyDetailView(selectedArticle: $selectedArticle)
                }
            }
            .background(Color(.systemGray6))
            .navigationBarTitle(Text("Study & Leaks"))
        }
    }
    
    var header: some View {
        
        VStack (alignment: .leading) {
            
            Text("Keep at it! Studying and reviewing your play is one of the best ways you can stay at the top of your game.")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.bottom, 15)
            
            Text("YTD Progress")
                .font(.title2)
                .bold()
            
            VStack {
                
                HStack {
                    VStack (alignment: .leading) {
                        
                        Text("Profit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(profit.accountingStyle())")
                            .bold()
                            .font(.title2)
                            .profitColor(total: profit)
                    }
                    
                    Spacer()
                    
                    VStack (alignment: .leading) {
                        
                        Text("Hourly")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(hourly.accountingStyle())")
                            .bold()
                            .font(.title2)
                            .profitColor(total: profit)
                    }
                    
                    Spacer()
                    
                    VStack (alignment: .leading) {
                        
                        Text("Sessions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(games)")
                            .bold()
                            .font(.title2)
                            .foregroundColor(games == 0 ? Color(.systemGray) : .primary)
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.3),
                    radius: 12, x: 0, y: 5)
            
            Text("Study Tips")
                .font(.title2)
                .bold()
                .padding(.top)
        }
        .padding(.horizontal)
    }
    
    var articles: some View {
        VStack (spacing: 20) {
            
            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                selectedArticle = MockData.sampleArticle
                showArticle.toggle()
            } label: {
                StudyCardView(article: MockData.sampleArticle)
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                selectedArticle = MockData.sampleArticle2
                showArticle.toggle()
            } label: {
                StudyCardView(article: MockData.sampleArticle2)
            }
            .buttonStyle(PlainButtonStyle())

            Button {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                selectedArticle = MockData.sampleArticle3
                showArticle.toggle()
            } label: {
                StudyCardView(article: MockData.sampleArticle3)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
            .preferredColorScheme(.dark)
            .environmentObject(SessionsListViewModel())
    }
}

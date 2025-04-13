//
//  MetricsView.additionalMetrics.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/13/25.
//

import SwiftUI

extension MetricsView {
    
    struct AdditionalMetricsView: View {
        
        @Environment(\.colorScheme) var colorScheme
        @EnvironmentObject var viewModel: SessionsListViewModel
        @EnvironmentObject var subManager: SubscriptionManager
        @State private var showPaywall = false
        @AppStorage("showReportsAsList") private var showReportsAsList = false
        
        var body: some View {
            
            VStack (alignment: .leading) {
                
                HStack (alignment: .lastTextBaseline) {
                    Text("My Reports")
                        .font(.custom("Asap-Black", size: 34))
                        .bold()
                        .padding(.horizontal)
                        .padding(.top)
                    
                    HStack (spacing: 0) {
                        Button {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            showReportsAsList.toggle()
                            
                        } label: {
                            Image(systemName: showReportsAsList ? "rectangle" : "list.bullet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .fontWeight(.bold)
                                .frame(height: 18)
                                
                        }
                        .tint(.brandPrimary)
                        
                        Text(" ›")
                            .bodyStyle()
                            .foregroundStyle(Color.brandPrimary)
                    }
                    
                    Spacer()
                }
                
                if showReportsAsList {
                    VStack (alignment: .leading, spacing: 8) {
                        HStack (spacing: 0) {
                            Text("View your ")
                                .bodyStyle()
                            
                            NavigationLink {
                                ProfitByYear()
                            } label: {
                                Text("__Annual Report__ \(Image(systemName: "arrow.turn.up.right"))")
                                    .bodyStyle()
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .cornerRadius(12)

                        HStack(spacing: 0) {
                            Text("View your ")
                                .bodyStyle()
                            
                            NavigationLink {
                                SleepAnalytics(activeSheet: .constant(.none))
                            } label: {
                                Text("__Health Analytics__ \(Image(systemName: "arrow.turn.up.right"))")
                                    .bodyStyle()
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .cornerRadius(12)

                        HStack(spacing: 0) {
                            Text("View your ")
                                .bodyStyle()
                            
                            NavigationLink {
                                ProfitByMonth(vm: viewModel)
                            } label: {
                                Text("__Monthly Snapshot__ \(Image(systemName: "arrow.turn.up.right"))")
                                    .bodyStyle()
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .cornerRadius(12)

                        HStack(spacing: 0) {
                            Text("View your ")
                                .bodyStyle()
                            
                            NavigationLink {
                                AdvancedTournamentReport(vm: viewModel)
                            } label: {
                                Text("__Tournament Report__ \(Image(systemName: "arrow.turn.up.right"))")
                                    .bodyStyle()
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .cornerRadius(12)

                        HStack(spacing: 0) {
                            Text("View your ")
                                .bodyStyle()
                            
                            NavigationLink {
                                ProfitByLocationView(viewModel: viewModel)
                            } label: {
                                Text("__Location Statistics__ \(Image(systemName: "arrow.turn.up.right"))")
                                    .bodyStyle()
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .cornerRadius(12)

                        HStack(spacing: 0) {
                            Text("View your ")
                                .bodyStyle()
                            
                            NavigationLink {
                                ProfitByStakesView(viewModel: viewModel)
                            } label: {
                                Text("__Game Stakes__ \(Image(systemName: "arrow.turn.up.right"))")
                                    .bodyStyle()
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .cornerRadius(12)

                        HStack(spacing: 0) {
                            Text("View your ")
                                .bodyStyle()
                            
                            NavigationLink {
                                TagReport()
                            } label: {
                                Text("__Tags Report__ \(Image(systemName: "arrow.turn.up.right"))")
                                    .bodyStyle()
                            }
                            
                            Spacer()
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 20)
                    
                } else {
                    ScrollView(.horizontal, showsIndicators: false, content: {
                        HStack (spacing: 12) {
                            
                            NavigationLink(
                                destination: ProfitByYear(),
                                label: {
                                    AdditionalMetricsCardView(title: "Annual Report",
                                                              description: "Year-over-year results",
                                                              image: "list.clipboard.fill",
                                                              color: .donutChartDarkBlue)
                                })
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(
                                destination: SleepAnalytics(activeSheet: .constant(.none)),
                                label: {
                                    AdditionalMetricsCardView(title: "Health Analytics",
                                                              description: "Sleep & mindfulness",
                                                              image: "stethoscope",
                                                              color: .lightGreen)
                                    
                                })
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(
                                destination: ProfitByMonth(vm: viewModel),
                                label: {
                                    AdditionalMetricsCardView(title: "Monthly Snapshot",
                                                              description: "Results by month",
                                                              image: "calendar",
                                                              color: .donutChartGreen)
                                })
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(
                                destination: AdvancedTournamentReport(vm: viewModel),
                                label: {
                                    AdditionalMetricsCardView(title: "Tournaments",
                                                              description: "More tournament stats",
                                                              image: "person.2.fill",
                                                              color: .brandPrimary)
                                })
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(
                                destination: ProfitByLocationView(viewModel: viewModel),
                                label: {
                                    AdditionalMetricsCardView(title: "Location Report",
                                                              description: "Stats by location",
                                                              image: "mappin.and.ellipse",
                                                              color: .donutChartRed)
                                })
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(
                                destination: ProfitByStakesView(viewModel: viewModel),
                                label: {
                                    AdditionalMetricsCardView(title: "Game Stakes",
                                                              description: "Individual stakes stats",
                                                              image: "dollarsign.circle",
                                                              color: .donutChartPurple)
                                })
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(
                                destination: TagReport(),
                                label: {
                                    AdditionalMetricsCardView(title: "Tag Report",
                                                              description: "Generate report by Tags",
                                                              image: "tag.fill",
                                                              color: colorScheme == .dark ? .brandWhite : .gray)
                                })
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.leading)
                        .padding(.trailing)
                        .frame(height: 150)
                    })
                    .scrollTargetLayout()
                    .scrollTargetBehavior(.viewAligned)
                    .scrollBounceBehavior(.automatic)
                }
            }
        }
    }
}

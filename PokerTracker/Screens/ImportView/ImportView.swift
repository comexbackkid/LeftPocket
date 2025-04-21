//
//  ImportView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 2/5/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView (.vertical) {
                
                VStack {
                    
                    title
                    
                    bodyText
                    
                    navigationLinks
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.brandBackground)
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("Import Data")
                .titleStyle()
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
    
    var bodyText: some View {
        
        VStack (alignment: .leading) {
            
            Text("Choose from the list below. Each app handles their data differently, and you'll need to lightly modify the contents of their exported file before importing.")
                .bodyStyle()
        }
        .padding(.horizontal)
    }
    
    var navigationLinks: some View {
        
        VStack (spacing: 15) {
            
            NavigationLink {
                BinkPokerImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Bink Poker")
                                .bodyStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            NavigationLink {
                PokerBankrollTrackerImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Poker Bankroll Tracker")
                                .bodyStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            NavigationLink {
                PokerAnalyticsImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Poker Analytics")
                                .bodyStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            NavigationLink {
                PokerbaseImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Pokerbase")
                                .bodyStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Divider()
            
            NavigationLink {
                LeftPocketImportView()
            } label: {
                HStack {
                    VStack (alignment: .leading) {
                        HStack {
                            
                            Image(systemName: "tray.and.arrow.down.fill")
                                .frame(width: 20)
                                .fontWeight(.black)
                                .padding(.trailing, 5)
                                .foregroundColor(.secondary)
                            
                            Text("Left Pocket")
                                .bodyStyle()
                                .bold()
                            
                            Spacer()
                            
                            Text("›")
                                .font(.title2)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(25)
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.35 : 1.0))
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.top, 40)
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView()
            .preferredColorScheme(.dark)
    }
}

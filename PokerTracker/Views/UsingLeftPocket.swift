//
//  UsingLeftPocket.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/5/24.
//

import SwiftUI

struct UsingLeftPocket: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack {
                
                HStack {
                    Text("Using Left Pocket")
                        .titleStyle()
                        .padding(.top, -37)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Read through the following documentation to get the most out of Left Pocket, so that you can put the most into your’s.")
                        .bodyStyle()
                        .opacity(0.8)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    
                    Spacer()
                }
                
                VStack (spacing: 15) {
                    
                    NavigationLink {
                        LoggingSessionsDocumentation()
                    } label: {
                        HStack {
                            VStack (alignment: .leading) {
                                HStack {
                                    
                                    Image(systemName: "doc.text.fill")
                                        .frame(width: 20)
                                        .fontWeight(.black)
                                        .padding(.trailing, 5)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Logging Sessions")
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
                        BrowseAndFilterDocumentation()
                    } label: {
                        HStack {
                            VStack (alignment: .leading) {
                                HStack {
                                    
                                    Image(systemName: "doc.text.fill")
                                        .frame(width: 20)
                                        .fontWeight(.black)
                                        .padding(.trailing, 5)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Browse & Filter")
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
                        MetricsDocumentation()
                    } label: {
                        HStack {
                            VStack (alignment: .leading) {
                                HStack {
                                    
                                    Image(systemName: "doc.text.fill")
                                        .frame(width: 20)
                                        .fontWeight(.black)
                                        .padding(.trailing, 5)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Metrics")
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
                        ChartsDocumentation()
                    } label: {
                        HStack {
                            VStack (alignment: .leading) {
                                HStack {
                                    
                                    Image(systemName: "doc.text.fill")
                                        .frame(width: 20)
                                        .fontWeight(.black)
                                        .padding(.trailing, 5)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Charts")
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
                        ReportsDocumentation()
                    } label: {
                        HStack {
                            VStack (alignment: .leading) {
                                HStack {
                                    
                                    Image(systemName: "doc.text.fill")
                                        .frame(width: 20)
                                        .fontWeight(.black)
                                        .padding(.trailing, 5)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Reports")
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
                        WidgetsDocumentation()
                    } label: {
                        HStack {
                            VStack (alignment: .leading) {
                                HStack {
                                    
                                    Image(systemName: "doc.text.fill")
                                        .frame(width: 20)
                                        .fontWeight(.black)
                                        .padding(.trailing, 5)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Widgets")
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
                        LocationsDocumentation()
                    } label: {
                        HStack {
                            VStack (alignment: .leading) {
                                HStack {
                                    
                                    Image(systemName: "doc.text.fill")
                                        .frame(width: 20)
                                        .fontWeight(.black)
                                        .padding(.trailing, 5)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Custom Locations")
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
                .background(Color(.systemBackground).opacity(colorScheme == .dark ? 0.25 : 1.0))
                .cornerRadius(20)
                .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 5)
            }
        }
        .background(Color.brandBackground)
    }
}

struct LoggingSessionsDocumentation: View {
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("Logging Sessions")
                        .cardTitleStyle()
                        .padding(.top)
                        .padding(.bottom, 20)
                    
                    Spacer()
                }
                
                Text("Left Pocket allows you to log a completed poker session, or begin a new live session from any screen in the app.\n\nTo begin:")
                    .bodyStyle()
                    .padding(.bottom, 20)
                
                VStack (alignment: .leading, spacing: 25) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        
                        Text("Tap + hold the Plus button at the bottom of the navigation bar")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Choose Live or Completed Session")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("By default, a single tap will bring up the Add Completed Session screen")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "4.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Enter all of the details from your session, and optionally paste in or type any notes or hand history into the Notes field")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "5.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Tap Save Session")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    Text("If you need additional help, feel free to reach out to Support via email.")
                        .bodyStyle()
                }
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
    }
}

struct BrowseAndFilterDocumentation: View {
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("Browse & Filter")
                        .cardTitleStyle()
                        .padding(.top)
                        .padding(.bottom, 20)
                    
                    Spacer()
                }
                
                Text("After navigating to the Sessions List view, you will see all of your logged poker sessions, with the most recent at the top. \n\nTo start filtering:")
                    .bodyStyle()
                    .padding(.bottom, 20)
                
                VStack (alignment: .leading, spacing: 25) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("By default, every session is shown")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("In the top right, you'll see two menu buttons for filtering")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("You can filter your sessions by cash games, tournaments, as well as locations, with even more options on the way")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "4.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Tap a session to view its details")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "5.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("To delete a session, swipe left on it from the Sessions List view")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    Text("If you need additional help, feel free to reach out to Support via email.")
                        .bodyStyle()
                }
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
    }
}

struct MetricsDocumentation: View {
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("Metrics")
                        .cardTitleStyle()
                        .padding(.top)
                        .padding(.bottom, 20)
                    
                    Spacer()
                }
                
                Text("Left Pocket offers a variety of advanced metrics & analytics to help with your study and progress as a player. \n\nTo begin:")
                    .bodyStyle()
                    .padding(.bottom, 20)
                
                VStack (alignment: .leading, spacing: 25) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Tap the Metrics icon in the navigation bar")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Scroll down to view your bankroll chart, player stats, monthly progress, and at the bottom, the Reports & Analytics section")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Also on this screen is a progress indicator letting you know when it's safe to move up in stakes")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    Text("If you need additional help, feel free to reach out to Support via email.")
                        .bodyStyle()
                }
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
    }
}

struct ChartsDocumentation: View {
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("Charts")
                        .cardTitleStyle()
                        .padding(.top)
                        .padding(.bottom, 20)
                    
                    Spacer()
                }
                
                Text("You'll find charts and graphs throughout the app, most notably in the Dashboard view, the Metrics view, your Annual Report, and on the iOS Home Screen widget.")
                    .bodyStyle()
                    .padding(.bottom, 20)
                
                VStack (alignment: .leading, spacing: 25) {
                    
                    Text("**Chart Locations**\nFrom the Dashboard & Metrics view you can get a look at your bankroll progress as a line chart. In the Metrics view, you will also find a bar chart of your net profits by month. Additionally, there is a line chart in the Annual Report that can be filtered by year.")
                        .bodyStyle()
                    
                    Text("**Interactivity**\nIf you're on the latest version of iOS, all of the charts in Left Pocket are interactive. Simply tap + hold on the chart for an annotation with more detail to appear.")
                        .bodyStyle()
                  
                    Text("If you need additional help, feel free to reach out to Support via email.")
                        .bodyStyle()
                }
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
    }
}

struct ReportsDocumentation: View {
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("Reports")
                        .cardTitleStyle()
                        .padding(.top)
                        .padding(.bottom, 20)
                    
                    Spacer()
                }
                
                Text("There are numerous filtering and reporting options available which are free for all users. They can all be found at the bottom of the Metrics view, under the section titled, Reports & Analytics.\n\nTo gather reports:")
                    .bodyStyle()
                    .padding(.bottom, 20)
                
                VStack (alignment: .leading, spacing: 25) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Choose the report you want")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("You have access to detailed reports on an annual basis, monthly, by location, and by game stakes")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Pro users can export the Annual Report")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "4.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Open the Annual Report, and at the bottom click the Export Last Year's Results button. You will be able to save a CSV of your sessions from the previous year.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "5.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("All reports can be toggled to display hourly rate or total amount.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    Text("If you need additional help, feel free to reach out to Support via email.")
                        .bodyStyle()
                }
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
    }
}

struct WidgetsDocumentation: View {
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("Widgets")
                        .cardTitleStyle()
                        .padding(.top)
                        .padding(.bottom, 20)
                    
                    Spacer()
                }
                
                Text("Widgets are available to all users and come in two sizes for your Home Screen – small or medium. The Left Pocket widget provides a glance at your bankroll chart, total bankroll, hourly rate, and session count.\n\nTo activate widgets:")
                    .bodyStyle()
                    .padding(.bottom, 20)
                
                VStack (alignment: .leading, spacing: 25) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("From your iOS Home Screen, tap + hold anywhere on your wallpaper and tap the Plus button in the upper left")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Search for Left Pocket")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Choose either the small, or medium-sized widget")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "4.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Click the Add Widget button")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    Text("If you need additional help, feel free to reach out to Support via email.")
                        .bodyStyle()
                }
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
    }
}

struct LocationsDocumentation: View {
    
    var body: some View {
        
        ScrollView (.vertical) {
            
            VStack (alignment: .leading) {
                
                HStack {
                    Text("Custom Locations")
                        .cardTitleStyle()
                        .padding(.top)
                        .padding(.bottom, 20)
                    
                    Spacer()
                }
                
                Text("Six locations come pre-loaded onto Left Pocket by default, however you can easily add your own custom locations. Locations can be added from two different places.\n\nTo add a location:")
                    .bodyStyle()
                    .padding(.bottom, 20)
                
                VStack (alignment: .leading, spacing: 25) {
                    HStack {
                        Image(systemName: "1.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Go to Settings & tap Locations")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("In the upper right, tap the Plus button and enter the name of the location")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("You can also add an image from your iOS Photo Library")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "4.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Press the Save Location button")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    HStack {
                        Image(systemName: "5.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .top)
                            .foregroundColor(Color.brandPrimary)
                        
                        Text("Locations can also be added directly from the New Session screen, by tapping the location dropdown menu.")
                            .bodyStyle()
                            .padding(.leading, 6)
                    }
                    
                    Text("If you need additional help, feel free to reach out to Support via email.")
                        .bodyStyle()
                }
            }
            .padding(.horizontal)
        }
        .background(Color.brandBackground)
    }
}

#Preview {
    UsingLeftPocket()
        .preferredColorScheme(.dark)
    
}

#Preview {
    LoggingSessionsDocumentation()
        .preferredColorScheme(.dark)
}

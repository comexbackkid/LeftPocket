//
//  LiveSessionWidget.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/20/24.
//

import Foundation
import ActivityKit
import SwiftUI
import WidgetKit

struct LeftPocketLiveSessionTimer: Widget {
    
    @Environment(\.colorScheme) var colorScheme
    
    let kind: String = "LiveSessionTimer"
    
    var body: some WidgetConfiguration {
        
        ActivityConfiguration(for: LiveSessionWidgetAttributes.self) { context in
            LiveSessionTimerView(state: context.state)
            
        } dynamicIsland: { context in
            DynamicIsland {
                expandedContent(contentState: context.state, isStale: context.isStale)
                
            } compactLeading: {
                
                Image(systemName: "timer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                    .bold()
                    .foregroundColor(.brandPrimary)

            } compactTrailing: {
                
                Image("logo-tiny")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 25)
                
            } minimal: {
                Image("logo-tiny")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 25)
            }
        }
    }
    
    @DynamicIslandExpandedContentBuilder
    private func expandedContent(contentState: LiveSessionWidgetAttributes.ContentState, isStale: Bool) -> DynamicIslandExpandedContent<some View> {
        
        // LEADING
        DynamicIslandExpandedRegion(.leading) {
            VStack {
//                Spacer()
                Image(systemName: "timer")
                    .resizable()
                    .foregroundStyle(Color.lightGreen)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
        }
        
        // TRAILING
        DynamicIslandExpandedRegion(.trailing) {
            VStack {
//                Spacer()
                Image("logo-tiny")
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            }
        }
        
        // CENTER
        DynamicIslandExpandedRegion(.center) {
            VStack {
                Text("Left Pocket")
                    .lineLimit(1)
                    .font(.custom("Asap-Bold", size: 32))
                    
                Text("Live Session started at")
                    .font(.custom("Asap-Regular", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text("\(contentState.startTime.formatted(date: .omitted, time: .shortened))")
                    .font(.custom("Asap-Regular", size: 16))
                    .bold()
                    .opacity(0.75)
            }
            .dynamicTypeSize(...DynamicTypeSize.large)
            .dynamicIsland(verticalPlacement: .belowIfTooWide)
        }

        // BOTTOM
//        DynamicIslandExpandedRegion(.bottom) {
//            
//            VStack (alignment: .leading) {
//                Spacer()
//                HStack {
//                    Text(contentState.startTime, style: .relative)
//                        .lineLimit(1)
//                        .font(.custom("Asap-Regular", size: 24))
//                }
//            }
//            .dynamicTypeSize(...DynamicTypeSize.large)
//            .padding(.bottom, 3)
//        }
    }
}

struct LiveSessionTimerView: View {
    
    @Environment(\.colorScheme) var colorScheme
    let state: LiveSessionWidgetAttributes.ContentState
    
    var body: some View {
        
        ZStack {
            
            backgroundGradient
            
            HStack {

                VStack (alignment: .leading, spacing: 1) {
                    
                    Text("\(state.startTime.formatted(date: .omitted, time: .shortened))")
                        .font(.custom("Asap-Bold", size: 23, relativeTo: .subheadline))
                    
                    Text("Session Start")
                        .opacity(0.5)
                        .font(.custom("Asap-Regular", size: 13, relativeTo: .caption))
                        .padding(.bottom, 6)
                    
                    Text(state.startTime, style: .relative)
                        .font(.custom("Asap-Bold", size: 20, relativeTo: .title2))
                        .monospacedDigit()
                    
                    Text("Total Elapsed Time")
                        .opacity(0.5)
                        .font(.custom("Asap-Regular", size: 13, relativeTo: .caption))
                }
                
                Image("logo-tiny")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 18, style: .circular))
                    .frame(width: 90)
            }
            .foregroundColor(.white)
            .padding()
            
//            HStack {
//
//                VStack (alignment: .leading, spacing: 1) {
//                    
//                    Text("Left Pocket")
//                        .font(.custom("Asap-Bold", size: 22, relativeTo: .subheadline))
//                    
//                    
//                    Text("Session started " + "\(state.startTime.formatted(date: .omitted, time: .shortened))")
//                        .opacity(0.5)
//                        .font(.custom("Asap-Regular", size: 16, relativeTo: .caption))
//                        .padding(.bottom, 6)
//                    
//                    Text(state.startTime, style: .relative)
//                        .font(.custom("Asap-Bold", size: 20, relativeTo: .title2))
//                        .monospacedDigit()
//                    
//                    Text("Since you sat down")
//                        .opacity(0.5)
//                        .font(.custom("Asap-Regular", size: 12, relativeTo: .caption))
//                        .padding(.bottom, 6)
//                }
//                
//                Image("logo-tiny")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .clipShape(.rect(cornerRadius: 18, style: .circular))
//                    .frame(width: 90)
//            }
//            .foregroundColor(.white)
//            .padding()
        }
    }
    
    var backgroundGradient: some View {
        Color("widgetBackground")
            .overlay(LinearGradient(colors: [colorScheme == .light ? .clear
                                             : .black.opacity(0.2), colorScheme == .light ? .black.opacity(0.6)
                                             : .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

struct LocationActivityView_Previews: PreviewProvider {
    
    static var previews: some View {
        LiveSessionWidgetAttributes(eventDescription: "Live Session")
//            .previewContext(LiveSessionWidgetAttributes.ContentState(startTime: Date(), elapsedTime: "00:55"), viewKind: .dynamicIsland(.expanded))
            .previewContext(LiveSessionWidgetAttributes.ContentState(startTime: Date(), elapsedTime: "00:55"), viewKind: .content)
    }
}

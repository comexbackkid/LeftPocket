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
//    private func expandedContent(contentState: LiveSessionWidgetAttributes.ContentState, isStale: Bool) -> DynamicIslandExpandedContent<some View> {
//        
//        // Account for the different Region sizes here
//        DynamicIslandExpandedRegion(.leading, priority: 1) {
//            VStack (alignment: .leading) {
//
//                Text(contentState.startTime, style: .relative)
//                    .lineLimit(1)
//                    .font(.custom("Asap-Bold", size: 25, relativeTo: .title2))
//
//                
//                Text("Playing at Encore Boston Harbor")
//                    .font(.custom("Asap-Regular", size: 15, relativeTo: .caption))
//                    .foregroundColor(.secondary)
//                    
//            }
//            .dynamicIsland(verticalPlacement: .belowIfTooWide)
//            .padding(.leading, 5)
//        }
//
//        
//        
//        
//        DynamicIslandExpandedRegion(.trailing) {
////            HStack {
////                Image("logo-tiny")
////                    .resizable()
////                    .clipShape(Circle())
////                    .aspectRatio(contentMode: .fit)
////                    .frame(width: 80, height: 80)
////                
////            }
//        }
//        
////        DynamicIslandExpandedRegion(.center) {
////            Text("Left Pocket")
////                .lineLimit(1)
////                .font(.custom("Asap-Regular", size: 18))
////                .dynamicIsland(verticalPlacement: .belowIfTooWide)
////                
////        }
//        
//        
//        
//        
////        DynamicIslandExpandedRegion(.bottom) {
////            
////            VStack (alignment: .leading) {
////                
////                HStack {
////                    
////                    Text(contentState.startTime, style: .relative)
////                        .lineLimit(1)
////                        .font(.custom("Asap-Bold", size: 25, relativeTo: .title2))
////                }
////                
////                Text("Playing at Encore Boston Harbor")
////                    .font(.custom("Asap-Regular", size: 15, relativeTo: .caption))
////                    .foregroundColor(.secondary)
////                    
////            }
////            .dynamicIsland(verticalPlacement: .belowIfTooWide)
////            .padding(.leading, 5)
////        }
//    }
    
    private func expandedContent(contentState: LiveSessionWidgetAttributes.ContentState, isStale: Bool) -> DynamicIslandExpandedContent<some View> {
        
        // Account for the different Region sizes here
        DynamicIslandExpandedRegion(.leading) {
            VStack (alignment: .leading) {
                
                Text("Live Session")
                    .font(.custom("Asap-Regular", size: 13, relativeTo: .caption))
                    .foregroundColor(.secondary)
                
                Text(contentState.startTime, style: .timer)
                    .lineLimit(1)
                    .font(.custom("Asap-Bold", size: 28, relativeTo: .title))
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)
            }
            .frame(maxHeight: 50)
            .padding(.leading, 5)
        }
        
        DynamicIslandExpandedRegion(.trailing) {
            HStack {
                Image("logo-tiny")
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
        }
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
                    
                    Text("Left Pocket")
                        .font(.custom("Asap-Bold", size: 22, relativeTo: .subheadline))
                    
                    
                    Text("Session Started " + "\(state.startTime.formatted(date: .omitted, time: .shortened))")
                        .opacity(0.5)
                        .font(.custom("Asap-Regular", size: 13, relativeTo: .caption))
                        .padding(.bottom, 6)
                    
                    Text(state.startTime, style: .relative)
                        .font(.custom("Asap-Bold", size: 22, relativeTo: .title2))
                        .monospacedDigit()
                }
                
                Image("logo-tiny")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
                    .frame(width: 75)
            }
            .foregroundColor(.white)
            .padding()
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

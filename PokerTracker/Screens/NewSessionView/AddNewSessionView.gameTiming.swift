//
//  AddNewSessionView.gameTiming.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/10/25.
//

import SwiftUI

extension AddNewSessionView {
    
    var gameTiming: some View {
        
        VStack {
            
            // MARK: DATE PICKER
            ForEach(newSession.times.indices, id: \.self) { index in
                let disabled = index < (newSession.tournamentDays - 1 ) || newSession.noMoreDays
                VStack {
                    
                    if newSession.multiDayToggle && index == 0 {
                        TournamentDayHeaderView(dayNumber: 1)
                    }
                    
                    else if index > 0 {
                        TournamentDayHeaderView(dayNumber: index + 1)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(.systemGray3))
                            .frame(width: 30)
                        
                        let range: ClosedRange<Date> = (index > 0) ? newSession.times[index - 1].end...Date.now : Date.distantPast...Date.now
                        DatePicker("Start", selection: $newSession.times[index].start, in: range, displayedComponents: [.date, .hourAndMinute])
                    }
                    .padding(.bottom, 10)
                    
                    HStack {
                        Image(systemName: "hourglass.tophalf.filled")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(.systemGray3))
                            .frame(width: 30)
                        
                        DatePicker("End", selection: $newSession.times[index].end, in: newSession.times[index].start...Date.now, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                .padding(.leading, 4)
                .accentColor(.brandPrimary)
                .font(.custom("Asap-Regular", size: 18))
                .datePickerStyle(.compact)
                .disabled(disabled)
                .opacity(disabled ? 0.5 : 1)
                .transition(.asymmetric(insertion: .scale(scale: 0.2, anchor: .top), removal: .opacity.combined(with: .scale(scale: 0.0, anchor: .top))))
            }
            
            // MARK: CONTROL BUTTONS
            if newSession.multiDayToggle {
                HStack {
                    Rectangle().frame(height: 0.75)
                        .opacity(0.1)
                    
                    Image(systemName: "x.square.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .fontWeight(.black)
                        .foregroundStyle(newSession.noMoreDays ? .gray : Color.red)
                        .opacity(newSession.noMoreDays ? 0.5 : 1)
                        .padding(.trailing)
                        .padding(.leading, newSession.tournamentDays > 1 ? 16 : -30)
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            withAnimation {
                                _ = newSession.times.removeLast()
                            }
                        }
                        .opacity(newSession.tournamentDays > 1 ? 1 : 0)
                        .animation(.snappy, value: newSession.tournamentDays)
                        .allowsHitTesting(newSession.noMoreDays ? false : true)
                    
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .fontWeight(.black)
                        .foregroundStyle(newSession.noMoreDays || newSession.tournamentDays == 8 ? .gray : Color.brandPrimary)
                        .opacity(newSession.noMoreDays || newSession.tournamentDays == 8 ? 0.5 : 1)
                        .padding(.horizontal)
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            if newSession.tournamentDays < 9 {
                                let lastEnd = newSession.times.last?.end ?? .now
                                let proposedStart = lastEnd
                                let now = Date()
                                let maxEnd = now
                                
                                // Validate the start isn't already in the future
                                guard proposedStart <= maxEnd else {
                                    newSession.alertItem = AlertContext.invalidTournamentDateSelection
                                    return
                                }
                                
                                // Propose a 2-hour interval, but clamp the end to now
                                let proposedEnd = min(proposedStart.addingTimeInterval(3600 * 2), now)
                                guard proposedEnd > proposedStart else {
                                    newSession.alertItem = AlertContext.invalidTournamentDateSelection
                                    return
                                }
                                
                                withAnimation {
                                    newSession.times.append(DateInterval(start: proposedStart, end: proposedEnd))
                                }
                            }
                        }
                        .allowsHitTesting(newSession.noMoreDays ? false : true)
                    
                    Image(systemName: newSession.noMoreDays ? "pencil.circle.fill" : "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .fontWeight(.black)
                        .foregroundStyle(newSession.noMoreDays ? Color.yellow : Color.green)
                        .padding(.leading)
                        .padding(.trailing, newSession.tournamentDays > 1 ? 16 : -30)
                        .onTapGesture {
                            let impact = UIImpactFeedbackGenerator(style: .soft)
                            impact.impactOccurred()
                            newSession.noMoreDays.toggle()
                        }
                        .opacity(newSession.tournamentDays > 1 ? 1 : 0)
                        .animation(.snappy, value: newSession.addDay)
                        .transition(.scale)
                        .symbolEffect(.bounce, value: newSession.noMoreDays)
                    
                    Rectangle().frame(height: 0.75)
                        .opacity(0.1)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .animation(.snappy, value: newSession.tournamentDays)
            }
        }
    }
}

struct TournamentDayHeaderView: View {
    let dayNumber: Int

    var body: some View {
        
        HStack {
            Rectangle().frame(height: 0.75)
                .opacity(0.1)
            
            Text("Day \(dayNumber)")
                .captionStyle()
                .fixedSize()
                .opacity(0.33)
                .padding(.horizontal)
            
            Rectangle().frame(height: 0.75)
                .opacity(0.1)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .transition(.scale)
    }
}

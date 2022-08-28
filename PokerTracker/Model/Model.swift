//
//  SessionModel.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/10/21.
//

import Foundation
import UIKit
import SwiftUI

struct PokerSession: Hashable, Codable, Identifiable {
    var id = UUID()
    let location: LocationModel
    let game: String
    let stakes: String
    let date: Date
    let profit: Int
    let notes: String
    let startTime: Date
    let endTime: Date
    let expenses: Int?
    
    var playingTIme: String {
        return sessionDuration.formattedDuration
    }
    
    // Individual session duration
    var sessionDuration: DateComponents {
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: self.startTime, to: self.endTime)
        return diffComponents
    }
    
    // Individual session hourly rate
    var hourlyRate: Int {
        let totalHours = sessionDuration.durationInHours == 0 ? 1 : sessionDuration.durationInHours
        return Int(Float(self.profit) / totalHours)
    }
}

struct Article: Hashable, Codable, Identifiable {
    var id = UUID()
    let image: String
    let title: String
    let snippet: String
    let story: String
}

// For some reason using the .currentWindow ext is not working with AppStorage and doesn't save dark/light mode state
class SystemThemeManager {
    static let shared = SystemThemeManager()
    init() {}
    
    func handleTheme(darkMode: Bool, system: Bool) {
        
        guard !system else {
//            UIApplication.shared.currentWindow?.overrideUserInterfaceStyle = .unspecified
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
            return
        }
        
//        UIApplication.shared.currentWindow?.overrideUserInterfaceStyle = darkMode ? .dark : .light
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkMode ? .dark : .light
    }
}

struct MockData {
    
    static let sampleArticle = Article(image: "variance-header",
                                       title: "Understanding Variance",
                                       snippet: "You must remember to not use variance as an excuse not to study, learn, and avoiding ways to improve your game.",
                                       story: """
"The risk of complaining about bad luck is that you tend to ignore your mistakes or the details of how you’re being outplayed."

Let that line resonate for a minute. For those that don’t know already, variance is the difference between how much money you expect to win on average over the long run and the results you are seeing in the short term. In other words, how unlucky OR how lucky you’re running. Variance is what causes long periods of winning sessions, as well as long periods of losing sessions.

There’s an inherit risk with looking too deep into variance, however.

You must remember to not use variance as an excuse not to study, learn, and avoiding ways to improve your game. It can become all too easy to simply chalk up a couple of losing sessions to variance and move on. Instead, what you should be doing after every game (good and bad) is reviewing what went right, and what went wrong.

Resources
The Mental Game of Poker, by: Jared Tendler, M.S.
""")
    
    static let sampleArticle2 = Article(image: "handhistory-header",
                                       title: "Hand Histories",
                                       snippet: "It is imperative for any poker player who takes the game seriously to record their hand histories.",
                                       story: """
It is imperative for any poker player who takes the game seriously to record their hand histories.

Obviously if you’re a live player, writing down every single hand is going to nearly impossible unless of course you’re some type of a vlogger or YouTube professional. For everyone else, the best recommendation is capture as many significant hands as you can. These might be spots that really made you think hard, or where a large sum of money was involved… heading in either direction.

Don’t only write down your losing hands.

Yes, those are important to study, but almost as important are your winning hands. It can be just as costly to continue playing sub-optimally as it is not knowing what to do in a spot. By thinking that you played a hand perfect when in fact you didn’t, you’re cementing in bad habits and forming unbiased views about your play.

Format your hand histories the same every time so they’re easy to read, especially if you post them on public forums. A clean, consistent format will usually result in more strategic feedback. A pen & paper is a little unrealistic to bring to a casino or card room, so we recommend a simple Notes app on your phone to simply jot down the key details.

Important things to document might include your effective stack size, position, bet amounts, pot sizes at each street, and how many players in the hand.

Hand analysis is the bread and butter of your off-table work, and repeating this quick method will undoubtedly make you a much stronger player. If you are serious about getting better at poker, I think you should analyze at least one hand every day to keep your skills sharp and your trajectory upward. In LeftPocket, there’s a handy Notes section with each recorded session where you can simply paste your hand histories in from your session to store them safely and to review at a later date.
""")
    
    static let sampleArticle3 = Article(image: "exploitplay-header",
                                       title: "Playing Exploitatively",
                                       snippet: "Exploitative strategies, when executed correctly and against the right opponent, make way more money.",
                                       story: """
Exploitative strategies, when executed correctly and against the right opponent, make way more money. Nowhere is this more true than at low stakes live where opponents are pretty transparent in their tendencies.

Below are a couple of quick adjustments you can make in your game to play a little less balanced, and more exploitative.

Change Your Opening Range

Do this based on either how tight or how loose players are around you. A good example might be low-mid suited connectors when you have calling stations behind you. Since they’re not folding pre flop, and you have no showdown value if you miss, you will have a truly difficult time getting them off any pairs, especially if they make top pair. Save your money and fold here.

Bet Sizing

If you know players in the big blind have a wide range and won’t 3-bet you often, feel free to up your raise higher knowing that you’re making more money in the long term by raising the cost of admission.

These players will happily defend hands like TJo, Ax, and 56-suited in horrible position. Get paid here.

Overfolding

Save this for those players who you know will never bluff the river. In live $1/2 and $1/3 games, this is most individuals. Occasionally you’ll come across a young reckless player who will 1x or 1.5x the pot on the river he senses weakness, but most of the time low stakes live players who bet the river, have it. You can save a lot of money by mucking second pairs and top pair + weak kicker in these spots.
""")
    
    static let mockLocation = LocationModel(name: "MGM Springfield", localImage: "mgmspringfield-header", imageURL: "")
    static let sampleSession = PokerSession(location: mockLocation,
                                            game: "NL Texas Hold Em",
                                            stakes: "1/3",
                                            date: Date().modifyDays(days: -7),
                                            profit: 863,
                                            notes: "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam. He tanks for a long time, asks if I’ll show, ultimately he lays it down. We find out he had TT. Did we play too aggressive?? MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                                            startTime: Date(),
                                            endTime: Date().modifyTime(minutes: 95),
                                            expenses: 10)
    
    static let allLocations = [
        LocationModel(name: "MGM Springfield", localImage: "mgmspringfield-header", imageURL: ""),
        LocationModel(name: "Encore Boston Harbor", localImage: "encore-header", imageURL: ""),
        LocationModel(name: "Boston Billiard Club", localImage: "boston-billiards-header", imageURL: ""),
        LocationModel(name: "The Brook", localImage: "brook-header", imageURL: ""),
        LocationModel(name: "Foxwoods Resort & Casino", localImage: "foxwoods-header", imageURL: ""),
        LocationModel(name: "Mohegan Sun Casino", localImage: "mohegan-sun-header", imageURL: ""),
        LocationModel(name: "Rivers Casino & Resort", localImage: "rivers-header", imageURL: "")
    ]
    
    static let allSessions = [
        PokerSession(location: allLocations[5],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -12),
                     profit: 325,
                     notes: "Hero is UTG so we raise to $15. MP player 3! to $45, everyone else folds. I flat, in this game there’s no 4! so it’s a dead giveaway in this game. ($93) Flop is 8d6c3d. Hero checks to Villain who bets $35. Hero raises to $100, Villain thinks for a few moments and then calls. ($293) Turn is a Js. We have $240 in our stack & Villain covers, we think for about 10 seconds and jam. He tanks for a long time, asks if I’ll show, ultimately he lays it down. We find out he had TT. Did we play too aggressive?? MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 115),
                     expenses: 0),

        PokerSession(location: allLocations[1],
                     game: "NL Texas Hold Em",
                     stakes: "1/3",
                     date: Date().modifyDays(days: -2),
                     profit: 225,
                     notes: "MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 95),
                     expenses: 7),

        PokerSession(location: allLocations[2],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -45),
                     profit: -1450,
                     notes: "Hero in CO, MP & LP limp I raise $15, Villain is on BTN (younger kid, stack around $550-$600) and he 3! to $45, we call. ($94) Flop is KsQh9h. I check, he bets $35, we call. ($160) Turn is Ac. I check again, Villain pauses a moment and puts in $100. We have about $320 left. Hero???",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 80),
                     expenses: 0),

        PokerSession(location: allLocations[3],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -1),
                     profit: 210,
                     notes: "MP limps, LJ limps, Hero on BTN makes it $15, they both call. ($48) Flop is KdKhTs. MP checks, LJ bets $10, I call, MP calls. ($78) Turn is Ac. MP checks, LJ checks, I bet $55 thinking they’re both super weak here. MP thinks for a moment and calls, LJ folds. ($188) River comes Qd. MP checks. Hero? We tank and ultimately check. MP is pissed and tables AK for a boat.",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 365),
                     expenses: 8),
        
        PokerSession(location: allLocations[0],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -36),
                     profit: -255,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 340),
                     expenses: 12),

        PokerSession(location: allLocations[0],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -90),
                     profit: 219,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 290),
                     expenses: 10),
        
        PokerSession(location: allLocations[4],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -4),
                     profit: 175,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 320),
                     expenses: 7),
        
        PokerSession(location: allLocations[3],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -400),
                     profit: 357,
                     notes: "Hero in CO, MP & LP limp I raise $15, Villain is on BTN (younger kid, stack around $550-$600) and he 3! to $45, we call. ($94) Flop is KsQh9h. I check, he bets $35, we call. ($160) Turn is Ac. I check again, Villain pauses a moment and puts in $100. We have about $320 left. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 320),
                     expenses: 7),
        
        PokerSession(location: allLocations[5],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -1000),
                     profit: 175,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 324),
                     expenses: 4),
        
        PokerSession(location: allLocations[6],
                     game: "NL Texas Hold Em",
                     stakes: "1/2",
                     date: Date().modifyDays(days: -1003),
                     profit: -100,
                     notes: "Two limpers, I raise to $12 from SB, BB folds, UTG+1 (primary villain) calls, BTN calls. ($38) Flop is QcTc4h. I check, everyone checks. Turn is a 9h. We check, UTG+1 checks, BTN bets $20. We call. UTG+1 raises to $80. BTN folds, we call. ($218) River is a 6h. I check, villain bets $140. Hero?",
                     startTime: Date(),
                     endTime: Date().modifyTime(minutes: 220),
                     expenses: 7),
    ]
    
    func chartArray() -> [Double] {
        let profitsArray = MockData.allSessions.map { Double($0.profit) }
        var cumBankroll = [Double]()
        var runningTotal = 0.0
        cumBankroll.append(0.0)
        
        for value in profitsArray.reversed() {
            runningTotal += value
            cumBankroll.append(runningTotal)
        }
        return cumBankroll
    }
    
    static let mockDataCoordinates: [Point] = [
        .init(x: 0, y: 5),
        .init(x: 1, y: -2),
        .init(x: 2, y: 10),
        .init(x: 3, y: 6),
        .init(x: 4, y: 9),
        .init(x: 5, y: 12),
        .init(x: 6, y: 14),
        .init(x: 7, y: 11)
    ]
    
//    static let mockDataCoordinates: [Point] = [
//        .init(x: 0, y: 5),
//        .init(x: 1, y: -2),
//        .init(x: 2, y: 10),
//        .init(x: 3, y: 6),
//        .init(x: 4, y: 9),
//        .init(x: 5, y: 12),
//        .init(x: 6, y: 14),
//        .init(x: 7, y: 11),
//    ]
}

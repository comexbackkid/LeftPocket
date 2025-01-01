//
//  MyGoals.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 9/26/24.
//

import SwiftUI

struct MyGoals: View {
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                title
                
                description
                
                GoalCell(goalTitle: "Study Habit",
                         goalSubtitle: "Read 6 hrs this month",
                         progress: 0.8,
                         image: "book")
                
                GoalCell(goalTitle: "Log Enough Hours",
                         goalSubtitle: "Play 40 hours this month",
                         progress: 0.2,
                         image: "pencil")
            }
        }
        .background(Color.brandBackground)
        .toolbar {
            Image(systemName: "plus")
                .foregroundStyle(Color.brandPrimary)
        }
    }
    
    var title: some View {
        
        HStack {
            
            Text("My Goals")
                .titleStyle()
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var description: some View {
        
        VStack (alignment: .leading, spacing: 20) {
            HStack {
                Text("Create your own goals or milestones for your poker journey. Measure & track progress here.")
                    .bodyStyle()
            }
        }
        .padding(.bottom, 25)
    }
}

struct GoalCell: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let goalTitle: String
    let goalSubtitle: String
    var progress: CGFloat
    let image: String
    
    var body: some View {
        
        VStack {
            
            HStack {
                VStack (alignment: .leading) {
                    Text(goalTitle)
                        .headlineStyle()
                    
                    Text(goalSubtitle)
                        .calloutStyle()
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack (alignment:.trailing) {
                    
                    Image(systemName: image)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary.opacity(0.7))
                    
                    Spacer()
                }
            }
            .padding(.bottom, 25)
            
            VStack {
                
                HStack {
                    
                    Text("0 hrs")
                    Spacer()
                    Text("6 hrs")
                }
                .font(.custom("Asap-Regular", size: 12, relativeTo: .caption2))
                
                CustomProgressView(progress: progress)
                    .padding(.bottom, 10)
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white)
        .cornerRadius(20)
        .shadow(color: colorScheme == .dark ? Color(.clear) : Color(.lightGray).opacity(0.25), radius: 12, x: 0, y: 0)
        .padding(.bottom)
    }
}

struct CustomProgressView: View {
    
    let progress: CGFloat
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .leading) {
                
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: geometry.size.width, height: 16)
                    .opacity(0.25)
                    .foregroundColor(.gray)
                
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: min(progress * geometry.size.width, geometry.size.width), height: 16)
                    .foregroundStyle(LinearGradient(gradient: .init(colors: [.teal, .mint]), startPoint: .leading, endPoint: .trailing))
            }
        }
    }
}

#Preview {
    NavigationView {
        MyGoals()
            .preferredColorScheme(.dark)
    }
}

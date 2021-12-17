//
//  HeaderView.swift
//  PokerTracker
//
//  Created by Christian Nachtrieb on 8/9/21.
//

import SwiftUI

struct HeaderView: View {
    
    @Binding var activeSheet: ActiveSheet?

    var body: some View {
        HStack {
//            Image("profile-pic")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 40, height: 40)
//                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
//            
//            VStack (alignment: .leading) {
//                Text("Hello,")
//                    .font(.caption)
//                    .opacity(0.6)
//                Text("Christian!")
//                    .bold()
//            }
            
            Spacer()
            
            Button(action: {
                activeSheet = .newSession
            }, label: {
                PlusButton()
            })
        }
        .padding()
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(activeSheet: .constant(.newSession))
    }
}

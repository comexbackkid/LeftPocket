//
//  ErrorView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 8/12/22.
//

import SwiftUI

struct FailureView: View {
    var body: some View {
        
        ZStack {
            Color("bgGray")
                .opacity(0.75)
            
            VStack {
                Image(systemName: "icloud.slash")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        FailureView()
    }
}

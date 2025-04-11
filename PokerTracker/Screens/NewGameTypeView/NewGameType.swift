//
//  NewGameType.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 3/30/25.
//

import SwiftUI

struct NewGameType: View {
    
    @EnvironmentObject var vm: SessionsListViewModel
    @Environment(\.dismiss) var dismiss
    @State private var gameTypeName: String = ""
    @State private var alertItem: AlertItem?
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            title
            
            Text("Enter your custom game type below and then tap the Save Game button.")
                .bodyStyle()
                .padding(.horizontal)
                .padding(.bottom, 30)
            
            textField
            
            buttons
            
            Spacer()
            
        }
        .background(Color.brandBackground)
        .dynamicTypeSize(.small...DynamicTypeSize.xLarge)
        .alert(item: $alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
    }
    
    var title: some View {
        
        HStack {
            Text("New Game Type")
                .titleStyle()
                .padding(.top, 30)
                .padding(.horizontal)
            
            Spacer()
        }
        
    }
   
    var textField: some View {
        
        HStack {
            Image(systemName: "dice")
                .fontWeight(.bold)
                .font(.headline).frame(width: 25)
                .foregroundColor(.secondary)
                .padding(.trailing, 10)
            
            TextField("Game Type", text: $gameTypeName)
                .font(.custom("Asap-Regular", size: 17))
        }
        .padding(18)
        .background(.gray.opacity(0.2))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
   
    var buttons: some View {
        
        VStack {
            Button {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()
                saveGameType()
                
            } label: {
                PrimaryButton(title: "Save Game")
            }
            .tint(Color.brandPrimary)
            
            Button(role: .cancel) {
                let impact = UIImpactFeedbackGenerator(style: .soft)
                impact.impactOccurred()
                dismiss()
                
            } label: {
                Text("Cancel")
                    .buttonTextStyle()
            }
            .tint(.red)
        }
        .padding(.horizontal)
    }
    
    private func saveGameType() {
        
        guard !gameTypeName.isEmpty else {
            alertItem = AlertContext.invalidCustomGame
            return
        }
        
        guard !vm.userGameTypes.contains(where: { name in
            name.lowercased() == gameTypeName.lowercased()
        }) else {
            alertItem = AlertContext.invalidCustomGameAlreadyExists
            return
        }
        
        vm.userGameTypes.append(gameTypeName.capitalized)
        dismiss()
    }
}

#Preview {
    NewGameType()
        .environmentObject(SessionsListViewModel())
        .preferredColorScheme(.dark)
}

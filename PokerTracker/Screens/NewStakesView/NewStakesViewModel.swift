//
//  NewStakesViewModel.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 4/17/24.
//

import Foundation

final class NewStakesViewModel: ObservableObject {
    
    @Published var smallBlind: String = "1"
    @Published var bigBlind: String = "2"
    @Published var presentation: Bool?
    @Published var alertItem: AlertItem?
    
    var stakeEntry: String {
        smallBlind + "/" + bigBlind
    }
    
    func saveStakes(viewModel: SessionsListViewModel, dismiss: () -> Void) {
        guard !viewModel.userStakes.contains(stakeEntry) else {
            alertItem = AlertContext.invalidCustomStakesAlreadyExists
            return
        }
        viewModel.addStakes(stakeEntry)
        dismiss()
    }
}

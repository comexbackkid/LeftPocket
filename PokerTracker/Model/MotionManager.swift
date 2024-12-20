//
//  MotionManager.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 10/30/24.
//

import Foundation
import CoreMotion
import Combine

class MotionMonitor: ObservableObject {
    
    private let motionManager = CMMotionManager()
    private var cancellable: AnyCancellable?
    
    @Published var pickupCount: Int = 0
    
    func startMonitoring() {
        
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.5
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else { return }
            
            // Detect significant movement suggesting a phone pickup
            if abs(motion.userAcceleration.x) > 0.75 || abs(motion.userAcceleration.y) > 0.75 || abs(motion.userAcceleration.z) > 0.75 {
                
                self.pickupCount += 1
                print("Pickup detected! Total pickups: \(self.pickupCount)")
            }
        }
    }
    
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
    }
}

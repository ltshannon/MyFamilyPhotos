//
//  SettingsService.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/24/25.
//

import Foundation
import SwiftUI

enum TimerInterval: Int, CaseIterable {
    case twoSeconds = 2
    case fiveSeconds = 5
    case tenSeconds = 10
}

class SettingsService: ObservableObject {
    static let shared = SettingsService()
    @Published var carouseAutomaticDisplay: Bool = false
    @AppStorage("carouseAutomaticDisplayState") var carouseAutomaticDisplayState: Bool = false
    @Published var timerInterval: TimerInterval = .fiveSeconds
    @AppStorage("timerInterval") var timerIntervalState: TimerInterval = .fiveSeconds
    @AppStorage("firstLaunch") var firstLaunch: Bool = true
    
    init() {
        self.carouseAutomaticDisplay = false
    }

    func toggleCarouseAutomaticDisplay() {
        carouseAutomaticDisplayState.toggle()
        carouseAutomaticDisplay = carouseAutomaticDisplayState
    }
    
    func setTimerInterval(timerInterval: TimerInterval) {
        timerIntervalState = timerInterval
        self.timerInterval = timerInterval
    }
    
}

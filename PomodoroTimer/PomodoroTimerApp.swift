//
//  PomodoroTimerApp.swift
//  PomodoroTimer
//
//  Created by Mc Cauley Bacalla on 12/18/25.
//

import SwiftUI

@main
struct PomodoroTimerApp: App {
    @StateObject private var timerManager = TimerManager()
    
    var body: some Scene {
        MenuBarExtra(timerManager.menuBarText, systemImage: "timer") {
            ContentView()
                .environmentObject(timerManager)
        }
        .menuBarExtraStyle(.window)
    }
}

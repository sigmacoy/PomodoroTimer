//
//  ContentView.swift
//  PomodoroTimer
//
//  Created by Mc Cauley Bacalla on 12/18/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Mode indicator
            HStack {
                Text(timerManager.currentMode == .work ? "WORK TIME" : "BREAK TIME")
                    .font(.headline)
                    .foregroundColor(timerManager.currentMode == .work ? .green : .blue)
                
                Spacer()
                
                Text(timerManager.menuBarText)
                    .font(.title2)
                    .monospacedDigit()
            }
            .padding(.horizontal)
            
            Divider()
            
            // Timer display
            Text(timeString(from: timerManager.currentTimeRemaining))
                .font(.system(size: 48, weight: .bold))
                .monospacedDigit()
                .foregroundColor(timerManager.currentMode == .work ? .green : .blue)
            
            // Buttons
            HStack(spacing: 15) {
                Button(timerManager.isRunning ? "⏸ Pause" : "▶️ Start") {
                    if timerManager.isRunning {
                        timerManager.stop()
                    } else {
                        timerManager.start()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("⏹ Reset") {
                    timerManager.reset()
                }
                .buttonStyle(.bordered)
            }
            
            Divider()
            
            // Time settings
            VStack(spacing: 15) {
                HStack {
                    Text("Work Time:")
                    Picker("", selection: Binding(
                        get: { timerManager.workTime / 60 },
                        set: { timerManager.setWorkTime(minutes: $0) }
                    )) {
                        ForEach([15, 20, 25, 30, 45], id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("Break Time:")
                    Picker("", selection: Binding(
                        get: { timerManager.breakTime / 60 },
                        set: { timerManager.setBreakTime(minutes: $0) }
                    )) {
                        ForEach([1, 5, 10, 15], id: \.self) { minutes in
                            Text("\(minutes) min").tag(minutes)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            Divider()
            
            // Quick action
            Button("🔁 Switch to \(timerManager.currentMode == .work ? "Break" : "Work")") {
                timerManager.switchMode()
            }
            
            // Quit
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .foregroundColor(.red)
            .padding(.top)
        }
        .padding()
        .frame(width: 320)
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

//
//  TimeManager.swift
//  PomodoroTimer
//
//  Created by Mc Cauley Bacalla on 12/18/25.
//

import Foundation

class TimerManager: ObservableObject {
    enum TimerMode {
        case work
        case breakTime
    }
    
    @Published var currentMode: TimerMode = .work
    @Published var workTime = 25 * 60
    @Published var breakTime = 5 * 60
    @Published var isRunning = false
    @Published var currentTimeRemaining: Int = 25 * 60
    
    private var timer: Timer?
    
    init() {
        currentTimeRemaining = workTime
    }
    
    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.currentTimeRemaining > 0 {
                self.currentTimeRemaining -= 1
            } else {
                self.switchMode()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func switchMode() {
        stop()
        
        if currentMode == .work {
            currentMode = .breakTime
            currentTimeRemaining = breakTime
            // Notify: Break time
            sendNotification(title: "Break Time!", message: "5 minutes rest")
        } else {
            currentMode = .work
            currentTimeRemaining = workTime
            // Notify: Work time
            sendNotification(title: "Work Time!", message: "25 minutes focus")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.start()
        }
    }
    
    func reset() {
        stop()
        currentMode = .work
        currentTimeRemaining = workTime
    }
    
    func setWorkTime(minutes: Int) {
        workTime = minutes * 60
        if currentMode == .work && !isRunning {
            currentTimeRemaining = workTime
        }
    }
    
    func setBreakTime(minutes: Int) {
        breakTime = minutes * 60
        if currentMode == .breakTime && !isRunning {
            currentTimeRemaining = breakTime
        }
    }
    
    private func sendNotification(title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    var menuBarText: String {
        let modeSymbol = currentMode == .work ? "👨‍💻" : "☕️"
        let minutes = currentTimeRemaining / 60
        let seconds = currentTimeRemaining % 60
        return "\(modeSymbol) \(String(format: "%02d:%02d", minutes, seconds))"
    }
}

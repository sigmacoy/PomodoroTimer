import SwiftUI
import UserNotifications

@main
struct PomodoroTimerApp: App {
    @StateObject private var timerManager = TimerManager()
    
//    init() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
//            if granted { print("Notification permission granted") }
//        }
//    }
    
    var body: some Scene {
        MenuBarExtra(timerManager.menuBarText) {
            ContentView()
                .environmentObject(timerManager)
        }
        .menuBarExtraStyle(.window)
    }
}

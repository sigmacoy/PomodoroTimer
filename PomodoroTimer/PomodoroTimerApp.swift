import SwiftUI
import UserNotifications
import Cocoa

// App Delegate to handle startup
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide Dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted { print("Notification permission granted") }
        }
    }
}

@main
struct PomodoroTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var timerManager = TimerManager()
    
    var body: some Scene {
        MenuBarExtra(timerManager.menuBarText) {
            ContentView()
                .environmentObject(timerManager)
        }
        .menuBarExtraStyle(.window)
    }
}

import SwiftUI
import UserNotifications
import Cocoa

// App Delegate to handle startup and notifications
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide Dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Set delegate to handle notification clicks
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted { print("Notification permission granted") }
        }
        
        // Observe activation changes and force accessory mode
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
    // Prevent app from activating when notification is clicked
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        return false
    }
    
    // Handle notification click - prevent app from showing
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // User clicked the notification - do nothing, don't activate app
        NSApp.setActivationPolicy(.accessory)
        
        // Don't activate the app
        NSApp.deactivate()
        
        completionHandler()
    }
    
    // This handles when notification is shown while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is "active" (menu bar)
        completionHandler([.banner, .sound])
        
        // Ensure dock stays hidden
        NSApp.setActivationPolicy(.accessory)
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

import Foundation
import UserNotifications
import Combine
import AVFoundation
import AppKit

class TimerManager: ObservableObject {
    enum TimerMode {
        case work
        case breakTime
    }
    
    @Published var currentMode: TimerMode = .work
    @Published var workTime: Int = 25 * 60
    @Published var breakTime: Int = 5 * 60
    @Published var isRunning: Bool = false
    @Published var elapsedSeconds: Int = 0
    private var audioPlayer: AVAudioPlayer?
    
    private var timer: AnyCancellable?
    
    var currentTimeRemaining: Int {
        let total = currentMode == .work ? workTime : breakTime
        return max(0, total - elapsedSeconds)
    }
    
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
//        print("Timer started. currentTimeRemaining: \(currentTimeRemaining)")
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedSeconds += 1
//                print("Tick! elapsedSeconds: \(self.elapsedSeconds), remaining: \(self.currentTimeRemaining)")
                
                if self.currentTimeRemaining <= 0 {
                    self.switchMode()
                }
            }
    }
    
    
    func stop() {
        timer?.cancel()
        timer = nil
        menuBarUpdateTimer?.cancel()  // Clean up menu bar timer
        menuBarUpdateTimer = nil
        isRunning = false
    }
    
    func switchMode() {
        stop()
        elapsedSeconds = 0
        
        currentMode = (currentMode == .work) ? .breakTime : .work
        sendNotification()
        start()
    }
    
    func reset() {
        stop()
        elapsedSeconds = 0
        currentMode = .work
    }
    
    func setWorkTime(minutes: Int) {
        workTime = minutes * 60
        if currentMode == .work { elapsedSeconds = 0 }
    }
    
    func setBreakTime(minutes: Int) {
        breakTime = minutes * 60
        if currentMode == .breakTime { elapsedSeconds = 0 }
    }
        
    private func sendNotification() {
        let title = currentMode == .work ? "Study Time!" : "Break Time!"
        let message = currentMode == .work ? "25 minutes focus" : "5 minutes rest"
        
        // Send macOS notification
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { _ in
            // Force hide dock icon after notification
            DispatchQueue.main.async {
                NSApp.setActivationPolicy(.accessory)
            }
        }
        
        // Play bell sound
        playBellSound()
    }

    private func playBellSound() {
        // Option A: If you added file to project (not Assets.xcassets)
        guard let soundURL = Bundle.main.url(forResource: "bell", withExtension: "mp3") else {
            // Try with capital MP3
            guard let soundURL2 = Bundle.main.url(forResource: "bell", withExtension: "MP3") else {
                print("Could not find bell.mp3 in bundle")
                return
            }
            playURL(soundURL2)
            return
        }
        playURL(soundURL)
    }

    private func playURL(_ url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    var menuBarText: String {
        let minutes = currentTimeRemaining / 60
        let seconds = currentTimeRemaining % 60
        let text = String(format: "%02d:%02d", minutes, seconds)
//        print("menuBarText updating to: \(text)")
        return text
    }
    
    @Published var menuBarTimeString: String = "25:00"

    private func updateMenuBarText() {
        let minutes = currentTimeRemaining / 60
        let seconds = currentTimeRemaining % 60
        menuBarTimeString = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var menuBarUpdateTimer: AnyCancellable?

    func startMenuBarUpdates() {
        // Update menu bar text every 0.5 seconds for smoother display
        menuBarUpdateTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                // This will trigger the menu bar to update
                self.objectWillChange.send()
            }
    }
}

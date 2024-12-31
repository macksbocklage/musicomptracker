import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager = TimerManager()
    @State private var showingLogSheet = false
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(timerManager.formattedTime)
                .font(.system(size: 70, weight: .medium, design: .monospaced))
                .foregroundColor(.orange)
            
            Spacer()
            
            HStack(spacing: 60) {
                // Play/Pause Button
                Button(action: {
                    if timerManager.isRunning {
                        timerManager.pauseTimer()
                    } else {
                        timerManager.startTimer()
                    }
                }) {
                    Image(systemName: timerManager.isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.orange)
                }
                
                // Stop Button
                Button(action: {
                    timerManager.stopTimer()
                    showingLogSheet = true
                }) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingLogSheet) {
            LogSessionView(duration: timerManager.elapsedTime)
        }
    }
}

class TimerManager: ObservableObject {
    @Published private(set) var isRunning = false
    @Published private(set) var elapsedTime: TimeInterval = 0
    private var timer: Timer?
    private var lastStartTime: Date?
    private var accumulatedTime: TimeInterval = 0
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func startTimer() {
        isRunning = true
        lastStartTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if let startTime = self.lastStartTime {
                self.elapsedTime = self.accumulatedTime + Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        if let startTime = lastStartTime {
            accumulatedTime += Date().timeIntervalSince(startTime)
        }
        lastStartTime = nil
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Calculate final elapsed time before stopping
        if let startTime = lastStartTime {
            accumulatedTime += Date().timeIntervalSince(startTime)
            elapsedTime = accumulatedTime
        }
        
        // Reset for next session
        lastStartTime = nil
        accumulatedTime = 0
    }
} 
import SwiftUI

struct TimerView: View {
    @StateObject private var timerManager = TimerManager()
    @StateObject private var sessionManager = SessionManager.shared
    @State private var showingLogSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome, Max")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let latestSession = sessionManager.sessions.sorted(by: { $0.date > $1.date }).first {
                    VStack(spacing: 6) {
                        HStack {
                            Text("Latest Session")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(formatRelativeDate(latestSession.date))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 14) {
                            // Duration
                            VStack(spacing: 2) {
                                Text(formatDuration(latestSession.duration))
                                    .font(.callout)
                                    .foregroundColor(.orange)
                                Text("Duration")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 25)
                            
                            // Motivation
                            VStack(spacing: 2) {
                                Text("\(latestSession.motivationLevel)")
                                    .font(.callout)
                                    .foregroundColor(.orange)
                                Text("Motivation")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if !latestSession.name.isEmpty {
                                Divider()
                                    .frame(height: 25)
                                
                                // Session Name
                                VStack(spacing: 2) {
                                    Text(latestSession.name)
                                        .font(.callout)
                                        .foregroundColor(.orange)
                                        .lineLimit(1)
                                    Text("Name")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
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
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today, " + formatter.string(from: date)
        }
        
        if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Yesterday, " + formatter.string(from: date)
        }
        
        if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, h:mm a" // e.g., "Monday, 3:30 PM"
            return formatter.string(from: date)
        }
        
        // For older dates
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
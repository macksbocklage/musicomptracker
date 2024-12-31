import SwiftUI

struct TimerDisplayView: View {
    let isRecording: Bool
    let startTime: Date?
    @State private var timeElapsed: TimeInterval = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(timeString(from: timeElapsed))
            .font(.system(size: 54, weight: .bold, design: .monospaced))
            .foregroundColor(.orange)
            .onReceive(timer) { _ in
                if let start = startTime, isRecording {
                    timeElapsed = Date().timeIntervalSince(start)
                }
            }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 
import SwiftUI

struct TimerView: View {
    @State private var isRecording = false
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var showingLogSheet = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color("StudioDark")
                .ignoresSafeArea()
            
            VStack {
                // Timer Display
                Text(timeString(from: elapsedTime))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .padding(.vertical, 50)
                
                // Record Button
                Button(action: toggleRecording) {
                    Circle()
                        .fill(isRecording ? Color.red : Color.orange)
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: isRecording ? "stop.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 50))
                        )
                }
            }
        }
        .onReceive(timer) { _ in
            if isRecording, let start = startTime {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
        .sheet(isPresented: $showingLogSheet) {
            LogSessionView(duration: elapsedTime)
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            // Stop recording and show log sheet
            showingLogSheet = true
        } else {
            // Start recording
            startTime = Date()
            elapsedTime = 0
        }
        isRecording.toggle()
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 
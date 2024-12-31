import SwiftUI

struct LogSessionView: View {
    let duration: TimeInterval
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sessionManager = SessionManager.shared
    
    @State private var name = ""
    @State private var motivationLevel = 3
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Name") {
                    TextField("Enter session name", text: $name)
                }
                
                Section("Duration") {
                    Text(timeString(from: duration))
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                
                Section("Motivation Level") {
                    Picker("Motivation", selection: $motivationLevel) {
                        ForEach(1...5, id: \.self) { level in
                            Text("\(level)").tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Log Session")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    saveSession()
                    dismiss()
                }
            )
        }
    }
    
    private func saveSession() {
        let session = CompositionSession(
            name: name.isEmpty ? "Untitled Session" : name,
            duration: duration,
            motivationLevel: motivationLevel,
            notes: notes,
            date: Date()
        )
        sessionManager.addSession(session)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 
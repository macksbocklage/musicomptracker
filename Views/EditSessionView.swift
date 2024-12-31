import SwiftUI

struct EditSessionView: View {
    let session: CompositionSession
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sessionManager = SessionManager.shared
    
    @State private var motivationLevel: Int
    @State private var notes: String
    
    init(session: CompositionSession) {
        self.session = session
        _motivationLevel = State(initialValue: session.motivationLevel)
        _notes = State(initialValue: session.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Details") {
                    Text(timeString(from: session.duration))
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text(formatDate(session.date))
                        .foregroundColor(.secondary)
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
            .navigationTitle("Edit Session")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveChanges() }
            )
        }
    }
    
    private func saveChanges() {
        let updatedSession = CompositionSession(
            id: session.id,
            duration: session.duration,
            motivationLevel: motivationLevel,
            notes: notes,
            date: session.date
        )
        sessionManager.updateSession(updatedSession)
        dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
} 
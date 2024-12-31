import SwiftUI

struct EditSessionView: View {
    let session: CompositionSession
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sessionManager = SessionManager.shared
    
    @State private var name: String
    @State private var motivationLevel: Int
    @State private var notes: String
    @State private var sessionDate: Date
    @State private var hours: Int
    @State private var minutes: Int
    @State private var seconds: Int
    
    init(session: CompositionSession) {
        self.session = session
        _name = State(initialValue: session.name)
        _motivationLevel = State(initialValue: session.motivationLevel)
        _notes = State(initialValue: session.notes)
        _sessionDate = State(initialValue: session.date)
        
        // Initialize time components
        let totalSeconds = Int(session.duration)
        _hours = State(initialValue: totalSeconds / 3600)
        _minutes = State(initialValue: (totalSeconds % 3600) / 60)
        _seconds = State(initialValue: totalSeconds % 60)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Session Time") {
                    HStack {
                        // Hours Picker
                        Picker("", selection: $hours) {
                            ForEach(0..<24) { hour in
                                Text("\(hour)")
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 50)
                        .clipped()
                        Text("h")
                        
                        // Minutes Picker
                        Picker("", selection: $minutes) {
                            ForEach(0..<60) { minute in
                                Text("\(minute)")
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 50)
                        .clipped()
                        Text("m")
                        
                        // Seconds Picker
                        Picker("", selection: $seconds) {
                            ForEach(0..<60) { second in
                                Text("\(second)")
                                    .tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 50)
                        .clipped()
                        Text("s")
                    }
                    .padding(.vertical)
                }
                
                Section("Start Date & Time") {
                    DatePicker(
                        "Start Time",
                        selection: $sessionDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
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
        let totalDuration = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        
        let updatedSession = CompositionSession(
            id: session.id,
            name: name.isEmpty ? "Untitled Session" : name,
            duration: totalDuration,
            motivationLevel: motivationLevel,
            notes: notes,
            date: sessionDate
        )
        sessionManager.updateSession(updatedSession)
        dismiss()
    }
} 
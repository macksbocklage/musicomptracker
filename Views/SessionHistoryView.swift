import SwiftUI

struct SessionHistoryView: View {
    @StateObject private var sessionManager = SessionManager.shared
    @State private var sessionToEdit: CompositionSession?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sessionManager.sessions.sorted(by: { $0.date > $1.date })) { session in
                    SessionRowView(session: session)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            sessionToEdit = session
                        }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Session History")
            .sheet(item: $sessionToEdit) { session in
                EditSessionView(session: session)
            }
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let sortedSessions = sessionManager.sessions.sorted(by: { $0.date > $1.date })
        offsets.forEach { index in
            let session = sortedSessions[index]
            sessionManager.deleteSession(session)
        }
    }
}

struct SessionRowView: View {
    let session: CompositionSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.name)
                .font(.headline)
            
            Text(formatDate(session.date))
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(timeString(from: session.duration), systemImage: "clock")
                Spacer()
                Label("Motivation: \(session.motivationLevel)", systemImage: "bolt.fill")
            }
            .foregroundColor(.gray)
            
            if !session.notes.isEmpty {
                Text(session.notes)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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
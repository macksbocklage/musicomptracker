import SwiftUI
import UniformTypeIdentifiers

struct SessionHistoryView: View {
    @StateObject private var sessionManager = SessionManager.shared
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingImportAlert = false
    @State private var importedSessionCount = 0
    
    var body: some View {
        NavigationView {
            Group {
                if sessionManager.sessions.isEmpty {
                    Text("No sessions recorded yet")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(sessionManager.sessions.sorted(by: { $0.date > $1.date })) { session in
                            SessionRowView(session: session)
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle("Session History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingExporter = true }) {
                            Label("Export Sessions", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { showingImporter = true }) {
                            Label("Import Sessions", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .fileExporter(
                isPresented: $showingExporter,
                document: SessionsCSVFile(sessions: sessionManager.sessions),
                contentType: .commaSeparatedText,
                defaultFilename: "composition_sessions.csv"
            ) { result in
                if case .failure(let error) = result {
                    print("Export error: \(error.localizedDescription)")
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.commaSeparatedText]
            ) { result in
                switch result {
                case .success(let file):
                    if let content = try? String(contentsOf: file, encoding: .utf8) {
                        let importedSessions = CSVManager.importFromCSV(content)
                        importedSessionCount = importedSessions.count
                        importedSessions.forEach { sessionManager.addSession($0) }
                        showingImportAlert = true
                    }
                case .failure(let error):
                    print("Import error: \(error.localizedDescription)")
                }
            }
            .alert("Import Successful", isPresented: $showingImportAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Imported \(importedSessionCount) sessions.")
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

struct SessionsCSVFile: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    let sessions: [CompositionSession]
    
    init(sessions: [CompositionSession]) {
        self.sessions = sessions
    }
    
    init(configuration: ReadConfiguration) throws {
        sessions = []
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let csvString = CSVManager.exportToCSV(sessions: sessions)
        let data = csvString.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
} 
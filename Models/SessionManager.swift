import Foundation

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    @Published private(set) var sessions: [CompositionSession] = []
    
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "compositionSessions"
    
    private init() {
        loadSessions()
    }
    
    func addSession(_ session: CompositionSession) {
        sessions.append(session)
        saveSessions()
    }
    
    func updateSession(_ session: CompositionSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            saveSessions()
        }
    }
    
    func deleteSession(_ session: CompositionSession) {
        sessions.removeAll { $0.id == session.id }
        saveSessions()
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
    
    private func loadSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([CompositionSession].self, from: data) {
            sessions = decoded
        }
    }
} 
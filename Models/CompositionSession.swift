import Foundation

struct CompositionSession: Identifiable, Codable {
    let id: UUID
    var duration: TimeInterval
    var motivationLevel: Int // 1-5 scale
    var notes: String
    var date: Date
    
    init(id: UUID = UUID(), duration: TimeInterval = 0, motivationLevel: Int = 3, notes: String = "", date: Date = Date()) {
        self.id = id
        self.duration = duration
        self.motivationLevel = motivationLevel
        self.notes = notes
        self.date = date
    }
} 
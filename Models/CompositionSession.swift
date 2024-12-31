import Foundation

struct CompositionSession: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration: TimeInterval
    var motivationLevel: Int
    var notes: String
    var date: Date
    
    init(id: UUID = UUID(), name: String = "", duration: TimeInterval = 0, motivationLevel: Int = 3, notes: String = "", date: Date = Date()) {
        self.id = id
        self.name = name
        self.duration = duration
        self.motivationLevel = motivationLevel
        self.notes = notes
        self.date = date
    }
} 
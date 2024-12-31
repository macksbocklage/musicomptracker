import Foundation
import UniformTypeIdentifiers

class CSVManager {
    static func exportToCSV(sessions: [CompositionSession]) -> String {
        // CSV Header
        var csvString = "Name,Date,Duration,Motivation Level,Notes\n"
        
        // CSV Rows
        for session in sessions {
            let formattedDate = formatDate(session.date)
            let formattedDuration = formatDuration(session.duration)
            
            // Escape fields that might contain commas
            let escapedName = escapeCSVField(session.name)
            let escapedNotes = escapeCSVField(session.notes)
            
            let row = "\(escapedName),\(formattedDate),\(formattedDuration),\(session.motivationLevel),\(escapedNotes)\n"
            csvString.append(row)
        }
        
        return csvString
    }
    
    static func importFromCSV(_ csvString: String) -> [CompositionSession] {
        var sessions: [CompositionSession] = []
        let rows = csvString.components(separatedBy: "\n")
        
        // Skip header row and empty rows
        let dataRows = rows.dropFirst().filter { !$0.isEmpty }
        
        for row in dataRows {
            if let session = parseCSVRow(row) {
                sessions.append(session)
            }
        }
        
        return sessions
    }
    
    private static func parseCSVRow(_ row: String) -> CompositionSession? {
        let fields = row.components(separatedBy: ",")
        guard fields.count >= 5 else { return nil }
        
        let name = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
        guard let date = parseDate(fields[1]),
              let duration = parseDuration(fields[2]) else { return nil }
        
        let motivationLevel = Int(fields[3]) ?? 3
        let notes = fields[4].trimmingCharacters(in: .whitespacesAndNewlines)
        
        return CompositionSession(
            name: name,
            duration: duration,
            motivationLevel: motivationLevel,
            notes: notes,
            date: date
        )
    }
    
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private static func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: dateString)
    }
    
    private static func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return "\(hours):\(minutes):\(seconds)"
    }
    
    private static func parseDuration(_ durationString: String) -> TimeInterval? {
        let components = durationString.components(separatedBy: ":")
        guard components.count == 3,
              let hours = Int(components[0]),
              let minutes = Int(components[1]),
              let seconds = Int(components[2]) else { return nil }
        
        return TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }
    
    private static func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escapedField)\""
        }
        return field
    }
} 
import Foundation

/// Errors that can occur during chatbot operation
enum ChatbotError: Error {
    case foundationModelsNotAvailable
    case initializationFailed
    case responseFailed
}

/// Simple chatbot implementation exactly as specified in AiCoach.md
/// Uses Foundation Models for iOS 26+ local AI coaching
@available(iOS 26.0, *)
class SimpleChatbot {
    private let tagManager: TriggerTagManager
    
    init() throws {
        // Simple initialization - Foundation Models will be available in iOS 26
        self.tagManager = TriggerTagManager()
        
        // For now, check if Foundation Models is available
        // This will work when iOS 26 is released
        guard #available(iOS 26.0, *) else {
            throw ChatbotError.foundationModelsNotAvailable
        }
    }
    
    // Simple message processing
    func chat(_ message: String, tags: [StandardTriggerTag] = []) async -> String {
        let context = buildSimpleContext(tags: tags)
        
        // TODO: Replace with actual Foundation Models implementation when iOS 26 is released
        // For now, return a placeholder response
        if #available(iOS 26.0, *) {
            // This will use the real Foundation Models API when available
            return await generateMockResponse(message: message, context: context)
        } else {
            return "Foundation Models not available on this iOS version."
        }
    }
    
    private func generateMockResponse(message: String, context: String) async -> String {
        // Mock response for testing until iOS 26 Foundation Models are available
        let responses = [
            "I understand you're dealing with \(message.lowercased()). Remember, you've already made great progress in your quit journey!",
            "That's a common challenge. Take a deep breath and remember why you decided to quit smoking.",
            "You're doing great! Each craving you overcome makes you stronger. Try taking a walk or drinking some water.",
            "I'm here to support you. What specific strategies have helped you in the past when facing similar situations?"
        ]
        
        // Add a small delay to simulate AI processing
        try? await Task.sleep(for: .milliseconds(800))
        
        return responses.randomElement() ?? "I'm here to help you on your quit smoking journey."
    }
    
    private func buildSimpleContext(tags: [StandardTriggerTag]) -> String {
        // Build context from user's quit journey and selected tags
        let daysQuit = UserDataManager.shared.getDaysQuit()
        let cigarettesSaved = UserDataManager.shared.getCigarettesSaved()
        let currentTriggers = tags.map { $0.localizedName }.joined(separator: ", ")
        
        return """
        User is on day \(daysQuit) of quitting.
        Saved \(cigarettesSaved) cigarettes.
        Current situation: \(currentTriggers)
        Help them with practical, empathetic advice.
        """
    }
}

/// Trigger tag manager for chatbot context
class TriggerTagManager {
    func getRelevantTags(for message: String) -> [StandardTriggerTag] {
        // Simple keyword matching for auto-suggestion
        let lowercaseMessage = message.lowercased()
        var suggestedTags: [StandardTriggerTag] = []
        
        // Check for trigger keywords
        if lowercaseMessage.contains("work") || lowercaseMessage.contains("office") {
            suggestedTags.append(.work)
        }
        if lowercaseMessage.contains("stress") || lowercaseMessage.contains("anxious") {
            suggestedTags.append(.stress)
        }
        if lowercaseMessage.contains("coffee") || lowercaseMessage.contains("caffeine") {
            suggestedTags.append(.coffee)
        }
        if lowercaseMessage.contains("meal") || lowercaseMessage.contains("food") || lowercaseMessage.contains("eat") {
            suggestedTags.append(.afterMeal)
        }
        if lowercaseMessage.contains("drink") || lowercaseMessage.contains("alcohol") || lowercaseMessage.contains("bar") {
            suggestedTags.append(.alcohol)
        }
        
        return suggestedTags
    }
}

/// User data manager for chatbot context
class UserDataManager {
    static let shared = UserDataManager()
    
    private init() {}
    
    func getDaysQuit() -> Int {
        // TODO: Connect to actual user profile data
        // For now return a placeholder
        return 15
    }
    
    func getCigarettesSaved() -> Int {
        // TODO: Calculate from actual cigarette tracking
        // For now return a placeholder
        return 150
    }
}
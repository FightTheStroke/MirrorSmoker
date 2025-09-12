import SwiftUI

/// Simple Chatbot View exactly as specified in AiCoach.md
/// Features tag-based context and basic conversation memory
@available(iOS 26.0, *)
struct ChatbotView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var selectedTags: Set<StandardTriggerTag> = []
    @State private var isGenerating: Bool = false
    @State private var chatbot: SimpleChatbot?
    
    var body: some View {
        VStack(spacing: 0) {
            // Tag selector
            TagSelectorView(selectedTags: $selectedTags)
            
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if isGenerating {
                            TypingIndicator()
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input field
            HStack(spacing: 12) {
                TextField("Type message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(isGenerating)
                
                Button("Send") {
                    sendMessage()
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
            }
            .padding()
            .background(.regularMaterial)
        }
        .navigationTitle("AI Coach Chat")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await initializeChatbot()
            addWelcomeMessage()
        }
    }
    
    private func initializeChatbot() async {
        do {
            chatbot = try SimpleChatbot()
        } catch {
            // Handle chatbot initialization error
            let errorMessage = ChatMessage(
                text: "Sorry, AI Chat is not available right now. Please try again later.",
                isFromUser: false
            )
            messages.append(errorMessage)
        }
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            text: "Hi! I'm your AI Coach. How can I help you today? You can select tags below to give me context about your situation.",
            isFromUser: false
        )
        messages.append(welcomeMessage)
    }
    
    private func sendMessage() {
        let messageText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(text: messageText, isFromUser: true)
        messages.append(userMessage)
        
        // Clear input
        inputText = ""
        isGenerating = true
        
        // Generate AI response
        Task {
            await generateAIResponse(for: messageText)
        }
    }
    
    private func generateAIResponse(for message: String) async {
        guard let chatbot = chatbot else {
            await MainActor.run {
                let errorMessage = ChatMessage(
                    text: "Sorry, I'm not available right now.",
                    isFromUser: false
                )
                messages.append(errorMessage)
                isGenerating = false
            }
            return
        }
        
        do {
            let response = await chatbot.chat(message, tags: Array(selectedTags))
            
            await MainActor.run {
                let aiMessage = ChatMessage(text: response, isFromUser: false)
                messages.append(aiMessage)
                isGenerating = false
            }
            
        } catch {
            await MainActor.run {
                let errorMessage = ChatMessage(
                    text: "Sorry, I had trouble processing that. Please try again.",
                    isFromUser: false
                )
                messages.append(errorMessage)
                isGenerating = false
            }
        }
    }
}

// MARK: - Supporting Views

struct TagSelectorView: View {
    @Binding var selectedTags: Set<StandardTriggerTag>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current situation:")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(StandardTriggerTag.allCases, id: \.self) { tag in
                        TagButton(
                            tag: tag,
                            isSelected: selectedTags.contains(tag)
                        ) {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }
}

struct TagButton: View {
    let tag: StandardTriggerTag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(tag.emoji)
                    .font(.caption)
                Text(tag.localizedName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? .blue.opacity(0.2) : .gray.opacity(0.1))
            .foregroundColor(isSelected ? .blue : .primary)
            .clipShape(Capsule())
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(message.isFromUser ? .blue : .gray.opacity(0.1))
                    )
                    .foregroundColor(message.isFromUser ? .white : .primary)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity * 0.75, alignment: message.isFromUser ? .trailing : .leading)
            
            if !message.isFromUser {
                Spacer()
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text("AI Coach is thinking...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .frame(width: 4, height: 4)
                                .foregroundColor(.blue)
                                .scaleEffect(animating ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: animating
                                )
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.gray.opacity(0.1))
                )
            }
            
            Spacer()
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Data Models

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

// MARK: - Fallback View for older iOS

struct ChatbotFallbackView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "message.badge")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Text("AI Chat")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Upgrade to iOS 26 to chat with your AI Coach using Apple's Foundation Models")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }) {
                Text("Check for iOS Update")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        NavigationView {
            ChatbotView()
        }
    } else {
        NavigationView {
            ChatbotFallbackView()
        }
    }
}
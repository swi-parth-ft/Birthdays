//
//  WishView.swift
//  Birthdays
//
//  Created by Parth Antala on 8/9/24.
//

import SwiftUI
import SwiftData
import Combine

struct WishView: View {
    var contact: Contact
    
    @StateObject var questionsViewModel = QuestionsViewModel()
    @StateObject var chatGPTViewModel = ChatGPTViewModel()
    @State private var allQuestionsAnswered = false
    
    
    
    var body: some View {
        NavigationStack {
            ZStack{
                TimelineView(.animation) { timeline in
                    let x = (sin(timeline.date.timeIntervalSince1970) + 1) / 2

                    MeshGradient(width: 3, height: 3, points: [
                        [0, 0], [Float(x), 0], [1, 0],
                        [0, 0.5], [Float(x), 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ], colors: [
                        .black, .purple, .pink,
                        .black, .black, .black,
                        .black, .black, .black
                    ])
                }.ignoresSafeArea()
                VStack {
                    if !allQuestionsAnswered {
                        
                        QuestionsScreen(viewModel: questionsViewModel, allQuestionsAnswered: $allQuestionsAnswered)
                    } else {
                        WishesScreen(answers: questionsViewModel.answers, name: contact.name, number: contact.phoneNumber ?? nil)
                    }
                }
            }
            .navigationTitle(contact.name)
            .preferredColorScheme(.dark)
        }
    }
}

struct QuestionView: View {
    @State private var offset: CGFloat = UIScreen.main.bounds.width
    var question: String
    var answer: Binding<String>
    
    var body: some View {
        VStack(alignment: .center) {
            Text(question)
                .font(.title)
                .padding()
                .foregroundColor(.white)
            TextField("Your answer", text: answer)
                .padding()
                .tint(.purple)
        }
        .multilineTextAlignment(.center)
        
    }
}



class QuestionsViewModel: ObservableObject {
    @Published var questions: [String] = [
        
        "What is your relationship with this person? (e.g., friend, family, colleague)",
        "How old is this person turning?",
        "What are some of this person's hobbies or interests?",
        "Is there a specific memory or inside joke you share with this person?",
        "What is a quality or characteristic you admire about this person?",
        "Do you want the message to be funny, heartfelt, or formal?",
        "Is there anything specific you want to include in the birthday wish?"
    ]
    @Published var answers: [String] = ["", "", "", "", "", "", ""]
    @Published var currentQuestionIndex = 0
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
}


struct QuestionsScreen: View {
    @StateObject var viewModel = QuestionsViewModel()
    @Binding var allQuestionsAnswered: Bool
    
    var body: some View {
        VStack {
            if !allQuestionsAnswered {
                QuestionView(question: viewModel.questions[viewModel.currentQuestionIndex], answer: $viewModel.answers[viewModel.currentQuestionIndex])
                Button("Next") {
                    if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                        viewModel.nextQuestion()
                    } else {
                        allQuestionsAnswered = true
                    }
                }
                .padding()
                .background(.white.opacity(0.5))
                .cornerRadius(22)
                .tint(.white)
            } else {
                Text("All questions answered!")
                // Call API and show results here
            }
        }
        .padding()
    }
}

class ChatGPTViewModel: ObservableObject {
   
    @Published var wish: String = ""
    let key = Env.init().key
    func generateWish(answers: [String], size: Int, name: String) {
        let prompt = """
        I need to create a birthday wish for someone based on the following information:
        - Name: \(name)
        - Relationship: \(answers[0])
        - Age: \(answers[1])
        - Hobbies/Interests: \(answers[2])
        - Memory/Inside Joke: \(answers[3])
        - Admired Quality: \(answers[4])
        - Tone (funny, heartfelt, formal): \(answers[5])
        - Additional Details: \(answers[6])

        Please generate a birthday wish message in \(size) words using this information.
        """
        let apiKey = "\(key)"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 150 // Optional: Adjust as needed
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = responseDict["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.wish = content
                        
                    }
                }
            }
        }.resume()
    }
 
}

struct WishesScreen: View {

    var answers: [String]
    var name: String
    var number: String?
    @State private var size = 60
    @State private var isLoading = false
    let key = Env.init().key
    @State private var wish: String = ""
    
    var body: some View {
        VStack {
            if !isLoading {
                HStack {
                    Button("Smaller") {
                        size -= 30
                        generateWish(answers: answers, size: size, name: name)
                    }
                    .padding()
                    .frame(width: 100)
                    .background(.white.opacity(0.5))
                    .cornerRadius(22)
                    .foregroundColor(.white)
                    Button("Regerate", systemImage: "sparkles") {
                        generateWish(answers: answers, size: size, name: name)
                    }
                    .padding()
                    .frame(width: 130)
                    .background(.white.opacity(0.5))
                    .cornerRadius(22)
                    .foregroundColor(.white)
                    Button("Longer") {
                        size += 30
                        generateWish(answers: answers, size: size, name: name)
                    }
                    .padding()
                    .frame(width: 100)
                    .background(.white.opacity(0.5))
                    .cornerRadius(22)
                    .foregroundColor(.white)
                }
                Text("Tap message to copy")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.top)
                
                ScrollView {
                    Text(wish)
                        .lineLimit(nil) // Allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .onTapGesture {
                            UIPasteboard.general.string = wish
                        }
                    if number != nil {
                        Button("", systemImage: "message.fill") {
                            messagePhoneNumber(number!, withText: wish.description)
                        }
                    }
                }
            } else {
                GifImage("Animation")
            }
            
            
        }
        .onAppear {
            generateWish(answers: answers, size: size, name: name)
        }
    }
    
    func generateWish(answers: [String], size: Int, name: String) {
        
        isLoading = true
        let prompt = """
        I need to create a birthday wish for someone based on the following information:
        - Name: \(name)
        - Relationship: \(answers[0])
        - Age: \(answers[1])
        - Hobbies/Interests: \(answers[2])
        - Memory/Inside Joke: \(answers[3])
        - Admired Quality: \(answers[4])
        - Tone (funny, heartfelt, formal): \(answers[5])
        - Additional Details: \(answers[6])

        Please generate a birthday wish message in \(size) words using this information.
        """
        let apiKey = "\(key)"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 150 // Optional: Adjust as needed
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let responseDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = responseDict["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.wish = content
                        isLoading = false
                        
                    }
                }
            }
        }.resume()
    }
    
    func messagePhoneNumber(_ phoneNumber: String, withText text: String) {
        // Encode the text to be URL-safe
        
        let messageURLString = "sms:\(phoneNumber)&body=\(text)"
        
        if let messageURL = URL(string: messageURLString) {
            if UIApplication.shared.canOpenURL(messageURL) {
                UIApplication.shared.open(messageURL, options: [:], completionHandler: nil)
            } else {
                print("Cannot send a message on this device.")
            }
        } else {
            print("Invalid URL.")
        }
    }
    
    
}

#Preview {
    WishesScreen(answers: [
        "John",                       // Name
        "best friend",                // Relationship
        "30",                         // Age
        "playing guitar, hiking",     // Hobbies/Interests
        "Our trip to the mountains",  // Memory/Inside Joke
        "kindness and sense of humor",// Admired Quality
        "funny",                      // Tone
        "Enjoy your special day!"     // Additional Details
    ], name: "Parth"
)
    
    WishView(contact: Contact(id: UUID(), name: "Parth", birthday: Date(), phoneNumber: "6478060801"))
}

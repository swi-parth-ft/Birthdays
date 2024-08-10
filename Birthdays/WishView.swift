//
//  WishView.swift
//  Birthdays
//
//  Created by Parth Antala on 8/9/24.
//

import SwiftUI
import SwiftData

struct WishView: View {
    var contact: Contact
    
    @StateObject var questionsViewModel = QuestionsViewModel()
    @StateObject var chatGPTViewModel = ChatGPTViewModel()
    @State private var allQuestionsAnswered = false

    var body: some View {
        VStack {
            if !allQuestionsAnswered {
                Text(contact.name)
                QuestionsScreen(viewModel: questionsViewModel, allQuestionsAnswered: $allQuestionsAnswered)
            } else {
                WishesScreen(viewModel: chatGPTViewModel, answers: questionsViewModel.answers)
            }
        }
    }
}

struct QuestionView: View {
    @State private var offset: CGFloat = UIScreen.main.bounds.width
    var question: String
    var answer: Binding<String>

    var body: some View {
        VStack {
            Text(question)
                .font(.title)
                .padding()
            TextField("Your answer", text: answer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .offset(x: offset)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                offset = 0
            }
        }
        .onDisappear {
            withAnimation(.easeIn(duration: 0.5)) {
                offset = -UIScreen.main.bounds.width
            }
        }
    }
}

import Combine

class QuestionsViewModel: ObservableObject {
    @Published var questions: [String] = ["What's the recipient's name?", "How old are they turning?", "What's a special memory you share?"]
    @Published var answers: [String] = ["", "", ""]
    @Published var currentQuestionIndex = 0

    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
}

import SwiftUI

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
            } else {
                Text("All questions answered!")
                // Call API and show results here
            }
        }
        .padding()
    }
}

class ChatGPTViewModel: ObservableObject {
    @Published var birthdayWishes: [String] = []

    func generateWishes(answers: [String]) {
        // Implement the API call to ChatGPT here
        // For demonstration purposes, we'll use static messages
        birthdayWishes = [
            "Happy Birthday \(answers[0])! Can't believe you're turning \(answers[1])! Remember our time at \(answers[2])?",
            "Wishing you a wonderful birthday, \(answers[0])! \(answers[1]) years young and many more to come. Let's never forget \(answers[2])."
        ]
    }
}

struct WishesScreen: View {
    @ObservedObject var viewModel = ChatGPTViewModel()
    var answers: [String]

    var body: some View {
        VStack {
            Text("Choose a Birthday Wish:")
                .font(.title)
                .padding()
            List(viewModel.birthdayWishes, id: \.self) { wish in
                Text(wish)
                    .onTapGesture {
                        UIPasteboard.general.string = wish
                    }
            }
        }
        .onAppear {
            viewModel.generateWishes(answers: answers)
        }
    }
}

#Preview {
    WishView(contact: Contact(id: UUID(), name: "Parth", birthday: Date(), phoneNumber: "6478060801"))
}

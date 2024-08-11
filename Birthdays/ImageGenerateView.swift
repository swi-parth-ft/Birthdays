//
//  ImageGenerateView.swift
//  Birthdays
//
//  Created by Parth Antala on 8/11/24.
//

import SwiftUI
import DotLottie

struct ImageGenerateView: View {
    var userInput: String

    @State private var generatedImage: UIImage? = nil
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    
                    
                    if isLoading {
                        DotLottieAnimation(fileName: "loading", config: AnimationConfig(autoplay: true, loop: true)).view()
                    }
                    
                    if let image = generatedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(22)
                            .shadow(color: .white, radius: 10)
                            .padding()
                        
                        
                    }
                }
                .padding()
                .onAppear {
                    generateImage()
                }
            }
            .toolbar {
                if let image = generatedImage {
                    let ShareableImage = Image(uiImage: generatedImage!)
                    ShareLink(item: ShareableImage, preview: SharePreview("Filtered Image", image: ShareableImage)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .tint(.orange)
                }
                
                
            }
        }
    }
    
    func generateImage() {
        isLoading = true
        let prompt = """
        Create a vibrant, birthday illustration. The scene should capture a cheerful character and festive elements. Include:

            - A character (John) engaging in activities related to creativity, humor, and celebration.
            - A background that reflects fun and joy, with decorations like balloons and confetti.

            The tone should be lighthearted and whimsical, reflecting a joyful and festive atmosphere.
        Reflect the following theme in the illustration: \(userInput)
        """
        OpenAIService.shared.generateImage(from: prompt) { result in
            isLoading = false
            switch result {
            case .success(let image):
                self.generatedImage = image
            case .failure(let error):
                print("Error generating image: \(error.localizedDescription)")
            }
        }
    }
    
    func generateImagePrompt(from birthdayMessage: String) -> String {
        // Define base prompt structure
        let basePrompt = """
        Create a vibrant, cartoonish birthday illustration featuring a cheerful character named John. The scene should include the following elements:

        1. John holding a paintbrush and standing next to a canvas with a colorful painting.
        2. A football field in the background with a football team scoring a touchdown.
        3. A few funny jokes or puns in speech bubbles around John, making it clear that he is known for his humor.
        4. Bright, festive decorations like balloons, confetti, and a 'Happy Birthday' banner.

        The overall tone should be lighthearted and whimsical, capturing the essence of celebration, creativity, and fun. Make sure the image conveys joy and excitement, reflecting the birthday wishes of laughter, art, and touchdowns.
        """
        
        // Append the user’s message to the base prompt
        let userPrompt = """
        \(basePrompt)

        Incorporate the following message into the illustration: \(birthdayMessage)
        """

        return userPrompt
    }
}


#Preview {
    ImageGenerateView(userInput: "")
}

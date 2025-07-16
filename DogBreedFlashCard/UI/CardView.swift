import Foundation
import SwiftUI

struct CardView: View {
    private var game: DogBreedGuesserGame
    private var onGameComplete: ((Bool) -> Void)?
    @State private var buttonsDisabled: Bool = false
    
    init(
        game: DogBreedGuesserGame,
        onGameComplete: ((Bool) -> Void)? = nil
    ) {
        self.game = game
        self.onGameComplete = onGameComplete
    }
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: game.dogImage.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 8)
            } placeholder: {
                Image("Placeholder_gray")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 8)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    )
            }
            
            VStack(spacing: 12) {
                ForEach(0..<game.options.count, id: \.self) { index in
                    Button(action: {
                        handleChoice(at: index)
                    }) {
                        Text(game.options[index])
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(buttonsDisabled ? Color.gray : Color.blue)
                            )
                    }
                    .frame(width: 300)
                    .disabled(buttonsDisabled)
                }
            }
        }
        .padding(EdgeInsets(top: 40, leading: 20, bottom: 40, trailing: 20))
    }
    
    private func handleChoice(at index: Int) {
        // Disable all buttons immediately to prevent the user from making multiple choices in the same round
        buttonsDisabled = true
        
        do {
            let isCorrect = try game.chooseOption(index: index)
            onGameComplete?(isCorrect)
        } catch {
            print("Error choosing option: \(error)")
        }
    }
}

#Preview {
    let sampleDogImage = DogImage(
        imageURL: "https://images.dog.ceo/breeds/samoyed/n02111889_10059.jpg",
        breed: Breed(mainBreed: "samoyed", subBreed: nil)
    )
    let sampleGame = DogBreedGuesserGame(
        dogImage: sampleDogImage,
        wrongBreedName: "Husky"
    )
    CardView(game: sampleGame)
}

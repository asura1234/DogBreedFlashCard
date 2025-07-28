import AVFoundation
import ConfettiSwiftUI
import Foundation
import GamePackage
import ModelsPackage
import SwiftUI

struct CardView: View {
    private var game: DogBreedGuesserGame
    private var onGameComplete: ((Bool) -> Void)?
    @State private var buttonsDisabled: Bool = false
    @State private var showCorrectEmoji: Bool = false
    @State private var showIncorrectEmoji: Bool = false
    @State private var confettiTrigger: Int = 0
    @State private var correctAudioPlayer: AVAudioPlayer?
    @State private var incorrectAudioPlayer: AVAudioPlayer?
    
    init(
        game: DogBreedGuesserGame,
        onGameComplete: ((Bool) -> Void)? = nil
    ) {
        self.game = game
        self.onGameComplete = onGameComplete
    }
    
    private var dogImageView: some View {
        ZStack {
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
            
            if showCorrectEmoji {
                Text("✅")
                    .font(.system(size: 120))
                    .background(.clear)
                    .scaleEffect(showCorrectEmoji ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: showCorrectEmoji)
            }
            
            if showIncorrectEmoji {
                Text("❌")
                    .font(.system(size: 120))
                    .background(.clear)
                    .scaleEffect(showIncorrectEmoji ? 1.0 : 0.0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0),
                        value: showIncorrectEmoji)
            }
        }
    }
    
    private var gameButtonsView: some View {
        VStack(spacing: 12) {
            ForEach(0..<game.options.count, id: \.self) { index in
                Button(
                    action: { handleChoice(at: index) },
                    label: {
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
                )
                .frame(width: 300)
                .disabled(buttonsDisabled)
                .accessibilityIdentifier("BreedButton\(index)")
                .accessibilityLabel("Breed option: \(game.options[index])")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            dogImageView
            gameButtonsView
        }
        .padding(EdgeInsets(top: 40, leading: 20, bottom: 40, trailing: 20))
        .confettiCannon(trigger: $confettiTrigger, confettiSize: 16)
        .onChange(of: game) { _, _ in
            resetGame()
        }
        .onAppear {
            setupAudioPlayers()
        }
    }
    
    private func handleChoice(at index: Int) {
        // Disable all buttons immediately to prevent the user from making multiple choices in the same round
        buttonsDisabled = true
        
        do {
            let isCorrect = try game.chooseOption(index: index)
            if isCorrect {
                confettiTrigger += 1
                showCorrectEmoji = true
                playCorrectSound()
            } else {
                showIncorrectEmoji = true
                playIncorrectSound()
            }
            
            // Delay the completion callback to allow emoji to be visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onGameComplete?(isCorrect)
            }
        } catch {
            print("Error choosing option: \(error)")
        }
    }
    
    private func resetGame() {
        buttonsDisabled = false
        showCorrectEmoji = false
        showIncorrectEmoji = false
    }
    
    private func setupAudioPlayers() {
        guard let correct_url = Bundle.main.url(forResource: "correct_sound_effect", withExtension: "mp3"),
              let incorrect_url = Bundle.main.url(forResource: "incorrect_sound_effect", withExtension: "mp3") else {
            return
        }
        correctAudioPlayer = try? AVAudioPlayer(contentsOf: correct_url)
        correctAudioPlayer?.prepareToPlay()
        incorrectAudioPlayer = try? AVAudioPlayer(contentsOf: incorrect_url)
        incorrectAudioPlayer?.prepareToPlay()
    }
    
    private func playCorrectSound() {
        correctAudioPlayer?.stop()
        correctAudioPlayer?.currentTime = 0
        correctAudioPlayer?.play()
    }
    
    private func playIncorrectSound() {
        incorrectAudioPlayer?.stop()
        incorrectAudioPlayer?.currentTime = 0
        incorrectAudioPlayer?.play()
    }
}

#Preview {
    let sampleDogImage = DogImage(
        imageURL: "https://images.dog.ceo/breeds/samoyed/n02111889_10059.jpg",
        breed: Breed(mainBreed: "samoyed", subBreed: nil)
    )
    let sampleGame = DogBreedGuesserGame(
        dogImage: sampleDogImage,
        wrongBreedNames: ["Husky"]
    )
    CardView(game: sampleGame)
}

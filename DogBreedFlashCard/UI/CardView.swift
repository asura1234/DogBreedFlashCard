import AVFoundation
import ConfettiSwiftUI
import Foundation
import SwiftUI

struct CardView: View {
    private var game: DogBreedGuesserGame
    private var progressTracker: ProgressTracker
    private var onGameComplete: (() -> Void)?
    
    @State private var trigger: Int = 0
    @State private var buttonsDisabled: Bool = false
    
    private var incorrectAudioPlayer: AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "incorrect_sound_effect", withExtension: "mp3")
        else {
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }
    
    private var correctAudioPlayer: AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: "correct_sound_effect", withExtension: "mp3")
        else {
            return nil
        }
        return try? AVAudioPlayer(contentsOf: url)
    }
    
    init(
        game: DogBreedGuesserGame,
        progressTracker: ProgressTracker,
        onGameComplete: (() -> Void)? = nil
    ) {
        self.game = game
        self.progressTracker = progressTracker
        self.onGameComplete = onGameComplete
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Number of Games Played: \(progressTracker.numberOfGamesPlayed)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Text("Correct answers: \(progressTracker.numberOfGamesWon)")
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Text("What breed is this?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
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
                            .progressViewStyle(CircularProgressViewStyle())
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
                    .confettiCannon(trigger: $trigger)
                }
            }
        }
        .padding()
    }
    
    private func handleChoice(at index: Int) {
        // Disable all buttons immediately to prevent the user from making multiple choices in the same round
        buttonsDisabled = true
        
        do {
            let isCorrect = try game.chooseOption(index: index)
            if isCorrect {
                progressTracker.recordGamePlayed(won: true)
                trigger += 1  // triger confetti
                correctAudioPlayer?.play()
                onGameComplete?()
            } else {
                progressTracker.recordGamePlayed(won: false)
                incorrectAudioPlayer?.play()
                onGameComplete?()
            }
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
    let progressTracker = ProgressTracker()
    
    CardView(game: sampleGame, progressTracker: progressTracker)
}

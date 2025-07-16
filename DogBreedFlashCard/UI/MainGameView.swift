import AVFoundation
import ConfettiSwiftUI
import SwiftUI

struct MainGameView: View {
    @State private var games: [DogBreedGuesserGame] = []
    @State private var progressTracker = ProgressTracker()
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var gameFactory: DogBreedGuesserGameFactory?
    @State private var trigger: Int = 0
    @State private var correctAudioPlayer: AVAudioPlayer?
    @State private var incorrectAudioPlayer: AVAudioPlayer?
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let errorMessage = errorMessage {
                errorView(errorMessage)
            } else if !games.isEmpty {
                gameView
            }
        }
        .task {
            setupAudioPlayers()
            await initializeFactory()
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)
            Text("Loading games...")
                .font(.title2)
                .padding(.top)
        }
    }
    
    private func errorView(_ errorMessage: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            Button("Retry") {
                Task {
                    await loadMoreGames()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var gameView: some View {
        VStack {
            progressHeader
            gameTitle
            cardStack
        }
    }
    
    private var progressHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Number of Games Played: \(progressTracker.numberOfGamesPlayed)")
                    .font(.body)
                    .foregroundColor(.secondary)
                Text("Correct answers: \(progressTracker.numberOfGamesWon)")
                    .font(.body)
                    .foregroundColor(.green)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var gameTitle: some View {
        Text("What breed is this?")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding()
    }
    
    private var cardStack: some View {
        ZStack {
            ForEach(Array(games.enumerated()), id: \.offset) { index, game in
                styledCardView(for: game, at: index)
            }
        }
    }
    
    private func styledCardView(for game: DogBreedGuesserGame, at index: Int) -> some View {
        CardView(game: game) { hasWon in
            progressTracker.recordGamePlayed(won: hasWon)
            if hasWon {
                trigger += 1
                correctAudioPlayer?.play()
            } else {
                incorrectAudioPlayer?.play()
            }
            moveToNextGame()
        }
        .confettiCannon(trigger: $trigger, confettiSize: 16)
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .opacity(index == 0 ? 1.0 : 0.0)
        .scaleEffect(index == 0 ? 1.0 : 0.8)
        .zIndex(Double(games.count - index))
    }
    
    @MainActor
    private func initializeFactory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            gameFactory = try await DogBreedGuesserGameFactory(dogAPIService: DogAPIService())
            await loadMoreGames()
        } catch {
            errorMessage = "Failed to initialize game factory: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    @MainActor
    private func loadMoreGames() async {
        guard let factory = gameFactory else {
            errorMessage = "Game factory not initialized"
            return
        }
        
        do {
            for _ in 0..<10 {
                let game = try await factory.getNextGame()
                games.append(game)
            }
        } catch {
            errorMessage = "Failed to load more games: \(error.localizedDescription)"
        }
        
        // Reset loading state if this was initial load
        isLoading = false
    }
    
    @MainActor
    private func moveToNextGame() {
        guard !games.isEmpty else { return }
        
        _ = withAnimation(.easeOut(duration: 0.3)) {
            games.removeFirst()
        }
        
        if games.count < 10 {
            Task {
                await loadMoreGames()
            }
        }
    }
    
    private func setupAudioPlayers() {
        if let url = Bundle.main.url(forResource: "correct_sound_effect", withExtension: "mp3") {
            correctAudioPlayer = try? AVAudioPlayer(contentsOf: url)
            correctAudioPlayer?.prepareToPlay()
        }
        
        if let url = Bundle.main.url(forResource: "incorrect_sound_effect", withExtension: "mp3") {
            incorrectAudioPlayer = try? AVAudioPlayer(contentsOf: url)
            incorrectAudioPlayer?.prepareToPlay()
        }
    }
}

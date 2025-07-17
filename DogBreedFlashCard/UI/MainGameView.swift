import AVFoundation
import ConfettiSwiftUI
import SwiftUI

struct MainGameView: View {
    @State private var games: [DogBreedGuesserGame] = []
    @State private var progressTracker = ProgressTracker()
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var gameFactory: DogBreedGuesserGameFactory?
    
    private let maxGames: Int
    private let minimumGames: Int
    
    init(maxGames: Int = 30, minimumGames: Int = 20) {
        self.maxGames = maxGames
        self.minimumGames = minimumGames
    }
    
    // this is used for testing purposes
    init(gameFactory: DogBreedGuesserGameFactory) {
        self.gameFactory = gameFactory
        self.maxGames = 30
        self.minimumGames = 10
    }
    
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
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -100 && abs(value.translation.width) > abs(value.translation.height) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            progressTracker.recordGamePlayed(won: false)
                            moveToNextGame()
                        }
                    }
                }
        )
    }
    
    private func styledCardView(for game: DogBreedGuesserGame, at index: Int) -> some View {
        CardView(game: game) { hasWon in
            progressTracker.recordGamePlayed(won: hasWon)
            moveToNextGame()
        }
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
        
        if gameFactory != nil {
            isLoading = false
            return
        }
        
        do {
            gameFactory = try await DogBreedGuesserGameFactory(
                dogAPIService: DogAPIService(),
                minimumGamesCount: minimumGames,
                maximumGamesCount: maxGames
            )
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
            if games.count >= 20 { return }
            let gamesNeeded = 30 - games.count
            let moreGames = try await factory.getNextGames(count: gamesNeeded)
            games.append(contentsOf: moreGames)
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
        
        if games.count < 20 {
            Task {
                await loadMoreGames()
            }
        }
    }
}

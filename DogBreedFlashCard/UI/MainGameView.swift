import SwiftUI

struct MainGameView: View {
    @State private var games: [DogBreedGuesserGame] = []
    @State private var progressTracker = ProgressTracker()
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var gameFactory: DogBreedGuesserGameFactory?
    
    var body: some View {
        ZStack {
            if isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2)
                    Text("Loading games...")
                        .font(.title2)
                        .padding(.top)
                }
            } else if let errorMessage = errorMessage {
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
            } else if !games.isEmpty {
                ZStack {
                    ForEach(Array(games.enumerated()), id: \.offset) { index, game in
                        CardView(
                            game: game,
                            progressTracker: progressTracker
                        ) {
                            moveToNextGame()
                        }
                        .opacity(index == 0 ? 1.0 : 0.0)
                        .scaleEffect(index == 0 ? 1.0 : 0.8)
                        .zIndex(Double(games.count - index))
                    }
                }
            }
            
        }
        .task {
            await initializeFactory()
        }
    }
    
    @MainActor
    private func initializeFactory() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create the game factory once and reuse it
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
        
        // Animate away the first CardView and remove it from the stack
        _ = withAnimation(.easeOut(duration: 0.3)) {
            // Remove the first game from the array
            // This will automatically remove the corresponding CardView from ZStack
            games.removeFirst()
        }
        
        // Check if we need to load more games
        if games.count < 10 {
            Task {
                await loadMoreGames()
            }
        }
    }
}

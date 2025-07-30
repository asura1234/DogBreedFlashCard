import AVFoundation
import ConfettiSwiftUI
import GamePackage
import ModelsPackage
import ServicesPackage
import SwiftUI

struct MainGameView: View {
    enum ViewState {
        case loading
        case error(String)
        case loaded
    }
    
    @State private var games: [DogBreedGuesserGame] = []
    @State private var progressTracker = ProgressTracker()
    @State private var viewState: ViewState = .loading
    @State private var gameFactory: GameFactoryProtocol?
    @State private var shouldInitialize = true

    private var maxGames: Int = 30
    private var minimumGames: Int = 20

    init(maxGames: Int = 30, minimumGames: Int = 20) {
        self.maxGames = maxGames
        self.minimumGames = minimumGames
    }

    // this is used with fake game factory for UI testing
    init(gameFactory: GameFactoryProtocol) {
        self.gameFactory = gameFactory
    }
    
    // this is used for previews
    init(state: ViewState, games: [DogBreedGuesserGame] = []) {
        self._viewState = State(initialValue: state)
        self._games = State(initialValue: games)
        self._shouldInitialize = State(initialValue: false)
    }
    
    var body: some View {
        Group {
            switch viewState {
            case .loading:
                loadingView
            case .error(let message):
                errorView(message)
            case .loaded:
                if games.isEmpty {
                    errorView("No games available. Please try again later.")
                } else {
                    gameView
                }
            }
        }
        .task {
            if shouldInitialize {
                await initializeFactory()
            }
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
                viewState = .loading
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
                    .accessibilityIdentifier("GamesPlayedLabel")
                Text("Correct answers: \(progressTracker.numberOfGamesWon)")
                    .font(.body)
                    .foregroundColor(.green)
                    .accessibilityIdentifier("CorrectAnswersLabel")
            }
            Spacer()
        }
        .padding(.horizontal)
    }

    private var gameTitle: some View {
        Text("Which breed is this?")
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
        .accessibilityIdentifier("GameCardStack")
        .accessibilityLabel("Swipe left to skip to next game")
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -100
                        && abs(value.translation.width) > abs(value.translation.height) {
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
        viewState = .loading

        if gameFactory != nil {
            await loadMoreGames()
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
            viewState = .error("Failed to initialize game factory: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func loadMoreGames() async {
        guard let factory = gameFactory else {
            viewState = .error("Game factory not initialized")
            return
        }

        do {
            if games.count >= minimumGames { 
                viewState = .loaded
                return 
            }
            let gamesNeeded = maxGames - games.count
            let moreGames = try await factory.getNextGames(count: gamesNeeded)
            games.append(contentsOf: moreGames)
            viewState = .loaded
        } catch {
            viewState = .error("Failed to load more games: \(error.localizedDescription)")
        }
    }

    private func moveToNextGame() {
        guard !games.isEmpty else { return }

        _ = withAnimation(.easeOut(duration: 0.3)) {
            games.removeFirst()
        }

        Task {
            await loadMoreGames()
        }
    }
}

struct MainGameViewPreview: PreviewProvider {
    static var testGame: DogBreedGuesserGame {
        let dogImage = DogImage(
            imageURL: "https://images.dog.ceo/breeds/pembroke/n02113023_2256.jpg",
            breed: Breed(mainBreed: "Pembroke", subBreed: nil))
        let wrongBreedNames = ["Golden Retriever", "Poodle", "Husky"]
        return DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)
    }
    
    static var previews: some View {
        Group {
            MainGameView(state: .error("Oops, something went wrong."))
                .previewDisplayName("Error State")
            MainGameView(state: .loading)
                .previewDisplayName("Loading State")
            MainGameView(state: .loaded, games: [testGame])
                .previewDisplayName("Loaded State with Game")
        }
    }
}

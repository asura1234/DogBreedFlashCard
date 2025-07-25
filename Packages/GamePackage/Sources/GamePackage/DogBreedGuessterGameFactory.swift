import Foundation
import ModelsPackage
import ServicesPackage

public protocol GameFactoryProtocol {
    func getNextGames(count: Int) async throws -> [DogBreedGuesserGame]
    func reset() async
}

public actor DogBreedGuesserGameFactory: GameFactoryProtocol {
    enum GameFactoryError: Error {
        case getNextGameError
        case generateNewGameError
    }

    // keep this function internal so the test framework can access it
    private(set) var gamesQueue: [DogBreedGuesserGame]
    // keep this function internal so the test framework can access it
    private(set) var allBreedNames: [String]

    private let dogAPIService: DogAPIServiceProtocol

    private let minimumGamesCount: Int

    private let maximumGamesCount: Int

    private let maximumLoadFailureCount: Int

    public init(
        dogAPIService: DogAPIServiceProtocol,
        minimumGamesCount: Int = 20,
        maximumGamesCount: Int = 30,
        maximumLoadFailureCount: Int = 5
    ) async throws {
        self.dogAPIService = dogAPIService
        self.gamesQueue = []
        self.allBreedNames = []
        self.minimumGamesCount = minimumGamesCount
        self.maximumGamesCount = maximumGamesCount
        self.maximumLoadFailureCount = maximumLoadFailureCount
        await self.reset()
    }

    public func getNextGames(count: Int = 10) async throws -> [DogBreedGuesserGame] {
        if gamesQueue.count > count {
            Task {
                await ensureMinimumGames()
            }
            let result = Array(gamesQueue.prefix(count))
            gamesQueue.removeFirst(count)
            return result
        } else {
            await ensureMinimumGames()
            let actualCount = min(count, gamesQueue.count)
            let result = Array(gamesQueue.prefix(actualCount))
            if actualCount > 0 {
                gamesQueue.removeFirst(actualCount)
            }
            if result.count < count {
                throw GameFactoryError.getNextGameError
            }
            return result
        }
    }

    public func reset() async {
        gamesQueue = []
        allBreedNames = []
        await fetchAllBreedNames()
        await ensureMinimumGames()
    }

    private func fetchAllBreedNames() async {
        do {
            let groups = try await dogAPIService.fetchAllBreeds()
            allBreedNames = groups.flatMap { $0.names }
        } catch {
            print("Failed to fetch breed names: \(error)")
            allBreedNames = []
        }
    }

    private func generateNewGame() async throws {
        let dogImage = try await dogAPIService.fetchRandomDogImage()
        let wrongBreedName = try getRandomWrongBreedName(excludeFrom: [dogImage.breed.name])
        let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedName: wrongBreedName)
        gamesQueue.append(game)
    }

    private func getRandomWrongBreedName(excludeFrom list: [String]) throws -> String {
        guard !allBreedNames.isEmpty,
              let randomWrongBreedName = allBreedNames.filter({ !list.contains($0) }).randomElement()
        else {
            throw GameFactoryError.generateNewGameError
        }
        return randomWrongBreedName
    }

    private func ensureMinimumGames() async {
        // If we have less than 20 games queued up, generate new ones concurrently until we have 30
        if gamesQueue.count >= minimumGamesCount { return }
        let gamesNeeded = maximumGamesCount - gamesQueue.count

        await withTaskGroup(of: Bool.self) { group in
            var failureCount = 0
            let maxFailures = maximumLoadFailureCount

            for _ in 0..<gamesNeeded {
                group.addTask {
                    do {
                        try await self.generateNewGame()
                        return true
                    } catch {
                        return false
                    }
                }
            }

            // Process results and stop if we hit failure limit
            for await result in group where result == false {
                failureCount += 1
                if failureCount >= maxFailures {
                    group.cancelAll()
                    break
                }
            }
        }
    }
}

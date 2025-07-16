actor DogBreedGuesserGameFactory {
    enum GameFactoryError: Error {
        case getNextGameError
        case generateNewGameError
    }
    
    // making this internal for testing purposes
    private(set) var gamesQueue: [DogBreedGuesserGame]
    // making this internal for testing purposes
    private(set) var allBreedNames: [String]
    
    private let dogAPIService: DogAPIServiceProtocol
    
    init(dogAPIService: DogAPIServiceProtocol) async throws {
        self.dogAPIService = dogAPIService
        self.gamesQueue = []
        self.allBreedNames = []
        
        await self.reset()
    }
    
    public func getNextGame() async throws -> DogBreedGuesserGame {
        await ensureMinimumQuestions()
        guard !gamesQueue.isEmpty else {
            throw GameFactoryError.getNextGameError
        }
        return gamesQueue.removeFirst()
    }
    
    public func reset() async {
        gamesQueue = []
        allBreedNames = []
        await fetchAllBreedNames()
        await ensureMinimumQuestions()
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
        let wrongBreedName = try getRandomWrongBreedName(excludeBreedName: dogImage.breed.name)
        let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedName: wrongBreedName)
        gamesQueue.append(game)
    }
    
    private func getRandomWrongBreedName(excludeBreedName: String) throws -> String {
        guard !allBreedNames.isEmpty,
              let randomWrongBreedName = allBreedNames.filter({ $0 != excludeBreedName }).randomElement()
        else {
            throw GameFactoryError.generateNewGameError
        }
        return randomWrongBreedName
    }
    
    private func ensureMinimumQuestions() async {
        // If we have less than 20 games queued up, generate new ones concurrently until we have 30
        if gamesQueue.count >= 20 { return }
        let questionsNeeded = 30 - gamesQueue.count
        
        await withTaskGroup(of: Bool.self) { group in
            var failureCount = 0
            let maxFailures = 10
            
            for _ in 0..<questionsNeeded {
                group.addTask {
                    do {
                        try await self.generateNewGame()
                        return true  // Success
                    } catch {
                        return false  // Failure
                    }
                }
            }
            
            // Process results and stop if we hit failure limit
            for await result in group {
                if !result {
                    failureCount += 1
                    if failureCount >= maxFailures {
                        group.cancelAll()
                        break
                    }
                }
            }
        }
    }
}

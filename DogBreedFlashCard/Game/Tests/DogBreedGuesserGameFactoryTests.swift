import Foundation
import Testing

@testable import DogBreedFlashCard

struct DogBreedGuesserGameFactoryTests {
    @Test("DogBreedGuesserGameFactory is initialized correctly")
    func testFactoryInitialization() async {
        let gameFactory = await DogBreedGuesserGameFactory(
            dogAPIService: FakeDogAPIService(hasRandomDelay: false)
        )
        
        let gamesCount = await gameFactory.gamesQueue.count
        let breedNamesCount = await gameFactory.allBreedNames.count
        
        #expect(gamesCount > 0, "Game factory should have more than 0 games queued up")
        
        #expect(breedNamesCount > 0, "Game factory should have fetched all breed names")
    }
    
    @Test("DogBreedGuesserGameFactory will always have games queued up.")
    func testGamesQueueCount() async {
        let gameFactory = await DogBreedGuesserGameFactory(
            dogAPIService: FakeDogAPIService(hasRandomDelay: true)
        )
        
        for _ in 1...30 {
            // add 0.5 seconds delay to simulate human reaction time
            try? await Task.sleep(nanoseconds: 500_000_000)
            let _ = try? await gameFactory.getNextGame()
            let queueCount = await gameFactory.gamesQueue.count
            #expect(queueCount > 0, "Game factory should never run out of games in the queue")
        }
    }
    
    @Test("DogBreedGuesserGameFactory will return a valid game when getNextGame is called.")
    func testGetNextGame() async {
        let gameFactory = await DogBreedGuesserGameFactory(
            dogAPIService: FakeDogAPIService(hasRandomDelay: false)
        )
        
        do {
            let game = try await gameFactory.getNextGame()
            #expect(
                !game.dogImage.imageURL.isEmpty,
                "getNextGame should return a valid DogBreedGuesserGame with a non-empty image URL"
            )
            #expect(
                game.dogImage.breed.name != "",
                "getNextGame should return a valid DogBreedGuesserGame with a non-empty breed name"
            )
            #expect(
                game.options.count == 2,
                "getNextGame should return a valid DogBreedGuesserGame with two options to choose from"
            )
            #expect(
                game.options[0] != game.options[1],
                "getNextGame should return a valid DogBreedGuesserGame with exactly two disctinct options"
            )
            let allBreedNames = await gameFactory.allBreedNames
            #expect(
                allBreedNames.contains(game.dogImage.breed.name),
                "getNextGame should return a valid DogBreedGuesserGame where the correct breed name is in the list of all breed names"
            )
            #expect(
                allBreedNames.contains(game.options.first { $0 != game.dogImage.breed.name }!),
                "getNextGame should return a valid DogBreedGuesserGame where the wrong breed name is in the list of all breed names"
            )
            #expect(
                game.options.contains(game.dogImage.breed.name),
                "getNextGame should return a valid DogBreedGuesserGame where the options contain the correct breed name"
            )
            #expect(
                game.isCorrect(option: game.dogImage.breed.name),
                "getNextGame should return a valid DogBreedGuesserGame with a clear correct option"
            )
        } catch {
            #expect(Bool(false), "Unexpected error thrown: \(error)")
        }
    }
    
    @Test("DogBreedGuesserGameFactory will reset the game queue when reset is called.")
    func testReset() async {
        let gameFactory = await DogBreedGuesserGameFactory(dogAPIService: FakeDogAPIService(hasRandomDelay: false))
        
        let initialCount = await gameFactory.gamesQueue.count
        #expect(
            initialCount > 0, "Game factory should have games queued up before reset")
        
        // make sure the games Queue is not full before the reset
        var currentCount = await gameFactory.gamesQueue.count
        while currentCount == 30 {
            _ = try? await gameFactory.getNextGame()
            currentCount = await gameFactory.gamesQueue.count
        }
        
        await gameFactory.reset()
        
        let finalCount = await gameFactory.gamesQueue.count
        #expect(
            finalCount == 30,
            "reset should clear the games queue and then refill it with 30 new games"
        )
    }
    
    @Test("DogBreedGuesserGameFactory will throw error when the games queue is empty.")
    func testGetNextGameError() async {
        // When
        let fakeDogAPIService = FakeDogAPIService(isFetchRandomDogImageBroken: true, hasRandomDelay: false)
        let factory = await DogBreedGuesserGameFactory(dogAPIService: fakeDogAPIService)
        
        // Then
        do {
            _ = try await factory.getNextGame()
            #expect(Bool(false), "Expected error to be thrown")
        } catch DogBreedGuesserGameFactory.GameFactoryError.getNextGameError {
            // This specific error is expected
        } catch DogBreedGuesserGameFactory.GameFactoryError.generateNewGameError {
            // This specific error is also expected
        } catch {
            #expect(Bool(false), "Unexpected error thrown: \(error)")
        }
    }
    
    @Test("DogBreedGuesserGameFactory will throw error when there are no breed names available.")
    func testGenerateNewGameError() async {
        // When
        let brokenDogAPIService = FakeDogAPIService(isFetchAllBreedsBroken: true, hasRandomDelay: false)
        let brokenFactory = await DogBreedGuesserGameFactory(dogAPIService: brokenDogAPIService)
        
        // Then
        do {
            _ = try await brokenFactory.getNextGame()
            #expect(Bool(false), "Expected error to be thrown")
        } catch DogBreedGuesserGameFactory.GameFactoryError.getNextGameError {
            // This specific error is expected
        } catch DogBreedGuesserGameFactory.GameFactoryError.generateNewGameError {
            // This specific error is also expected
        } catch {
            #expect(Bool(false), "Unexpected error thrown: \(error)")
        }
    }
}

import Foundation
import ModelsPackage
import Testing

@testable import GamePackage

struct DogBreedGuesserGameTests {
    let dogImage = DogImage(
        imageURL: "https://images.dog.ceo/breeds/pembroke/n02113023_1168.jpg",
        breed: Breed(mainBreed: "Pembroke", subBreed: nil))
    let wrongBreedNames = ["Husky"]

    @Test("DogBreedGuesserGame is initialized correctly")
    func testInitialization() {
        // When
        let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)

        // Then
        #expect(game.options.count == wrongBreedNames.count, "Options should contain 2 items")
        #expect(
            game.options.contains(dogImage.breed.name), "Options should contain the correct breed name")
        #expect(game.options.contains(wrongBreedNames), "Options should contain the wrong breed name")
    }

    @Test("Result is correct when the option is the correct breed name")
    func testCorrectOption() {
        let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)

        // When
        let isCorrect = game.isCorrect(option: dogImage.breed.name)

        // Then
        #expect(isCorrect, "The correct breed name should be correct")
    }

    @Test("Result is incorrect when the option is the wrong breed name")
    func testIncorrectOption() {
        let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)

        // swiftlint:disable:next force_unwrapping
        for wrongBreedName in wrongBreedNames {
            // When
            let isCorrect = game.isCorrect(option: wrongBreedName)
            // Then
            #expect(!isCorrect, "The wrong breed name should be incorrect")
        }
        
    }

    @Test("Options are shuffled randomly")
    func testShuffledOptions() {
        // Always guessing the first option should win at least 10 out of 40 games (very high probability)
        var wins = 0
        for _ in 1...40 {
            do {
                let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)
                let result = try game.chooseOption(index: 0)
                wins += result ? 1 : 0
            } catch {
                #expect(Bool(false), "Unexpected error thrown: \(error)")
            }
        }

        // Then
        #expect(wins > 10, "Options should be shuffled")
    }

    @Test("Choosing an invalid option index throws an error")
    func testInvalidOptionIndex() {
        let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)

        var invalidOptionIndexErrorThrown = false
        // When
        do {
            _ = try game.chooseOption(index: wrongBreedNames.count)
        } catch DogBreedGuesserGame.GameError.invalidOptionIndex {
            invalidOptionIndexErrorThrown = true
        } catch {
            #expect(Bool(false), "Unexpected error thrown: \(error)")
        }
        #expect(invalidOptionIndexErrorThrown, "Invalid option index error should be thrown")
    }
}

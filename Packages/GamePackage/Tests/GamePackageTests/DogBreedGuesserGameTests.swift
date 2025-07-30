import Foundation
import ModelsPackage
import Testing

@testable import GamePackage

struct DogBreedGuesserGameTests {
    let dogImage = DogImage(
        imageURL: "https://images.dog.ceo/breeds/pembroke/n02113023_1168.jpg",
        breed: Breed(mainBreed: "Pembroke", subBreed: nil))
    let wrongBreedNameGroups = [["Husky"], ["Golden Retriever", "Poodle", "Husky"]]

    @Test("DogBreedGuesserGame is initialized correctly")
    func testInitialization() {
        for wrongBreedNames in wrongBreedNameGroups {
            // When
            let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)

            // Then
            #expect(game.options.count == wrongBreedNames.count + 1, "Options should contain certain number of items")
            #expect(
                game.options.contains(dogImage.breed.name), "Options should contain the correct breed name")
            #expect(Set(game.options).isSuperset(of: Set(wrongBreedNames)), "Options should contain the wrong breed name")
        }
    }

    @Test("Result is correct when the option is the correct breed name")
    func testCorrectOption() {
        for wrongBreedNames in wrongBreedNameGroups {
            // When
            let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)
            let isCorrect = game.isCorrect(option: dogImage.breed.name)

            // Then
            #expect(isCorrect, "The correct breed name should be correct")
        }
    }

    @Test("Result is incorrect when the option is the wrong breed name")
    func testIncorrectOption() {
        for wrongBreedNames in wrongBreedNameGroups {
            let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)

            // swiftlint:disable:next force_unwrapping
            for wrongBreedName in wrongBreedNames {
                // When
                let isCorrect = game.isCorrect(option: wrongBreedName)
                // Then
                #expect(!isCorrect, "The wrong breed name should be incorrect")
            }
        }
    }

    @Test("Options are shuffled randomly")
    func testShuffledOptions() {
        for wrongBreedNames in wrongBreedNameGroups {
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
            #expect(wins > 0, "Options should be shuffled")
            #expect(wins < 40, "Options should be shuffled")
        }
    }

    @Test("Choosing an invalid option index throws an error")
    func testInvalidOptionIndex() {
        for wrongBreedNames in wrongBreedNameGroups {
            // When
            let game = DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)
            var invalidOptionIndexErrorThrown = false

            do {
                _ = try game.chooseOption(index: wrongBreedNames.count + Int.random(in: 1...10))
            } catch DogBreedGuesserGame.GameError.invalidOptionIndex {
                invalidOptionIndexErrorThrown = true
            } catch {
                #expect(Bool(false), "Unexpected error thrown: \(error)")
            }

            // Then
            #expect(invalidOptionIndexErrorThrown, "Invalid option index error should be thrown")
        }
    }
}

import Foundation
import ModelsPackage

public struct DogBreedGuesserGame: Identifiable, Equatable {
    public static func == (lhs: DogBreedGuesserGame, rhs: DogBreedGuesserGame) -> Bool {
        lhs.id == rhs.id
    }
    
    private static func generateID(correctBreedName: String, wrongBreedNames: [String]) -> Int {
        var hasher = Hasher()
        hasher.combine(correctBreedName)
        wrongBreedNames.forEach {
            hasher.combine($0)
        }
        // Combine current time to ensure uniqueness across instances
        hasher.combine(Date().timeIntervalSince1970)
        return hasher.finalize()
    }

    public var id: Int

    enum GameError: Error {
        case invalidOptionIndex
    }

    public let dogImage: DogImage
    public let options: [String]
    private let correctBreedName: String
    private let wrongBreedNames: [String]

    public init(dogImage: DogImage, wrongBreedNames: [String]) {
        self.dogImage = dogImage
        self.correctBreedName = dogImage.breed.name
        self.wrongBreedNames = wrongBreedNames
        self.options = ([correctBreedName] + wrongBreedNames).shuffled()
        self.id = Self.generateID(correctBreedName: correctBreedName, wrongBreedNames: wrongBreedNames)
    }

    // keep this function internal so the test framework can access it
    func isCorrect(option: String) -> Bool {
        return option == correctBreedName
    }

    public func chooseOption(index: Int) throws -> Bool {
        guard index >= 0 && index < options.count else {
            throw GameError.invalidOptionIndex
        }
        return isCorrect(option: options[index])
    }
}

import Foundation
import ModelsPackage

public struct DogBreedGuesserGame: Identifiable, Equatable {
    public static func == (lhs: DogBreedGuesserGame, rhs: DogBreedGuesserGame) -> Bool {
        lhs.id == rhs.id
    }

    public var id: Int

    enum GameError: Error {
        case invalidOptionIndex
    }

    public let dogImage: DogImage
    public let options: [String]
    private let correctBreedName: String
    private let wrongBreedName: String

    public init(dogImage: DogImage, wrongBreedName: String) {
        self.dogImage = dogImage
        self.correctBreedName = dogImage.breed.name
        self.wrongBreedName = wrongBreedName
        self.options = [correctBreedName, wrongBreedName].shuffled()
        self.id = Self.generateID(correctBreedName: correctBreedName, wrongBreedName: wrongBreedName)
    }

    private static func generateID(correctBreedName: String, wrongBreedName: String) -> Int {
        var hasher = Hasher()
        hasher.combine(correctBreedName)
        hasher.combine(wrongBreedName)
        // Combine current time to ensure uniqueness across instances
        hasher.combine(Date().timeIntervalSince1970)
        return hasher.finalize()
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

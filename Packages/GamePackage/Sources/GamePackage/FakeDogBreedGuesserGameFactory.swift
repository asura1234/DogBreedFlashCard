import Foundation
import ModelsPackage

public class FakeDogBreedGuesserGameFactory: GameFactoryProtocol {

    public init() {}

    public func getNextGames(count: Int) async throws -> [DogBreedGuesserGame] {
        Array(
            repeating:
                DogBreedGuesserGame(
                    dogImage:
                        DogImage(
                            imageURL: "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
                            breed: Breed(mainBreed: "hound", subBreed: "afghan")
                        ),
                    wrongBreedNames: ["Golden Retriever"]
                ),
            count: count
        )
    }

    public func reset() async {}
}

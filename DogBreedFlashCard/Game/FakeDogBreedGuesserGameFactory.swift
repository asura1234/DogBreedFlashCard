import Foundation

class FakeDogBreedGuesserGameFactory: GameFactoryProtocol {
  func getNextGames(count: Int) async throws -> [DogBreedGuesserGame] {
    Array(
      repeating:
        DogBreedGuesserGame(
          dogImage:
            DogImage(
              imageURL: "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
              breed: Breed(mainBreed: "hound", subBreed: "afghan")
            ),
          wrongBreedName: "Golden Retriever"
        ),
      count: count
    )
  }

  func reset() async {}
}

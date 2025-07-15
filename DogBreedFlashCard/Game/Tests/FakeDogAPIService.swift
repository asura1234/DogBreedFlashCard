import Foundation
@testable import DogBreedFlashCard

class FakeDogAPIService: DogAPIServiceProtocol {
    private let dogImages: [DogImage] = [
        .init(
            imageURL: "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
            breed: Breed(mainBreed: "hound", subBreed: "afghan")
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/bulldog-boston/n02096585_1023.jpg",
            breed: Breed(mainBreed: "bulldog", subBreed: "boston")
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/retriever-golden/n02099601_1001.jpg",
            breed: Breed(mainBreed: "retriever", subBreed: "golden")
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/labrador/n02099712_1001.jpg",
            breed: Breed(mainBreed: "labrador", subBreed: nil)
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/poodle/n02113799_1001.jpg",
            breed: Breed(mainBreed: "poodle", subBreed: nil)
        )
    ]
    
    private let breedGroups: [BreedGroup] = [
        .init(mainBreed: "hound", subBreeds: ["afghan"]),
        .init(mainBreed: "bulldog", subBreeds: ["boston"]),
        .init(mainBreed: "retriever", subBreeds: ["golden"]),
        .init(mainBreed: "labrador", subBreeds: []),
        .init(mainBreed: "poodle", subBreeds: [])
    ]
    
    func fetchRandomDogImage() async throws -> DogImage {
        /// simulate delay of 1 second for testing purposes
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return dogImages[Int.random(in: 0..<dogImages.count)]
    }
    
    func fetchAllBreeds() async throws -> [BreedGroup] {
        /// simulate delay of 1 second for testing purposes
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return breedGroups
    }
}

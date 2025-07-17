import Foundation
import ModelsPackage

@testable import ServicesPackage

class FakeDogAPIService: DogAPIServiceProtocol {
    private let isFetchRandomDogImageBroken: Bool
    private let isFetchAllBreedsBroken: Bool
    private let hasRandomDelay: Bool
    
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
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/dalmatian/cooper1.jpg",
            breed: Breed(mainBreed: "dalmatian", subBreed: nil)
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/setter-gordon/n02101006_3062.jpg",
            breed: Breed(mainBreed: "gordon", subBreed: "setter")
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/deerhound-scottish/n02092002_5152.jpg",
            breed: Breed(mainBreed: "deerhound", subBreed: "scottish")
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/elkhound-norwegian/n02091467_815.jpg",
            breed: Breed(mainBreed: "elkhound", subBreed: "norwegian")
        ),
        .init(
            imageURL: "https://images.dog.ceo/breeds/sheepdog-indian/Himalayan_Sheepdog.jpg",
            breed: Breed(mainBreed: "Sheepdog", subBreed: "Himalayan")
        ),
    ]
    
    private let breedGroups: [BreedGroup] = [
        .init(mainBreed: "hound", subBreeds: ["afghan"]),
        .init(mainBreed: "bulldog", subBreeds: ["boston"]),
        .init(mainBreed: "retriever", subBreeds: ["golden"]),
        .init(mainBreed: "labrador", subBreeds: []),
        .init(mainBreed: "poodle", subBreeds: []),
        .init(mainBreed: "dalmatian", subBreeds: []),
        .init(mainBreed: "gordon", subBreeds: ["setter"]),
        .init(mainBreed: "deerhound", subBreeds: ["scottish"]),
        .init(mainBreed: "elkhound", subBreeds: ["norwegian"]),
        .init(mainBreed: "Sheepdog", subBreeds: ["Himalayan"]),
    ]
    
    init(
        isFetchRandomDogImageBroken: Bool = false,
        isFetchAllBreedsBroken: Bool = false,
        hasRandomDelay: Bool = false
    ) {
        self.isFetchRandomDogImageBroken = isFetchRandomDogImageBroken
        self.isFetchAllBreedsBroken = isFetchAllBreedsBroken
        self.hasRandomDelay = hasRandomDelay
    }
    
    func fetchRandomDogImage() async throws -> DogImage {
        guard !isFetchRandomDogImageBroken else {
            throw DogAPIError.noData
        }
        
        if hasRandomDelay {
            let delay = Double.random(in: 0.2...1.0)
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * delay))
        }
        return dogImages[Int.random(in: 0..<dogImages.count)]
    }
    
    func fetchAllBreeds() async throws -> [BreedGroup] {
        guard !isFetchAllBreedsBroken else {
            throw DogAPIError.noData
        }
        
        // simulate delay for testing purposes
        if hasRandomDelay {
            let delay = Double.random(in: 0.2...1.0)
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * delay))
        }
        return breedGroups
    }
}

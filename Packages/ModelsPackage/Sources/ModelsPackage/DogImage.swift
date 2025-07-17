import Foundation

public struct DogImage {
    public let imageURL: String
    public let breed: Breed
    
    public init(imageURL: String, breed: Breed) {
        self.imageURL = imageURL
        self.breed = breed
    }
}

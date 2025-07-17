import Foundation

public struct DogImage {
    let imageURL: String
    let breed: Breed
    
    init(imageURL: String, breed: Breed) {
        self.imageURL = imageURL
        self.breed = breed
    }
    
    init(from response: DogImageResponse) {
        self.imageURL = response.message
        
        // Extract breed from URL path
        // URL format: https://images.dog.ceo/breeds/[breed]/[filename]
        guard let url = URL(string: response.message),
              url.pathComponents.count >= 3 && url.pathComponents[1] == "breeds"
        else {
            self.breed = Breed(mainBreed: "unknown", subBreed: nil)
            return
        }
        
        let breedComponent = url.pathComponents[2]
        // Handle sub-breeds (e.g., "hound-afghan")
        let breedParts = breedComponent.split(separator: "-")
        if breedParts.count == 2 {
            self.breed = Breed(mainBreed: String(breedParts[0]), subBreed: String(breedParts[1]))
        } else {
            self.breed = Breed(mainBreed: String(breedParts[0]), subBreed: nil)
        }
    }
}

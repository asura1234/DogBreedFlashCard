import SwiftUI
import ModelsPackage
import GamePackage

struct MainGameViewPreview: PreviewProvider {
    static var testGame: DogBreedGuesserGame {
        let dogImage = DogImage(
            imageURL: "https://images.dog.ceo/breeds/pembroke/n02113023_1168.jpg",
            breed: Breed(mainBreed: "Pembroke", subBreed: nil))
        let wrongBreedNames = ["Golden Retriever", "Poodle", "Husky"]
        return DogBreedGuesserGame(dogImage: dogImage, wrongBreedNames: wrongBreedNames)
    }
    
    static var previews: some View {
        Group {
            MainGameView(state: .error("Oops, something went wrong."))
                .previewDisplayName("Error State")
            MainGameView(state: .loading)
                .previewDisplayName("Loading State")
            MainGameView(state: .loaded, games: [testGame])
                .previewDisplayName("Loaded State with Game")
        }
    }
}

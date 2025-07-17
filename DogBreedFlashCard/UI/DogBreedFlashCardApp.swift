import SwiftUI

@main
struct DogBreedFlashCardApp: App {
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["TESTING"] == "1" {
                MainGameView(gameFactory: FakeDogBreedGuesserGameFactory())
            } else {
                MainGameView()
            }
        }
    }
}

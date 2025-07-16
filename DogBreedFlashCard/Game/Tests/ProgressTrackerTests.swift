import Foundation
import Testing

@testable import DogBreedFlashCard

struct ProgressTrackerTests {
    @Test("ProgressTracker records games played and won correctly")
    func testProgressTracker() {
        let tracker = ProgressTracker()
        // Initial state
        #expect(tracker.numberOfGamesPlayed == 0, "Initial games played should be 0")
        #expect(tracker.numberOfGamesWon == 0, "Initial games won should be 0")
        
        // Record a game played and won
        tracker.recordGamePlayed(won: true)
        #expect(tracker.numberOfGamesPlayed == 1, "Games played should be 1 after one game")
        #expect(tracker.numberOfGamesWon == 1, "Games won should be 1 after winning one game")
        
        // Record 5 games played, 3 won
        for i in 1...5 {
            tracker.recordGamePlayed(won: i <= 3) // First 3 games are wins
        }
        #expect(tracker.numberOfGamesPlayed == 6, "Games played should be 6 after recording 5 more games")
        #expect(tracker.numberOfGamesWon == 4, "Games won should be 4 after winning 3 out of 5 games")
        
        // Reset the tracker
        tracker.reset()
        #expect(tracker.numberOfGamesPlayed == 0, "After a reset games played should be 0")
        #expect(tracker.numberOfGamesWon == 0, "After a reset games won should be 0")
    }
}


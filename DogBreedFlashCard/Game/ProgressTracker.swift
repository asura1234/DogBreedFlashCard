import Foundation

public class ProgressTracker{
    private(set) var numberOfGamesPlayed: Int = 0
    private(set) var numberOfGamesWon: Int = 0
    
    public func recordGamePlayed(won: Bool) {
        if won {
            numberOfGamesWon += 1
        }
        numberOfGamesPlayed += 1
    }
    
    public func reset() {
        numberOfGamesPlayed = 0
        numberOfGamesWon = 0
    }
}

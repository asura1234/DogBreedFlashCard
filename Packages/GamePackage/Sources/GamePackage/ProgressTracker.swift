import Foundation

public class ProgressTracker {
    public private(set) var numberOfGamesPlayed: Int = 0
    public private(set) var numberOfGamesWon: Int = 0
    
    public init() {}
    
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

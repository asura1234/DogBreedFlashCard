import Foundation

public struct BreedGroup {
    public let mainBreed: String
    public let subBreeds: [String]
    
    public var names: [String] {
        if subBreeds.isEmpty {
            return [mainBreed.capitalized]
        } else {
            return subBreeds.map { "\($0.capitalized) \(mainBreed.capitalized)" }
        }
    }
    
    public init(mainBreed: String, subBreeds: [String]) {
        self.mainBreed = mainBreed
        self.subBreeds = subBreeds
    }
}

public struct Breed: Equatable {
    public let mainBreed: String
    public let subBreed: String?
    
    public var name: String {
        subBreed.map { "\($0.capitalized) \(mainBreed.capitalized)" } ?? mainBreed.capitalized
    }
    
    public static func == (lhs: Breed, rhs: Breed) -> Bool {
        return lhs.mainBreed == rhs.mainBreed && lhs.subBreed == rhs.subBreed
    }
    
    public init(mainBreed: String, subBreed: String?) {
        self.mainBreed = mainBreed.lowercased()
        self.subBreed = subBreed?.lowercased()
    }
}

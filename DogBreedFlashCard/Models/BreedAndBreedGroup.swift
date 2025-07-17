import Foundation

public struct BreedGroup {
    let mainBreed: String
    let subBreeds: [String]
    
    var names: [String] {
        if subBreeds.isEmpty {
            return [mainBreed.capitalized]
        } else {
            return subBreeds.map { "\($0.capitalized) \(mainBreed.capitalized)" }
        }
    }
}

public struct Breed: Equatable {
    let mainBreed: String
    let subBreed: String?
    
    var name: String {
        subBreed.map { "\($0.capitalized) \(mainBreed.capitalized)" } ?? mainBreed.capitalized
    }
    
    public static func == (lhs: Breed, rhs: Breed) -> Bool {
        return lhs.mainBreed == rhs.mainBreed && lhs.subBreed == rhs.subBreed
    }
    
    init(mainBreed: String, subBreed: String?) {
        self.mainBreed = mainBreed.lowercased()
        self.subBreed = subBreed?.lowercased()
    }
}

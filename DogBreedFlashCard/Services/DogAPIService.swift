import Foundation

struct DogImageResponse: Codable {
    let message: String
    let status: String
}

struct AllBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}

struct BreedGroup {
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

struct Breed: Equatable {
    let mainBreed: String
    let subBreed: String?
    
    var name: String {
        subBreed.map { "\($0.capitalized) \(mainBreed.capitalized)" } ?? mainBreed.capitalized
    }
    
    public static func ==(lhs: Breed, rhs: Breed) -> Bool {
        return lhs.mainBreed == rhs.mainBreed &&
               lhs.subBreed == rhs.subBreed
    }
    
    init(mainBreed: String, subBreed: String?) {
        self.mainBreed = mainBreed.lowercased()
        self.subBreed = subBreed?.lowercased()
    }
}

struct DogImage {
    let imageURL: String
    let breed: Breed
    
    init(from response: DogImageResponse) {
        self.imageURL = response.message
        
        // Extract breed from URL path
        // URL format: https://images.dog.ceo/breeds/[breed]/[filename]
        guard let url = URL(string: response.message),
              url.pathComponents.count >= 3 && url.pathComponents[1] == "breeds" else {
            self.breed = Breed(mainBreed: "unknown", subBreed: nil)
            return
        }
        
        let breedComponent = url.pathComponents[2]
        // Handle sub-breeds (e.g., "hound-afghan")
        let breedParts = breedComponent.split(separator: "-")
        if breedParts.count == 2 {
            // Capitalize and join sub-breeds (e.g., "Afghan Hound")
            self.breed = Breed(mainBreed: String(breedParts[0]), subBreed: String(breedParts[1]))
        } else {
            self.breed = Breed(mainBreed: String(breedParts[0]), subBreed: nil)
        }
    }
}

@MainActor
class DogAPIService: ObservableObject {
    private let baseURL = "https://dog.ceo/api"
    private let session = URLSession.shared
    
    enum APIError: Error, LocalizedError {
        case invalidURL
        case noData
        case decodingError
        case networkError(Error)
        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from server"
            }
        }
    }
    
    /// Fetches a random dog image
    func fetchRandomDogImage() async throws -> DogImage {
        guard let url = URL(string: "\(baseURL)/breeds/image/random") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            guard !data.isEmpty else {
                throw APIError.noData
            }
            
            let dogResponse = try JSONDecoder().decode(DogImageResponse.self, from: data)
            return DogImage(from: dogResponse)
            
        } catch _ as DecodingError {
            throw APIError.decodingError
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    /// Fetches all breeds and their sub-breeds
    func fetchAllBreeds() async throws -> [BreedGroup] {
        guard let url = URL(string: "\(baseURL)/breeds/list/all") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }
            
            guard !data.isEmpty else {
                throw APIError.noData
            }
            
            let breedsResponse = try JSONDecoder().decode(AllBreedsResponse.self, from: data)
            
            // Transform the response into an array of BreedGroup
            var breedGroups: [BreedGroup] = []
            for (mainBreed, subBreeds) in breedsResponse.message {
                let group = BreedGroup(mainBreed: mainBreed, subBreeds: subBreeds)
                breedGroups.append(group)
            }
            
            return breedGroups
            
        } catch _ as DecodingError {
            throw APIError.decodingError
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

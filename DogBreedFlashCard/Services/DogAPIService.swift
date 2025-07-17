import Foundation

struct DogImageResponse: Codable {
    let message: String
    let status: String
}

struct AllBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}

public protocol DogAPIServiceProtocol {
    func fetchRandomDogImage() async throws -> DogImage
    func fetchAllBreeds() async throws -> [BreedGroup]
}

enum DogAPIError: Error, LocalizedError {
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

class DogAPIService: DogAPIServiceProtocol {
    private let baseURL = "https://dog.ceo/api"
    private let session = URLSession.shared
    
    /// Fetches a random dog image
    func fetchRandomDogImage() async throws -> DogImage {
        guard let url = URL(string: "\(baseURL)/breeds/image/random") else {
            throw DogAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw DogAPIError.invalidResponse
            }
            
            guard !data.isEmpty else {
                throw DogAPIError.noData
            }
            
            let dogResponse = try JSONDecoder().decode(DogImageResponse.self, from: data)
            return DogImage(from: dogResponse)
            
        } catch _ as DecodingError {
            throw DogAPIError.decodingError
        } catch let error as DogAPIError {
            throw error
        } catch {
            throw DogAPIError.networkError(error)
        }
    }
    
    /// Fetches all breeds and their sub-breeds
    func fetchAllBreeds() async throws -> [BreedGroup] {
        guard let url = URL(string: "\(baseURL)/breeds/list/all") else {
            throw DogAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200
            else {
                throw DogAPIError.invalidResponse
            }
            
            guard !data.isEmpty else {
                throw DogAPIError.noData
            }
            
            let breedsResponse = try JSONDecoder().decode(AllBreedsResponse.self, from: data)
            
            var breedGroups: [BreedGroup] = []
            for (mainBreed, subBreeds) in breedsResponse.message {
                let group = BreedGroup(mainBreed: mainBreed, subBreeds: subBreeds)
                breedGroups.append(group)
            }
            
            return breedGroups
            
        } catch _ as DecodingError {
            throw DogAPIError.decodingError
        } catch let error as DogAPIError {
            throw error
        } catch {
            throw DogAPIError.networkError(error)
        }
    }
}

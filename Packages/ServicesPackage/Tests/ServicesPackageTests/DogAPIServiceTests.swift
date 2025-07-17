import Foundation
import ModelsPackage
import Testing

@testable import ServicesPackage

struct DogAPIServiceTests {
    // Given
    let apiService = DogAPIService()

    @Test("Fetch random dog image returns valid DogImage")
    func testFetchRandomDogImageSuccess() async throws {
        // When
        let dogImage = try await apiService.fetchRandomDogImage()

        // Then
        #expect(!dogImage.imageURL.isEmpty, "Image URL should not be empty")
        #expect(dogImage.imageURL.hasPrefix("https://"), "Image URL should start with https://")
        #expect(dogImage.imageURL.contains("images.dog.ceo"), "Image URL should be from dog.ceo domain")
        #expect(!dogImage.breed.name.isEmpty, "Breed should not be empty")
        #expect(dogImage.breed.name != "unknown", "Breed should be extracted from URL")
        #expect(dogImage.breed.name != "unknown", "Breed should be extracted from URL")
    }

    @Test("Fetch random dog image breed extraction works correctly")
    func testBreedExtractionFromURL() async throws {
        // When
        let dogImage = try await apiService.fetchRandomDogImage()

        // Then
        #expect(!dogImage.breed.name.isEmpty, "Breed name should be extracted")
        #expect(dogImage.breed.name.first?.isUppercase == true, "Breed name should be capitalized")

        // Verify breed is not just the raw URL component
        #expect(
            dogImage.breed.name.allSatisfy {
                $0.isLetter
                || $0.isWhitespace
            }, "Breed name (\(dogImage.breed.name)) should not contain symbols or numbers")
        #expect(
            dogImage.breed.mainBreed.allSatisfy { $0.isLetter },
            "mainBreed (\(dogImage.breed.mainBreed)) should not contain symbols or numbers")
        #expect(
            (dogImage.breed.subBreed?.allSatisfy { $0.isLetter } ?? true),
            "subBreed (\(dogImage.breed.subBreed ?? "none")) should not contain symbols or numbers")
    }

    @Test("Multiple fetch random dog image calls return different results")
    func testMultipleFetchCallsReturnDifferentResults() async throws {
        // When
        let dogImage1 = try await apiService.fetchRandomDogImage()
        let dogImage2 = try await apiService.fetchRandomDogImage()
        let dogImage3 = try await apiService.fetchRandomDogImage()
        let dogImage4 = try await apiService.fetchRandomDogImage()
        let dogImage5 = try await apiService.fetchRandomDogImage()

        // Then
        let imageURLs = [
            dogImage1.imageURL, dogImage2.imageURL, dogImage3.imageURL, dogImage4.imageURL,
            dogImage5.imageURL
        ]
        let uniqueURLs = Set(imageURLs)

        // At least 2 out of 5 should be different (very high probability)
        #expect(uniqueURLs.count >= 2, "Multiple calls should return different images")
    }

    @Test("Fetch all breeds returns valid breed groups")
    func testFetchAllBreedsSuccess() async throws {
        // When
        let groups = try await apiService.fetchAllBreeds()

        // Then
        #expect(!groups.isEmpty, "Should return at least one breed group")
        #expect(groups.count > 50, "Should return many breed groups (API has 100+ breeds)")

        // Check structure of first breed group
        let firstGroup = groups.first!
        #expect(!firstGroup.mainBreed.isEmpty, "Main breed should not be empty")
        #expect(
            firstGroup.mainBreed.allSatisfy { $0.isLetter }, "Main breed should only contain letters")
    }

    @Test("Fetch all breeds contains expected common breeds")
    func testFetchAllBreedsContainsCommonBreeds() async throws {
        // When
        let groups = try await apiService.fetchAllBreeds()
        let mainBreeds = groups.map { $0.mainBreed }

        // Then - Check for some common breeds that should always be available
        let expectedBreeds = ["bulldog", "labrador", "retriever", "terrier", "poodle", "papillon"]

        for expectedBreed in expectedBreeds {
            let hasBreed = mainBreeds.contains(expectedBreed)
            #expect(hasBreed, "Should contain \(expectedBreed)")
        }
    }

    @Test("Fetch all breeds has proper sub-breed structure")
    func testFetchAllBreedsSubBreedStructure() async throws {
        // When
        let groups = try await apiService.fetchAllBreeds()

        // Then
        // Find a breed group that has sub-breeds (like terrier)
        let breedWithSubBreeds = groups.first { group in
            !group.subBreeds.isEmpty
        }

        #expect(breedWithSubBreeds != nil, "Should have at least one breed with sub-breeds")

        if let group = breedWithSubBreeds {
            #expect(!group.subBreeds.isEmpty, "Sub-breeds array should not be empty")

            for subBreed in group.subBreeds {
                #expect(!subBreed.isEmpty, "Sub-breed should not be empty")
                #expect(subBreed.allSatisfy { $0.isLetter }, "Sub-breed should only contain letters")
            }
        }
    }

    @Test("DogImage initializer handles breed extraction correctly")
    func testDogImageBreedExtraction() throws {
        // Given
        let testCases: [(url: String, expectedBreed: Breed)] = [
            (
                "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
                Breed(mainBreed: "hound", subBreed: "afghan")
            ),
            (
                "https://images.dog.ceo/breeds/bulldog-boston/n02096585_1023.jpg",
                Breed(mainBreed: "bulldog", subBreed: "boston")
            ),
            (
                "https://images.dog.ceo/breeds/retriever-golden/n02099601_1001.jpg",
                Breed(mainBreed: "retriever", subBreed: "golden")
            ),
            (
                "https://images.dog.ceo/breeds/labrador/n02099712_1001.jpg",
                Breed(mainBreed: "labrador", subBreed: nil)
            ),
            (
                "https://images.dog.ceo/breeds/poodle/n02113799_1001.jpg",
                Breed(mainBreed: "poodle", subBreed: nil)
            )
        ]

        // When & Then
        for testCase in testCases {
            let response = DogImageResponse(message: testCase.url, status: "success")
            let dogImage = DogImage(from: response)

            #expect(
                dogImage.breed == testCase.expectedBreed,
                "Expected '\(testCase.expectedBreed)' but got '\(dogImage.breed)' for URL: \(testCase.url)")
        }
    }

    @Test("DogImage initializer handles invalid URL")
    func testDogImageInvalidURL() throws {
        // Given
        let invalidResponse = DogImageResponse(message: "invalid-url", status: "success")

        // When
        let dogImage = DogImage(from: invalidResponse)

        // Then
        #expect(dogImage.breed.name == "Unknown", "Should return 'Unknown' for invalid URL")
        #expect(dogImage.imageURL == "invalid-url", "Should preserve original message")
    }

    @Test("Random dog image breed exists in complete breeds list")
    func testRandomDogImageBreedExistsInAllBreedsList() async throws {
        // Given
        let groups = try await apiService.fetchAllBreeds()
        let allBreedNames = groups.flatMap { $0.names }

        // Run the test 5 times to ensure consistency
        for iteration in 1...5 {
            // When
            let randomImage = try await apiService.fetchRandomDogImage()

            // Then
            let randomImageBreed = randomImage.breed.name

            // The random image breed should be findable in our all breeds list
            let breedFound = allBreedNames.contains(randomImageBreed)

            #expect(
                breedFound,
                "Iteration \(iteration): Random image breed '\(randomImageBreed)' should exist in the all-breeds list"
            )
        }
    }

    @Test("DogImageResponse struct decodes correctly")
    func testDogImageResponseDecodingSuccess() throws {
        // Given
        let jsonString = """
      {
          "message": "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
          "status": "success"
      }
      """
        let jsonData = jsonString.data(using: .utf8)!

        // When
        let response = try JSONDecoder().decode(DogImageResponse.self, from: jsonData)

        // Then
        #expect(
            response.message == "https://images.dog.ceo/breeds/hound-afghan/n02088094_1003.jpg",
            "Should decode message correctly")
        #expect(response.status == "success", "Should decode status correctly")
    }

    @Test("AllBreedsResponse struct decodes correctly")
    func testAllBreedsResponseDecodingSuccess() throws {
        // Given
        let jsonString = """
      {
          "message": {
              "terrier": ["scottish", "welsh"],
              "bulldog": [],
              "retriever": ["golden", "labrador"]
          },
          "status": "success"
      }
      """
        let jsonData = jsonString.data(using: .utf8)!

        // When
        let response = try JSONDecoder().decode(AllBreedsResponse.self, from: jsonData)

        // Then
        #expect(response.status == "success", "Should decode status correctly")
        #expect(response.message.count == 3, "Should have 3 breed groups")
        #expect(
            response.message["terrier"] == ["scottish", "welsh"],
            "Should decode terrier sub-breeds correctly")
        #expect(response.message["bulldog"] == [], "Should decode empty sub-breeds correctly")
        #expect(
            response.message["retriever"] == ["golden", "labrador"],
            "Should decode retriever sub-breeds correctly")
    }

    @Test("AllBreedsResponse struct handles failure response")
    func testAllBreedsResponseDecodingFailure() throws {
        // Given
        let jsonString = """
      {
          "message": "Breed not found (master breed does not exist)",
          "status": "error"
      }
      """
        let jsonData = jsonString.data(using: .utf8)!

        // When & Then
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(AllBreedsResponse.self, from: jsonData)
        }
    }

    @Test("DogImageResponse struct handles failure response")
    func testDogImageResponseDecodingFailure() throws {
        // Given
        let jsonString = """
      {
          "message": "Breed not found (master breed does not exist)",
          "status": "error"
      }
      """
        let jsonData = jsonString.data(using: .utf8)!

        // When
        let response = try JSONDecoder().decode(DogImageResponse.self, from: jsonData)

        // Then
        #expect(
            response.message == "Breed not found (master breed does not exist)",
            "Should decode error message correctly")
        #expect(response.status == "error", "Should decode error status correctly")
    }
}

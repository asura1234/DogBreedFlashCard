import Foundation
import Testing

@testable import ModelsPackage

struct BreedAndBreedGroupTests {
    @Test("Breed is initialized correctly and is not case sensitive to the input parameters")
    func testBreedInitialization() {
        let breed1 = Breed(mainBreed: "poodle", subBreed: nil)
        #expect(breed1.name == "Poodle")
        #expect(breed1.name.first?.isUppercase == true, "Breed name should be capitalized")
        #expect(breed1.name.allSatisfy { $0.isLetter }, "bread1 name should contain only letters")
        #expect(breed1.mainBreed == "poodle")
        #expect(breed1.subBreed == nil)
        
        let breed2 = Breed(mainBreed: "retriever", subBreed: "golden")
        #expect(breed2.name == "Golden Retriever")
        let nameParts2 = breed2.name.split(separator: " ")
        #expect(nameParts2.count == 2, "breed2 should have both main and sub breeds")
        #expect(
            nameParts2[0].first?.isUppercase == true && nameParts2[1].first?.isUppercase == true,
            "Both parts should be capitalized")
        #expect(breed2.mainBreed == "retriever")
        #expect(breed2.subBreed == "golden")
    }
    
    @Test("BreedGroup is initialized correctly and is not case sensitive to the input parameters")
    func testBreedGroupInitialization() {
        let breedGroup1 = BreedGroup(mainBreed: "poodle", subBreeds: [])
        
        #expect(breedGroup1.names.count == 1, "Breed group should have 1 name")
        #expect(breedGroup1.names.contains("Poodle"), "Breed group should contain Poodle")
        
        let breedGroup2 = BreedGroup(
            mainBreed: "retriever", subBreeds: ["chesapeake", "curly", "flatcoated", "golden"])
        
        for name in breedGroup2.names {
            let nameParts = name.split(separator: " ")
            #expect(nameParts.count == 2, "Each name in breedGroup2 should have both main and sub breeds")
            #expect(
                nameParts[0].first?.isUppercase == true && nameParts[1].first?.isUppercase == true,
                "Each name in breedgroup2 should have both parts should be capitalized")
        }
        
        #expect(breedGroup2.names.count == 4, "Breed group should have 4 names")
        #expect(
            breedGroup2.names.contains("Chesapeake Retriever"),
            "Breed group should contain Chesapeake Retriever")
        #expect(
            breedGroup2.names.contains("Curly Retriever"), "Breed group should contain Curly Retriever")
        #expect(
            breedGroup2.names.contains("Flatcoated Retriever"),
            "Breed group should contain Flatcoated Retriever")
        #expect(
            breedGroup2.names.contains("Golden Retriever"), "Breed group should contain Golden Retriever")
    }
}

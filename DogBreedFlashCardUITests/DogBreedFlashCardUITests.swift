import XCTest

@testable import DogBreedFlashCard

final class DogBreedFlashCardUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        app.launchEnvironment["TESTING"] = "1"
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testCorrectAnswerButton() throws {
        let gameCardStack = app.otherElements["GameCardStack"]
        XCTAssertTrue(gameCardStack.waitForExistence(timeout: 5.0), "Game card stack should appear")

        let breedButton0 = app.buttons["BreedButton0"]
        let breedButton1 = app.buttons["BreedButton1"]

        XCTAssertTrue(breedButton0.waitForExistence(timeout: 3.0), "First breed button should exist")
        XCTAssertTrue(breedButton1.exists, "Second breed button should exist")

        let gamesPlayedLabel = app.staticTexts["GamesPlayedLabel"]
        let correctAnswersLabel = app.staticTexts["CorrectAnswersLabel"]

        XCTAssertTrue(
            gamesPlayedLabel.waitForExistence(timeout: 2.0), "Games played label should exist")
        XCTAssertTrue(correctAnswersLabel.exists, "Correct answers label should exist")

        // The fake game uses a fake game factory, which always has "Afghan Hound" as correct and "Golden Retriever" as wrong
        let correctButton = breedButton0.label.contains("afghan") ? breedButton0 : breedButton1

        correctButton.tap()

        Thread.sleep(forTimeInterval: 1.0)

        XCTAssertTrue(breedButton0.exists, "Buttons should still exist after correct answer")
        XCTAssertTrue(breedButton1.exists, "Buttons should still exist after correct answer")

        let updatedGamesPlayedText = gamesPlayedLabel.label
        let updatedCorrectAnswersText = correctAnswersLabel.label

        XCTAssertTrue(updatedGamesPlayedText.contains("1"), "Games played should be incremented")
        XCTAssertTrue(updatedCorrectAnswersText.contains("1"), "Correct answers should be incremented")
    }

    func testIncorrectAnswerButton() throws {
        let gameCardStack = app.otherElements["GameCardStack"]
        XCTAssertTrue(gameCardStack.waitForExistence(timeout: 5.0), "Game card stack should appear")

        let breedButton0 = app.buttons["BreedButton0"]
        let breedButton1 = app.buttons["BreedButton1"]

        XCTAssertTrue(breedButton0.waitForExistence(timeout: 3.0), "First breed button should exist")
        XCTAssertTrue(breedButton1.exists, "Second breed button should exist")

        let gamesPlayedLabel = app.staticTexts["GamesPlayedLabel"]
        let correctAnswersLabel = app.staticTexts["CorrectAnswersLabel"]

        XCTAssertTrue(
            gamesPlayedLabel.waitForExistence(timeout: 2.0), "Games played label should exist")
        XCTAssertTrue(correctAnswersLabel.exists, "Correct answers label should exist")

        // The fake game uses a fake game factory, which always has "Afghan Hound" as correct and "Golden Retriever" as wrong
        let incorrectButton = breedButton0.label.contains("Golden") ? breedButton0 : breedButton1

        incorrectButton.tap()

        Thread.sleep(forTimeInterval: 1.0)

        XCTAssertTrue(breedButton0.exists, "Buttons should still exist after incorrect answer")
        XCTAssertTrue(breedButton1.exists, "Buttons should still exist after incorrect answer")

        let updatedGamesPlayedText = gamesPlayedLabel.label
        let updatedCorrectAnswersText = correctAnswersLabel.label

        XCTAssertTrue(updatedGamesPlayedText.contains("1"), "Games played should be incremented")
        XCTAssertTrue(updatedCorrectAnswersText.contains("0"), "Correct answers should remain 0")
    }

    func testSwipeToSkip() throws {
        let gameCardStack = app.otherElements["GameCardStack"]
        XCTAssertTrue(gameCardStack.waitForExistence(timeout: 5.0), "Game card stack should appear")

        let gamesPlayedLabel = app.staticTexts["GamesPlayedLabel"]
        let correctAnswersLabel = app.staticTexts["CorrectAnswersLabel"]

        XCTAssertTrue(
            gamesPlayedLabel.waitForExistence(timeout: 2.0), "Games played label should exist")
        XCTAssertTrue(correctAnswersLabel.exists, "Correct answers label should exist")

        let breedButton0 = app.buttons["BreedButton0"]
        let breedButton1 = app.buttons["BreedButton1"]
        XCTAssertTrue(breedButton0.waitForExistence(timeout: 3.0), "First breed button should exist")
        XCTAssertTrue(breedButton1.exists, "Second breed button should exist")

        let startCoordinate = gameCardStack.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5))
        let endCoordinate = gameCardStack.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.5))
        startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)

        Thread.sleep(forTimeInterval: 1.0)

        XCTAssertTrue(breedButton0.exists, "Buttons should still exist after swipe")
        XCTAssertTrue(breedButton1.exists, "Buttons should still exist after swipe")

        let updatedGamesPlayedText = gamesPlayedLabel.label
        let updatedCorrectAnswersText = correctAnswersLabel.label

        XCTAssertTrue(
            updatedGamesPlayedText.contains("1"), "Games played should be incremented after swipe")
        XCTAssertTrue(
            updatedCorrectAnswersText.contains("0"), "Correct answers should remain 0 after swipe skip")
    }
}

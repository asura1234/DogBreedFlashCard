# Dog Breed Flash Card

A SwiftUI iOS app that helps users learn dog breeds through an interactive guessing game.

## Features

- Interactive flash card game with dog breed images
- Sound effects for correct/incorrect answers
- Progress tracking throughout gameplay
- Clean, intuitive user interface

## Backend
This project is based this public and free API: https://dog.ceo/dog-api/documentation

## Architecture

This project demonstrates modern Swift development practices with **modular Swift Package architecture**:

- **GamePackage**: Core game logic and progress tracking
- **ModelsPackage**: Data models for breeds and images  
- **ServicesPackage**: API service for fetching dog images

Each package is self-contained with clear dependencies, promoting code reusability and maintainability.

## Testing

The project includes **comprehensive test coverage** across all modules:

- Unit tests for all Swift packages
- UI tests for the main application
- Automated test runner script (`scripts/run_tests.sh`)
- Fake implementations for reliable testing

Run all tests with:
```bash
./scripts/run_tests.sh
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
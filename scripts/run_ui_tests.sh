#!/bin/bash

# Script to run UI tests for DogBreedFlashCard on iPhone 16 Simulator with latest iOS
set -e

echo "🧪 Running UI tests for DogBreedFlashCard on iPhone 16 Simulator..."
echo "================================================"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_FILE="$PROJECT_ROOT/DogBreedFlashCard.xcodeproj"

# Check if project file exists
if [ ! -d "$PROJECT_FILE" ]; then
    echo "❌ Error: Xcode project not found at $PROJECT_FILE"
    exit 1
fi

# Check if UI test target exists
if ! xcodebuild -project "$PROJECT_FILE" -list | grep -q "DogBreedFlashCardUITests"; then
    echo "❌ Error: DogBreedFlashCardUITests target not found in project"
    echo "Available targets:"
    xcodebuild -project "$PROJECT_FILE" -list
    exit 1
fi

echo "📱 Target: DogBreedFlashCardUITests"
echo "📱 Device: iPhone 16 Simulator"
echo "📱 OS: Latest iOS"
echo ""

# Change to project directory
cd "$PROJECT_ROOT"

# Run UI tests
echo "🚀 Starting UI tests..."
echo "----------------------------------------"

if xcodebuild test \
    -project "DogBreedFlashCard.xcodeproj" \
    -scheme "DogBreedFlashCard" \
    -destination "platform=iOS Simulator,name=iPhone 16,OS=latest" \
    -only-testing:DogBreedFlashCardUITests \
    -derivedDataPath ".build"; then
    
    echo ""
    echo "✅ UI tests passed successfully!"
    echo "================================================"
    echo "📊 Test Summary:"
    echo "   Target: DogBreedFlashCardUITests"
    echo "   Device: iPhone 16 Simulator"
    echo "   Status: ✅ PASSED"
    exit 0
else
    echo ""
    echo "❌ UI tests failed!"
    echo "================================================"
    echo "📊 Test Summary:"
    echo "   Target: DogBreedFlashCardUITests"
    echo "   Device: iPhone 16 Simulator"
    echo "   Status: ❌ FAILED"
    exit 1
fi 
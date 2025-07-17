#!/bin/bash

# Script to run tests for all local Swift packages
set -e

echo "🧪 Running tests for all local Swift packages..."
echo "================================================"

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="$PROJECT_ROOT/Packages"

# Check if Packages directory exists
if [ ! -d "$PACKAGES_DIR" ]; then
    echo "❌ Error: Packages directory not found at $PACKAGES_DIR"
    exit 1
fi

# Find all Package.swift files and run tests
PACKAGE_DIRS=($(find "$PACKAGES_DIR" -name "Package.swift" -exec dirname {} \;))

if [ ${#PACKAGE_DIRS[@]} -eq 0 ]; then
    echo "❌ No Swift packages found in $PACKAGES_DIR"
    exit 1
fi

echo "Found ${#PACKAGE_DIRS[@]} Swift package(s):"
for dir in "${PACKAGE_DIRS[@]}"; do
    echo "  - $(basename "$dir")"
done
echo ""

# Run tests for each package
SUCCESS_COUNT=0
TOTAL_COUNT=${#PACKAGE_DIRS[@]}

for PACKAGE_DIR in "${PACKAGE_DIRS[@]}"; do
    PACKAGE_NAME=$(basename "$PACKAGE_DIR")
    echo "🔍 Testing $PACKAGE_NAME..."
    echo "----------------------------------------"
    
    cd "$PACKAGE_DIR"
    
    if swift test; then
        echo "✅ $PACKAGE_NAME tests passed"
        ((SUCCESS_COUNT++))
    else
        echo "❌ $PACKAGE_NAME tests failed"
    fi
    
    echo ""
done

# Summary
echo "================================================"
echo "📊 Test Summary:"
echo "   Packages tested: $TOTAL_COUNT"
echo "   Passed: $SUCCESS_COUNT"
echo "   Failed: $((TOTAL_COUNT - SUCCESS_COUNT))"

if [ $SUCCESS_COUNT -eq $TOTAL_COUNT ]; then
    echo "🎉 All package tests passed!"
    exit 0
else
    echo "💥 Some package tests failed!"
    exit 1
fi
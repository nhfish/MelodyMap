#!/bin/bash

# MelodyMap Test Runner Script
# Usage: ./scripts/run-tests.sh [unit|ui|performance|all]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to run unit tests
run_unit_tests() {
    print_status "Running unit tests..."
    
    xcodebuild test \
        -project MelodyMap.xcodeproj \
        -scheme MelodyMap \
        -destination 'platform=iOS Simulator,name=iPhone 13,OS=15.2' \
        -derivedDataPath build \
        -resultBundlePath TestResults.xcresult \
        -enableCodeCoverage YES
    
    print_success "Unit tests completed successfully!"
}

# Function to run UI tests
run_ui_tests() {
    print_status "Running UI tests..."
    
    xcodebuild test \
        -project MelodyMap.xcodeproj \
        -scheme MelodyMapUITests \
        -destination 'platform=iOS Simulator,name=iPhone 13,OS=15.2' \
        -derivedDataPath build \
        -resultBundlePath UITestResults.xcresult
    
    print_success "UI tests completed successfully!"
}

# Function to run performance tests
run_performance_tests() {
    print_status "Running performance tests..."
    
    xcodebuild test \
        -project MelodyMap.xcodeproj \
        -scheme MelodyMap \
        -destination 'platform=iOS Simulator,name=iPhone 13,OS=15.2' \
        -only-testing:MelodyMapTests/ContentServiceTests/testCacheLoadPerformance \
        -only-testing:MelodyMapTests/ContentServiceTests/testCacheSavePerformance \
        -only-testing:MelodyMapTests/SearchViewModelTests/testSearchPerformance \
        -derivedDataPath build \
        -resultBundlePath PerformanceTestResults.xcresult
    
    print_success "Performance tests completed successfully!"
}

# Function to run accessibility tests
run_accessibility_tests() {
    print_status "Running accessibility tests..."
    
    xcodebuild test \
        -project MelodyMap.xcodeproj \
        -scheme MelodyMapUITests \
        -destination 'platform=iOS Simulator,name=iPhone 13,OS=15.2' \
        -only-testing:MelodyMapUITests/AccessibilityTests \
        -derivedDataPath build \
        -resultBundlePath AccessibilityTestResults.xcresult
    
    print_success "Accessibility tests completed successfully!"
}

# Function to generate coverage report
generate_coverage_report() {
    print_status "Generating coverage report..."
    
    if [ -f "TestResults.xcresult" ]; then
        xcrun xccov view --report --html TestResults.xcresult --output-dir coverage-report
        print_success "Coverage report generated in coverage-report/"
    else
        print_warning "No test results found for coverage report"
    fi
}

# Function to clean up
cleanup() {
    print_status "Cleaning up build artifacts..."
    rm -rf build
    rm -f *.xcresult
    print_success "Cleanup completed!"
}

# Main script logic
case "${1:-all}" in
    "unit")
        run_unit_tests
        generate_coverage_report
        ;;
    "ui")
        run_ui_tests
        ;;
    "performance")
        run_performance_tests
        ;;
    "accessibility")
        run_accessibility_tests
        ;;
    "all")
        print_status "Running all tests..."
        run_unit_tests
        run_ui_tests
        run_performance_tests
        run_accessibility_tests
        generate_coverage_report
        print_success "All tests completed successfully!"
        ;;
    "clean")
        cleanup
        ;;
    *)
        print_error "Invalid option: $1"
        echo "Usage: $0 [unit|ui|performance|accessibility|all|clean]"
        echo ""
        echo "Options:"
        echo "  unit         Run unit tests only"
        echo "  ui           Run UI tests only"
        echo "  performance  Run performance tests only"
        echo "  accessibility Run accessibility tests only"
        echo "  all          Run all tests (default)"
        echo "  clean        Clean up build artifacts"
        exit 1
        ;;
esac 
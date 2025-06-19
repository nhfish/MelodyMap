# GMASPM (Google Mobile Ads Swift Package Manager)

A Swift Package Manager wrapper for the Google Mobile Ads SDK for iOS.

## Overview
This package provides easy integration of Google Mobile Ads into iOS applications built with Swift and SwiftUI. It includes the complete Google Mobile Ads framework with support for rewarded ads, banner ads, and other ad formats.

## Current Status
**DISABLED** - This package is currently disabled during development to focus on core app functionality. The app uses a mock implementation for testing purposes.

## Features
- Google Mobile Ads SDK integration
- Support for rewarded ads, banner ads, and other formats
- Swift Package Manager compatibility
- iOS 15.2+ support

## Usage
To enable Google Mobile Ads integration:

1. Go to Project Settings ▸ Build Settings ▸ Other Swift Flags
2. Add `-D ADS_ENABLED`
3. Ensure this package is properly linked in your project
4. Test with actual ad units

## Disabled State
When disabled (current state):
- The system uses mock implementation
- No actual ad requests are made
- Development can continue without SDK compatibility issues
- No Google Mobile Ads framework required

## Requirements
- iOS 15.2+
- Xcode 13+
- Swift 5.0+

## License
Google Mobile Ads SDK license applies. See Google's official documentation for details.

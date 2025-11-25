# Tinto (cafecito-ios)

**Role:** Senior iOS Architect & Backend Lead
**Tech Stack:** iOS 18 (SwiftUI), MapKit (Native), Firebase (Firestore + Auth + Storage)

## 1. Project Overview

"Tinto" is a crowd-sourced coffee discovery app.
- **Core Loop:** Users view a map of coffee shops -> Filter by "Brew Method" (Nitro, Pour Over) -> View/Add Ratings -> Earn Badges.
- **Key Technical Constraint:** We are using **Apple MapKit** (not Google Maps) to save costs. We must build a custom "Shop Adder" using `MKLocalSearch`.

## 2. Architecture

### Data Models (`Sources/Models`)
- **Shop**: Represents a coffee shop with aggregated ratings.
- **Review**: Individual user reviews with specific brew method ratings and vibe tags.
- **User**: User profile with badges and settings.

### Core Managers (`Sources/Managers`)
- **LocationManager**: Handles CoreLocation permissions and updates.
- **ShopDiscoveryManager**: Wrapper around `MKLocalSearch` to find shops and sync them to Firestore.

## 3. Setup Instructions

### Prerequisites
- Xcode 16+ (for iOS 18 SDK)
- Firebase Account

### Firebase Setup
1. Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an iOS App to the project.
3. Download `GoogleService-Info.plist`.
4. Drag `GoogleService-Info.plist` into the project root in Xcode.

### Dependencies
This project relies on the Firebase iOS SDK.
1. In Xcode, go to **File > Add Packages Dependencies...**
2. Enter `https://github.com/firebase/firebase-ios-sdk`.
3. Select the following libraries:
   - `FirebaseFirestore`
   - `FirebaseAuth`
   - `FirebaseStorage`

### Configuration
Ensure your `Info.plist` includes the permissions found in `Configuration/Info_Permissions.plist`:
- `NSLocationWhenInUseUsageDescription`
- `NSCameraUsageDescription`

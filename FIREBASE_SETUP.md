# Firebase Setup Guide for RaktaSetu

## Overview
This guide explains the Firebase configuration and Firestore database structure for the RaktaSetu blood donation app.

## Prerequisites
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase account and project created at https://console.firebase.google.com
- Flutter Firebase packages installed (already in pubspec.yaml)

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Create Project"
3. Enter project name: `raktasetu-app`
4. Enable Google Analytics (optional)
5. Create project

## Step 2: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Phone** authentication
3. Configure phone sign-in settings:
   - Add your supported regions/countries
   - For testing: Add test phone numbers with test OTP codes

## Step 3: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Select region: `asia-south1` (India)
4. Start in **Production mode**
5. Click "Create"

### Security Rules Configuration

Update Firestore Rules to:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - User can read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Donors collection - Public read, authenticated write
    match /donors/{donorId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == donorId;
    }

    // Blood Requests - Public read, authenticated write
    match /bloodRequests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.requesterUid;
    }

    // Donations - User can read/write their own
    match /donations/{donationId} {
      allow read: if request.auth.uid == resource.data.uid;
      allow write: if request.auth.uid == resource.data.uid;
    }

    // Blood Banks - Public read only
    match /bloodBanks/{bankId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Notifications - User can read their own
    match /notifications/{notificationId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if false;
    }
  }
}
```

## Step 4: Configure Firebase in Flutter

### Option A: Automatic Configuration (Recommended)

```bash
cd c:\Users\prath\OneDrive\Desktop\raktasetu
flutterfire configure
```

Select:
- Firebase Project: `raktasetu-app`
- Platform: Android and iOS
- Features: Authentication, Firestore

This will generate `lib/firebase_options.dart`

### Option B: Manual Configuration

The `lib/firebase_options.dart` file is already created with placeholder values. Update it with your Firebase project credentials from Firebase Console:

1. Go to Firebase Console → Project Settings
2. Copy API keys and credentials
3. Update `firebase_options.dart`

## Step 5: Create Firestore Collections

### 1. Users Collection
```
Collection: users
Document: {user_uid}
Fields:
  - uid: string
  - name: string
  - phoneNumber: string
  - bloodGroup: string (O+, O-, A+, A-, B+, B-, AB+, AB-)
  - district: string
  - avatar: string (URL)
  - donations: number (0)
  - unitsCollected: number (0)
  - lastDonationDate: timestamp (null)
  - rating: number (5.0)
  - isComplete: boolean (true)
  - createdAt: timestamp
  - updatedAt: timestamp
```

### 2. Donors Collection
```
Collection: donors
Document: {user_uid}
Fields:
  - id: string (user_uid)
  - name: string
  - phoneNumber: string
  - bloodGroup: string
  - latitude: number
  - longitude: number
  - district: string
  - lastDonationDate: timestamp (null)
  - isAvailable: boolean (true)
  - donations: number (0)
  - rating: number (5.0)
  - createdAt: timestamp
  - updatedAt: timestamp
```

### 3. Blood Requests Collection
```
Collection: bloodRequests
Document: {auto_generated_id}
Fields:
  - requesterUid: string
  - patientName: string
  - hospitalName: string
  - bloodGroup: string
  - units: number
  - urgency: string (Critical, High, Medium)
  - contactNumber: string
  - notes: string (optional)
  - status: string (active, fulfilled, cancelled)
  - createdAt: timestamp
  - updatedAt: timestamp
```

### 4. Donations Collection
```
Collection: donations
Document: {auto_generated_id}
Fields:
  - uid: string (donor uid)
  - bloodGroup: string
  - location: string
  - units: number
  - status: string (completed, pending, cancelled)
  - donatedAt: timestamp
```

### 5. Blood Banks Collection
```
Collection: bloodBanks
Document: {auto_generated_id}
Fields:
  - name: string
  - address: string
  - phone: string
  - distance: string
  - rating: number
  - availableBloodGroups: array
  - isOpen: boolean
  - openHours: string
  - latitude: number
  - longitude: number
```

### 6. Notifications Collection
```
Collection: notifications
Document: {auto_generated_id}
Fields:
  - userId: string
  - title: string
  - message: string
  - type: string (urgentNeed, donorRequest, nearbyAlert, etc.)
  - metadata: map (optional)
  - isRead: boolean (false)
  - createdAt: timestamp
```

## Step 6: Test Phone Authentication

In Firebase Console:

1. Go to **Authentication** → **Sign-in method** → **Phone**
2. Scroll to "Phone numbers for testing"
3. Add test numbers:
   - Phone: `+919876543210` → OTP: `123456`
   - Phone: `+919999999999` → OTP: `123456`

This allows you to test without actual SMS

## Step 7: Initialize Firestore with Sample Data

For initial testing, add sample donors and blood banks to Firestore:

### Sample Donors
```json
{
  "id": "donor_001",
  "name": "Rohan Kumar",
  "phoneNumber": "+919876543210",
  "bloodGroup": "B+",
  "latitude": 12.9716,
  "longitude": 77.5946,
  "district": "Bangalore",
  "lastDonationDate": null,
  "isAvailable": true,
  "donations": 5,
  "rating": 4.8
}
```

### Sample Blood Banks
```json
{
  "id": "bank_001",
  "name": "Apollo Blood Bank",
  "address": "Apollo Hospital, Koramangala, Bangalore",
  "phone": "+91 80 4006 6666",
  "distance": "1.2 km",
  "rating": 4.8,
  "availableBloodGroups": ["O+", "O-", "A+", "A-", "B+", "B-", "AB+", "AB-"],
  "isOpen": true,
  "openHours": "6:00 AM - 10:00 PM",
  "latitude": 12.9716,
  "longitude": 77.5946
}
```

## Step 8: Environment Variables

Update `lib/firebase_options.dart` with your Firebase project credentials:

1. Firebase Console → Project Settings → General
2. Scroll to "Your apps" → Android app → Copy **google-services.json** content
3. Copy the API keys and database URLs
4. Update `firebase_options.dart`

## Running the App

```bash
flutter pub get
flutter run
```

## Testing Firebase Connection

1. **Test Authentication:**
   - Go to Login page
   - Enter test phone: `+919876543210`
   - Enter OTP: `123456`
   - Should see "Auth Success"

2. **Test Firestore:**
   - Complete signup
   - Check Firebase Console → Firestore → Users collection
   - You should see user document created

3. **Test Blood Requests:**
   - Post blood request
   - Check Firebase Console → Firestore → bloodRequests collection
   - Request should be saved

## Troubleshooting

### "Firebase not initialized" Error
- Make sure `Firebase.initializeApp()` is called in `main.dart`
- Check that `firebase_core` is imported correctly

### OTP Not Sending
- Enable Phone Authentication in Firebase Console
- Add test phone numbers if in development
- Check Android/iOS configuration

### Firestore Document Not Saving
- Check Security Rules allow the operation
- Check that user is authenticated (currentUser != null)
- Check browser console for errors

### Performance Issues
- Use appropriate indexing in Firestore
- Limit query results with `.limit()` and `.offset()`
- Cache data locally when possible

## Next Steps

1. Set up Cloud Functions for automated tasks:
   - Send notifications when blood requests are created
   - Calculate donor availability based on donation history
   - Clean up expired blood requests

2. Set up Firebase Cloud Messaging for push notifications

3. Set up Firebase Crashlytics for error monitoring

4. Set up Firebase Analytics for user behavior tracking

## References

- Firebase Console: https://console.firebase.google.com
- Firebase Documentation: https://firebase.google.com/docs
- Flutter Firebase: https://firebase.flutter.dev
- Firestore Security Rules: https://firebase.google.com/docs/firestore/security/start

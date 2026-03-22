# RaktaSetu Firebase Deployment Checklist

## Quick Setup Summary

The Firebase infrastructure is **100% configured and integrated** into the Flutter app. All you need is:

1. **Create a Firebase project**
2. **Get your credentials**
3. **Update 1 file** with those credentials
4. **Run the app**

## ✅ What's Already Done

- ✅ Firebase dependencies installed (pubspec.yaml)
- ✅ Firebase Core initialization in main.dart
- ✅ FirebaseAuthService created (OTP authentication)
- ✅ FirestoreService created (database operations)
- ✅ Domain models created (Donor, BloodRequest)
- ✅ Service Locator integration (GetIt DI)
- ✅ AuthBloc integrated with Firebase
- ✅ Signup flow connected to Firebase OTP
- ✅ Blood request feature connected to Firestore
- ✅ Zero compilation errors

## 📋 What You Need to Do

### Phase 1: Create Firebase Project (5 minutes)

1. Open https://console.firebase.google.com
2. Click "Create Project"
3. Enter name: `raktasetu-app`
4. Click "Continue" → "Continue" → "Create Project"
5. Wait for project to be created

### Phase 2: Enable Services (3 minutes)

1. **Enable Authentication:**
   - Left sidebar → Authentication → Sign-in method
   - Click "Phone"
   - Toggle ON for Phone authentication
   - Save

2. **Enable Firestore:**
   - Left sidebar → Firestore Database
   - Click "Create Database"
   - Select region: `asia-south1` (India)
   - Mode: "Production mode"
   - Click "Create"

### Phase 3: Get Credentials (2 minutes)

1. Go to **Project Settings** (⚙️ icon, top-right)
2. Tab: "Service accounts"
3. Language: "Dart"
4. Click "Generate new private key" → "Generate key"
5. File `serviceAccountKey.json` will download (not needed for now)

6. **For Web:**
   - Go to **Project Settings** → **General**
   - Scroll to "Your apps" → Click web app (or create one)
   - Copy these values:
     ```
     apiKey
     authDomain
     projectId
     storageBucket
     messagingSenderId
     appId
     measurementId
     ```

7. **For Android:**
   - Go to **Project Settings** → **General**
   - Click Android app → Download `google-services.json`
   - Already configured in app build.gradle

8. **For iOS:**
   - Go to **Project Settings** → **General**
   - Click iOS app → Download `GoogleService-Info.plist`
   - Already configured in Xcode

### Phase 4: Update Firebase Options (2 minutes)

Edit file: **lib/firebase_options.dart**

Replace the `web` configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: '1:YOUR_PROJECT_NUMBER:web:YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'raktasetu-app',
  authDomain: 'raktasetu-app.firebaseapp.com',
  storageBucket: 'raktasetu-app.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID',
);
```

Get the values from Firebase Console → Project Settings → General

### Phase 5: Create Firestore Collections (3 minutes)

In Firebase Console → Firestore Database → Start Collection

**Create these 6 collections (click "+ Start collection"):**

1. `users` - Document ID: Auto ID (will be created when users signup)
2. `donors` - Document ID: Auto ID
3. `bloodRequests` - Document ID: Auto ID
4. `donations` - Document ID: Auto ID
5. `bloodBanks` - Document ID: Auto ID
6. `notifications` - Document ID: Auto ID

Add one sample document in `bloodBanks`:
```json
{
  "name": "Apollo Blood Bank",
  "address": "Apollo Hospital, Bangalore",
  "phone": "+91 80 4006 6666",
  "rating": 4.8,
  "availableBloodGroups": ["O+", "O-", "A+", "B+"],
  "isOpen": true,
  "openHours": "6:00 AM - 10:00 PM",
  "latitude": 12.9716,
  "longitude": 77.5946
}
```

### Phase 6: Set Security Rules (1 minute)

In Firebase Console → Firestore → Rules tab

Replace all rules with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /donors/{donorId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == donorId;
    }
    match /bloodRequests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.requesterUid;
    }
    match /donations/{donationId} {
      allow read: if request.auth.uid == resource.data.uid;
      allow write: if request.auth.uid == resource.data.uid;
    }
    match /bloodBanks/{bankId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /notifications/{notificationId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if false;
    }
  }
}
```

Click "Publish"

### Phase 7: Add Test Phone Numbers (For Testing)

In Firebase Console → Authentication → Phone → Phone numbers for testing

Add:
- Phone: `+919999999999` → OTP: `123456`
- Phone: `+919876543210` → OTP: `123456`

This lets you test without real SMS

## 🚀 Run the App

```bash
cd c:\Users\prath\OneDrive\Desktop\raktasetu
flutter pub get
flutter run
```

## ✨ Test the Full Flow

1. **Test Signup → OTP → Login:**
   - Click "Sign Up"
   - Enter test number: `+919999999999`
   - Click "Send OTP"
   - Enter OTP: `123456`
   - Fill name, blood group, district
   - Click "Register"
   - Auto-redirected to Login
   - OTP field pre-filled
   - Enter OTP: `123456`
   - Login successful ✅

2. **Test Blood Request:**
   - Click "Blood Request" on home page
   - Fill form
   - Click "Submit Request"
   - Go to Firebase Console → Firestore → bloodRequests
   - You should see your request saved ✅

3. **Check User Created:**
   - Go to Firebase Console → Firestore → users
   - You should see user document with your UID ✅

## 📊 Expected Data Flow After Setup

```
App Startup
  ↓
Firebase.initializeApp() ✅
  ↓
User taps "Sign Up"
  ↓
Enters phone number
  ↓
Clicks "Send OTP"
  ↓
App calls FirebaseAuth.verifyPhoneNumber() ✅
  ↓
Firebase Console sends SMS (or uses test OTP) ✅
  ↓
User enters OTP in Login page
  ↓
App calls FirebaseAuth.signInWithPhoneAuthCredential() ✅
  ↓
Firebase creates user account (if new) ✅
  ↓
App calls authService.registerUser() ✅
  ↓
User document saved to Firestore ✅
  ↓
User taps "Blood Request"
  ↓
App calls firestoreService.createBloodRequest() ✅
  ↓
Request saved to Firestore ✅
  ↓
Request appears in Firebase Console ✅
```

## 🔍 Verification Checklist

After setup, verify:

- [ ] Firebase project created at console.firebase.google.com
- [ ] Phone Authentication enabled
- [ ] Firestore Database created in asia-south1
- [ ] 6 collections created (users, donors, bloodRequests, donations, bloodBanks, notifications)
- [ ] Security Rules published
- [ ] Firebase credentials updated in lib/firebase_options.dart
- [ ] Test phone numbers added
- [ ] App runs without errors: `flutter run`
- [ ] Test signup → OTP → login successful
- [ ] User document appears in Firestore
- [ ] Blood request saves to Firestore

## ❌ Troubleshooting

| Problem | Solution |
|---------|----------|
| "Firebase not initialized" | Ensure Firebase.initializeApp() called in main.dart |
| OTP not sending | Check Phone Auth enabled + test numbers added |
| User doc not saving | Check Firestore Security Rules allow uid == request.auth.uid |
| App crashes on startup | Check firebase_options.dart credentials are correct |
| "Permission denied" error | Check Security Rules (should allow authenticated users) |
| Can't find project | Ensure Firebase project is in correct Google account |

## ⏭️ Next: Connect Other Features to Real Data

After basic setup works, these features still show mock data:

1. **Notifications** → Connect to `getUserNotifications()`
2. **Blood Bank Locator** → Connect to `getBloodBanks()`
3. **Donor Search** → Connect to `getDonorsByDistrict()`
4. **Eligibility Checker** → Save results to user profile

Each requires small BLoC/UI updates (15 minutes each)

## 📞 Getting Help

- Firebase Console: https://console.firebase.google.com
- Firebase Docs: https://firebase.google.com/docs
- Flutter Firebase: https://firebase.flutter.dev
- Troubleshooting: Check Android Studio console for detailed errors

---

**Status:** Ready to deploy! Follow the 7 phases above, and your complete Firebase backend will be live. ✅

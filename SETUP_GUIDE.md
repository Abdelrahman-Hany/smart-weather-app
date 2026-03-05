# Setup Guide — New Features

## Overview of New Features

### 1. Firebase Authentication

- **Anonymous sign-in** — users can use the weather app without an account
- **Email/password** — create an account to access premium features
- **Google Sign-In** — quick sign-in with Google
- **Account linking** — upgrade anonymous account to email

### 2. AI Outfit Recommendations (Premium)

- Gemini AI analyzes current weather conditions
- Recommends 4-6 clothing items with reasons
- Generates shopping links to Amazon, Google Shopping, ASOS, Zara
- Includes weather-specific tips

### 3. Premium Subscription

- In-app purchase integration (Google Play / App Store)
- Firestore-backed subscription tracking
- Monthly ($2.99) and Yearly ($19.99) plans
- Premium gate — AI features require active subscription

---

## Setup Steps

### Step 1: Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project (or use existing)
3. Enable these services:
   - **Authentication** → Enable Email/Password and Google providers
   - **Cloud Firestore** → Create database in production mode

4. Install FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   ```

5. Configure Firebase for your app:

   ```bash
   flutterfire configure
   ```

   This generates `lib/firebase_options.dart`. Then update `main.dart`:

   ```dart
   import 'firebase_options.dart';

   // In main():
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

### Step 2: Google Sign-In Setup

**Android:**

- The SHA-1 fingerprint is automatically configured by FlutterFire
- Ensure `google-services.json` is in `android/app/`

**iOS:**

- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Add URL scheme to `ios/Runner/Info.plist` (FlutterFire does this)

### Step 3: Gemini AI API Key

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create an API key
3. Update `lib/core/secrets/app_secrets.dart`:
   ```dart
   static const String geminiApiKey = 'YOUR_ACTUAL_GEMINI_API_KEY';
   ```

### Step 4: In-App Purchases

**Google Play:**

1. Create your app in Google Play Console
2. Set up subscriptions:
   - Product ID: `weather_premium_monthly` — Monthly at $2.99
   - Product ID: `weather_premium_yearly` — Yearly at $19.99
3. Add a license tester in Play Console → Settings → License testing

**App Store:**

1. Create subscriptions in App Store Connect
2. Use same product IDs as above

### Step 5: Firestore Security Rules

Deploy these rules to secure the subscriptions collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /subscriptions/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Step 6: Install Dependencies

```bash
flutter pub get
```

### Step 7: Run

```bash
flutter run
```

---

## Architecture

```
lib/features/
├── auth/                          # Firebase Authentication
│   ├── domain/
│   │   ├── entities/app_user_entity.dart
│   │   ├── repositories/auth_repository.dart
│   │   └── usecases/
│   │       ├── sign_in_anonymously.dart
│   │       ├── sign_in_with_email.dart
│   │       ├── sign_in_with_google.dart
│   │       ├── sign_out.dart
│   │       └── sign_up_with_email.dart
│   ├── data/
│   │   ├── models/app_user_model.dart
│   │   ├── datasources/firebase_auth_datasource.dart
│   │   └── repositories/auth_repository_impl.dart
│   └── presentation/
│       ├── cubit/auth_cubit.dart & auth_state.dart
│       └── screens/login_screen.dart & profile_screen.dart
│
├── premium/                       # Subscription & Payment
│   ├── domain/
│   │   ├── entities/subscription_entity.dart
│   │   ├── repositories/premium_repository.dart
│   │   └── usecases/
│   │       ├── check_premium_status.dart
│   │       └── purchase_premium.dart
│   ├── data/
│   │   ├── models/subscription_model.dart
│   │   ├── datasources/premium_datasource.dart
│   │   └── repositories/premium_repository_impl.dart
│   └── presentation/
│       ├── cubit/premium_cubit.dart & premium_state.dart
│       └── screens/premium_screen.dart
│
└── ai_recommendation/             # AI Clothing Advisor
    ├── domain/
    │   ├── entities/clothing_recommendation_entity.dart
    │   ├── repositories/ai_recommendation_repository.dart
    │   └── usecases/get_clothing_recommendations.dart
    ├── data/
    │   ├── models/clothing_recommendation_model.dart
    │   ├── datasources/ai_remote_datasource.dart
    │   └── repositories/ai_recommendation_repository_impl.dart
    └── presentation/
        ├── cubit/ai_recommendation_cubit.dart & state
        ├── screens/ai_outfit_screen.dart & ai_recommendation_screen.dart
        └── widgets/premium_gate_widget.dart
```

## User Flow

```
App Launch
  ├─ Weather loads normally (no auth required)
  ├─ User taps profile icon (top-right)
  │   ├─ Not signed in → Login Screen
  │   │   ├─ Sign in with Email/Password
  │   │   ├─ Sign in with Google
  │   │   └─ Continue as Guest (anonymous)
  │   └─ Signed in → Profile Screen
  │       ├─ View account info
  │       ├─ Upgrade to Premium
  │       └─ Sign out
  │
  └─ User taps "AI Outfit Advisor" button (in weather view)
      ├─ Not signed in → Auth gate → Login Screen
      ├─ Anonymous → Account gate → Login Screen
      ├─ Not premium → Premium gate → Premium Screen
      └─ Premium user → AI Recommendation Screen
          ├─ Gemini analyzes weather
          ├─ Shows clothing items with reasons
          ├─ Shopping links (Amazon, Google, ASOS, Zara)
          └─ Weather tips
```

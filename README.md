# IIS Mobile Application

Standalone Flutter assignment project with two experiences based on the supplied Figma page: **KinTree** (Home, Family Tree, Family Chat, Profile) and **Meditation & Music** (Home, Albums, Playlists, Profile, Settings). Both use shared onboarding, sign-in, and account profile data.

## Run

```sh
flutter pub get
flutter run
```

Firebase is required for the authentication and onboarding flow. Sign-in and registration use Firebase Authentication, while the profile and onboarding status are synchronized to Firestore. SharedPreferences stores local onboarding/cache state and custom playlist data.

## Architecture

- `features/auth/domain`: user profile and repository contract.
- `features/auth/data`: Firebase Auth/Firestore adapter behind the repository contract.
- `features/auth/presentation`: Riverpod account state, onboarding, login, and registration.
- `features/kintree` and `features/meditation`: independent UI flows, sharing account state and theme tokens.

## Firebase setup

The supplied Firebase Android configuration is installed at `android/app/google-services.json` and matches this app's Android application ID. Firebase initializes on every app launch; there is no local authentication fallback or build flag. Enable Email/Password sign-in in Firebase Authentication and create a Firestore database before launching the sign-in or onboarding flow.

Run the Android app normally:

```sh
flutter run
```

In Firestore, allow an authenticated user to read and write only `users/{uid}` where the document ID equals `request.auth.uid`. The app stores the user profile and onboarding completion in that document and caches onboarding state locally. The music player and family content remain prototype/sample data; no audio streaming or real-time family chat backend is configured.

Suggested Firestore rules for this profile collection:

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, create, update, delete: if request.auth != null
        && request.auth.uid == uid;
    }
  }
}
```

In Firebase Console, enable **Authentication → Sign-in method → Email/Password**, create the Firestore database, and publish the rules above before testing account creation or sign-in.

Only Android Firebase configuration was supplied. To run Firebase-backed auth on iOS, add the matching `GoogleService-Info.plist` from the same Firebase project to `ios/Runner/` and complete the platform setup.

## Design implementation

The nine screens follow the individual Figma frame exports supplied for this assignment. KinTree uses `#FBF9F4`, Georgia for its serif headings, and Roboto for interface copy. Meditation uses Inter with `#4F46E5` and `#7C3AED`; the inspected Settings text styles use Plus Jakarta Sans and Sora, and the Albums empty-state heading uses Playfair Display. Fonts are bundled for consistent rendering on Android.

Portraits, family photos, the heirloom photo, album cover and lotus artwork are local assets. Cards, text, controls, tree connectors, navigation and scrolling are Flutter widgets. Settings group shadows are painted outside their rounded clipping bounds. The experiences are constrained to 448 logical pixels on wide displays and scroll or wrap on narrow screens. Family Tree pans horizontally.

Switch experiences through **KinTree header avatar → Switch app**, or **Meditation Profile → menu → Settings emblem → Switch app**. The chooser remains on the navigation stack.

## Visual review

`design_review/index.html` contains side-by-side comparisons for all nine screens. The left image is the supplied Figma reference normalized to 390 logical pixels, excluding exported canvas margins and iOS status bars. The right image is a full-content Flutter render. Device system bars are managed by the operating system.

To regenerate the renders and comparisons:

```sh
flutter test test/figma_visual_review_test.dart
python3 tool/generate_design_comparisons.py
```

The comparison generator requires Pillow. The visual suite also checks layout at 320 logical pixels. Its authentication double is confined to the test harness; the app always initializes Firebase and uses Firebase Authentication.

The comparison images are review evidence, not a claim of pixel identity. Font rasterization, device text scaling and native system insets can affect the final device render.

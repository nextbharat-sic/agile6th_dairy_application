# Kisan Diary 🐄📱

A modern, cross-platform dairy management app built with Flutter and Firebase. Kisan Diary empowers dairy farmers and businesses to track milk production, manage expenses, generate insightful reports, and streamline daily operations—all in a beautiful, responsive, and multilingual interface.

---

## 🚀 Features
- **Milk Entry & Tracking**: Log daily milk yields for cows and buffaloes, including fat and SNF values
- **Expense Management**: Record, categorize, and analyze dairy-related expenses
- **Comprehensive Reports**: Charts and summaries for production, revenue, and profit
- **Authentication**: Email/Password and Google Sign-In via Firebase Auth
- **Multi-language**: English and Telugu with runtime switching
- **Responsive UI**: Phone and tablet friendly (Sizer, adaptive layouts)
- **Offline-Friendly**: Works with intermittent connectivity (Firestore local cache)

---

## 🏗️ Architecture at a Glance
- Clean, modular layering with clear separation of concerns:
  - Presentation (widgets/screens)
  - Providers (state management)
  - Services (business logic)
  - Repositories (data access)
  - Entities/Models (domain + DTOs)
- Backed by Firebase (Auth, Firestore, Storage)

See full diagrams in `ARCHITECTURE_DIAGRAM.md` and details in `TECHNICAL_DOCUMENTATION.md`.

---

## 📦 Tech Stack
- Flutter 3.9.2, Dart 3.6+
- Provider, Sizer, Google Fonts
- Firebase Core, Auth, Firestore, Storage
- fl_chart, connectivity_plus, shared_preferences, intl, image_picker

Key dependencies (excerpt from `pubspec.yaml`):

```yaml
dependencies:
  flutter: { sdk: flutter }
  provider: ^6.1.1
  firebase_core: ^4.1.1
  firebase_auth: ^6.1.0
  cloud_firestore: ^6.0.2
  firebase_storage: ^13.0.2
  google_sign_in: ^6.3.0
  fl_chart: ^1.1.1
  sizer: ^3.1.3
  google_fonts: ^6.1.0
  shared_preferences: ^2.2.2
  connectivity_plus: ^7.0.0
  intl: ^0.20.2
```

---

## 🗂️ Project Structure
```
dairy_manager/
├─ dairy_manager/
│  ├─ lib/
│  │  ├─ backend/
│  │  │  ├─ entities/          # Domain entities (validation/business rules)
│  │  │  ├─ repositories/      # Firestore access (CRUD, queries)
│  │  │  └─ services/          # Use-cases/business logic orchestration
│  │  ├─ constants/            # Enums, constants
│  │  ├─ core/                 # Cross-cutting exports
│  │  ├─ l10n/                 # Localization (EN, TE)
│  │  ├─ models/               # DTOs for UI/Data transfer
│  │  ├─ presentation/         # Screens and UI flows
│  │  ├─ providers/            # Provider-based state management
│  │  ├─ routes/               # Centralized route map
│  │  ├─ theme/                # Theming and typography
│  │  ├─ utils/                # Helpers (date, validators, ids)
│  │  ├─ widgets/              # Reusable UI components
│  │  └─ main.dart             # App entry
│  ├─ android/ | ios/          # Native configs
│  ├─ assets/images/           # Images and icons
│  └─ firebase.json            # Firebase config mapping
├─ ARCHITECTURE_DIAGRAM.md
└─ TECHNICAL_DOCUMENTATION.md
```

---

## ⚙️ Setup & Run

### Prerequisites
- Flutter SDK (3.6.0+ recommended)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- A Firebase project (Auth + Firestore + Storage)

### 1) Install dependencies
```bash
cd dairy_manager/dairy_manager
flutter pub get
```

### 2) Configure Firebase
- Place Android `google-services.json` at `dairy_manager/android/app/`
- Place iOS `GoogleService-Info.plist` at `dairy_manager/ios/Runner/`
- Ensure `lib/firebase_options.dart` is generated (FlutterFire CLI) or matches `firebase.json`

### 3) Run
```bash
flutter run
```

---

## 🔐 Authentication
- Email/Password and Google Sign-In (via `firebase_auth`, `google_sign_in`)
- Auth flow controlled by `AuthProvider` and `AppRoutes.initial` wrapper

---

## 🧮 Core Domains
- Expenses: `ExpenseEntity`, `ExpenseRepository`, `ExpenseService`, `ExpensesProvider`
- Income & Reports: `IncomeModel`, `ReportService` (with `IncomeRepository`, `ExpenseRepository`)
- Users: `UserEntity`, `UserModel`, `UserRepository`

---

## 🧭 Navigation
- Centralized routes in `lib/routes/app_routes.dart`
- Initial route wraps auth state to redirect to login/home

---

## 🌐 Localization
- English and Telugu via `lib/l10n/*`
- Switch at runtime with `LanguageProvider`

---

## 🧪 Testing
```bash
flutter test
```
- Add unit tests for services/repositories
- Add widget tests for screens and flows

---

## 🚢 Build & Release
- Android APK: `flutter build apk --release`
- Android AAB: `flutter build appbundle --release`
- iOS: `flutter build ios --release`
- Web: `flutter build web`

---

## 📖 Further Reading
- Detailed docs: see `TECHNICAL_DOCUMENTATION.md`
- Architecture visuals: see `ARCHITECTURE_DIAGRAM.md`

---

## 📝 License
MIT or your chosen license.

---

> Made with ❤️ for the dairy community.

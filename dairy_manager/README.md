# Dairy Manager 🐄📱

A modern, cross-platform dairy management app built with Flutter and Firebase. Dairy Manager empowers dairy farmers and businesses to track milk production, manage expenses, generate insightful reports, and streamline daily operations—all in a beautiful, responsive, and multilingual interface.

---

## 🚀 Features

- **Milk Entry & Tracking**: Log daily milk yields for cows and buffaloes, including fat and SNF values.
- **Expense Management**: Record, categorize, and review all dairy-related expenses.
- **Comprehensive Reports**: Visualize production, revenue, and profit trends with interactive charts and tables.
- **User Authentication**: Secure sign-in with Google and email/password, powered by Firebase Auth.
- **Community & Collaboration**: (Planned) Connect with other dairy managers and share insights.
- **Multi-language Support**: Seamless switching between English and Telugu.
- **Responsive UI**: Optimized for phones and tablets, with smooth animations and modern design.
- **Offline Support**: Core features work even without an internet connection (with sync on reconnect).

---

## 🏗️ Tech Stack & Architecture

- **Flutter 3.9.2**: Modern, declarative UI for Android, iOS, and web.
- **Firebase**: Auth, Firestore, Storage, Analytics.
- **Provider**: State management for scalable, testable code.
- **fl_chart**: Beautiful, interactive charts for reports.
- **Sizer**: Responsive layouts for all device sizes.
- **Modular Structure**: Clean separation of presentation, business logic, data, and core utilities.

### Directory Overview

```
dairy_manager/
├── android/           # Android native config
├── ios/               # iOS native config
├── lib/
│   ├── backend/       # Entities, repositories, and services (data & business logic)
│   ├── constants/     # App-wide constants
│   ├── core/          # Core exports/utilities
│   ├── l10n/          # Localization (English, Telugu)
│   ├── models/        # Data models
│   ├── presentation/  # UI screens & widgets (dashboard, login, reports, etc.)
│   ├── providers/     # State management (auth, navigation, language, expenses)
│   ├── routes/        # App navigation routes
│   ├── theme/         # Theming (light/dark)
│   ├── utils/         # Utility functions (date, validation, etc.)
│   ├── widgets/       # Reusable UI components
│   └── main.dart      # App entry point
├── assets/
│   └── images/        # App icons, illustrations, and UI images
├── pubspec.yaml       # Dependencies & asset config
└── README.md          
```

---

## ⚡ Getting Started

### Prerequisites
- Flutter SDK (3.6.0+ recommended)
- Dart SDK
- Android Studio or VS Code (with Flutter extensions)
- Firebase project (for Auth, Firestore, Storage)

### Setup
1. **Clone the repo:**
   ```bash
   git clone <your-repo-url>
   cd dairy_manager/dairy_manager
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Firebase:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective folders.
   - Update `firebase_options.dart` if needed (generated via FlutterFire CLI).
4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🧑‍💻 Key Modules & Screens

- **Login & Registration**: Secure onboarding with Google or email.
- **Dashboard**: Animated home with quick stats and navigation.
- **Milk Entry**: Intuitive forms for daily milk, fat, and SNF logging.
- **Expenses**: Add/view expenses by category, with history and summaries.
- **Reports**: Interactive charts, tables, and export options for production, revenue, and profit.
- **Settings**: Profile management, language switch, and app preferences.

---

## 🌐 Localization
- English and Telugu supported out of the box.
- Easily extendable for more languages via `lib/l10n/`.

---

## 🎨 Theming & UX
- Custom light/dark themes in `lib/theme/app_theme.dart`.
- Consistent Material Design with custom icons and illustrations.
- Responsive layouts using Sizer and MediaQuery.

---

## 🛡️ Security & Best Practices
- Firebase Auth for secure login.
- Firestore rules for data privacy.
- Input validation and error handling throughout.
- Modular, testable codebase with clear separation of concerns.

---

## 🧩 Extending & Customizing
- Add new screens in `lib/presentation/` and register routes in `lib/routes/app_routes.dart`.
- Add new providers for state management in `lib/providers/`.
- Add new languages in `lib/l10n/`.
- Customize themes in `lib/theme/`.

---

## 📝 Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 📦 Deployment
- **Android:**
  ```bash
  flutter build apk --release
  ```
- **iOS:**
  ```bash
  flutter build ios --release
  ```
- **Web:**
  ```bash
  flutter build web
  ```

---

## 🙏 Acknowledgments
- Built with [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Firebase for backend services
- [fl_chart](https://pub.dev/packages/fl_chart) for charts
- [Sizer](https://pub.dev/packages/sizer) for responsive UI
- Material Design inspiration

---

> Made with ❤️ for the dairy community.

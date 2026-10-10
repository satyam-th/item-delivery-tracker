# Milk - Daily Delivery & Shop Record App

A complete, offline-first Flutter application designed for local businesses to track daily deliveries, returns, rates, and automated billing. It is optimized for ease of use, with dual-language support (English/Nepali) and automatic daily resets.

## 🚀 Features

- **Daily Grid Tracker**: Log items delivered (Load) and items returned for each customer daily.
- **Smart Rates**: 
  - *Universal Rates*: Base price for items.
  - *Custom Rates*: Unique pricing overrides for specific customers.
- **Automatic Midnight Reset**: The daily grid automatically clears its Load/Return counters at midnight, while preserving all historical transaction data.
- **Transaction History**: A detailed, filterable view of all past transactions.
- **Manage Customers**: Add, edit, delete, and reorder customers smoothly with drag-and-drop functionality.
- **Data Persistence**: All records, rates, and lists are automatically saved locally using `SharedPreferences`. No data is lost when closing the app.
- **Built-in Live Calculator**: A Samsung-style calculator that evaluates expressions as you type and keeps a history of your calculations.
- **Dual Language**: Seamlessly toggle between English and Nepali.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Local Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Math Engine**: [math_expressions](https://pub.dev/packages/math_expressions) (for the live calculator)

## 📦 Building from Source

To build the APK, ensure you have Flutter and the required JDK installed. 

```bash
flutter pub get
flutter build apk --release
```

## 📱 Screenshots & UI

- **Home Screen**: A frozen-column grid layout for fast data entry across multiple items.
- **History Screen**: Date-picker and dropdown filters to find exact transactions.
- **Settings**: Configuration for languages and management screens.

## 📄 License

This project is open-source and available for local business usage.

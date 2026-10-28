# 📦 Item Delivery Tracker (Shop Record)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://android.com)
[![Offline First](https://img.shields.io/badge/Storage-100%25%20Offline-success)](#)
[![Language](https://img.shields.io/badge/Language-English%20%7C%20नेपाली-orange)](#)
[![Tests](https://img.shields.io/badge/Tests-17%2F17%20Passing-brightgreen)](#)

A fast, lightweight, and offline-first Flutter application designed for local distribution businesses (e.g., milk delivery, bakeries, water jar suppliers, tea & grocery distribution) to track daily vehicle stock, item deliveries, returns, custom rates, bill sharing, and automated revenue calculation.

---

## 🌟 Key Features

### 🚚 1. Morning Vehicle Stock & Live Remaining Tracker (New!)
- **Morning Vehicle Load (गाडी लोड):** Record total packets loaded into the delivery vehicle at the start of the day (e.g., 1,700 Nilo, 1,300 Hariyo).
- **Top Vehicle Status Bar:** Displays total loaded packets and **live remaining stock** right at the top of the Home screen.
- **Real-Time Remaining Calculation:**
  $$\text{Remaining Stock} = \text{Loaded} - \text{Total Dropped} + \text{Total Returned}$$
- **Bottom Summary Row:** Strictly displays total dropped (delivered) and returned quantities across all customers.

### 📲 2. History Bill Sharing & Instant Search (New!)
- **Instant Search:** Search history records in real-time by customer name or item name.
- **Multi-Filter Support:** Filter transactions simultaneously by date, customer, and item.
- **Sticky Bottom Action Bar:** Displays real-time filtered transaction count and total rupees billed.
- **One-Tap Share Bill:** Formats clean delivery receipts and shares directly via WhatsApp, SMS, Viber, or copies to clipboard via `share_plus`.

### 📦 3. One-Tap Batch Load & Return
- **Tap Customer Row:** Tapping any customer name opens a streamlined **Tabbed Bottom Sheet**.
- **Load (दिएको) & Return (फिर्ता) Tabs:** Switch effortlessly between delivery and return counts without losing entered numbers.
- **Batch Entry:** Enter quantities for all items at once with `+` / `-` steppers or direct numeric keyboard typing.
- **Context Badges:** View what was loaded while entering returns (and vice-versa) to prevent delivery errors.
- **One-Tap Save:** Saves all items simultaneously and recalculates all customer row totals and today's grand total.

### 📊 4. High-Speed Daily Delivery Grid
- **Frozen Layout:** Customer names remain fixed on the left while item columns scroll smoothly horizontally.
- **Real-Time Billing:** Automatically calculates total rupees owed per customer:
  $$\text{Row Total} = \sum (\text{Delivered} - \text{Returned}) \times \text{Rate}$$
- **Daily Grand Total Header:** Live display of today's total revenue banner at the top.
- **Quick Cell Edit:** Tap any individual cell to fine-tune specific load and return values directly.

### 💰 5. Smart Rate System
- **Universal Rates:** Set standard baseline prices for each item.
- **Custom Customer Rates:** Assign customer-specific price overrides (e.g., wholesale rates or special agreements) that automatically take precedence.

### 🔄 6. Automatic Midnight Reset
- The app automatically detects date changes upon launch or resumption.
- Daily grid entries reset cleanly at midnight for the new business day.
- **Zero Data Loss:** All previous deliveries are archived into permanent transaction history and past morning stock archives.

### 👥 7. Customer & Item Management
- Add, edit, and delete customers and items with safe delete-confirmation dialogs.
- Reorder customer delivery routes smoothly using drag-and-drop.
- Long-press any customer name directly from the home screen for instant customer management.

### 🧮 8. Built-in Live Calculator
- Quick calculator integrated into the app.
- Evaluates mathematical expressions in real-time as you type using `math_expressions`.
- Keeps an audit log of calculation history.

### 🌐 9. Dual Language (English / नेपाली)
- Switch seamlessly between English and Nepali with one tap in Settings.
- Pre-configured with Nepali business terminology (*दिएको*, *फिर्ता*, *कुल जम्मा*, *गाडी लोड*, *बाँकी*, *दरहरू*).

---

## 🛠 Tech Stack

| Component | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) (Material 3) |
| **Language** | [Dart](https://dart.dev/) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Local Storage** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Math Engine** | [math_expressions](https://pub.dev/packages/math_expressions) |
| **Sharing** | [share_plus](https://pub.dev/packages/share_plus) |

---

## 📂 Project Structure

```text
shop_record/
├── android/               # Android native configuration & Gradle scripts
├── assets/                # App launcher icon and media assets
├── lib/
│   ├── main.dart          # App entry point, MultiProvider setup, navigation bar
│   ├── providers.dart     # DataProvider (state, business logic, storage) & LocaleProvider
│   ├── constants/
│   │   └── app_colors.dart# Centralized color palette
│   └── screens/
│       ├── home_screen.dart             # Daily frozen-table tracker, morning stock & sheet
│       ├── history_screen.dart          # Transaction history with search, filters & WhatsApp share
│       ├── tools_screen.dart            # Built-in live expression calculator
│       ├── settings_screen.dart         # Language toggle & management navigation
│       ├── manage_customers_screen.dart # Reorderable customer management
│       ├── manage_items_screen.dart     # Item catalog management
│       └── manage_rates_screen.dart     # Universal and custom rate manager
├── test/
│   ├── data_provider_test.dart          # Unit tests for providers, calculations & persistence
│   ├── home_screen_widget_test.dart     # Widget tests for Home grid and vehicle stock
│   └── screens_test.dart                # Widget tests for History, Tools, Settings & Manage screens
└── pubspec.yaml           # Project dependencies and configuration
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.x or later)
- Android SDK (API 34+ recommended)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/satyam-th/item-delivery-tracker.git
   cd item-delivery-tracker
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Run on a connected device / emulator:**
   ```bash
   flutter run
   ```

---

## 📦 Building Release APK

To generate an optimized release APK for Android:

```bash
flutter build apk --release
```

The compiled APK will be output to:
```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Running Tests

To run the automated unit and widget test suite (17 tests):

```bash
flutter test
```

---

## 📱 How to Use

1. **Start of Day:**
   - Launch the app. If it is a new day, the delivery grid starts fresh automatically.
   - Tap **"गाडी लोड मिलाउनुहोस् (Edit Vehicle Stock)"** at the top to record initial vehicle load.
2. **Recording Deliveries & Returns:**
   - Tap any customer's name on the left column.
   - In the **Load (दिएको)** tab, enter items delivered.
   - Switch to the **Return (फिर्ता)** tab to enter empty containers or returned items.
   - Tap **Save (बचत गर्नुहोस्)** to apply all changes.
3. **Checking Stock & Totals:**
   - View live remaining vehicle stock in the top status bar.
   - View customer row totals on the rightmost column and total dropped at the bottom row.
   - View overall revenue banner at the top of the Home screen.
4. **Searching & Sharing Bills:**
   - Tap the **History (इतिहास)** tab at the bottom.
   - Use the search bar or filters (Date, Customer, Item) to isolate records.
   - Tap **"Share Bill (बिल सेयर गर्नुहोस्)"** in the bottom action bar to send via WhatsApp or SMS.
5. **Adjusting Rates:**
   - Open **Settings (सेटिङहरू) $\rightarrow$ Manage Rates (दरहरू व्यवस्थापन)** to update default or customer-specific pricing.

---

## 📄 License

This project is open-source and free for commercial and personal local business usage.

# 📦 Item Delivery Tracker (Shop Record)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://android.com)
[![Offline First](https://img.shields.io/badge/Storage-100%25%20Offline-success)](#)
[![Language](https://img.shields.io/badge/Language-English%20%7C%20नेपाली-orange)](#)

A fast, lightweight, and offline-first Flutter application designed for local distribution businesses (e.g., milk delivery, bakeries, water jar suppliers, tea & grocery distribution) to track daily item deliveries, returns, custom rates, and automated revenue calculation.

---

## 🌟 Key Features

### 🚚 1. One-Tap Batch Load & Return (New!)
- **Tap Customer Row:** Tapping any customer name opens a streamlined **Tabbed Bottom Sheet**.
- **Load (दिएको) & Return (फिर्ता) Tabs:** Switch effortlessly between delivery and return counts without losing entered numbers.
- **Batch Entry:** Enter quantities for all items (e.g., Nilo, Hariyo, Ghae, Tea, Dhae) at once with `+` / `-` steppers or direct numeric keyboard typing.
- **Context Badges:** View what was loaded while entering returns (and vice-versa) to prevent delivery errors.
- **One-Tap Save:** Saves all items simultaneously and recalculates all customer row totals and today's grand total.

### 📊 2. High-Speed Daily Delivery Grid
- **Frozen Layout:** Customer names remain fixed on the left while item columns scroll smoothly horizontally.
- **Real-Time Billing:** Automatically calculates total rupees owed per customer:
  $$\text{Row Total} = \sum (\text{Delivered} - \text{Returned}) \times \text{Rate}$$
- **Daily Grand Total Header:** Live display of today's total revenue banner at the top.
- **Quick Cell Edit:** Tap any individual cell to fine-tune specific load and return values directly.

### 💰 3. Smart Rate System
- **Universal Rates:** Set standard baseline prices for each item.
- **Custom Customer Rates:** Assign customer-specific price overrides (e.g., wholesale rates or special agreements) that automatically take precedence.

### 🔄 4. Automatic Midnight Reset
- The app automatically detects date changes upon launch or resumption.
- Daily grid entries reset cleanly at midnight for the new business day.
- **Zero Data Loss:** All previous deliveries are archived into permanent transaction history.

### 📜 5. Transaction History & Filtering
- Comprehensive audit trail of every delivery and return.
- Filter past records by:
  - Specific dates / date ranges
  - Individual customers
  - Specific items
- Delete or adjust erroneous transactions anytime.

### 👥 6. Customer & Item Management
- Add, edit, and delete customers and items with ease.
- Reorder customer delivery routes smoothly using drag-and-drop.
- Long-press any customer name directly from the home screen for instant customer management.

### 🧮 7. Built-in Live Calculator
- Samsung-style quick calculator integrated into the app.
- Evaluates mathematical expressions in real-time as you type.
- Keeps an audit log of calculation history.

### 🌐 8. Dual Language (English / नेपाली)
- Switch seamlessly between English and Nepali with one tap in Settings.
- Pre-configured with Nepali business terminology (*दिएको*, *फिर्ता*, *कुल जम्मा*, *दरहरू*).

---

## 🛠 Tech Stack

| Component | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) (Material Design) |
| **Language** | [Dart](https://dart.dev/) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Local Storage** | [shared_preferences](https://pub.dev/packages/shared_preferences) |
| **Math Engine** | [math_expressions](https://pub.dev/packages/math_expressions) |

---

## 📂 Project Structure

```text
shop_record/
├── android/               # Android native configuration & Gradle scripts
├── assets/                # App launcher icon and media assets
├── lib/
│   ├── main.dart          # App entry point, MultiProvider setup, navigation bar
│   ├── models.dart        # Core domain models (Customer, Item, DeliveryRecord)
│   ├── providers.dart     # DataProvider (state, business logic, storage) & LocaleProvider
│   └── screens/
│       ├── home_screen.dart             # Daily frozen-table tracker & Load/Return sheet
│       ├── history_screen.dart          # Transaction history with filters
│       ├── tools_screen.dart            # Built-in live expression calculator
│       ├── settings_screen.dart         # Language toggle & navigation to management
│       ├── manage_customers_screen.dart # Reorderable customer management
│       ├── manage_items_screen.dart     # Item catalog management
│       └── manage_rates_screen.dart     # Universal and custom rate manager
└── pubspec.yaml           # Project dependencies and configuration
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.x or later)
- Java JDK 17
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

## 📱 How to Use

1. **Start of Day:**
   - Launch the app. If it is a new day, the delivery grid starts fresh automatically.
2. **Recording Deliveries & Returns:**
   - Tap any customer's name on the left column.
   - In the **Load (दिएको)** tab, enter or increment items delivered.
   - Switch to the **Return (फिर्ता)** tab to enter empty containers or returned items.
   - Tap **Save (बचत गर्नुहोस्)** to apply all changes.
3. **Checking Totals:**
   - View customer row totals on the rightmost column.
   - View the overall revenue banner at the top of the Home screen.
4. **Reviewing Past Transactions:**
   - Tap the **History (इतिहास)** tab at the bottom to inspect or filter transactions by customer, item, or date.
5. **Adjusting Rates:**
   - Open **Settings (सेटिङहरू) $\rightarrow$ Manage Rates (दरहरू व्यवस्थापन)** to update default or customer-specific pricing.

---

## 📄 License

This project is open-source and free for commercial and personal local business usage.

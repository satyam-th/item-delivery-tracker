# 📦 Item Delivery Tracker (Shop Record)

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://android.com)
[![Offline First](https://img.shields.io/badge/Storage-100%25%20Offline-success)](#)
[![Language](https://img.shields.io/badge/Language-English%20%7C%20नेपाली-orange)](#)
[![Tests](https://img.shields.io/badge/Tests-18%2F18%20Passing-brightgreen)](#)

A fast, lightweight, and offline-first Flutter application designed for local distribution businesses (e.g., milk delivery, bakeries, water jar suppliers, tea & grocery distribution) to track daily vehicle stock, item deliveries, damaged returns, custom rates, bill sharing, and automated revenue calculation.

---

## 🌟 Key Features

### 🚚 1. Morning Vehicle Stock & Live Remaining Tracker
- **Morning Vehicle Load (गाडी लोड):** Record total packets loaded into the delivery vehicle at the start of the day (e.g., 1,700 Nilo, 1,300 Hariyo).
- **Top Vehicle Status Bar:** Displays total loaded packets and **live remaining stock** right at the top of the Home screen.
- **Accurate Remaining Stock Calculation:**
  $$\text{Remaining Vehicle Stock} = \text{Loaded} - \text{Total Dropped}$$
  *(Damaged returned products do not add back into usable vehicle stock).*
- **Bottom Summary Row:** Strictly displays total dropped (delivered) and damaged/returned quantities across all customers.

### 📲 2. History Bill Sharing & Damaged Breakdown
- **Real-Time Instant Search:** Search history records instantly by customer or item name.
- **Accurate Filtered Totals:** The summary bar calculates and displays the exact financial total and record count for currently active filters.
- **Dedicated Damaged Section (नोक्सानी विवरण):** Displays total damaged product count along with individual item-by-item breakdown tags (e.g. `nilo: 4`, `hariyo: 2`).
- **One-Tap Share Bill:** Formats clean delivery receipts including grand total and damaged breakdown, and shares directly via WhatsApp, SMS, Viber, or copies to clipboard via `share_plus`.

### 🔄 3. Flexible Auto & Manual Reset System
- **Manual Reset Button (ग्रिड रिसेट गर्नुहोस्):** Immediately archives the current grid and morning vehicle stock into permanent history and clears the delivery table fresh.
- **Configurable Reset Settings (रिसेट सेटिङ):**
  - **Reset Mode:** Choose between **Automatic (स्वचालित)** or **Manual Only (म्यानुअल मात्र)**.
  - **Custom Reset Time:** Specify the exact reset time (e.g. 12:00 AM, 4:00 AM).
  - **Custom Frequency:** Choose between **Daily (दैनिक)**, **Weekly (साप्ताहिक)**, or **Custom Weekdays (कस्टम दिन)**.
- **Transaction Timestamps:** Each transaction record displays complete 12-hour formatted time with AM/PM and calendar date (e.g. `Nov 12 · 5:28 PM`).

### 📦 4. One-Tap Batch Load & Return
- **Tap Customer Row:** Tapping any customer name opens a streamlined **Tabbed Bottom Sheet**.
- **Load (दिएको) & Damaged/Return (फिर्ता) Tabs:** Switch effortlessly between delivery and damaged counts without losing entered numbers.
- **Batch Entry:** Enter quantities for all items at once with `+` / `-` steppers or direct numeric keyboard typing.
- **One-Tap Save:** Saves all items simultaneously and recalculates all customer row totals and today's grand total.

### 📊 5. High-Speed Daily Delivery Grid
- **Frozen Layout:** Customer names remain fixed on the left while item columns scroll smoothly horizontally.
- **Real-Time Billing:** Automatically calculates total rupees owed per customer:
  $$\text{Row Total} = \sum (\text{Delivered} - \text{Damaged}) \times \text{Rate}$$
- **Daily Grand Total Header:** Live display of today's total revenue banner at the top.
- **Quick Cell Edit:** Tap any individual cell to fine-tune specific load and return values directly.

### 💰 6. Smart Rate System
- **Universal Rates:** Set standard baseline prices for each item.
- **Custom Customer Rates:** Assign customer-specific price overrides (e.g., wholesale rates or special agreements) that automatically take precedence.

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
- Pre-configured with Nepali business terminology (*दिएको*, *फिर्ता / नोक्सानी*, *कुल जम्मा*, *गाडी लोड*, *बाँकी*, *दरहरू*).

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
│       ├── history_screen.dart          # Transaction history with search, filters, damaged breakdown & share
│       ├── tools_screen.dart            # Built-in live expression calculator
│       ├── settings_screen.dart         # Language toggle, manual reset & reset settings
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

To run the automated unit and widget test suite (18 tests):

```bash
flutter test
```

---

## 📱 How to Use

1. **Start of Day:**
   - Launch the app. If it is a new day, the delivery grid starts fresh according to your reset schedule.
   - Tap **"गाडी लोड मिलाउनुहोस् (Edit Vehicle Stock)"** at the top to record initial vehicle load.
2. **Recording Deliveries & Damaged Items:**
   - Tap any customer's name on the left column.
   - In the **Load (दिएको)** tab, enter items delivered.
   - In the **Return (फिर्ता / Damaged)** tab, enter damaged products.
   - Tap **Save (बचत गर्नुहोस्)** to apply all changes.
3. **Checking Stock & Totals:**
   - View live remaining vehicle stock in the top status bar.
   - View customer row totals on the rightmost column and total dropped at the bottom row.
   - View overall revenue banner at the top of the Home screen.
4. **Searching, History & Sharing Bills:**
   - Tap the **History (इतिहास)** tab at the bottom.
   - Use search or filters (Date, Customer, Item) to filter records.
   - Inspect the total billed amount and the detailed damaged products breakdown section at the bottom.
   - Tap **"Share Bill (बिल सेयर गर्नुहोस्)"** to send receipts via WhatsApp or SMS.
5. **Configuring Reset Schedule & Manual Reset:**
   - Open **Settings (सेटिङहरू) $\rightarrow$ Reset Mode** to select Automatic or Manual reset, reset time, and frequency.
   - Tap **"Reset Grid Now (ग्रिड रिसेट गर्नुहोस्)"** anytime to clear the grid manually on demand.

---

## 📄 License

This project is open-source and free for commercial and personal local business usage.

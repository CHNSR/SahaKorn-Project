# SahaKorn Project (sahakorn3)

A comprehensive Flutter-based Cooperative Store Management and Financial Services application.

## 🚀 Overview

SahaKorn is a dual-role mobile application designed for cooperative shops. It empowers **Shop Owners** to manage transactions, credit/loans, and sales insights, while allowing **Customers** to track their activities and shop profiles.

## ✨ Key Features

### 🔐 Authentication & Security
- **Firebase Auth**: Secure email/password and social login.
- **Role-Based Access**: Distinct interfaces for **Shopper** and **Customer**.
- **Biometric Login**: Future-ready support for FaceID/Fingerprint.

### 🏪 Shop Owner Mode
- **Dashboard**: Real-time overview of sales, credit, and daily stats.
- **Transaction Management**:
  - Record sales via **QR Code** or manual entry.
  - **Transaction History**: Filterable list of past transactions.
  - **Visual Analytics**: Interactive charts (`fl_chart`) and heatmaps (`flutter_heatmap_calendar`) for sales trends.
  - **Export**: Ability to export data (CSV integration).
- **Loan & Credit Management**:
  - **Customer Credit Styling**: Manage credit limits for individual customers.
  - **Loan Tracking**: Give loans, record repayments, and view loan history.
  - **Visuals**: Credit usage charts and stats.
- **Shop Settings**: customizable profile and configurations.

### 👤 Customer Mode
- **Profile**: Manage personal details and preferences.
- **Shop Creation**: Customers can register to become shop owners.
- **Activity Tracking**: View personal purchase history (planned).
- **Settings**: Theme toggle (Dark/Light), Language (TH/EN), and Notifications.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend**: 
  - [Firebase](https://firebase.google.com/) (Auth, Firestore)
  - [Supabase](https://supabase.com/) (Alternative backend integration)
- **Local Storage**: `hive`, `shared_preferences`, `sqflite`
- **State Management**: `provider`
- **UI/UX**: 
  - `google_fonts` (Inter/Kanit)
  - `stylish_bottom_bar`
  - `fl_chart` & `flutter_heatmap_calendar`
  - `mobile_scanner` for QR functionality

## 📂 Project Structure

- `lib/src/screens/user/shop`: Shop management features (Loans, Transactions, Settings).
- `lib/src/screens/user/customer`: Customer-facing screens.
- `lib/src/services`: Firebase and Supabase service layers.
- `lib/src/widgets`: Reusable UI components.

## 🚀 Getting Started

1. **Clone the repo**
   ```bash
   git clone <repository_url>
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Setup Firebase/Env**
   - Ensure `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) are in `android/app` / `ios/Runner`.
4. **Run the app**
   ```bash
   flutter run
   ```

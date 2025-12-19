# SahaKorn Project (sahakorn3)

Platform for Cooperative Store Management and Financial Features.

## Overview

SahaKorn is a Flutter-based mobile application designed to facilitate management for cooperative shops and provide financial services to members. The application supports a dual-role system, allowing users to interact either as **Customers** or **Shop Owners**.

## Features

### 🔐 Authentication & Security
- **Firebase Authentication**: Secure login and registration.
- **Biometric Login**: Support for fingerprint/face ID (planned/UI implemented).
- **Role Management**: Seamless switching between Customer and Shop roles.

### 👤 Customer Features
- **Profile Management**: Edit personal details (Name, Address, Phone).
- **Settings**:
    - Dark/Light Theme toggle.
    - Notification preferences.
    - Language selection (TH/EN).
- **Shop Creation**: Ability for customers to register and open their own shop.

### 🏪 Shop Owner Features
- **Dashboard**: Overview of current balance, income, and expenses.
- **Transaction Management**: 
    - Track daily/monthly transactions.
    - Visualize trends with interactive charts (`fl_chart`).
- **Loan Management**: 
    - Track credit limits and available loan balance.
    - Visualization of loan usage over time.
- **Financial Visualization**: Heatmaps and line charts for better financial insights.

## Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Backend/Auth**: [Firebase](https://firebase.google.com/)
- **State Management**: Provider
- **UI Components**: 
    - `fl_chart` for graphs.
    - `flutter_heatmap_calendar` for activity visualization.
    - Material 3 Design.
- **Utilities**: `intl` for formatting.

## Getting Started

1. **Prerequisites**: Ensure you have Flutter SDK installed.
2. **Installation**:
    ```bash
    flutter pub get
    ```
3. **Run**:
    ```bash
    flutter run
    ```
    *Note: This project uses Firebase. Ensure you have your `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) configured.*

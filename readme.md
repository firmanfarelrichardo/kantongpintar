<div align="center">
  <h1>💰 Kantong Pintar</h1>
  <p><strong>Smart Personal Finance Management App</strong></p>
  
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-3.9.2-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/SQLite-3-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
    <img src="https://img.shields.io/badge/License-Private-red?style=for-the-badge" alt="License" />
  </p>
</div>

---

## 📋 Table of Contents

- [About](#-about)
- [Features](#-features)
- [Screenshots](#-screenshots)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Database Schema](#-database-schema)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 About

**Kantong Pintar** adalah aplikasi manajemen keuangan pribadi yang membantu Anda mengelola pemasukan, pengeluaran, anggaran, dan target tabungan dengan cara yang **mudah**, **intuitif**, dan **profesional**.

Aplikasi ini dibangun dengan prinsip **Clean Architecture** dan **Repository Pattern** untuk memastikan kode yang maintainable, testable, dan scalable.

### 🌟 Why Kantong Pintar?

- ✅ **Multi-Account Support** - Kelola beberapa akun (Cash, E-Wallet, Bank)
- ✅ **Budget Tracking** - Pantau pengeluaran per kategori anggaran
- ✅ **Savings Goals** - Tetapkan dan capai target tabungan
- ✅ **Expense Categories** - Kategorisasi transaksi yang fleksibel
- ✅ **Visual Analytics** - Grafik dan statistik keuangan
- ✅ **Offline First** - Data tersimpan lokal dengan SQLite
- ✅ **Clean UI/UX** - Desain modern dan user-friendly

---

## ✨ Features

### 💳 Account Management
- Buat dan kelola multiple akun (ATM Card, E-Money, Cash)
- Tracking saldo real-time untuk setiap akun
- Transfer antar akun

### 📊 Transaction Tracking
- Catat pemasukan dan pengeluaran
- Pilihan tanpa kategori untuk transaksi fleksibel
- Filter berdasarkan tanggal, kategori, atau akun
- Pencarian transaksi cepat

### 🎯 Budget & Pocket System
- Buat anggaran (pocket) per kategori
- Alokasi dana otomatis ke anggaran
- Monitor pengeluaran vs budget
- Notifikasi ketika mendekati limit

### 💎 Saving Goals
- Tetapkan target tabungan
- Tracking progress visual
- Multiple savings goals aktif
- Estimasi waktu pencapaian

### 📈 Analytics & Reports
- Grafik pendapatan vs pengeluaran
- Analisis spending per kategori
- Trend keuangan bulanan
- Export laporan (Coming Soon)

---

## 📱 Screenshots

> _Screenshots will be added soon_

---

## 🏗️ Architecture

Aplikasi ini menggunakan **Clean Architecture** dengan pemisahan layer yang jelas:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│   (Pages, Widgets, Providers)           │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│         Business Logic Layer            │
│        (Repositories, Services)         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│   (Models, Database Service, SQLite)    │
└─────────────────────────────────────────┘
```

### Design Patterns Used:
- **Repository Pattern** - Data access abstraction
- **Singleton Pattern** - Database service management
- **Provider Pattern** - State management
- **Factory Pattern** - Model creation from database

---

## 🛠️ Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.9.2 |
| **Language** | Dart 3.9.2 |
| **Database** | SQLite (sqflite) |
| **State Management** | Provider |
| **Charts** | FL Chart |
| **Date Formatting** | Intl (id_ID locale) |
| **Dev Tools** | Device Preview, Flutter Lints |

### Key Dependencies:

```yaml
dependencies:
  flutter_sdk: flutter
  sqflite: ^2.3.3+1           # Local database
  provider: ^6.0.0            # State management
  intl: ^0.20.2               # Internationalization
  fl_chart: ^0.68.0           # Charts & graphs
  path_provider: ^2.1.3       # File system paths
  device_preview: ^1.1.0      # Multi-device preview
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/firmanfarelrichardo/kantongpintar.git
   cd kantongpintar
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For development (with Device Preview)
   flutter run
   
   # For production build
   flutter run --release
   ```

4. **Build for specific platform**
   ```bash
   # Android
   flutter build apk --release
   
   # iOS
   flutter build ios --release
   
   # Windows
   flutter build windows --release
   ```

### Troubleshooting

**Error: Unable to find Visual Studio toolchain (Windows)**
```bash
# Install Visual Studio 2022 with "Desktop development with C++" workload
# Then run:
flutter doctor -v
flutter config --enable-windows-desktop
```

**Database initialization error**
```bash
flutter clean
flutter pub get
```

---

## 📁 Project Structure

```
lib/
├── main.dart                      # Entry point
├── models/                        # Data models
│   ├── account.dart
│   ├── category.dart
│   ├── pocket.dart
│   ├── transaction.dart
│   └── saving_goal.dart
├── services/                      # Business logic & repositories
│   ├── database_service.dart     # SQLite setup
│   ├── account_repository.dart
│   ├── category_repository.dart
│   ├── pocket_repository.dart
│   ├── transaction_repository.dart
│   └── saving_goal_repository.dart
├── providers/                     # State management
│   └── home_provider.dart
├── pages/                         # UI screens
│   ├── main_screen.dart          # Bottom navigation
│   ├── home/
│   ├── transaction/
│   ├── graph/
│   ├── account/
│   ├── pockets/
│   ├── category/
│   ├── saving_goals/
│   └── settings/
└── utils/                         # Helper functions
    └── currency_format.dart
```

---

## 🗄️ Database Schema

### Tables Overview

```sql
-- Accounts (ATM, E-Money, Cash)
CREATE TABLE Accounts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  initial_balance REAL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Categories (Income/Expense)
CREATE TABLE Categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- 'income' or 'expense'
  icon_emoji TEXT,
  parent_id TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Pockets (Budget Allocation)
CREATE TABLE Pockets (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  target_amount REAL DEFAULT 0,
  category_id TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES Categories(id)
);

-- Transactions
CREATE TABLE Transactions (
  id TEXT PRIMARY KEY,
  account_id TEXT NOT NULL,
  category_id TEXT,
  pocket_id TEXT,
  amount REAL NOT NULL,
  type TEXT NOT NULL,  -- 'income', 'expense', 'transfer'
  description TEXT,
  transaction_date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (account_id) REFERENCES Accounts(id),
  FOREIGN KEY (category_id) REFERENCES Categories(id),
  FOREIGN KEY (pocket_id) REFERENCES Pockets(id)
);

-- Saving Goals
CREATE TABLE SavingGoals (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  target_amount REAL NOT NULL,
  current_amount REAL DEFAULT 0,
  target_date TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

### Entity Relationships

```
Accounts (1) ──── (N) Transactions
Categories (1) ──── (N) Transactions
Categories (1) ──── (N) Pockets
Pockets (1) ──── (N) Transactions
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Write meaningful commit messages
- Add comments for complex logic
- Update README if needed

---

## 📄 License

This project is **private** and not licensed for public use or distribution.

**Copyright © 2025 Firman Farel Richardo**

---

## 👨‍💻 Author

**Firman Farel Richardo**

- GitHub: [@firmanfarelrichardo](https://github.com/firmanfarelrichardo)

---

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Material Design for UI guidelines
- FL Chart for beautiful charts
- SQLite for reliable local storage

---

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p>⭐ Star this repo if you find it helpful!</p>
</div>

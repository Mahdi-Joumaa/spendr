# 💸 Spendr

> *Know where your money goes.*

Spendr is a personal finance tracker built with Flutter and Firebase. Clean dark UI, real-time expense tracking, category budgets, spending charts, and monthly insights — all in your pocket.

---

## ✨ Features

- 🔐 **Secure Auth** — Email/password signup and login with Firebase Authentication
- 💰 **Expense Logging** — Log expenses instantly with a custom numpad, category picker, note, and date
- 📊 **Dashboard** — See your total spending, budget progress, a donut chart breakdown, and recent transactions at a glance
- 📅 **History** — Browse past months, search transactions, and see your spending pattern as a bar chart with peak day detection
- 🎯 **Budget Management** — Set per-category limits, track spending rings, and get health scores (Excellent → Over Budget)
- 👤 **Profile** — Edit your name, adjust your monthly budget, change your password
- 🌑 **Dark Mode Only** — Obsidian dark theme, built for comfort

---

## 📱 Screens

| Screen | What it does |
|---|---|
| **Splash** | Landing screen — routes logged-in users to dashboard automatically |
| **Login** | Email + password login with show/hide password |
| **Sign Up** | Create account → set your first monthly budget |
| **Dashboard** | Total spent, budget bar, donut chart, recent transactions |
| **Add Expense** | Custom numpad, 5 categories, note, date picker |
| **History** | Month selector, search, bar chart, grouped transactions |
| **Budgets** | Category rings, health card, edit limits, delete expenses |
| **Profile** | Edit name, adjust budget, change password, logout |

---

## 🏗️ Architecture

Spendr follows a clean layered architecture:

```
UI (screens + widgets)
        ↕
State (Riverpod providers)
        ↕
Data (services)
        ↕
Firebase (Firestore + Auth)
```

Each layer only talks to the one directly next to it. Screens never talk to Firebase directly. Ever.

---

## 📁 Project Structure

```
lib/
├── main.dart                     # Entry point + routes
├── firebase_options.dart         # Auto-generated (gitignored)
│
├── models/
│   ├── user_model.dart           # User data + fromMap/toMap
│   ├── expense_model.dart        # Expense data + fromMap/toMap
│   └── budget_model.dart         # Budget data + fromMap/toMap
│
├── services/
│   ├── auth_service.dart         # Signup, login, logout, seed budgets
│   ├── expense_service.dart      # Add, stream, delete expenses
│   └── budget_service.dart       # Stream budgets, update limits
│
├── providers/
│   ├── auth_provider.dart        # Auth state, current user
│   ├── expense_provider.dart     # Expenses, total spent, by category
│   └── budget_provider.dart      # Budget list stream
│
├── screens/
│   ├── splash/                   # Auth routing
│   ├── auth/                     # Login + Signup
│   ├── dashboard/                # Main screen
│   ├── add_expense/              # Add transaction
│   ├── history/                  # Transaction history
│   ├── budget/                   # Budget management
│   └── profile/                  # User settings
│
├── widgets/
│   ├── spendr_app_bar.dart       # App bar with wallet icon + notification
│   ├── bottom_nav_bar.dart       # Bottom navigation (4 tabs)
│   ├── donut_chart.dart          # Category donut chart (fl_chart)
│   ├── expense_tile.dart         # Single transaction row
│   └── budget_ring.dart          # Circular progress ring (CustomPainter)
│
└── utils/
    ├── theme.dart                # AppColors + AppTheme.dark
    ├── constants.dart            # Categories, default values
    └── helpers.dart              # Date formatting, grouping, health labels
```

---

## 🗄️ Firestore Schema

```
users/
  {userId}
    ├── uid
    ├── name
    ├── email
    ├── currency
    ├── monthlyBudget          ← set by user on first signup
    └── createdAt

    budgets/
      {categoryId}             ← one doc per category
        ├── categoryId
        ├── name
        ├── icon
        ├── colorHex
        ├── budgetLimit
        └── createdAt

    expenses/
      {expenseId}              ← one doc per transaction
        ├── expenseId
        ├── amount
        ├── categoryId
        ├── note
        ├── date
        ├── month              ← "2026-03" used for fast filtering
        └── createdAt
```

---

## 🗂️ Categories

| ID | Display Name | Color |
|---|---|---|
| `food` | Food & Dining | 🟢 Green |
| `transport` | Transport | 🔵 Blue |
| `shopping` | Shopping | 🩷 Pink |
| `health` | Health | 🔴 Red |
| `other` | Other | ⚫ Grey |

---

## ⚙️ Tech Stack

| What | Why |
|---|---|
| **Flutter** | Cross-platform UI — one codebase for Android, iOS, Web |
| **Firebase Auth** | Secure email/password authentication |
| **Cloud Firestore** | Real-time NoSQL database with live streams |
| **Riverpod** | Global state management — providers watch each other |
| **fl_chart** | Donut chart + bar chart |
| **intl** | Date formatting and number formatting |
| **uuid** | Unique IDs for each expense document |
| **Firebase Hosting** | Web deployment |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/yourusername/spendr.git
cd spendr

# 2. Install Flutter packages
flutter pub get

# 3. Connect to your Firebase project
flutterfire configure

# 4. Run the app
flutter run
```

### pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: latest
  firebase_auth: latest
  cloud_firestore: latest
  flutter_riverpod: latest
  fl_chart: ^1.2.0
  intl: latest
  uuid: latest
```

---

## 🔥 Firebase Setup

### 1. Authentication
Firebase Console → Authentication → Sign-in method → Enable **Email/Password**

### 2. Firestore
Firebase Console → Firestore Database → Create Database → Start in **Test Mode** → Set your region

### 3. Security Rules
Firebase Console → Firestore → Rules tab → paste this → Publish:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### 4. Composite Index
The history query filters by `month` and orders by `date`. Firestore requires a composite index for this combination. When you first run the query, Firebase will throw an error with a direct link to create the index automatically. Click it, wait ~2 minutes for it to build, and you're done.

---

## 🌐 Deploying to Web

```bash
# Build for web
flutter build web

# Deploy to Firebase Hosting
firebase deploy
```

Live at: `https://your-project-id.web.app`

Every time you make changes, run those two commands again. The URL never changes.

---

## 🔒 Security — Files That Never Go to GitHub

All covered in `.gitignore`:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
firebase.json
.firebaserc
.firebase/
.env
.env.*
*.env
google-services.json
GoogleService-Info.plist
```

> **Rule:** If Firebase generated it, it stays local. Never commit it.

---

## 🧠 How Riverpod Providers Chain

```
authStateProvider           →  who is logged in right now (stream)
        ↓
currentUserProvider         →  fetches user doc from Firestore (future)
        ↓
expensesProvider            →  live stream of this month's expenses
        ↓
totalSpentProvider          →  sum of all expenses (computed automatically)
spentByCategoryProvider     →  { categoryId: amount } map (computed)
        ↓
budgetsProvider             →  live stream of all budget documents
```

When Firestore data changes → `expensesProvider` emits → computed providers recalculate → every watching widget rebuilds. You never manually refresh anything.

---

## 📌 Key Design Decisions

**Why a `month` field on every expense?**
Firestore can't do date range queries efficiently. Storing `"2026-03"` on every expense makes filtering by month a simple `.where()` instead of a complex date range query.

**Why Riverpod over setState?**
The dashboard, history, and budgets screens all need the same expense data. With Riverpod one stream feeds all three. With setState you'd be passing data through constructors all the way down.

**Why CustomPainter for budget rings?**
`fl_chart`'s PieChart is great for multi-slice charts but overkill for a single circular progress ring. CustomPainter draws exactly what we need with zero overhead.

**Why no automatic total budget recalculation?**
The monthly budget is set once by the user and stays fixed. Category limits are independent — changing one category's limit doesn't change the total. The user stays in full control.

---

## 🛣️ Roadmap

- [ ] Push notifications — budget warnings + monthly report alerts
- [ ] PDF/Excel monthly report export
- [ ] Light mode
- [ ] Profile photo upload
- [ ] Recurring expenses
- [ ] Multi-currency support

---

## 👨‍💻 Built By

Mahdi — built from scratch.
Designed in Stitch. Coded in Flutter. Powered by Firebase.

---

*Spendr • Version 1.0.0*

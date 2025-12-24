# ExpenseMate 💸📱

ExpenseMate is a modern iOS expense tracking app built with **SwiftUI** and **SwiftData** (iOS 17+), focused on clarity, speed, and calendar-based financial insights.

The app allows users to track **income and expenses**, visualize them in **monthly calendars and charts**, and review **daily transaction details** with ease.

---

## ✨ Features

- 📅 **Monthly calendar view**
  - Visual markers for days with income and/or expenses
  - Configurable week start (Sunday / Monday)

- 🧾 **Daily transactions**
  - List of income & expense entries per selected day
  - Category, amount, and optional notes
  - Daily balance calculation

- 📊 **Charts & analytics**
  - Monthly summaries for Income / Expense / Balance
  - Category-based breakdowns
  - Expandable charts view with different time scopes

- ⚙️ **Settings**
  - Week start configuration
  - Default currency support
  - Clean, iOS-native UX

---

## 🧠 App Architecture

- **SwiftUI** — declarative UI
- **SwiftData** — persistence layer (iOS 17+)
- **MVVM-style separation**
- Modular views:
  - Home
  - Calendar
  - Charts
  - Transaction editor
  - Settings

---

## 🖼 Screenshots & What They Showcase

The screenshots included in this repository highlight key UX and technical aspects of the app:

<img src="Products/Simulator Screenshot - iPhone 17 Pro - 2025-12-24 at 22.58.50.png" width="300">

### 1️⃣ Home / Calendar View
- Monthly calendar grid
- Day markers for:
  - 🟢 income
  - 🔴 expenses
- Selected day highlighting
- Quick overview of current month totals

➡️ **Demonstrates**:
- Calendar logic
- Date grouping
- SwiftUI layout composition

<img src="Products/Simulator Screenshot - iPhone 17 Pro - 2025-12-24 at 23.00.05.png" width="300">

### 2️⃣ Daily Transactions View
- List of transactions for a specific day
- Category icons (SF Symbols)
- Color-coded amounts (green/red)
- Inline daily balance summary

➡️ **Demonstrates**:
- SwiftData querying
- Dynamic lists
- Conditional formatting
- Data-driven UI updates

<img src="Products/Simulator Screenshot - iPhone 17 Pro - 2025-12-24 at 22.58.58.png" width="300">

### 3️⃣ Charts View
- Income / Expense / Balance tabs
- Monthly category breakdowns
- Expandable charts section

➡️ **Demonstrates**:
- Aggregation logic
- Data visualization
- Separation between mini & full charts
- Scalable analytics architecture

<img src="Products/Simulator Screenshot - iPhone 17 Pro - 2025-12-24 at 23.00.09.png" width="300">

### 4️⃣ Transaction Editor
- Add / edit income or expense
- Category selection
- Notes support

➡️ **Demonstrates**:
- Form handling in SwiftUI
- Reusable editor logic
- Clean navigation flows

---

## 🛠 Tech Stack

- **Swift 5**
- **SwiftUI**
- **SwiftData**
- **Combine**
- **SF Symbols**
- iOS 17+

---

## 🚧 Status

ExpenseMate is under active development.  
Upcoming improvements include:

- Custom date range analytics
- Export / backup options
- Advanced filtering
- iCloud sync

---

## 👤 Author

Developed by **Alex Senu**

---

## 📜 License

This project is for educational and portfolio purposes.

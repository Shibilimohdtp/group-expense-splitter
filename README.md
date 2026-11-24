# Group Expense Splitter

A Flutter + Firebase app for splitting shared bills among friends, flatmates and travel groups. Create a group, add expenses, and see who owes whom.

> Personal project, built 2024–2025. The working title inside the code is "SplitWise". It is not affiliated with Splitwise Inc.

## Features
- **Accounts:** email/password sign-up and login, Google Sign-In, password reset (Firebase Authentication)
- **Groups:** create groups, invite members, and share a join link or QR code
- **Expenses:** choose who paid, and split four ways: equally, by exact amounts, by percentage or by shares
- **Receipts:** attach a photo to an expense (Firebase Storage)
- **Balances:** per-group balances, suggested settlements and spending charts
- **Expense list:** filter by date range and other criteria
- **Export:** generate a PDF summary and share it
- **Notifications:** push (Firebase Cloud Messaging) and local notifications
- **Settings:** currency symbol, light/dark theme
- **Local storage:** SQLite (sqflite) cache for groups and expenses

## Tech stack
| Area | Tools |
|------|-------|
| Framework | Flutter, Dart |
| State management | Provider |
| Navigation | go_router |
| Backend | Firebase Auth, Cloud Firestore, Firebase Storage, Firebase Cloud Messaging |
| Local data | sqflite, shared_preferences |
| UI | fl_chart, flutter_staggered_animations, cached_network_image |
| Other | pdf, share_plus, qr_flutter, image_picker |

## Project structure
```
splitwise/lib/
├── constants/   # colours and theme
├── features/    # screens: authentication, groups, expenses, home, profile, settings, notifications
├── models/      # user, group, expense, invited member, notification
├── services/    # auth, expenses, groups, users, notifications, export, settings, SQLite helper
├── utils/       # currency helpers
└── widgets/     # reusable components grouped by screen
```

## Running it locally
1. Install the Flutter SDK (stable channel).
2. Create your own Firebase project and enable Authentication (email and Google), Firestore and Storage.
3. From `splitwise/`, run `flutterfire configure` to generate `firebase_options.dart` and `google-services.json` for your project.
4. Run:
   ```bash
   cd splitwise
   flutter pub get
   flutter run
   ```

## Status
- Fully built personal project; not published on app stores.
- Next steps: automated tests, a screenshot gallery, and removing generated build files from the repository.

## Author
**Shibili Muhammed T P**: [LinkedIn](https://www.linkedin.com/in/shibilimohdtp) · [Forma Studio](https://formastdio.com)

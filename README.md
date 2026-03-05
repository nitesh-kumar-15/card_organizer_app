# Card Organizer App

A Flutter app for organizing playing cards by suit. Built for **MAD (Mobile Application Development) In-Class 8**.

## About

Card Organizer lets you browse suit folders (Hearts, Diamonds, Clubs, Spades), view and manage cards in each folder, and add, edit, or delete cards. Data is stored locally using SQLite.

## Features

- **Folders (suits)**  
  - Grid of four suit folders with card counts  
  - Tap a folder to open its cards  
  - Delete a folder (all cards in that folder are removed via cascade)

- **Cards**  
  - List of cards in the selected folder  
  - Add new cards  
  - Edit card name, suit, folder, and optional image path  
  - Delete cards  
  - Optional card images from `assets/cards/`

- **Persistence**  
  - SQLite database (`card_organizer.db`) with:  
    - `folders` table (id, folder_name, timestamp)  
    - `cards` table (id, card_name, suit, image_url, folder_id) and foreign key with `ON DELETE CASCADE`  
  - App comes pre-filled with four suit folders and 13 cards per suit (Ace–King).

## Project Structure

```
lib/
├── main.dart                 # App entry, theme, home = FoldersScreen
├── models/
│   ├── card.dart             # PlayingCard model
│   └── folder.dart           # Folder model
├── repositories/
│   ├── card_repository.dart  # CRUD for cards
│   └── folder_repository.dart # CRUD for folders
├── helpers/
│   └── database_helper.dart  # SQLite init, schema, prepopulate
└── screens/
    ├── folders_screen.dart   # Grid of suit folders
    ├── cards_screen.dart     # List of cards in a folder
    └── add_edit_card_screen.dart # Add/Edit card form
```

## Requirements

- Flutter SDK (e.g. compatible with Dart `^3.10.7`)
- Dependencies in `pubspec.yaml`: `flutter`, `sqflite`, `path`, `path_provider`, `image_picker`, `http`

## Getting Started

1. **Clone the repo**
   ```bash
   git clone https://github.com/nitesh-kumar-15/card_organizer_app.git
   cd card_organizer_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

Choose a device (e.g. simulator, emulator, or connected device) when prompted.

## Assets

Card images can be placed under `assets/cards/` (e.g. `hearts_ace.png`, `spades_king.png`). The app references paths like `assets/cards/<suit>_<card>.png`; if an image is missing, a placeholder icon is shown.

## License

This project is for educational use (MAD In-Class 8).

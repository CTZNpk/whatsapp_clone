# WhatsApp Clone

## Overview
This project is a basic implementation of a WhatsApp clone built using Flutter. It demonstrates the core functionalities of a messaging application, including real-time messaging, user authentication, and media sharing. The app integrates Firebase as the backend for database, authentication, and storage.

---

## Features
- User authentication (email and phone number).
- Real-time messaging.
- Media sharing (images, videos, and files).
- Chat list and individual chat screens.
- Online/offline user status.
- Firebase Firestore integration for data storage.
- Firebase Storage for media handling.

---

## Prerequisites
- **Flutter SDK**: Ensure Flutter is installed on your system. You can download it from [flutter.dev](https://flutter.dev/docs/get-started/install).
- **Firebase Project**: Create a Firebase project and configure it for your app.
- **IDE**: Recommended IDEs are Visual Studio Code or Android Studio.

---

## Installation

### Steps
1. Clone the repository:
    ```bash
    git clone https://github.com/CTZNpk/whatsapp_clone.git
    cd whatsapp_clone
    ```

2. Get the dependencies:
    ```bash
    flutter pub get
    ```

3. Configure Firebase:
    - Download the `google-services.json` file for Android and place it in the `android/app` directory.
    - Download the `GoogleService-Info.plist` file for iOS and place it in the `ios/Runner` directory.

4. Run the application:
    ```bash
    flutter run
    ```

---

## Directory Structure
```
.
├── lib
│   ├── main.dart             # Entry point of the application
│   ├── screens               # Contains UI screens
│   │   ├── chat_screen.dart  # Chat screen UI
│   │   ├── home_screen.dart  # Home screen with chat list
│   ├── models                # Data models
│   │   ├── user_model.dart   # User data model
│   │   ├── message_model.dart # Message data model
│   ├── services              # Application services
│   │   ├── auth_service.dart # Authentication logic
│   │   ├── chat_service.dart # Chat-related logic
│   ├── theme                 # App theming configurations
│   │   ├── app_theme.dart    # Theme settings
│   ├── shared                # Shared utilities and components
│       ├── constants.dart    # Shared constants
```

---

## How It Works
- The app uses Firebase Authentication for user login and signup.
- Chat messages are stored in Firebase Firestore, ensuring real-time synchronization across devices.
- Media files are uploaded to Firebase Storage, and their URLs are saved in Firestore.
- The app uses Flutter widgets to create responsive and user-friendly interfaces.

---

## Future Enhancements
- Add voice and video call features.
- Implement end-to-end encryption for messages.
- Enhance group chat functionality.
- Add dark mode support.
- Improve UI/UX with animations and transitions.

---

## Contributing
Contributions are welcome! Feel free to fork the repository, make improvements, and submit a pull request.

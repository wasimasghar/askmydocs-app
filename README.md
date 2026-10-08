# AskMyDocs

A Flutter app for chatting with your PDFs. Upload documents, ask questions in
plain language, and get answers with links back to the exact page they came
from.

Runs on **Android, iOS and the web** from one codebase, with a responsive
layout for phones, tablets and desktop browsers.

> **Backend:** this app talks to the AskMyDocs API, which handles PDF parsing,
> indexing and answering.
> See **[wasimasghar/askmydocs-api](https://github.com/wasimasghar/askmydocs-api)**
> for setup and API details.

---

## Features

### Dashboard (chat)

- **Ask questions about your PDFs** in a chat interface.
- **User messages** on the right, **assistant answers** on the left.
- **Sources under every answer**: an expandable "Sources" section shows chips
  like `my_file.pdf · p.3`. Tap one to read the exact passage (bottom sheet on
  phones, dialog on wider screens).
- **Typing indicator** while the answer is being generated.
- **Suggested questions** on an empty chat to get started quickly.
- **Conversation context**: the last 6 messages are sent along, so follow-up
  questions work.
- **Error handling with retry**: a failed answer shows an inline
  "Try again" button and a message explaining what went wrong.
- **New chat** button to start over.
- **Enter to send** on web and desktop (Shift + Enter for a new line).

### Settings (documents)

- **Server status card**: online/offline indicator and number of indexed
  chunks.
- **Upload PDF**: pick a PDF from the device (works on web too). A progress
  indicator shows while the file is uploaded and indexed.
- **Up to 3 PDFs**: a `2 / 3 PDFs` counter on the upload card. At the limit,
  the upload button is disabled with a hint to delete one first.
- **PDF only, max 10 MB**, checked in the app before uploading and again by
  the server.
- **Document list**: name, page count, chunk count and an "Indexed" status for
  each PDF.
- **Delete PDF**: with a confirmation dialog. Only that row shows a spinner
  while it is deleted.
- **Clear feedback**: success and error messages as SnackBars, using the
  server's own error text (e.g. "my_file.pdf is already uploaded.").
- **Loading, error (with retry) and empty states.**

### Design

- Material 3 with a deep indigo / violet theme, soft gradients and rounded
  cards.
- **Light and dark mode** (follows the system setting).
- Inter font via `google_fonts`.
- **Responsive**: bottom navigation bar on phones (< 600 px), navigation rail
  on wider screens, content centred at max 900 px on desktop.

---

## Tech stack

| Area             | Package                          |
| ---------------- | -------------------------------- |
| State management | `flutter_bloc`, `equatable`      |
| Networking       | `dio`                            |
| File picking     | `file_picker` (bytes, web-safe)  |
| Fonts            | `google_fonts`                   |

---

## Getting started

### 1. Start the backend

Follow the instructions in
[askmydocs-api](https://github.com/wasimasghar/askmydocs-api). By default the
app expects it at port **3999**.

### 2. Run the app

```bash
flutter pub get

# Web
flutter run -d chrome
# or, for any browser (Firefox, Safari...):
flutter run -d web-server --web-port 8080   # then open http://localhost:8080

# Android emulator / iOS simulator
flutter run
```

### 3. Server URL

| Platform                 | Default URL               |
| ------------------------ | ------------------------- |
| Web, iOS, macOS          | `http://127.0.0.1:3999`   |
| Android emulator         | `http://10.0.2.2:3999`    |

To use another server (for example a **physical phone** on the same Wi-Fi,
which can't reach your computer's `127.0.0.1`), pass it at build time:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3999
```

No API keys or secrets are stored in the app.

> **Web note:** the browser blocks requests to the API unless the backend
> allows CORS for the app's origin (e.g. `http://localhost:8080`).

---

## Project structure

```
lib/
├── main.dart                 # Providers: repositories + blocs
├── app/                      # MaterialApp, theme, responsive navigation shell
├── core/
│   ├── constants/            # Strings, sizes, limits
│   ├── network/              # Dio client, endpoints, config, error mapping
│   ├── theme/                # Colors, text styles, light/dark themes
│   └── utils/                # Breakpoints, PDF picker
├── data/
│   ├── models/               # ChatMessage, Source, Document (JSON)
│   └── repositories/         # Abstract repos, real API impls, mocks
├── features/
│   ├── dashboard/            # Chat: bloc, screen, widgets
│   └── settings/             # Documents: bloc, screen, widgets
└── shared/widgets/           # Reusable cards, buttons, empty/error/loading
```

### Working without a backend

Mock repositories with realistic fake data are included. In `lib/main.dart`,
swap the real repositories for the mocks:

```dart
RepositoryProvider<ChatRepository>(create: (_) => MockChatRepository()),
RepositoryProvider<DocumentRepository>(create: (_) => MockDocumentRepository()),
```

---

## Tests

```bash
flutter test
```

Covers the chat and documents blocs, the API repositories (using a fake HTTP
adapter, no server needed), and the responsive breakpoints.

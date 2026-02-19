# Pinterest Clone - Flutter App

> 🚀 **New here?** Start with [START_HERE.md](START_HERE.md) for a 5-minute setup!

A beautiful Pinterest-style image browsing app built with Flutter, featuring Clean Architecture and real-time photo fetching from the Pexels API.

## ✨ Features

- 🎨 Pinterest-style masonry grid layout
- 🖼️ Real photos from Pexels API
- ⚡ Image caching for fast loading
- 🔄 Pull-to-refresh functionality
- 📜 Infinite scroll pagination
- ✨ Shimmer loading effects
- 🏗️ Clean Architecture implementation
- 🔧 State management with Riverpod

## 🚀 Quick Start

### 1. Get Your API Key (2 minutes)
Visit [Pexels API](https://www.pexels.com/api/) and sign up for a free API key.

### 2. Configure (30 seconds)
Open `lib/core/constants/api_constants.dart` and add your key:
```dart
static const String apiKey = 'YOUR_PEXELS_API_KEY_HERE';
```

### 3. Run (1 minute)
```bash
flutter pub get
flutter run
```

### ⚠️ Important: Network Error Fix
If you get a "Failed host lookup" error:
1. **Stop the app** (Ctrl+C or Stop button)
2. **Close the emulator completely**
3. **Restart the emulator**
4. **Run again**: `flutter run`

The internet permission has been added to AndroidManifest.xml. A simple emulator restart will fix the network issue.

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more solutions.

## 📁 Project Structure

```
lib/
├── core/                    # Shared utilities
│   ├── constants/          # API configuration
│   ├── network/            # HTTP client
│   └── utils/              # Result pattern
│
├── features/home/          # Home feature (Clean Architecture)
│   ├── data/              # API integration & models
│   ├── domain/            # Business logic & entities
│   └── presentation/      # UI & state management
│
└── screen/                # Other screens
```

## 🏗️ Architecture

This project implements Clean Architecture with three distinct layers:

- **Domain Layer**: Business logic and entities (pure Dart)
- **Data Layer**: API integration and data models
- **Presentation Layer**: UI and state management (Flutter + Riverpod)

```
UI → State Management → Use Cases → Repository → Data Source → API
```

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get started in 3 steps
- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed setup instructions
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Architecture diagrams and patterns
- **[API_INTEGRATION.md](API_INTEGRATION.md)** - API details and usage
- **[IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)** - What was built
- **[CHECKLIST.md](CHECKLIST.md)** - Setup and verification checklist

## 🛠️ Tech Stack

- **Flutter** - UI framework
- **Riverpod** - State management
- **Dio** - HTTP client
- **Pexels API** - Photo source
- **cached_network_image** - Image caching
- **Shimmer** - Loading effects
- **flutter_staggered_grid_view** - Masonry layout

## 📦 Dependencies

```yaml
flutter_riverpod: ^2.6.1      # State management
dio: ^5.7.0                    # Networking
cached_network_image: ^3.4.1  # Image caching
shimmer: ^3.0.0                # Loading effects
flutter_staggered_grid_view: ^0.7.0  # Grid layout
```

## 🎯 Key Features

### Clean Architecture
- Separation of concerns
- Testable code
- Maintainable structure
- Scalable design

### API Integration
- Real-time photo fetching
- Proper error handling
- Type-safe responses
- Rate limit handling

### Performance
- Image caching
- Lazy loading
- Efficient state management
- Smooth scrolling

### UI/UX
- Pinterest-style grid
- Shimmer loading
- Pull-to-refresh
- Infinite scroll
- Error states with retry

## 🔧 Configuration

### API Key Setup
1. Get your free API key from [Pexels](https://www.pexels.com/api/)
2. Open `lib/core/constants/api_constants.dart`
3. Replace `YOUR_PEXELS_API_KEY` with your actual key

### Customization
- Change grid columns in `home_screen_new.dart`
- Adjust photos per page in `photo_provider.dart`
- Customize colors and styles in theme

## 🧪 Testing

### Manual Testing
```bash
flutter run
```

### Test Features
- ✅ Photos load from API
- ✅ Pull-to-refresh works
- ✅ Infinite scroll works
- ✅ Images are cached
- ✅ Error handling works

## 📱 Screenshots

The app features:
- Pinterest-style masonry grid
- Smooth scrolling
- Beautiful shimmer loading
- Clean, modern UI

## 🤝 Contributing

This is a learning project demonstrating Clean Architecture in Flutter. Feel free to:
- Fork the repository
- Create feature branches
- Submit pull requests
- Report issues

## 📄 License

This project uses the Pexels API. All photos are provided by Pexels and are free to use under the [Pexels License](https://www.pexels.com/license/).

## 🙏 Acknowledgments

- [Pexels](https://www.pexels.com/) for providing the free photo API
- Flutter team for the amazing framework
- Riverpod for excellent state management

## 📞 Support

If you encounter any issues:
1. Check the documentation files
2. Review console logs
3. Verify your API key
4. Check internet connection

## 🎓 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Pexels API Docs](https://www.pexels.com/api/documentation/)

---

Made with ❤️ using Flutter and Clean Architecture

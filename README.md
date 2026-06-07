# 🧭 WanderMate

An AI-powered location-based travel assistant developed with Flutter.

WanderMate helps users discover nearby places using Google Maps, Google Places API, weather-aware recommendations, crowd density reporting, and Gemini AI-powered travel assistance. The application combines location-based services and artificial intelligence to provide a personalized travel and exploration experience.

---

## ✨ Features

* 🗺️ Google Maps Integration
* 📍 Google Places API Integration
* 🤖 Gemini AI Travel Assistant
* 🔍 Smart Query Analysis
* 👥 Crowd Density Reporting
* 🌤️ Weather-Based Recommendations
* 🎯 Personalized User Preferences
* 🏛️ Historical Places Discovery
* 🍽️ Local Food Recommendations
* 📸 Photography Spot Suggestions

---

## 📱 Screenshots

### Onboarding Experience

| Language Selection                             | Currency Selection                             |
| ---------------------------------------------- | ---------------------------------------------- |
| ![](assets/screenshots/language_selection.png) | ![](assets/screenshots/currency_selection.png) |

| Travel Style                             | Budget Selection                             |
| ---------------------------------------- | -------------------------------------------- |
| ![](assets/screenshots/travel_style.png) | ![](assets/screenshots/budget_selection.png) |

### Home Map

![Home Map](assets/screenshots/home_map.png)

### Place Detail & Crowd Reporting

![Place Detail](assets/screenshots/place_detail.png)

### AI Recommendation

![AI Recommendation](assets/screenshots/ai_recommendation.png)

### Explore Screen

![Explore Top](assets/screenshots/explore_top.png)

![Explore Bottom](assets/screenshots/explore_bottom.png)

---

## 🛠️ Technologies

### Mobile Development

* Flutter 3.41.6
* Dart 3.11.4

### APIs & Services

* Google Maps API
* Google Places API
* Gemini API

### State Management

* Riverpod
* Provider

### Storage

* SharedPreferences
* SQLite (sqflite)

### Additional Packages

* Geolocator
* Geocoding
* Go Router
* Cached Network Image
* Flutter Animate
* Flutter SVG

---

## 🏗️ Project Architecture

```text
lib/
├── constants/
├── core/
├── models/
├── presentation/
├── routes/
├── theme/
├── utils/
└── widgets/
```

---

## ⚙️ Configuration

For security reasons, API keys are not included in this repository.

Open:

```dart
lib/core/api_keys.dart
```

Replace the placeholder values with your own:

```dart
class ApiKeys {
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
}
```

Required APIs:

* Google Maps SDK
* Google Places API
* Google Geocoding API
* Gemini API

---

## 🚀 Installation

```bash
git clone https://github.com/dilara-sambur/WanderMate.git
cd WanderMate

flutter pub get
flutter run
```

---

## 🔒 Security

The application was analyzed using Mobile Security Framework (MobSF) to identify and address potential mobile security issues.

---

## 👩‍💻 Author

**Dilara Sambur**

Management Information Systems
Bilecik Şeyh Edebali University


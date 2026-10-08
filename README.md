# 🩺 SafeBand — Application Flutter Alzheimer

Application mobile de surveillance de bracelet IoT pour les patients atteints d'Alzheimer.

---

## 📱 Fonctionnalités

| Fonctionnalité | Description |
|---|---|
| 🔋 **Alerte batterie faible** | Notification push quand la batterie descend sous 20% |
| ⌚ **Bracelet retiré** | Détection immédiate et alerte si le bracelet est enlevé |
| 📍 **Sortie de zone** | Géofence configurable (rayon en mètres autour du domicile) |
| 🗺️ **Localisation GPS** | Carte temps réel avec position du patient |
| 🆘 **Bouton SOS** | Alerte d'urgence depuis l'app ou le bracelet physique |
| 🔐 **Authentification** | Login / Register avec Firebase Auth |
| 🔔 **Notifications push** | FCM + notifications locales critiques |

---

## 🏗️ Architecture

```
lib/
├── main.dart                    ← Point d'entrée + Firebase init
├── theme/
│   └── app_theme.dart           ← Thème dark custom
├── models/
│   └── models.dart              ← Patient, BraceletStatus, AlertEvent, AppUser
├── services/
│   ├── auth_service.dart        ← Firebase Auth (login, register, reset)
│   ├── bracelet_service.dart    ← Realtime DB + Firestore + notifications
│   └── notification_service.dart← FCM + flutter_local_notifications
├── providers/
│   └── providers.dart           ← Riverpod state management
├── screens/
│   ├── splash_screen.dart       ← Écran de démarrage animé
│   ├── auth_screen.dart         ← Login / Register
│   ├── home_screen.dart         ← Navigation principale (BottomNav)
│   ├── dashboard_screen.dart    ← Tableau de bord temps réel
│   ├── map_screen.dart          ← Carte Google Maps + géofence
│   ├── history_screen.dart      ← Historique des alertes
│   └── settings_screen.dart     ← Paramètres, contacts, notifications
└── widgets/
    ├── patient_header_widget.dart
    ├── stat_card_widget.dart
    ├── battery_card_widget.dart
    ├── alert_banner_widget.dart
    ├── sos_button_widget.dart
    └── section_title_widget.dart
```

---

## 🔥 Firebase Setup

### 1. Créer le projet Firebase
1. Aller sur [console.firebase.google.com](https://console.firebase.google.com)
2. Créer un projet : `SafeBand`
3. Ajouter une app **Android** avec le package `com.safeband.app`
4. Télécharger `google-services.json` → placer dans `android/app/`
5. *(optionnel iOS)* Télécharger `GoogleService-Info.plist` → placer dans `ios/Runner/`

### 2. Activer les services Firebase
| Service | Configuration |
|---|---|
| **Authentication** | Activer Email/Password |
| **Firestore** | Créer en mode test, puis appliquer `firestore.rules` |
| **Realtime Database** | Créer, région `europe-west1`, appliquer `database.rules.json` |
| **Cloud Messaging** | Aucune config supplémentaire (auto avec google-services.json) |

### 3. Structure Firestore
```
users/
  {uid}/
    email: string
    displayName: string
    patientId: string
    fcmToken: string

patients/
  patient_001/
    name: "Mohamed Karim"
    age: 72
    braceletId: "bracelet_SB0042"
    safeZone: { latitude, longitude, radiusMeters, active }
    contacts: [ { name, phone, relation } ]
    alerts/
      {alertId}/
        type: "battery"|"removed"|"outOfZone"|"sos"
        message: string
        timestamp: Timestamp
        resolved: bool
```

### 4. Structure Realtime Database
```json
{
  "bracelets": {
    "bracelet_SB0042": {
      "battery": 23,
      "worn": true,
      "inZone": true,
      "lat": 36.8065,
      "lng": 10.1815,
      "gpsSignal": 4,
      "sos": false,
      "lastSync": 1710000000000
    }
  }
}
```

---

## 🗺️ Google Maps Setup

### Android
1. Aller sur [console.cloud.google.com](https://console.cloud.google.com)
2. Activer **Maps SDK for Android**
3. Créer une clé API
4. Dans `android/app/src/main/AndroidManifest.xml`, remplacer :
   ```xml
   android:value="YOUR_GOOGLE_MAPS_API_KEY"
   ```

### iOS
Dans `ios/Runner/AppDelegate.swift` :
```swift
import GoogleMaps
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

---

## 🚀 Installation

```bash
# 1. Cloner / décompresser le projet
cd safeband

# 2. Installer les dépendances
flutter pub get

# 3. Placer google-services.json dans android/app/

# 4. Lancer l'app
flutter run

# Build release Android
flutter build apk --release

# Build release iOS
flutter build ios --release
```

---

## 📡 Communication Bracelet ↔ App

Le bracelet IoT (ESP32 / Arduino avec module GSM/WiFi) envoie ses données vers **Firebase Realtime Database** :

```cpp
// Exemple ESP32 (Arduino)
#include <WiFi.h>
#include <Firebase_ESP_Client.h>

void loop() {
  // Lire capteurs
  int battery  = readBattery();
  bool worn    = readWornSensor();
  float lat    = gps.location.lat();
  float lng    = gps.location.lng();
  bool sos     = digitalRead(SOS_BUTTON_PIN);

  // Envoyer à Firebase
  Firebase.RTDB.setInt(&fbdo,   "/bracelets/bracelet_SB0042/battery",  battery);
  Firebase.RTDB.setBool(&fbdo,  "/bracelets/bracelet_SB0042/worn",     worn);
  Firebase.RTDB.setFloat(&fbdo, "/bracelets/bracelet_SB0042/lat",      lat);
  Firebase.RTDB.setFloat(&fbdo, "/bracelets/bracelet_SB0042/lng",      lng);
  Firebase.RTDB.setBool(&fbdo,  "/bracelets/bracelet_SB0042/sos",      sos);
  Firebase.RTDB.setInt(&fbdo,   "/bracelets/bracelet_SB0042/lastSync", millis());
  delay(30000); // toutes les 30 secondes
}
```

---

## 🛠️ Technologies utilisées

| Tech | Usage |
|---|---|
| **Flutter 3.x** | Framework mobile cross-platform |
| **Firebase Auth** | Authentification sécurisée |
| **Cloud Firestore** | Base de données patients et alertes |
| **Firebase Realtime DB** | Statut bracelet temps réel |
| **Firebase Messaging (FCM)** | Notifications push |
| **Google Maps Flutter** | Carte et géofence |
| **flutter_riverpod** | State management |
| **flutter_local_notifications** | Notifications locales |

---

## 👨‍💻 Développé par

Projet SafeBand — Bracelet IoT Alzheimer

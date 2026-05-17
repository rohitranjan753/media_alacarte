# Ad Campaign Performance Dashboard

> **Flutter Mobile Application** for monitoring ad campaign performance with ML-powered CTR forecasting and anomaly detection.

A professional 4-screen Flutter application built for Media Alacarte that provides real-time campaign analytics, ML-based performance predictions, spend analysis, and automated anomaly alerts.

---

## 📱 Features

### 🎯 Campaign List
- Real-time campaign overview with pull-to-refresh
- Filter by status (All / Active / Paused)
- Search campaigns by name
- Campaign cards showing:
  - Budget progress bars
  - Impressions, Clicks, CTR metrics
  - Status badges
- Smooth animations and shimmer loading states

### 📊 Campaign Detail
- 30-day CTR history chart with interactive tooltips
- 7-day ML-powered CTR forecast with confidence intervals
- Budget recommendations based on predicted trends
- Historical vs. forecast data visualization using fl_chart
- Pull-to-refresh for latest metrics

### 💰 Spend Summary
- Total spend KPI card
- Date range selector (Last 7 / 14 / 30 Days)
- Spend by channel donut chart (Search / Social / Display)
- Top 3 performers ranked by CTR
- Dynamic chart legends and animations

### 🚨 Anomaly Alerts
- Real-time monitoring (polls every 30 seconds)
- ML-based anomaly detection for:
  - Spend spikes (red alerts)
  - CTR drops (yellow alerts)
- Live status bar with countdown timer
- Local push notifications for new anomalies
- Empty state with "All metrics healthy" message

### 👤 Profile & Settings
- User profile management
- App settings and preferences
- Logout functionality with confirmation dialog

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Screens    │  │   Widgets    │  │  Animations  │          │
│  └──────┬───────┘  └──────────────┘  └──────────────┘          │
│         │                                                         │
│         ▼                                                         │
│  ┌──────────────────────────────────────────────────┐           │
│  │                 BLoC Layer                        │           │
│  │  (State Management - flutter_bloc)               │           │
│  │  • CampaignListBloc                              │           │
│  │  • CampaignDetailBloc                            │           │
│  │  • SpendSummaryBloc                              │           │
│  │  • AnomalyBloc                                   │           │
│  └──────┬───────────────────────────────────────────┘           │
└─────────┼─────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
│  ┌──────────────────────────────────────────────────┐           │
│  │               Repositories                        │           │
│  │  • CampaignRepository                            │           │
│  │  • MlRepository                                  │           │
│  │  └─► (Hive caching layer - optional)            │           │
│  └──────┬───────────────────────────────────────────┘           │
│         │                                                         │
│         ▼                                                         │
│  ┌──────────────────────────────────────────────────┐           │
│  │                  Services                         │           │
│  │  • AdsApiService (Dio)                           │           │
│  │  • MlApiService (Dio)                            │           │
│  │  • NotificationService                           │           │
│  └──────┬───────────────────────────────────────────┘           │
└─────────┼─────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────┐
│                     External Services                            │
│  • Ads API (campaign data, metrics, summary)                    │
│  • ML API (CTR forecasting, anomaly detection)                  │
│  • Local Notifications (flutter_local_notifications)            │
└─────────────────────────────────────────────────────────────────┘
```

### Architecture Patterns

- **Clean Architecture**: Clear separation between UI, business logic, and data
- **BLoC Pattern**: Unidirectional data flow with flutter_bloc
- **Repository Pattern**: Abstract data sources from business logic
- **Dependency Injection**: get_it for service location and DI
- **Named Routes**: Centralized navigation via app_router.dart

### Key Principles

✅ No business logic in build() methods
✅ All API calls wrapped in try/catch
✅ Loading indicators on every async operation
✅ Error handling with user-facing messages
✅ Proper state management (no setState abuse)
✅ Reactive UI updates with ValueNotifiers and Streams

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.41.8 or higher (Channel: stable)
- **Dart SDK**: 3.11.5 or higher
- **IDE**: VS Code or Android Studio with Flutter/Dart plugins
- **Device/Emulator**: iOS 12+ or Android 5.0+ (API 21+)

### Verified Environment

This project has been tested with the following configuration:

```
Flutter SDK:     3.41.8 (stable channel)
Dart SDK:        3.11.5
DevTools:        2.54.2
Android SDK:     36.0.0
Xcode:           26.2 (Build 17C52)
CocoaPods:       1.16.2
Java:            OpenJDK 21.0.6
```

**Supported Platforms:**
- ✅ Android (API 21+)
- ✅ iOS (12.0+)
- ✅ macOS Desktop
- ✅ Web (Chrome)

**Verified Devices:**
- Android Emulator (API 36, arm64)
- macOS Desktop (darwin-arm64)
- Chrome Browser (web)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd media_alacarte
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```

4. **Run code generation** (if using freezed/json_serializable)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Running the App

#### Development Mode
```bash
flutter run
```

#### Release Mode (Android)
```bash
flutter run --release
```

#### Specific Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Build for Production

#### Android APK
```bash
flutter build apk --release
```
---

## 🔧 Environment Verification

### Check Flutter Installation
```bash
flutter doctor -v
```

This should show all checkmarks (✓) for:
- Flutter SDK
- Android toolchain
- Xcode (macOS only)
- Connected devices
- Network resources

---

## 🧪 Testing

### Run All Tests
```bash
flutter test
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Specific Test File
```bash
flutter test test/repositories/campaign_repository_test.dart
```

### Test Structure
```
test/
├── repositories/
│   ├── campaign_repository_test.dart
│   └── ml_repository_test.dart
└── blocs/
    ├── campaign_list_bloc_test.dart
    └── anomaly_bloc_test.dart
```

### Testing Tools
- **bloc_test**: Testing BLoC state transitions
- **mocktail**: Mocking dependencies
- **flutter_test**: Core testing framework

---

## 📦 Dependencies

### Core Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management |
| `dio` | ^5.7.0 | HTTP client for API calls |
| `fl_chart` | ^0.69.0 | Data visualization (line/pie charts) |
| `flutter_local_notifications` | ^18.0.0 | Push notifications |
| `equatable` | ^2.0.5 | Value equality for models |
| `get_it` | ^8.0.2 | Dependency injection |
| `hive_flutter` | ^1.1.0 | Local caching (optional) |

### Dev Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `bloc_test` | ^9.1.7 | BLoC testing utilities |
| `mocktail` | ^1.0.4 | Mocking framework |
| `flutter_lints` | Latest | Dart linting rules |

---

## 🌐 API Integration

### Base URL
```
https://e5eb0d84-2b7e-4c32-98b9-233668b4e189.mock.pstmn.io/v1
```

### Endpoints

#### Ads API
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/campaigns` | GET | List all campaigns |
| `/campaigns/:id` | GET | Get campaign details |
| `/campaigns/:id/history` | GET | Get 30-day CTR history |
| `/campaigns/summary` | GET | Get spend summary (by channel + date range) |
| `/campaigns/metrics/live` | GET | Get real-time metrics snapshot |

#### ML API
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/forecast/ctr` | POST | Generate 7-day CTR forecast |
| `/anomaly/detect` | POST | Detect anomalies from snapshot |

### Request Examples

**CTR Forecast:**
```json
POST /forecast/ctr
{
  "campaign_id": "camp_001",
  "history": [
    { "date": "2026-05-01", "ctr": 4.2 },
    { "date": "2026-05-02", "ctr": 4.5 }
  ],
  "horizon_days": 7
}
```

**Anomaly Detection:**
```json
POST /anomaly/detect
{
  "snapshot": {
    "campaign_id": "camp_001",
    "spend": 15000,
    "ctr": 2.1,
    "impressions": 50000,
    "clicks": 1050,
    "timestamp": "2026-05-16T10:30:00Z"
  }
}
```

---

## 🎨 Design System

### Colors
```dart
// Background
background:  #111113
surface:     #1B1A1E
cardBorder:  #232127

// Accent
primary:      #1CB4BF (teal brand)
primaryLight: #1ECDD9

// Status
statusActive: #22C55E (green)
statusPaused: #F59E0B (amber)
statusEnded:  #6B7280 (gray)

// Alerts
alertSpend: #EF4444 (red - spend spike)
alertCTR:   #F59E0B (yellow - CTR drop)

// Text
textPrimary:   #F5F5F6
textSecondary: #9A9AA2
```

### Typography
- **Font Family**: System default (San Francisco on iOS, Roboto on Android)
- **Weights**: 400 (regular), 500 (medium), 600 (semibold), 700 (bold)
- **Sizes**: 11px - 32px (responsive via MediaQuery)

### Spacing Scale
```
4 / 8 / 12 / 16 / 24 / 32 / 48 px
```

### Corner Radius
- Cards: 12px
- Chips: 8px
- Badges: 6px

---

## 📱 Notifications Setup

### Android
1. Notification permissions are requested at runtime (Android 13+)
2. Icons located at: `android/app/src/main/res/mipmap-*/ic_launcher.png`
3. Required permissions added to `AndroidManifest.xml`:
   - `POST_NOTIFICATIONS`
   - `VIBRATE`
   - `INTERNET`


### Testing Notifications
1. Navigate to Anomaly Alerts screen
2. Enable notifications via toggle at bottom
3. Wait for polling cycle (30 seconds)
4. Notifications appear when new anomalies detected

---

## 🔧 Configuration

### Environment Variables
Currently using hardcoded API base URL. For multiple environments:

```dart
// lib/config/environment.dart
abstract class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://e5eb0d84-2b7e-4c32-98b9-233668b4e189.mock.pstmn.io/v1',
  );
}
```

Run with:
```bash
flutter run --dart-define=API_BASE_URL=https://your-api.com/v1
```

---

## 📝 Assumptions & Design Decisions

### API Assumptions
1. **Mock API**: Using Postman mock server, responses may be static
2. **CTR Format**: API returns CTR as ratio (0.048), converted to percentage (4.8%) for display
3. **Polling Frequency**: Anomaly detection polls every 30 seconds (adjustable)
4. **Forecast Horizon**: Fixed 7-day forecast window
5. **Date Ranges**: Summary supports 7/14/30 days only

### Implementation Decisions
1. **State Management**: Chose BLoC over Riverpod for:
   - Clear event/state separation
   - Better testing support with bloc_test
   - Explicit state transitions

2. **Caching**: Hive implemented but optional:
   - Fallback to cached data on network errors
   - Reduces API calls for frequently accessed data

3. **Error Handling**: All errors converted to user-friendly messages:
   - Network errors → "Unable to connect. Check your internet."
   - Timeout errors → "Request timed out. Try again."
   - Parse errors → "Invalid data received."

4. **Dark Mode Only**: Per spec, only dark theme implemented
   - Consistent with dashboard/analytics aesthetics
   - Reduces eye strain for extended monitoring

5. **Animations**: Subtle, smooth transitions:
   - Shimmer for loading states (not just spinners)
   - Staggered list item animations
   - Smooth page transitions with slide/fade

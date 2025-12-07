# Pixel Love - Flutter Clean Architecture

## 📁 Folder Structure

```
lib/
├── core/
│   ├── env/                      # Environment config (.env loader)
│   ├── network/                  # Dio API client + Interceptors
│   │   ├── dio_api.dart
│   │   ├── api_result.dart
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart
│   │       ├── log_interceptor.dart
│   │       └── error_interceptor.dart
│   ├── errors/                   # Failure & Exception classes
│   ├── utils/                    # Validators, Mapper
│   └── config/                   # App config
│
├── features/                     # Clean Architecture per feature
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/      # Remote API calls
│   │   │   ├── models/           # DTO (JSON serialization)
│   │   │   └── repositories/     # Repository implementation
│   │   ├── domain/
│   │   │   ├── entities/         # Business models
│   │   │   ├── repositories/     # Repository interface
│   │   │   └── usecases/         # Use cases
│   │   └── presentation/
│   │       ├── bindings/         # GetX bindings
│   │       ├── controllers/      # GetX controllers
│   │       └── pages/            # UI screens
│   ├── user/
│   ├── couple/
│   ├── pet/
│   ├── memory/
│   └── payment/
│
├── routes/
│   ├── app_routes.dart           # Route names
│   └── app_pages.dart            # GetX pages + bindings
│
├── bindings/
│   └── initial_binding.dart      # Global dependencies
│
└── main.dart
```

---

## 🔧 Setup Instructions

### 1. Create `.env` file in project root

```env
API_BASE_URL=https://your-api.com/api
ONE_SIGNAL_KEY=XXXX
PAYOS_CLIENT_ID=XXXX
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

---

## 🏗️ Architecture Principles

### Clean Architecture Layers

1. **Data Layer** (Outer)
   - Remote DataSources → API calls
   - DTOs → JSON serialization
   - Repository Implementation → Converts DTO → Entity

2. **Domain Layer** (Core)
   - Entities → Business models (immutable)
   - Repository Interface → Contract
   - UseCases → Single responsibility business logic

3. **Presentation Layer**
   - Controllers → GetX state management
   - Pages → UI screens
   - Bindings → Dependency injection

---

## 🌐 API Integration

### DioApi Client

All API calls go through `DioApi`:

```dart
final dioApi = Get.find<DioApi>();

final result = await dioApi.post(
  '/auth/google',
  data: {'idToken': token},
  fromJson: (json) => AuthUserDto.fromJson(json['data']),
);
```

### Interceptors

1. **AuthInterceptor** → Auto-inject JWT token
2. **LogInterceptor** → Log requests/responses
3. **ErrorInterceptor** → Handle 401 → Redirect to login

---

## 📦 Feature Modules

### Auth Module
- **POST** `/auth/google` → Google login
- **POST** `/auth/facebook` → Facebook login

**Features:**
- Google Sign-In integration
- Facebook Auth integration
- JWT token storage (GetStorage)
- Auto-login on app start

### User Module
- **GET** `/user/me` → Get current user
- **PUT** `/user/update` → Update profile

**Features:**
- Profile display with avatar
- Edit profile dialog
- Pull-to-refresh

### Couple Module
- **POST** `/couple/create` → Create couple room
- **POST** `/couple/join` → Join with invite code
- **GET** `/couple/info` → Get couple info

**Features:**
- Create couple room
- Generate invite code
- Copy invite code to clipboard
- Join couple room

### Pet Module
- **GET** `/pet/status` → Get pet status
- **POST** `/pet/feed` → Feed pet

**Features:**
- Pet stats (Level, EXP, Hunger, Happiness)
- Feed pet action
- Visual progress bars
- Hungry pet warning

### Memory Module
- **POST** `/memory/upload` → Upload memory (multipart)
- **GET** `/memory/list` → Get memory list

**Features:**
- Image upload via ImagePicker
- Gallery & Camera support
- Grid view display
- Full screen preview

### Payment Module
- **POST** `/payment/create` → Create payment link
- **POST** `/payment/webhook` → Webhook (backend only)

**Features:**
- Multiple coin packages
- PayOS WebView integration
- Payment completion detection
- Cancel payment flow

---

## 🎯 ApiResult Pattern

All API calls return `ApiResult<T>`:

```dart
final result = await useCase.call();

result.when(
  success: (data) {
    // Handle success
  },
  error: (failure) {
    // Handle error
    Get.snackbar('Error', failure.message);
  },
);
```

---

## 🔐 Error Handling

### Failure Types

- `ServerFailure` → API errors
- `NetworkFailure` → Network issues
- `UnauthorizedFailure` → 401 errors
- `ValidationFailure` → 400 errors

### Auto Logout on 401

When JWT expires, `ErrorInterceptor` auto-redirects to login.

---

## 🚀 Adding New Features with Mason

### Manual Feature Creation (Template)

For new feature `example`:

```
lib/features/example/
├── data/
│   ├── datasources/
│   │   └── example_remote_datasource.dart
│   ├── models/
│   │   └── example_dto.dart
│   └── repositories/
│       └── example_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── example.dart
│   ├── repositories/
│   │   └── example_repository.dart
│   └── usecases/
│       └── get_example_usecase.dart
└── presentation/
    ├── bindings/
    │   └── example_binding.dart
    ├── controllers/
    │   └── example_controller.dart
    └── pages/
        └── example_screen.dart
```

### Steps:

1. Create folder structure
2. Create Entity (domain/entities)
3. Create DTO (data/models)
4. Create DataSource interface + impl
5. Create Repository interface + impl
6. Create UseCases
7. Create Controller (GetX)
8. Create Screen
9. Create Binding
10. Add route to `app_routes.dart` & `app_pages.dart`

---

## 📱 Screens

### Auth Screen
- Google & Facebook login buttons
- Beautiful gradient background

### Home Screen
- User profile card
- Quick action grid
- Pet status preview
- Bottom navigation

### Profile Screen
- Avatar display
- User info (email, phone, coins)
- Edit profile

### Couple Screen
- Create/Join couple room
- Display couple info
- Copy invite code

### Pet Screen
- Pet avatar
- Level & stats
- Feed button
- Progress bars

### Memory Screen
- Grid view of memories
- Upload from gallery/camera
- Full screen preview

### Payment Screen
- Coin packages
- Bonus badges
- WebView integration

---

## 🔄 State Management

Using **GetX**:

```dart
class ExampleController extends GetxController {
  final _isLoading = false.obs;
  final _data = <Item>[].obs;
  
  bool get isLoading => _isLoading.value;
  List<Item> get data => _data;
  
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }
  
  Future<void> fetchData() async {
    _isLoading.value = true;
    // API call
    _isLoading.value = false;
  }
}
```

---

## 🎨 UI/UX Features

- Material Design 3
- Pink/Purple theme
- Smooth animations
- Pull-to-refresh
- Loading states
- Error handling with snackbars
- Empty states
- Responsive design

---

## 📝 Next Steps

### Suggested Enhancements

1. **Refresh Token Flow**
   - Implement token refresh
   - Store refresh token securely

2. **Offline Support**
   - Cache data with GetStorage
   - Sync when online

3. **Push Notifications**
   - OneSignal integration
   - Real-time updates

4. **Pet Animations**
   - Flame engine integration
   - Interactive pet

5. **Social Features**
   - Friend list
   - Chat system

6. **Analytics**
   - Firebase Analytics
   - User behavior tracking

---

## 🐛 Debugging

### Check API Logs

All requests/responses are logged via `CustomLogInterceptor`.

### Check Token

```dart
final storage = GetStorage();
final token = storage.read('access_token');
print('Token: $token');
```

### Network Issues

If API calls fail:
1. Check `.env` file
2. Verify API_BASE_URL
3. Check internet connection
4. Check server status

---

## 📚 Dependencies

- `get: ^4.6.6` → State management & routing
- `dio: ^5.4.0` → HTTP client
- `flutter_dotenv: ^5.1.0` → Environment config
- `get_storage: ^2.1.1` → Local storage
- `google_sign_in: ^6.2.1` → Google auth
- `flutter_facebook_auth: ^6.0.4` → Facebook auth
- `image_picker: ^1.0.7` → Image selection
- `webview_flutter: ^4.5.0` → WebView for payments
- `cached_network_image: ^3.3.1` → Image caching
- `equatable: ^2.0.5` → Value equality
- `intl: ^0.19.0` → Date formatting

---

## 🎓 Learning Resources

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [GetX Documentation](https://pub.dev/packages/get)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Flutter Best Practices](https://flutter.dev/docs/development/ui/layout/best-practices)

---

## ✅ Production Checklist

Before deploying:

- [ ] Update API_BASE_URL in .env
- [ ] Add proper error messages (Vietnamese)
- [ ] Test all API endpoints
- [ ] Add loading indicators
- [ ] Handle edge cases
- [ ] Test on real devices
- [ ] Configure app icons & splash screen
- [ ] Set up ProGuard rules (Android)
- [ ] Configure Firebase (if needed)
- [ ] Test payment flow end-to-end
- [ ] Add analytics events

---

**Built with ❤️ using Flutter Clean Architecture + GetX**

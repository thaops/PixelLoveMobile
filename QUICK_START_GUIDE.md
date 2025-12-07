# Quick Start Guide - Login & Couple Features

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Environment
Ensure your `.env` file contains:
```env
API_BASE_URL=http://your-backend-url.com
```

### 3. Run the App
```bash
flutter run
```

---

## 🔑 Key Components

### Authentication Controller
**Location:** `lib/features/auth/presentation/controllers/auth_controller.dart`

**Methods:**
- `loginWithGoogle()` - Handle Google Sign-In
- `loginWithFacebook()` - Handle Facebook Sign-In
- `completeProfile(name, dob)` - Submit profile completion
- `logout()` - Sign out user

**Usage:**
```dart
final authController = Get.find<AuthController>();
await authController.loginWithGoogle();
```

### Couple Controller
**Location:** `lib/features/couple/presentation/controllers/couple_controller.dart`

**Methods:**
- `generateCoupleCode()` - Create new couple code
- `joinCoupleByCode(code)` - Join using partner's code
- `copyCoupleCode()` - Copy code to clipboard
- `shareCoupleCode()` - Share code via system share
- `navigateToCoupleSpace()` - Go to couple chat

**Usage:**
```dart
final coupleController = Get.find<CoupleController>();
await coupleController.generateCoupleCode();
```

### Socket Service
**Location:** `lib/core/services/socket_service.dart`

**Methods:**
- `connect(coupleRoomId)` - Connect to couple room
- `disconnect()` - Disconnect socket
- `sendMessage(message, coupleRoomId)` - Send chat message
- `feedPet(coupleRoomId)` - Trigger pet feeding

**Usage:**
```dart
final socketService = Get.find<SocketService>();
socketService.connect(user.coupleRoomId!);
socketService.sendMessage("Hello!", user.coupleRoomId!);
```

### Storage Service
**Location:** `lib/core/services/storage_service.dart`

**Methods:**
- `saveToken(token)` - Store auth token
- `getToken()` - Retrieve auth token
- `saveUser(user)` - Store user data
- `getUser()` - Retrieve user data
- `clearAll()` - Clear all storage
- `isLoggedIn` - Check login status

**Usage:**
```dart
final storageService = Get.find<StorageService>();
final user = storageService.getUser();
```

---

## 🎯 Common Tasks

### Check User Mode
```dart
final storageService = Get.find<StorageService>();
final user = storageService.getUser();

if (user?.mode == 'solo') {
  // Show couple selection
} else if (user?.mode == 'couple') {
  // Navigate to couple space
}
```

### Navigate to Couple Space
```dart
Get.toNamed(AppRoutes.coupleSpace);
```

### Get Current User
```dart
final authController = Get.find<AuthController>();
final user = authController.currentUser;
```

### Listen to Socket Events
```dart
final socketService = Get.find<SocketService>();

// Check connection status
Obx(() => Text(socketService.isConnected ? 'Online' : 'Offline'));

// Get messages
Obx(() {
  final messages = socketService.messages;
  return ListView.builder(
    itemCount: messages.length,
    itemBuilder: (context, index) {
      return Text(messages[index]['message']);
    },
  );
});
```

---

## 🛣️ Routes Reference

```dart
// Authentication
AppRoutes.login              // Login screen
AppRoutes.completeProfile    // Complete profile form

// Home
AppRoutes.home              // Main home screen

// Couple
AppRoutes.coupleSelection   // Choose create/join
AppRoutes.createCouple      // Generate code screen
AppRoutes.coupleCode        // Display generated code
AppRoutes.joinCouple        // Enter partner's code
AppRoutes.coupleSpace       // Couple chat room

// Other
AppRoutes.profile           // User profile
AppRoutes.pet               // Pet screen
AppRoutes.memory            // Memories
AppRoutes.payment           // Buy coins
```

---

## 🐛 Debugging Tips

### Check Token
```dart
final storage = Get.find<GetStorage>();
print('Token: ${storage.read('access_token')}');
```

### Check User Data
```dart
final storageService = Get.find<StorageService>();
final user = storageService.getUser();
print('User: ${user?.toJson()}');
```

### Check Socket Connection
```dart
final socketService = Get.find<SocketService>();
print('Socket connected: ${socketService.isConnected}');
```

### Clear Storage (for testing)
```dart
final storageService = Get.find<StorageService>();
await storageService.clearAll();
```

---

## 📱 Testing Flow

### Test Login Flow
1. Open app → Login screen
2. Tap "Sign in with Google"
3. Complete Google auth
4. If new user → Complete profile screen
5. Fill name and DOB → Submit
6. Should navigate to Home

### Test Couple Creation
1. From Home → Tap "Find Partner"
2. Tap "Create Couple Code"
3. Tap "Generate Code"
4. Code should appear
5. Copy or share code
6. Tap "Continue to Couple Space"
7. Should see chat interface

### Test Couple Join
1. From Home → Tap "Find Partner"
2. Tap "Join Couple"
3. Enter partner's code
4. Tap "Join Couple"
5. Should navigate to Couple Space
6. Socket should connect automatically

### Test Chat
1. In Couple Space
2. Type message in input
3. Tap send button
4. Message should appear in chat
5. Partner should receive message (if connected)

---

## ⚠️ Common Issues

### Issue: Socket not connecting
**Solution:**
- Check API_BASE_URL in .env
- Verify token is valid
- Check backend WebSocket server is running

### Issue: Login not working
**Solution:**
- Verify Google/Facebook credentials
- Check API endpoint is correct
- Check network connection

### Issue: User data not persisting
**Solution:**
- Check GetStorage is initialized in main.dart
- Verify StorageService is in InitialBinding

### Issue: Navigation not working
**Solution:**
- Check all routes are defined in app_routes.dart
- Verify all pages are added to app_pages.dart
- Check bindings are properly configured

---

## 🔧 Customization

### Change Socket Events
Edit `lib/core/services/socket_service.dart`:
```dart
_socket!.on('your-custom-event', (data) {
  // Handle custom event
});
```

### Add New API Endpoints
1. Add method to datasource (e.g., `auth_remote_datasource.dart`)
2. Add method to repository interface
3. Implement in repository implementation
4. Create use case
5. Call from controller

### Modify UI Theme
Edit `lib/main.dart`:
```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yourColor, // Change primary color
  ),
),
```

---

## 📚 Additional Resources

- **GetX Documentation:** https://pub.dev/packages/get
- **Socket.IO Client:** https://pub.dev/packages/socket_io_client
- **Google Sign-In:** https://pub.dev/packages/google_sign_in
- **Share Plus:** https://pub.dev/packages/share_plus

---

## 💡 Tips

1. **Always use Get.find()** to access controllers/services
2. **Wrap reactive widgets with Obx()** for automatic updates
3. **Check user mode** before navigating to couple features
4. **Disconnect socket** when leaving couple space
5. **Handle loading states** for better UX
6. **Show error messages** using Get.snackbar()

---

## 🎉 You're Ready!

The implementation is complete and ready for testing. Follow the testing flow above to verify all features work correctly.

For any issues or questions, refer to the IMPLEMENTATION_SUMMARY.md for detailed information about the architecture and implementation.


# ✅ LOGOUT FEATURE - Complete Implementation

## 🎯 What Was Added

### 1. **Home Screen** - AppBar with Profile Icon
```dart
appBar: AppBar(
  title: const Text('Pixel Love'),
  actions: [
    IconButton(
      icon: const Icon(Icons.account_circle),
      onPressed: () => Get.toNamed(AppRoutes.profile),
      tooltip: 'Profile',
    ),
  ],
),
```

**Result**: User can tap profile icon in AppBar → Navigate to Profile

---

### 2. **Home Screen** - Tappable User Card
```dart
Card(
  child: InkWell(
    onTap: () => Get.toNamed(AppRoutes.profile),
    child: Row([
      // Avatar, Name, Coins
      Icon(Icons.arrow_forward_ios), // ← Visual hint
    ]),
  ),
)
```

**Result**: User can tap their profile card → Navigate to Profile

---

### 3. **Couple Space** - Profile Icon in AppBar
```dart
appBar: AppBar(
  title: const Text('Couple Space'),
  actions: [
    IconButton(
      icon: const Icon(Icons.account_circle),
      onPressed: () => Get.toNamed(AppRoutes.profile),
    ),
    // Connection status badge
  ],
),
```

**Result**: User can access profile from Couple Space too

---

### 4. **Profile Screen** - Logout Button (Already Existed)
```dart
OutlinedButton.icon(
  onPressed: () => _showLogoutDialog(context),
  icon: const Icon(Icons.logout),
  label: const Text('Đăng xuất'),
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.red,
    side: const BorderSide(color: Colors.red),
  ),
)
```

**With Confirmation Dialog**:
```dart
AlertDialog(
  title: const Text('Đăng xuất'),
  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
  actions: [
    TextButton('Hủy'),
    ElevatedButton('Đăng xuất') → authController.logout()
  ],
)
```

---

## 🔄 Logout Flow

```
User Tap Logout Button
  ↓
Confirmation Dialog
  ↓
User Confirms
  ↓
AuthController.logout()
  ↓
1. LogoutUseCase.call()
  ↓
2. Clear token from storage
  ↓
3. Clear user data from storage
  ↓
4. Sign out from Google
  ↓
5. Navigate to Login Screen
  ↓
User logged out ✅
```

---

## 📁 Files Modified

1. ✅ `lib/views/home_screen.dart`
   - Added AppBar with profile icon
   - Made user card tappable
   - Added arrow icon as visual hint

2. ✅ `lib/features/couple/presentation/pages/couple_space_screen.dart`
   - Added profile icon in AppBar
   - Import AppRoutes

3. ℹ️ `lib/features/user/presentation/pages/user_profile_screen.dart`
   - Already has logout button (no changes needed)

---

## 🎨 UI/UX Improvements

### Before:
- ❌ No easy way to access profile from Home
- ❌ No logout button visible
- ❌ User must remember how to find settings

### After:
- ✅ **2 ways** to access profile from Home:
  1. Tap profile icon in AppBar
  2. Tap user info card
- ✅ Clear visual hint (arrow icon on card)
- ✅ Profile icon also in Couple Space
- ✅ Red logout button in Profile screen
- ✅ Confirmation dialog prevents accidental logout

---

## 🧪 Test Scenarios

### Test 1: Logout from Home
```
1. Open app → Home screen
2. Tap profile icon (top right) → Profile opens
3. Scroll down → See "Đăng xuất" button
4. Tap logout → Confirmation dialog
5. Tap "Đăng xuất" → Navigate to Login ✅
```

### Test 2: Logout via User Card
```
1. Open app → Home screen
2. Tap user card (with avatar & name) → Profile opens
3. Tap "Đăng xuất" → Confirm → Logged out ✅
```

### Test 3: Logout from Couple Space
```
1. In Couple Space (chat)
2. Tap profile icon (top right) → Profile opens
3. Tap "Đăng xuất" → Confirm → Logged out ✅
```

### Test 4: Cancel Logout
```
1. Profile screen → Tap "Đăng xuất"
2. Dialog appears
3. Tap "Hủy" → Dialog closes, stay logged in ✅
```

---

## ✅ Features Working

| Feature | Status | Location |
|---------|--------|----------|
| Profile Icon (Home) | ✅ | AppBar top-right |
| Tappable User Card | ✅ | Home screen |
| Profile Icon (Couple) | ✅ | AppBar top-right |
| Logout Button | ✅ | Profile screen |
| Confirmation Dialog | ✅ | Before logout |
| Clear Storage | ✅ | On logout |
| Google Sign Out | ✅ | On logout |
| Navigate to Login | ✅ | After logout |

---

## 🎉 Summary

**3 Entry Points to Profile**:
1. Home AppBar → Profile icon
2. Home User Card → Tap anywhere
3. Couple Space AppBar → Profile icon

**In Profile Screen**:
- User info displayed
- Edit profile option
- **Red Logout Button** at bottom
- Confirmation dialog for safety

**After Logout**:
- All data cleared
- Google session closed
- Back to Login screen

**Perfect UX! User can easily logout from anywhere in the app.** ✨


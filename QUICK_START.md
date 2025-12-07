# 🚀 Quick Start Guide - Pixel Love

## ⚡ 5-Minute Setup

### 1. Create `.env` File

Tạo file `.env` trong thư mục gốc project:

```bash
API_BASE_URL=https://your-api.com/api
ONE_SIGNAL_KEY=XXXX
PAYOS_CLIENT_ID=XXXX
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run App

```bash
flutter run
```

---

## 🎯 Test Features

### Test Login
1. Mở app
2. Nhấn "Đăng nhập với Google" hoặc "Đăng nhập với Facebook"
3. Xác thực → Redirect to Home

### Test Profile
1. Home → Nhấn icon profile (góc trên phải)
2. Xem thông tin user
3. Nhấn Edit → Update name

### Test Couple
1. Home → Quick Actions → "Couple Room"
2. "Create Couple Room" hoặc "Join with Code"
3. Copy invite code để chia sẻ

### Test Pet
1. Home → Quick Actions → "My Pet"
2. Xem pet status (Level, Hunger, Happiness)
3. Nhấn "Feed Pet"

### Test Memory
1. Home → Quick Actions → "Memories"
2. Nhấn FAB (+) icon
3. Chọn "Gallery" hoặc "Take Photo"
4. Upload ảnh

### Test Payment
1. Home → Quick Actions → "Buy Coins"
2. Chọn coin package
3. WebView mở → Test payment flow

---

## 🔧 Configuration

### Google Sign-In (Android)

1. Thêm SHA-1 vào Firebase Console:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

2. Tải `google-services.json` và đặt vào `android/app/`

### Facebook Login

1. Mở `android/app/src/main/res/values/strings.xml`:
```xml
<string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
<string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
```

2. Update `android/app/src/main/AndroidManifest.xml` (đã có template)

---

## 📂 Project Structure

```
lib/
├── core/              # Base classes, network, errors
├── features/          # All features (auth, user, couple, pet, memory, payment)
├── routes/            # Navigation
├── bindings/          # Global DI
├── views/             # Shared views (home)
└── main.dart
```

---

## 🐛 Common Issues

### Issue: API calls fail
**Solution:** Check `.env` file có đúng API_BASE_URL chưa

### Issue: Login không hoạt động
**Solution:** Configure OAuth credentials (Google SHA-1, Facebook App ID)

### Issue: Hot reload không work
**Solution:** Stop app → `flutter clean` → `flutter pub get` → Run again

---

## 📖 Full Documentation

- `README_ARCHITECTURE.md` → Chi tiết kiến trúc
- `MASON_BRICK_GUIDE.md` → Hướng dẫn generate feature mới
- `IMPLEMENTATION_SUMMARY.md` → Tóm tắt implementation

---

## 🎉 You're Ready!

App đã được setup với:
✅ Clean Architecture
✅ 6 modules hoàn chỉnh
✅ 12+ API endpoints
✅ Beautiful UI/UX
✅ Error handling
✅ State management với GetX

**Next:** Test với backend API của bạn! 🚀


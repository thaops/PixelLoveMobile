# ✅ FIXED: Backend requires accessToken (not idToken)

## 🐛 Problem

Backend API `/auth/google` expects `accessToken` but Flutter was sending `idToken`:

**Backend Error**:
```json
{
  "message": [
    "property idToken should not exist",
    "accessToken should not be empty",
    "accessToken must be a string"
  ],
  "error": "Bad Request",
  "statusCode": 400
}
```

---

## ✅ Solution

Changed all references from `idToken` → `accessToken`:

### 1. **AuthController** (Flutter)
```dart
// ❌ BEFORE
final idToken = googleAuth.idToken;
final result = await _loginGoogleUseCase.call(idToken);

// ✅ AFTER
final accessToken = googleAuth.accessToken;
final result = await _loginGoogleUseCase.call(accessToken);
```

### 2. **AuthRemoteDataSource**
```dart
// ❌ BEFORE
data: {'idToken': idToken}

// ✅ AFTER
data: {'accessToken': accessToken}
```

### 3. **Repository & UseCase**
All method signatures updated:
- `loginGoogle(String idToken)` → `loginGoogle(String accessToken)`

---

## 📁 Files Modified

1. ✅ `lib/features/auth/presentation/controllers/auth_controller.dart`
2. ✅ `lib/features/auth/data/datasources/auth_remote_datasource.dart`
3. ✅ `lib/features/auth/domain/repositories/auth_repository.dart`
4. ✅ `lib/features/auth/data/repositories/auth_repository_impl.dart`

---

## 🔍 Why accessToken?

| Token | Purpose | How to verify |
|-------|---------|---------------|
| `accessToken` | Call Google APIs | Send in header: `Authorization: Bearer {token}` |
| `idToken` | Contains user info (JWT) | Verify JWT signature with Google public keys |

**Backend uses**: `https://www.googleapis.com/oauth2/v2/userinfo` with `accessToken`

---

## 🧪 Test Now

```bash
flutter run
```

**Expected Flow**:
1. Tap "Đăng nhập với Google"
2. Select Google account
3. Send `accessToken` to backend
4. Backend calls Google API with token
5. Returns user data + JWT token
6. If `needProfile: true` → CompleteProfile
7. Else → Home/CoupleSpace

---

## 📝 Request Format

**Correct Request**:
```json
POST /api/auth/google
{
  "accessToken": "ya29.a0AfH6SMBx..."
}
```

**Backend Response**:
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "...",
    "email": "...",
    "name": "...",
    ...
  },
  "needProfile": false
}
```

---

## ✅ Status: READY TO TEST

All changes committed. No compile errors. Login should work now! 🎉


# ✅ FIXED: Complete Profile Endpoint

## 🐛 Problem

Frontend was calling `/api/user/profile` but backend expects `/api/auth/update-profile`:

**Error**:
```json
{
  "message": "Cannot POST /api/user/profile",
  "error": "Not Found",
  "statusCode": 404
}
```

**Request Data** (correct):
```json
{
  "name": "yhh",
  "dob": "2000-01-14"
}
```

---

## ✅ Solution

Changed endpoint from `/user/profile` → `/auth/update-profile`:

```dart
// ❌ BEFORE
return await _dioApi.post(
  '/user/profile',
  data: {'name': name, 'dob': dob},
);

// ✅ AFTER
return await _dioApi.post(
  '/auth/update-profile',
  data: {'name': name, 'dob': dob},
);
```

---

## 📁 File Modified

✅ `lib/features/user/data/datasources/user_remote_datasource.dart`

---

## 🔍 Backend Endpoints (Correct)

### Auth Endpoints:
| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| POST | `/api/auth/google` | Login với Google | - |
| POST | `/api/auth/facebook` | Login với Facebook | - |
| POST | `/api/auth/update-profile` | ✅ Complete profile (name, dob) | `UpdateProfileDto` |
| GET | `/api/auth/me` | Get current user | - |

### User Endpoints:
| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| GET | `/api/user/me` | Get user info | - |
| PUT | `/api/user/update` | Update profile (name, avatar, mode) | `UpdateUserDto` |

---

## 📝 Notes

**POST `/api/auth/update-profile`**:
- Dùng sau khi login lần đầu
- Bổ sung `name` và `dob`
- Backend tự tính `zodiac` từ DOB
- Trả về user object với zodiac

**PUT `/api/user/update`**:
- Dùng để cập nhật thông tin khác
- Có thể update: `name`, `avatar`, `mode`
- Khác với `update-profile` (chỉ dùng lần đầu)

---

## 🧪 Test Flow

```
1. Login with Google ✅
2. Backend returns: needProfile = true
3. Navigate to CompleteProfile screen
4. User enters: name = "yhh", dob = "2000-01-14"
5. Tap "Complete Profile"
6. POST /api/auth/update-profile ✅
   {
     "name": "yhh",
     "dob": "2000-01-14"
   }
7. Backend calculates zodiac
8. Returns user with zodiac
9. Navigate to Home/CoupleSpace ✅
```

---

## ✅ Status: FIXED

Complete profile should work now! 🎉


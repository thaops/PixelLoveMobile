# Hướng Dẫn Tạo Sprite Sheet Animation Đúng Chuẩn Flame

## 🟥 VẤN ĐỀ HIỆN TẠI

### Sprite Sheet Của Bạn:
- ❌ Tất cả frame giống nhau → không có animation
- ❌ Frame size quá nhỏ (64x64) → khi scale lên bị blur/pixelation
- ❌ Layout không tối ưu

### Kết Quả:
- Animation đứng yên (vì frame giống nhau)
- Hình bị mờ/blur khi scale
- Hiển thị như "ô vuông pixel"

---

## 🟩 YÊU CẦU SPRITE SHEET ĐÚNG CHUẨN

### 1. Các Frame Phải Khác Nhau
```
✅ ĐÚNG: Frame 1 → Frame 2 → Frame 3 (có thay đổi)
❌ SAI: Frame 1 = Frame 2 = Frame 3 (giống hệt)
```

### 2. Frame Size Tối Ưu
```
✅ Tốt: 128x128, 256x256, 512x512
⚠️ Chấp nhận: 64x64 (nhưng scale phải nguyên số)
❌ Tránh: Frame quá nhỏ (< 64x64)
```

### 3. Layout Grid Đều
```
✅ ĐÚNG:
[Frame 1] [Frame 2] [Frame 3] [Frame 4] [Frame 5]
[Frame 6] [Frame 7] [Frame 8] [Frame 9] [Frame 10]
...

❌ SAI:
Frame size không đều, spacing lộn xộn
```

### 4. JSON Mapping Đúng
```json
{
  "frame_width": 128,
  "frame_height": 128,
  "columns": 5,
  "rows": 3,
  "frames": [
    {"x": 0, "y": 0, "w": 128, "h": 128},
    {"x": 128, "y": 0, "w": 128, "h": 128},
    ...
  ]
}
```

---

## 🟦 CÁCH TẠO SPRITE SHEET ANIMATION

### Option 1: Dùng Tool Online
1. **Aseprite** (paid, best) - https://www.aseprite.org/
2. **Piskel** (free) - https://www.piskelapp.com/
3. **Photoshop/GIMP** với timeline

### Option 2: Tạo Thủ Công
1. Vẽ từng frame khác nhau
2. Export theo grid đều
3. Tạo JSON mapping

### Option 3: Dùng AI/Generator
- Tạo animation từ AI
- Export sprite sheet
- Generate JSON

---

## 🟩 BEST PRACTICES CHO FLAME

### 1. Frame Size
```dart
// Frame 64x64 → Component size nên là bội số
size: Vector2(128, 128)  // 2x scale
size: Vector2(192, 192)  // 3x scale
size: Vector2(256, 256)  // 4x scale

// Tránh:
size: Vector2(200, 200)  // Không phải bội số → blur
```

### 2. Scale Nguyên Số
```dart
// ✅ Tốt: Scale 2x, 3x, 4x
final scale = 2.0;
size = Vector2(frameWidth * scale, frameHeight * scale);

// ❌ Tránh: Scale lẻ (1.5x, 2.3x)
```

### 3. Pixel Perfect Rendering
```dart
// Flame tự động xử lý, nhưng đảm bảo:
// - Frame size đủ lớn
// - Scale nguyên số
// - Không crop frame
```

---

## 🟦 CÁC LOẠI ANIMATION PHỔ BIẾN

### A. Idle Animation (12-24 frames)
- Nhân vật đứng yên nhưng có chuyển động nhẹ
- Ví dụ: thở, lắc lư, chớp mắt

### B. Walk Animation (8-12 frames)
- Đi bộ, chạy
- Loop liên tục

### C. Happy Animation (4-8 frames)
- Nhảy, vui mừng
- Play 1 lần rồi quay về idle

### D. Eat Animation (6-10 frames)
- Ăn, uống
- Play 1 lần

---

## 🟩 HƯỚNG DẪN TẠO SPRITE SHEET CHO PROJECT NÀY

### Bước 1: Vẽ Animation
1. Vẽ 12-24 frame idle animation (khác nhau)
2. Frame size: 128x128 hoặc 256x256
3. Layout: 5 columns x 3-5 rows

### Bước 2: Export Sprite Sheet
1. Export PNG với tất cả frame
2. Đảm bảo spacing đều
3. Background transparent

### Bước 3: Tạo JSON
```json
{
  "image": "assets/images/pixel_pet.png",
  "frame_width": 128,
  "frame_height": 128,
  "columns": 5,
  "rows": 3,
  "default_interval": 0.12,
  "frames": [
    {"x": 0, "y": 0, "w": 128, "h": 128},
    {"x": 128, "y": 0, "w": 128, "h": 128},
    ...
  ],
  "animations": {
    "idle": {
      "frames": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
      "interval": 0.12
    }
  }
}
```

### Bước 4: Update Code
- Code hiện tại đã đúng, chỉ cần sprite sheet mới

---

## 🟩 TÓM TẮT

### Vấn Đề:
- ❌ Sprite sheet có frame giống nhau → không animation
- ❌ Frame quá nhỏ → blur khi scale

### Giải Pháp:
- ✅ Tạo sprite sheet với frame khác nhau
- ✅ Frame size >= 128x128
- ✅ Scale nguyên số (2x, 3x, 4x)
- ✅ JSON mapping đúng

### Code:
- ✅ Code hiện tại đã đúng chuẩn Flame
- ✅ Chỉ cần sprite sheet mới là sẽ chạy

---

## 📝 LƯU Ý

1. **Animation chỉ chạy khi frame khác nhau**
2. **Frame size lớn = chất lượng tốt hơn**
3. **Scale nguyên số = không blur**
4. **JSON phải match với sprite sheet**


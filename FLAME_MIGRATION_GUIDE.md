# Flame 1.34.0 Migration Guide - Pixel Love

## 📋 Tổng quan

Hướng dẫn migrate từ `flutter_sprite` sang **Flame 1.34.0** với syntax mới nhất.

## 🔄 Thay đổi chính trong Flame 1.34.0

### 1. Mixins cho Gesture Handling

**❌ Cũ (deprecated):**
```dart
class MyGame extends FlameGame with HasDraggables, HasTappables
```

**✅ Mới (Flame 1.34.0):**
```dart
class MyGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks
```

**Component level:**
```dart
// ❌ Cũ
class PetComponent extends SpriteComponent with Draggable, Tappable

// ✅ Mới
class PetComponent extends SpriteComponent with DragCallbacks, TapCallbacks
```

### 2. SpriteSheet Loading

**❌ Cũ (deprecated):**
```dart
final spriteSheet = SpriteSheet.fromImage(
  image: await gameRef.images.load('pixel_pet.png'),
  srcSize: Vector2(64, 64),
);
```

**✅ Mới (Flame 1.34.0):**
```dart
final image = await gameRef.images.load('pixel_pet.png');
final spriteSheet = SpriteSheet(
  image: image,
  srcSize: Vector2(64, 64),
);
```

### 3. Load Animation từ JSON

**✅ Cách đúng với JSON:**
```dart
// Load JSON
final jsonString = await rootBundle.loadString('assets/pixel_pet.json');
final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

// Parse frames
final frames = (jsonData['frames'] as List)
    .map((frame) => SpriteAnimationFrameData(
          sourceSize: Vector2(frame['w'], frame['h']),
          srcPosition: Vector2(frame['x'], frame['y']),
        ))
    .toList();

// Tạo animation từ frame data
final animation = SpriteAnimation.fromFrameData(
  image,
  SpriteAnimationData.sequenced(
    amount: frames.length,
    stepTime: 0.12,
    textureSize: Vector2(64, 64),
  ),
);
```

### 4. Effect với EffectController

**❌ Thiếu controller tổng:**
```dart
add(
  SequenceEffect([
    ScaleEffect.to(Vector2(1.1, 1.1), EffectController(duration: 0.2)),
    ScaleEffect.to(Vector2(1.0, 1.0), EffectController(duration: 0.2)),
  ]),
);
```

**✅ Đúng - có EffectController tổng:**
```dart
add(
  SequenceEffect(
    [
      ScaleEffect.to(Vector2(1.1, 1.1), EffectController(duration: 0.2)),
      ScaleEffect.to(Vector2(1.0, 1.0), EffectController(duration: 0.2)),
    ],
    EffectController(), // Controller tổng cho sequence
  ),
);
```

### 5. Drag/Tap Event Handlers

**❌ Cũ:**
```dart
@override
bool onDragUpdate(DragUpdateInfo info) {
  position += info.delta.global;
  return true;
}
```

**✅ Mới:**
```dart
@override
bool onDragUpdate(DragUpdateEvent event) {
  position += event.delta;
  return true;
}

@override
bool onDragStart(DragStartEvent event) {
  return true;
}

@override
bool onDragEnd(DragEndEvent event) {
  return true;
}

@override
bool onTapDown(TapDownEvent event) {
  // Handle tap
  return true;
}
```

## 📦 Dependencies

Thêm vào `pubspec.yaml`:

```yaml
dependencies:
  flame: ^1.34.0
```

## 🎯 Migration Steps

### Step 1: Update pubspec.yaml
```yaml
dependencies:
  flame: ^1.34.0
  # Có thể giữ cached_network_image cho background network
  cached_network_image: ^3.3.1
```

### Step 2: Tạo Game Class
```dart
class PixelLoveGame extends FlameGame
    with HasCollisionDetection, TapCallbacks, DragCallbacks {
  // ...
}
```

### Step 3: Convert Pet Component
- Load sprite từ JSON với `SpriteAnimation.fromFrameData`
- Dùng `DragCallbacks` thay vì `Draggable`
- Dùng `TapCallbacks` thay vì `Tappable`

### Step 4: Convert Background
- Dùng `SpriteComponent` cho background
- Nếu cần network image, có thể overlay Flutter widget

### Step 5: Convert Items
- Mỗi item là một `Component` riêng
- Dùng `Effect` với `EffectController` đúng cách
- Mixin `TapCallbacks` nếu cần click

## ✅ Checklist Migration

- [ ] Update `pubspec.yaml` với Flame 1.34.0
- [ ] Đổi mixins: `HasDraggables` → `DragCallbacks`
- [ ] Đổi mixins: `HasTappables` → `TapCallbacks`
- [ ] Update `SpriteSheet.fromImage` → `SpriteSheet(image: ...)`
- [ ] Load animation từ JSON đúng cách
- [ ] Thêm `EffectController` tổng cho `SequenceEffect`
- [ ] Update event handlers: `DragUpdateInfo` → `DragUpdateEvent`
- [ ] Test drag/tap functionality
- [ ] Test animation smoothness
- [ ] Verify 60 FPS performance

## 🚀 Performance Benefits

- **60 FPS game loop** thay vì Flutter widget rebuild
- **Direct canvas rendering** không qua widget tree
- **Component system** tối ưu cho animation
- **Effect system** mượt mà cho item animation

## 📚 Resources

- [Flame Documentation](https://docs.flame-engine.org/)
- [Flame 1.34.0 Changelog](https://pub.dev/packages/flame/changelog)
- Example code: `lib/flame_migration_example.dart`


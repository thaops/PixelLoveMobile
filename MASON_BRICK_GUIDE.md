# Mason Brick Template Guide

## 🧱 How to Use Mason Bricks for New Features

This guide shows you how to create reusable Mason bricks to generate new features following Clean Architecture pattern.

---

## 📦 Setup Mason CLI

### 1. Install Mason

```bash
dart pub global activate mason_cli
```

### 2. Initialize Mason in Project

```bash
mason init
```

This creates `mason.yaml` in your project root.

---

## 🏗️ Create Feature Brick

### 1. Create Brick Template

```bash
mason new feature_simple
```

This creates:
```
bricks/
└── feature_simple/
    ├── brick.yaml
    └── __brick__/
```

### 2. Configure `brick.yaml`

```yaml
name: feature_simple
description: Generate Clean Architecture feature module
version: 1.0.0

vars:
  - feature_name:
      type: string
      description: Feature name (e.g., notification)
      prompt: What is the feature name?
  - entity_name:
      type: string
      description: Entity name (e.g., Notification)
      prompt: What is the entity name?
```

---

## 📂 Brick Template Structure

Create the following structure in `__brick__/`:

```
__brick__/
└── lib/
    └── features/
        └── {{feature_name}}/
            ├── data/
            │   ├── datasources/
            │   │   └── {{feature_name}}_remote_datasource.dart
            │   ├── models/
            │   │   └── {{entity_name.snakeCase()}}_dto.dart
            │   └── repositories/
            │       └── {{feature_name}}_repository_impl.dart
            ├── domain/
            │   ├── entities/
            │   │   └── {{entity_name.snakeCase()}}.dart
            │   ├── repositories/
            │   │   └── {{feature_name}}_repository.dart
            │   └── usecases/
            │       └── get_{{entity_name.snakeCase()}}_usecase.dart
            └── presentation/
                ├── bindings/
                │   └── {{feature_name}}_binding.dart
                ├── controllers/
                │   └── {{feature_name}}_controller.dart
                └── pages/
                    └── {{feature_name}}_screen.dart
```

---

## 📝 Template Files

### 1. Entity Template

**File:** `domain/entities/{{entity_name.snakeCase()}}.dart`

```dart
import 'package:equatable/equatable.dart';

class {{entity_name.pascalCase()}} extends Equatable {
  final String id;
  final String name;

  const {{entity_name.pascalCase()}}({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}
```

### 2. DTO Template

**File:** `data/models/{{entity_name.snakeCase()}}_dto.dart`

```dart
import 'package:pixel_love/features/{{feature_name}}/domain/entities/{{entity_name.snakeCase()}}.dart';

class {{entity_name.pascalCase()}}Dto {
  final String id;
  final String name;

  {{entity_name.pascalCase()}}Dto({
    required this.id,
    required this.name,
  });

  factory {{entity_name.pascalCase()}}Dto.fromJson(Map<String, dynamic> json) {
    return {{entity_name.pascalCase()}}Dto(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  {{entity_name.pascalCase()}} toEntity() {
    return {{entity_name.pascalCase()}}(
      id: id,
      name: name,
    );
  }
}
```

### 3. DataSource Template

**File:** `data/datasources/{{feature_name}}_remote_datasource.dart`

```dart
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/{{feature_name}}/data/models/{{entity_name.snakeCase()}}_dto.dart';

abstract class {{entity_name.pascalCase()}}RemoteDataSource {
  Future<ApiResult<List<{{entity_name.pascalCase()}}Dto>>> getAll();
  Future<ApiResult<{{entity_name.pascalCase()}}Dto>> getById(String id);
}

class {{entity_name.pascalCase()}}RemoteDataSourceImpl implements {{entity_name.pascalCase()}}RemoteDataSource {
  final DioApi _dioApi;

  {{entity_name.pascalCase()}}RemoteDataSourceImpl(this._dioApi);

  @override
  Future<ApiResult<List<{{entity_name.pascalCase()}}Dto>>> getAll() async {
    return await _dioApi.get(
      '/{{feature_name}}/list',
      fromJson: (json) {
        final data = json['data'] ?? json;
        if (data is List) {
          return data.map((item) => {{entity_name.pascalCase()}}Dto.fromJson(item)).toList();
        }
        return <{{entity_name.pascalCase()}}Dto>[];
      },
    );
  }

  @override
  Future<ApiResult<{{entity_name.pascalCase()}}Dto>> getById(String id) async {
    return await _dioApi.get(
      '/{{feature_name}}/$id',
      fromJson: (json) => {{entity_name.pascalCase()}}Dto.fromJson(json['data'] ?? json),
    );
  }
}
```

### 4. Repository Interface Template

**File:** `domain/repositories/{{feature_name}}_repository.dart`

```dart
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/entities/{{entity_name.snakeCase()}}.dart';

abstract class {{entity_name.pascalCase()}}Repository {
  Future<ApiResult<List<{{entity_name.pascalCase()}}>>> getAll();
  Future<ApiResult<{{entity_name.pascalCase()}}>> getById(String id);
}
```

### 5. Repository Implementation Template

**File:** `data/repositories/{{feature_name}}_repository_impl.dart`

```dart
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/{{feature_name}}/data/datasources/{{feature_name}}_remote_datasource.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/entities/{{entity_name.snakeCase()}}.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/repositories/{{feature_name}}_repository.dart';

class {{entity_name.pascalCase()}}RepositoryImpl implements {{entity_name.pascalCase()}}Repository {
  final {{entity_name.pascalCase()}}RemoteDataSource _remoteDataSource;

  {{entity_name.pascalCase()}}RepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<{{entity_name.pascalCase()}}>>> getAll() async {
    final result = await _remoteDataSource.getAll();

    return result.when(
      success: (dtoList) => ApiResult.success(
        dtoList.map((dto) => dto.toEntity()).toList(),
      ),
      error: (error) => ApiResult.error(error),
    );
  }

  @override
  Future<ApiResult<{{entity_name.pascalCase()}}>> getById(String id) async {
    final result = await _remoteDataSource.getById(id);

    return result.when(
      success: (dto) => ApiResult.success(dto.toEntity()),
      error: (error) => ApiResult.error(error),
    );
  }
}
```

### 6. UseCase Template

**File:** `domain/usecases/get_{{entity_name.snakeCase()}}_usecase.dart`

```dart
import 'package:pixel_love/core/network/api_result.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/entities/{{entity_name.snakeCase()}}.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/repositories/{{feature_name}}_repository.dart';

class Get{{entity_name.pascalCase()}}UseCase {
  final {{entity_name.pascalCase()}}Repository _repository;

  Get{{entity_name.pascalCase()}}UseCase(this._repository);

  Future<ApiResult<List<{{entity_name.pascalCase()}}>>> call() {
    return _repository.getAll();
  }
}
```

### 7. Controller Template

**File:** `presentation/controllers/{{feature_name}}_controller.dart`

```dart
import 'package:get/get.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/entities/{{entity_name.snakeCase()}}.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/usecases/get_{{entity_name.snakeCase()}}_usecase.dart';

class {{entity_name.pascalCase()}}Controller extends GetxController {
  final Get{{entity_name.pascalCase()}}UseCase _get{{entity_name.pascalCase()}}UseCase;

  {{entity_name.pascalCase()}}Controller(this._get{{entity_name.pascalCase()}}UseCase);

  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _items = <{{entity_name.pascalCase()}}>[].obs;

  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  List<{{entity_name.pascalCase()}}> get items => _items;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final result = await _get{{entity_name.pascalCase()}}UseCase.call();

      result.when(
        success: (items) {
          _items.assignAll(items);
        },
        error: (error) {
          _errorMessage.value = error.message;
          Get.snackbar(
            'Error',
            error.message,
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
```

### 8. Screen Template

**File:** `presentation/pages/{{feature_name}}_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pixel_love/features/{{feature_name}}/presentation/controllers/{{feature_name}}_controller.dart';

class {{entity_name.pascalCase()}}Screen extends GetView<{{entity_name.pascalCase()}}Controller> {
  const {{entity_name.pascalCase()}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{entity_name.pascalCase()}}'),
      ),
      body: Obx(() {
        if (controller.isLoading && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.items.isEmpty) {
          return const Center(child: Text('No items found'));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchData,
          child: ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return ListTile(
                title: Text(item.name),
              );
            },
          ),
        );
      }),
    );
  }
}
```

### 9. Binding Template

**File:** `presentation/bindings/{{feature_name}}_binding.dart`

```dart
import 'package:get/get.dart';
import 'package:pixel_love/core/network/dio_api.dart';
import 'package:pixel_love/features/{{feature_name}}/data/datasources/{{feature_name}}_remote_datasource.dart';
import 'package:pixel_love/features/{{feature_name}}/data/repositories/{{feature_name}}_repository_impl.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/repositories/{{feature_name}}_repository.dart';
import 'package:pixel_love/features/{{feature_name}}/domain/usecases/get_{{entity_name.snakeCase()}}_usecase.dart';
import 'package:pixel_love/features/{{feature_name}}/presentation/controllers/{{feature_name}}_controller.dart';

class {{entity_name.pascalCase()}}Binding extends Bindings {
  @override
  void dependencies() {
    final dioApi = Get.find<DioApi>();

    Get.lazyPut<{{entity_name.pascalCase()}}RemoteDataSource>(
      () => {{entity_name.pascalCase()}}RemoteDataSourceImpl(dioApi),
    );

    Get.lazyPut<{{entity_name.pascalCase()}}Repository>(
      () => {{entity_name.pascalCase()}}RepositoryImpl(
        Get.find<{{entity_name.pascalCase()}}RemoteDataSource>(),
      ),
    );

    Get.lazyPut(() => Get{{entity_name.pascalCase()}}UseCase(
      Get.find<{{entity_name.pascalCase()}}Repository>(),
    ));

    Get.lazyPut(
      () => {{entity_name.pascalCase()}}Controller(
        Get.find<Get{{entity_name.pascalCase()}}UseCase>(),
      ),
    );
  }
}
```

---

## 🚀 Using the Brick

### 1. Add Brick to `mason.yaml`

```yaml
bricks:
  feature_simple:
    path: bricks/feature_simple
```

### 2. Get Bricks

```bash
mason get
```

### 3. Generate New Feature

```bash
mason make feature_simple
```

**Example input:**
```
What is the feature name? notification
What is the entity name? Notification
```

This generates the complete feature structure!

---

## 📋 Post-Generation Steps

### 1. Add Routes

**In `app_routes.dart`:**
```dart
static const String notification = '/notification';
```

**In `app_pages.dart`:**
```dart
GetPage(
  name: AppRoutes.notification,
  page: () => const NotificationScreen(),
  binding: NotificationBinding(),
),
```

### 2. Update API Endpoints

Edit the generated `_remote_datasource.dart` to match your backend API.

### 3. Customize Entity

Add more fields to the entity as needed.

### 4. Add More UseCases

Create additional use cases (create, update, delete) following the same pattern.

---

## 🎯 Best Practices

1. **Keep entities immutable** → Use `final` fields
2. **Use meaningful names** → `GetUserProfileUseCase` not `FetchUseCase`
3. **One use case per action** → Don't combine multiple operations
4. **DTOs map 1:1 with API** → Entities map to business needs
5. **Controllers handle UI logic only** → Business logic in UseCases

---

## 🔧 Advanced: Multiple Entity Brick

For features with multiple entities (e.g., Order + OrderItem), create:

```yaml
vars:
  - feature_name:
      type: string
  - entities:
      type: array
      prompt: Enter entity names (comma separated)
```

---

## 📦 Alternative: Use Existing Bricks

Instead of creating your own, you can use community bricks:

```bash
mason add feature_brick
mason make feature_brick
```

---

## ✅ Checklist After Generating

- [ ] Update API endpoints
- [ ] Add proper error handling
- [ ] Customize UI components
- [ ] Add loading states
- [ ] Add empty states
- [ ] Test API integration
- [ ] Add to routes
- [ ] Test navigation flow

---

**Happy Coding! 🚀**


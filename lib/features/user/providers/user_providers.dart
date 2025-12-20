import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/user/data/datasources/user_remote_datasource.dart';
import 'package:pixel_love/features/user/data/repositories/user_repository_impl.dart';
import 'package:pixel_love/features/user/domain/repositories/user_repository.dart';
import 'package:pixel_love/features/user/domain/usecases/complete_profile_usecase.dart';
import 'package:pixel_love/features/user/domain/usecases/delete_account_usecase.dart';
import 'package:pixel_love/features/user/domain/usecases/onboard_usecase.dart';
import 'package:pixel_love/features/user/domain/usecases/update_profile_usecase.dart';
import 'package:pixel_love/features/user/presentation/notifiers/onboard_notifier.dart';
import 'package:pixel_love/features/user/presentation/notifiers/settings_notifier.dart';
import 'package:pixel_love/features/user/presentation/notifiers/user_notifier.dart';

// ============================================
// User Feature Providers
// ============================================

/// User Remote DataSource provider
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return UserRemoteDataSourceImpl(dioApi);
});

/// User Repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return UserRepositoryImpl(remoteDataSource, storageService);
});

/// Complete Profile UseCase provider
final completeProfileUseCaseProvider = Provider<CompleteProfileUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return CompleteProfileUseCase(repository);
});

/// Onboard UseCase provider
final onboardUseCaseProvider = Provider<OnboardUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return OnboardUseCase(repository);
});

/// Update Profile UseCase provider
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

/// Delete Account UseCase provider
final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return DeleteAccountUseCase(repository);
});

/// User Notifier provider (Riverpod v3)
final userNotifierProvider = NotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);

/// Onboard Notifier provider (Riverpod v3)
final onboardNotifierProvider = NotifierProvider<OnboardNotifier, OnboardState>(
  OnboardNotifier.new,
);

/// Settings Notifier provider (Riverpod v3)
final settingsNotifierProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);


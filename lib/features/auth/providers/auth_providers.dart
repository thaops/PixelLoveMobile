import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pixel_love/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pixel_love/features/auth/domain/repositories/auth_repository.dart';
import 'package:pixel_love/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:pixel_love/features/auth/domain/usecases/login_google_usecase.dart';
import 'package:pixel_love/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pixel_love/features/auth/notifiers/auth_notifier.dart';
import 'package:pixel_love/features/auth/notifiers/auth_state.dart';

// ============================================
// Auth Feature Providers
// ============================================

/// Khởi tạo GoogleSignIn (v7+ dùng singleton + initialize)
final googleSignInInitProvider = FutureProvider<void>((ref) async {
  await GoogleSignIn.instance.initialize();
});

/// GoogleSignIn singleton
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

/// Auth Remote DataSource provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return AuthRemoteDataSourceImpl(dioApi);
});

/// Auth Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepositoryImpl(remoteDataSource, prefs);
});

/// UseCases providers
final loginGoogleUseCaseProvider = Provider<LoginGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginGoogleUseCase(repository);
});

final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetMeUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

/// Auth Notifier provider (Riverpod v3)
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/startup/notifiers/startup_notifier.dart';

// ============================================
// Startup Feature Providers
// ============================================

/// Startup Notifier provider
final startupNotifierProvider = 
    AsyncNotifierProvider<StartupNotifier, StartupState>(
  () => StartupNotifier(),
);


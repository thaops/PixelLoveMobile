import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/services/rewarded_ad_service.dart';

final rewardedAdServiceProvider = Provider<RewardedAdService>((ref) {
  final service = RewardedAdService();
  ref.onDispose(() => service.dispose());
  return service;
});

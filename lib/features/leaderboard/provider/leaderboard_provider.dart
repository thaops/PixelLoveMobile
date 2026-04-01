import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/leaderboard/data/datasoucres/leaderboard_remote_datasoucre.dart';
import 'package:pixel_love/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:pixel_love/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:pixel_love/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:pixel_love/features/leaderboard/presentation/notifiers/leaderboard_notifier.dart';

final leaderboardDatasoucreProvider = Provider<LeaderboardRemoteDatasoucre>((ref) {
  final dioApi = ref.watch(dioApiProvider);
  return LeaderboardRemoteDatasoucreImpl(dioApi);
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final remoteDatasoucre = ref.watch(leaderboardDatasoucreProvider);
  return LeaderboardRepositoryImpl(remoteDatasoucre);
});

final getLeaderboardUsecaseProvider = Provider<GetLeaderboardUsecase>((ref) {
  final repository = ref.watch(leaderboardRepositoryProvider);
  return GetLeaderboardUsecase(repository);
});

final leaderboardProvider = NotifierProvider<LeaderboardNotifier, LeaderboardState>(
  LeaderboardNotifier.new,
);
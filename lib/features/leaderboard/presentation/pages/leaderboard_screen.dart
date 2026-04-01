import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/leaderboard/presentation/notifiers/leaderboard_notifier.dart';
import 'package:pixel_love/features/leaderboard/provider/leaderboard_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/core/theme/app_colors.dart';
import 'package:pixel_love/core/widgets/app_back_icon.dart';
import 'package:pixel_love/features/leaderboard/domain/entities/leaderboard.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(leaderboardProvider.notifier).getLeaderboard(),
    );
  }

  int _calculateScore(LeaderboardUser user) {
    return user.lpScore;
  }

  void _showCoupleDetails(LeaderboardUser user) {
    ref.read(leaderboardProvider.notifier).getCoupleDetail(user.coupleId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final detailState = ref.watch(leaderboardProvider);
          final detail = detailState.currentCoupleDetail;
          final isDetailLoading = detailState.isDetailLoading;

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CachedNetworkImage(
                        imageUrl: user.backgroundUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.pink[50]),
                        errorWidget: (context, url, error) =>
                            Container(color: Colors.pink[50]),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black26,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _buildAvatars(user.members, size: 100),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Text(
                    user.members.map((m) => m.name).join(' & '),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (detail != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        detail.bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  if (isDetailLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: AppColors.primaryPink),
                      ),
                    )
                  else if (detail != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              Icons.local_fire_department,
                              'Streak',
                              '${detail.stats.streak}',
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              Icons.favorite,
                              'Ngày yêu',
                              '${detail.stats.loveDays}',
                              Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              Icons.pets,
                              'Pet Lv.',
                              '${detail.stats.petLevel}',
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              Icons.auto_awesome,
                              'Hearts',
                              '${detail.stats.totalHearts}',
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Khoảnh khắc yêu thương',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    _buildGallery(detail.gallery),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(leaderboardProvider.notifier).sendHeart(user.coupleId);
                      },
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      label: const Text(
                        'Thả tim cổ vũ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: isFullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const AppBackIcon(),
              ),
            ),
            const Text(
              'Bảng xếp hạng #',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(LeaderboardState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryPink),
      );
    }

    final leaderboard = state.leaderboard;
    if (leaderboard == null || leaderboard.items.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bảng xếp hạng',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final items = List<LeaderboardUser>.from(leaderboard.items);
    items.sort((a, b) => _calculateScore(b).compareTo(_calculateScore(a)));

    final top3 = items.take(3).toList();
    final others = items.skip(3).toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            _buildPodium(top3),
            const SizedBox(height: 30),
            ...List.generate(others.length, (index) {
              return _buildRankItem(others[index], index + 4);
            }),
          ],
        ),
        _buildStickyUserRank(leaderboard),
      ],
    );
  }

  Widget _buildPodium(List<LeaderboardUser> top3) {
    if (top3.isEmpty) return const SizedBox();

    return Container(
      height: 350,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (top3.length >= 2) _buildPodiumItem(top3[1], 2, 140, const Color(0xFFFFD1E1)),
          const SizedBox(width: 8),
          _buildPodiumItem(top3[0], 1, 180, const Color(0xFFFFB2D1)),
          const SizedBox(width: 8),
          if (top3.length >= 3) _buildPodiumItem(top3[2], 3, 110, const Color(0xFFFFE5F1)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardUser user,
    int rank,
    double height,
    Color color,
  ) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 600 + (rank * 200)),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: () => _showCoupleDetails(user),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildAvatarWithBadge(user.members, rank),
              const SizedBox(height: 8),
              Text(
                user.members.map((m) => m.name).join(' & '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              _buildPointsBadge(_getFormattedValue(user)),
              const SizedBox(height: 12),
              Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    '$rank',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithBadge(List<Members> members, int rank) {
    double size = rank == 1 ? 80 : 65;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildAvatars(members, size: size),
        Positioned(top: -10, right: -5, child: _getRankBadge(rank)),
      ],
    );
  }

  Widget _getRankBadge(int rank) {
    IconData icon;
    Color color;
    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.orange;
        break;
      case 2:
        icon = Icons.workspace_premium;
        color = Colors.grey;
        break;
      default:
        icon = Icons.military_tech;
        color = Colors.brown;
    }
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildPointsBadge(String points) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB74D),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        points,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRankItem(LeaderboardUser user, int rank) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showCoupleDetails(user),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildAvatars(user.members, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.members.map((m) => m.name).join(' & '),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${user.loveDays} ngày yêu',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildMetricIcon(),
                  const SizedBox(width: 4),
                  Text(
                    _getMetricValue(user),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    rank % 2 == 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: rank % 2 == 0 ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedValue(LeaderboardUser user) {
    return '${user.lpScore} LP';
  }

  Widget _buildMetricIcon() {
    return const Icon(Icons.bolt, size: 18, color: Colors.yellowAccent);
  }

  String _getMetricValue(LeaderboardUser user) {
    return '${user.lpScore}';
  }

  Widget _buildGallery(List<String> images) {
    if (images.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text(
          'Chưa có ảnh kỷ niệm nào',
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          double rotation = (index % 2 == 0) ? 0.05 : -0.05;
          final image = images[index];
          return Transform.rotate(
            angle: rotation,
            child: GestureDetector(
              onTap: () => _showFullScreenImage(image),
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullScreenImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Material(
        color: Colors.black.withValues(alpha: 0.9),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Hero(
              tag: url,
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatars(List<Members> members, {double size = 50}) {
    if (members.isEmpty) return CircleAvatar(radius: size / 2);
    if (members.length == 1) return _buildSingleAvatar(members[0].avatarUrl, size);

    return SizedBox(
      width: size * 1.4,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _buildSingleAvatar(members[0].avatarUrl, size),
          ),
          Positioned(
            right: 0,
            child: _buildSingleAvatar(members[1].avatarUrl, size),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleAvatar(String? url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: (url != null && url.isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: url,
                placeholder: (context, url) => Container(color: AppColors.primaryPinkLight),
                errorWidget: (context, url, error) => const Icon(Icons.person, size: 20),
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColors.primaryPinkLight,
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildStickyUserRank(Leaderboard leaderboard) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryPink,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '#${leaderboard.myRank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            // Placeholder for your couple avatars
            _buildAvatars([
              Members(userId: 'u1', name: 'Bạn', avatarUrl: ''),
              Members(userId: 'u2', name: 'Partner', avatarUrl: ''),
            ], size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Thứ hạng của bạn',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    leaderboard.myRank == 1 ? 'Bạn đang ở Top 1! Xuất sắc 🏆' : 'Cố gắng lên nào! 💪',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${leaderboard.myStreak}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

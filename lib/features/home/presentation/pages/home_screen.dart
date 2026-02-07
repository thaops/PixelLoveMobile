import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/core/providers/core_providers.dart';
import 'package:pixel_love/features/home/presentation/controllers/home_controller.dart';
import 'package:pixel_love/features/home/presentation/widgets/home_bottom_action_bar.dart';
import 'package:pixel_love/features/home/presentation/widgets/home_error_view.dart';
import 'package:pixel_love/features/home/presentation/widgets/home_interactive_map.dart';
import 'package:pixel_love/features/home/presentation/widgets/home_loading_indicator.dart';
import 'package:pixel_love/features/home/presentation/widgets/home_profile_button.dart';
import 'package:pixel_love/features/home/providers/home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final _transformationController = TransformationController();
  late HomeController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      ref: ref,
      transformationController: _transformationController,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeState = ref.watch(homeNotifierProvider);
    final user = ref.read(storageServiceProvider).getUser();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: _buildBody(homeState, user?.avatar),
      ),
    );
  }

  Widget _buildBody(homeState, String? avatarUrl) {
    final homeData = homeState.homeData;

    if (homeData == null) {
      if (homeState.errorMessage != null) {
        return HomeErrorView(
          errorMessage: homeState.errorMessage!,
          onRetry: _controller.retry,
        );
      }
      return Container(color: Colors.black);
    }

    _schedulePositionInit(homeData);

    return Stack(
      children: [
        HomeInteractiveMap(
          homeData: homeData,
          transformationController: _transformationController,
          showRadioMenu: _controller.showRadioMenu,
          radioRect: _controller.radioRect,
          onCloseRadioMenu: _controller.closeRadioMenu,
          onShowRadioMenu: (rect) {
            _controller.toggleRadioMenu(rect);
          },
        ),
        if (homeState.isUpdating) const HomeLoadingIndicator(),
        HomeProfileButton(avatarUrl: avatarUrl),
        const HomeBottomActionBar(),
      ],
    );
  }

  void _schedulePositionInit(homeData) {
    if (_controller.lastHomeData == homeData) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.initializePosition(homeData, MediaQuery.of(context).size);
      }
    });
  }
}

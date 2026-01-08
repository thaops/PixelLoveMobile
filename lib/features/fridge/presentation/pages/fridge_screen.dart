import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pixel_love/core/utils/image_loader_utils.dart';
import 'package:pixel_love/core/widgets/background_loading_screen.dart';
import 'package:pixel_love/features/fridge/domain/entities/fridge.dart';
import 'package:pixel_love/features/fridge/presentation/notifiers/fridge_notifier.dart';
import 'package:pixel_love/features/fridge/providers/fridge_providers.dart';
import 'package:pixel_love/routes/app_routes.dart';

class FridgeScreen extends ConsumerStatefulWidget {
  const FridgeScreen({super.key});

  @override
  ConsumerState<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends ConsumerState<FridgeScreen> {
  bool _backgroundLoaded = false;
  bool _isPreloading = false;
  String? _lastBackgroundUrl;

  /// Preload và đợi background + frame note render xong
  Future<void> _preloadAndWaitForAssets(Fridge fridgeData) async {
    if (_isPreloading || _backgroundLoaded) return;

    setState(() {
      _isPreloading = true;
    });

    try {
      final List<Future<void>> preloadFutures = [];

      // Preload background
      final bgUrl = fridgeData.background.imageUrl;
      if (bgUrl.isNotEmpty && mounted) {
        final imageProvider = NetworkImage(bgUrl);
        preloadFutures.add(
          ImageLoaderUtils.waitForImageToRender(imageProvider, context)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  // ignore: avoid_print
                  print(
                    '⚠️ Fridge background preload timeout, continue anyway',
                  );
                  return false;
                },
              )
              .then((rendered) {
                if (rendered) {
                  // ignore: avoid_print
                  print('✅ Fridge background image rendered successfully');
                } else {
                  // ignore: avoid_print
                  print(
                    '⚠️ Timeout or error rendering fridge image, proceeding anyway',
                  );
                }
              }),
        );
      }

      // Preload note frame images
      for (final note in fridgeData.notes) {
        if (note.frameImageUrl.isEmpty || !mounted) continue;
        final provider = CachedNetworkImageProvider(note.frameImageUrl);
        preloadFutures.add(
          precacheImage(provider, context).timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              // ignore: avoid_print
              print(
                '⚠️ Fridge note frame preload timeout for ${note.frameImageUrl}',
              );
            },
          ),
        );
      }

      await Future.wait(preloadFutures, eagerError: false);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Fridge assets preload error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPreloading = false;
          _backgroundLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fridgeState = ref.watch(fridgeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: _buildBody(screenSize, fridgeState),
      ),
    );
  }

  Widget _buildBody(Size screenSize, FridgeState fridgeState) {
    final fridgeData = fridgeState.fridgeData;
    final backgroundUrl = fridgeData?.background.imageUrl ?? '';

    // Nếu background thay đổi (ví dụ refresh), reset trạng thái preload
    if (_lastBackgroundUrl != backgroundUrl) {
      _lastBackgroundUrl = backgroundUrl;
      _backgroundLoaded = false;
      _isPreloading = false;
    }

    // Nếu chưa có data tủ lạnh, hiển thị luôn màn hình loading (không đen)
    if (fridgeData == null) {
      return BackgroundLoadingScreen(
        backgroundImageUrl: backgroundUrl,
        title: 'Đang tải tủ lạnh kỷ niệm',
        subtitle: 'Vui lòng đợi...',
        onLoadComplete: () {},
        onLoadError: () {},
      );
    }

    // Preload background + frame note trước khi hiển thị màn hình
    if (!_backgroundLoaded && backgroundUrl.isNotEmpty && !_isPreloading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadAndWaitForAssets(fridgeData);
      });

      return BackgroundLoadingScreen(
        backgroundImageUrl: backgroundUrl,
        title: 'Đang tải tủ lạnh kỷ niệm',
        subtitle: 'Vui lòng đợi...',
        onLoadComplete: () {
          // Không set _backgroundLoaded tại đây,
          // chờ _preloadAndWaitForBackground xử lý
        },
        onLoadError: () {
          if (mounted) {
            setState(() {
              _backgroundLoaded = true;
            });
          }
        },
      );
    }

    // Nếu đang preload, vẫn hiển thị loading screen
    if (_isPreloading) {
      return BackgroundLoadingScreen(
        backgroundImageUrl: backgroundUrl,
        title: 'Đang tải tủ lạnh kỷ niệm',
        subtitle: 'Vui lòng đợi...',
        onLoadComplete: () {
          // Không làm gì, đợi _preloadAndWaitForBackground xong
        },
        onLoadError: () {
          if (mounted) {
            setState(() {
              _backgroundLoaded = true;
            });
          }
        },
      );
    }

    return Stack(
      children: [
        // Background image (full screen)
        _buildBackground(fridgeData.background, screenSize),

        // Notes (sorted by zIndex)
        ..._buildNotes(fridgeData.notes, screenSize),

        // Floating button để tạo note mới
        _buildCreateNoteButton(),
      ],
    );
  }

  Widget _buildBackground(FridgeBackground background, Size screenSize) {
    return Positioned.fill(
      child: Image.network(
        background.imageUrl,
        fit: BoxFit.cover,
        width: screenSize.width,
        height: screenSize.height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(Icons.error_outline, color: Colors.white54, size: 48),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildNotes(List<FridgeNote> notes, Size screenSize) {
    // Sort notes theo zIndex (tăng dần) để render đúng thứ tự
    final sortedNotes = List<FridgeNote>.from(notes)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return sortedNotes.map((note) {
      return _buildNote(note, screenSize);
    }).toList();
  }

  Widget _buildNote(FridgeNote note, Size screenSize) {
    // Tính position theo % của màn hình
    final left = screenSize.width * note.position.x;
    final top = screenSize.height * note.position.y;

    // Kích thước note (vừa phải ~110px width)
    const double noteWidth = 110.0;

    return Positioned(
      left: left - (noteWidth / 2), // Center note tại position
      top: top,
      child: GestureDetector(
        onTap: () => _openNotePreview(note),
        child: Transform.rotate(
          angle: note.rotation, // Rotation đã là radian từ API
          child: _buildNoteContent(note, noteWidth),
        ),
      ),
    );
  }

  Widget _buildNoteContent(FridgeNote note, double width) {
    return SizedBox(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Frame image (background của note)
          CachedNetworkImage(
            imageUrl: note.frameImageUrl,
            width: width,
            fit: BoxFit.contain,
            errorWidget: (context, url, error) {
              return Container(
                width: width,
                height: width * 1.2, // Tỷ lệ ước tính
                decoration: BoxDecoration(
                  color: Colors.pink.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.note, color: Colors.pink),
                ),
              );
            },
            placeholder: (context, url) {
              return Container(
                width: width,
                height: width * 1.2,
                color: Colors.grey.shade300,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),

          // Text content overlay
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Center(
                child: Text(
                  note.content,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openNotePreview(FridgeNote note) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Note phóng to
                CachedNetworkImage(
                  imageUrl: note.frameImageUrl,
                  width: 380,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) {
                    return Container(
                      width: 380,
                      height: 380 * 1.2,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.note, color: Colors.pink, size: 48),
                      ),
                    );
                  },
                  placeholder: (context, url) {
                    return Container(
                      width: 380,
                      height: 380 * 1.2,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),

                // Text overlay
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          note.content,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateNoteButton() {
    return Positioned(
      right: 24,
      bottom: 24,
      child: SafeArea(
        top: false,
        child: Material(
          elevation: 8,
          shape: const CircleBorder(),
          color: Colors.pink,
          shadowColor: Colors.black54,
          child: InkWell(
            onTap: () => context.go(AppRoutes.createNote),
            customBorder: const CircleBorder(),
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pink,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.edit_note, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/widgets/app_back_icon.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore_for_file: use_build_context_synchronously

class CozyRoomScreen extends StatefulWidget {
  const CozyRoomScreen({super.key});

  @override
  State<CozyRoomScreen> createState() => _CozyRoomScreenState();
}

class _CozyRoomScreenState extends State<CozyRoomScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1a1326))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString('assets/web/cozy_room.html');
    _controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1326),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFffb778)),
            ),
          if (Navigator.of(context).canPop())
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const AppBackIcon(size: 54),
              ),
            ),
        ],
      ),
    );
  }
}

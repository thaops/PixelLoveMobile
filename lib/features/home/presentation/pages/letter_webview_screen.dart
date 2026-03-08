import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pixel_love/core/widgets/app_back_icon.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LetterWebviewScreen extends StatefulWidget {
  const LetterWebviewScreen({super.key});

  @override
  State<LetterWebviewScreen> createState() => _LetterWebviewScreenState();
}

class _LetterWebviewScreenState extends State<LetterWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://petal-whispers-heart.vercel.app/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            ),
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

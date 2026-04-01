import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixel_love/features/watch_together/providers/watch_together_providers.dart';

class WtAddVideoBar extends ConsumerStatefulWidget {
  const WtAddVideoBar({super.key});

  @override
  ConsumerState<WtAddVideoBar> createState() => _WtAddVideoBarState();
}

class _WtAddVideoBarState extends ConsumerState<WtAddVideoBar> {
  final _ctrl = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _ctrl.text.trim();
    if (url.isEmpty || _isAdding) return;
    setState(() => _isAdding = true);
    await ref.read(watchTogetherNotifierProvider.notifier).addVideo(url);
    _ctrl.clear();
    if (mounted) setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl,
              decoration: const InputDecoration(
                hintText: 'Thêm link YouTube...',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          _isAdding
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _submit,
                ),
        ],
      ),
    );
  }
}

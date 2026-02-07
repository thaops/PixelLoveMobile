import 'package:flutter/material.dart';
import 'package:pixel_love/core/theme/app_colors.dart';

class NoteSaveButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const NoteSaveButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<NoteSaveButton> createState() => _NoteSaveButtonState();
}

class _NoteSaveButtonState extends State<NoteSaveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.isLoading
              ? null
              : () async {
                  setState(() => _isPressed = true);
                  await Future.delayed(const Duration(milliseconds: 150));
                  if (!mounted) return;
                  setState(() => _isPressed = false);
                  widget.onTap();
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 56,
            margin: EdgeInsets.only(
              top: _isPressed ? 6 : 0,
              bottom: _isPressed ? 0 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              boxShadow: _isPressed
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Container(
                  width: 200,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withRed(180),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: 200,
                  height: 50,
                  margin: EdgeInsets.only(top: _isPressed ? 6 : 0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryPink, Color(0xFFFF8DA1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Dán lên tủ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

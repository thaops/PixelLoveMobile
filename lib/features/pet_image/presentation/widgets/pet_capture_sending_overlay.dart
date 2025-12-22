import 'package:flutter/material.dart';

class PetCaptureSendingOverlay extends StatelessWidget {
  const PetCaptureSendingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}



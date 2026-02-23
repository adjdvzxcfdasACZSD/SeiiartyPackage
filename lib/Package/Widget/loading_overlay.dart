// loading_overlay.dart
import 'package:flutter/material.dart';
import '../Core/app_theme.dart';

class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {Color? color}) {
    if (_overlayEntry != null) return; // already showing

    color ??= AppTheme.mainColor;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // dim background — blocks touches
          ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.3)),
          Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(color: color),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
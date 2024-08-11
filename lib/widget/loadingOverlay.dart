import 'package:flutter/material.dart';

class LoadingOverlay {
  static final _overlayEntry = OverlayEntry(
    builder: (context) => Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );

  static OverlayState? _overlayState;

  static void show(BuildContext context) {
    if (_overlayState == null) {
      _overlayState = Overlay.of(context);
      _overlayState!.insert(_overlayEntry);
    }
  }

  static void hide() {
    _overlayEntry.remove();
    _overlayState = null;
  }
}

import 'package:flutter/material.dart';
import 'package:doctorapp/Module/Payment/payment_debug_screen.dart';

/// Helper class to launch the payment debug screen from anywhere in the app
class PaymentDebugLauncher {
  /// Show a debug button overlay that can be used to access the debug screen
  /// Useful during development to quickly access debugging tools
  static OverlayEntry? _overlayEntry;
  
  /// Show a floating action button that opens the debug screen when pressed
  static void showDebugButton(BuildContext context) {
    if (_overlayEntry != null) {
      return; // Already showing
    }
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        right: 20,
        bottom: 100,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openDebugScreen(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[700],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bug_report, color: Colors.white),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  /// Hide the debug button
  static void hideDebugButton() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  
  /// Open the payment debug screen
  static void _openDebugScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PaymentDebugScreen()),
    );
  }
  
  /// Add a debug button to a specific payment screen
  static Widget addDebugButtonTo(Widget child) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 16,
          bottom: 16,
          child: Builder(
            builder: (context) => FloatingActionButton.small(
              backgroundColor: Colors.red[700],
              onPressed: () => _openDebugScreen(context),
              child: const Icon(Icons.bug_report),
            ),
          ),
        ),
      ],
    );
  }
}

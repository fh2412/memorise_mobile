import 'package:flutter/material.dart';

class SnackBarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(String message, {bool isError = false}) {
    // 1. Get the context from the key
    final context = messengerKey.currentContext;
    if (context == null) return;

    // 2. Access your theme's ColorScheme
    final colorScheme = Theme.of(context).colorScheme;

    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          // Use themed text color
          style: TextStyle(
            color: isError ? colorScheme.onError : colorScheme.onInverseSurface,
          ),
        ),
        // Material 3 often uses 'inverseSurface' for standard snacks
        backgroundColor: isError
            ? colorScheme.error
            : colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16), // Gives it that floating look
      ),
    );
  }
}

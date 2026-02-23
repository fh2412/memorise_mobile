import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/logout_view_model.dart';
import 'package:go_router/go_router.dart'; // Assuming you use go_router based on your main.dart

class LogoutButton extends StatelessWidget {
  final bool isFullWidth;

  const LogoutButton({super.key, this.isFullWidth = true});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<LogoutViewModel>(
      builder: (context, vm, child) {
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton.icon(
            onPressed: vm.isLoading ? null : () => _handleLogout(context, vm),
            icon: vm.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : Icon(Icons.logout, color: colorScheme.error),
            label: Text("Logout", style: TextStyle(color: colorScheme.error)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.error),
            ),
          ),
        );
      },
    );
  }

  void _handleLogout(BuildContext context, LogoutViewModel vm) async {
    await vm.logout();

    if (context.mounted) {
      // Navigate to login and clear the navigation stack
      context.go('/login');
    }
  }
}

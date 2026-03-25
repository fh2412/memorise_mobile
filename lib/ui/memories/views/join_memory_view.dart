import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memorise_mobile/ui/memories/view_models/join_memory_view_model.dart';
import 'package:provider/provider.dart';

class JoinMemoryScreen extends StatefulWidget {
  final String token;
  const JoinMemoryScreen({super.key, required this.token});

  @override
  State<JoinMemoryScreen> createState() => _JoinMemoryScreenState();
}

class _JoinMemoryScreenState extends State<JoinMemoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load the data as soon as the route is hit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JoinMemoryViewModel>().loadInvite(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<JoinMemoryViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHigh,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: vm.isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "You're Invited!",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${vm.inviterName ?? 'A friend'} wants to share the memory \"${vm.memoryName ?? 'Untitled'}\" with you.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => context.go('/'), // Navigate home
                              child: const Text("Not now"),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () async {
                                final success = await vm.acceptInvite(
                                  widget.token,
                                );
                                if (success && context.mounted) {
                                  // Navigate to the specific memory or show success
                                  context.go('/memories');
                                }
                              },
                              child: const Text("Join Memory"),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

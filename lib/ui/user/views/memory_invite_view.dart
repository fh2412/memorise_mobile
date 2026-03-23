import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/user/view_models/memory_invite_view_model.dart';
import 'package:provider/provider.dart';

class MemoryInviteScreen extends StatelessWidget {
  const MemoryInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add to Memory'),
          // Keeps the transition smooth from the main app
          surfaceTintColor: Colors.transparent,
        ),
        body: const TabBarView(
          children: [_InternalAddTab(), _SocialShareTab()],
        ),
        // We use a Column to mimic the structure of a NavigationBar
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1, thickness: 0.5), // Subtle M3 line
            Container(
              // Using surfaceContainer to match the NavigationBar background
              color: colorScheme.surfaceContainer,
              child: SafeArea(
                child: TabBar(
                  // Styling to match the M3 NavigationBar look
                  indicatorColor: colorScheme.primary,
                  indicatorWeight: 3,
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  dividerColor:
                      Colors.transparent, // Remove default bottom line
                  tabs: const [
                    Tab(icon: Icon(Icons.person_add_rounded), text: "Direct"),
                    Tab(icon: Icon(Icons.share_rounded), text: "Social"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InternalAddTab extends StatelessWidget {
  const _InternalAddTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MemoryInviteViewModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Using the official M3 SearchBar
          SearchBar(
            hintText: "Search by username or email",
            leading: const Icon(Icons.search),
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            onChanged: (value) => viewModel.searchUsers(value),
          ),
          const SizedBox(height: 24),
          if (viewModel.isLoading)
            const LinearProgressIndicator() // Cleaner for M3 search
          else
            const Expanded(
              child: Center(child: Text("Start typing to find friends")),
            ),
        ],
      ),
    );
  }
}

class _SocialShareTab extends StatelessWidget {
  const _SocialShareTab();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Using a Container with a tonal background for the icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2,
              size: 48,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Share Memory Access",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text("Generate a unique link or QR code."),
        ],
      ),
    );
  }
}

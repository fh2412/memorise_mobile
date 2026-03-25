import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/user/view_models/memory_invite_view_model.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class MemoryInviteScreen extends StatefulWidget {
  final String memoryId;
  const MemoryInviteScreen({super.key, required this.memoryId});

  @override
  State<MemoryInviteScreen> createState() => _MemoryInviteScreen();
}

class _MemoryInviteScreen extends State<MemoryInviteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // The Secret Sauce: Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        // Tab index 1 is "Social". Trigger the fetch!
        context.read<MemoryInviteViewModel>().fetchInviteToken(widget.memoryId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add to Memory')),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _InternalAddTab(),
          _SocialShareTab(
            token: context.watch<MemoryInviteViewModel>().inviteToken,
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          Container(
            color: colorScheme.surfaceContainer,
            child: SafeArea(
              child: TabBar(
                controller: _tabController,
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.person_add_outlined), text: "Direct"),
                  Tab(icon: Icon(Icons.share_outlined), text: "Social"),
                ],
              ),
            ),
          ),
        ],
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
            //onChanged: (value) => viewModel.searchUsers(value),
          ),
          const SizedBox(height: 24),
          if (viewModel.isTokenLoading)
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
  final String? token;

  static const String baseUrl = 'https://memorise.online/join/';

  const _SocialShareTab({required this.token});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MemoryInviteViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 1. Handling Loading State
    if (viewModel.isTokenLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Generating invite link..."),
          ],
        ),
      );
    }

    // 2. Handling Error/Empty State
    if (token == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off_rounded, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Failed to generate invite.\nTap 'Social' tab again to retry.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // 3. The Main UI State
    final fullInviteUrl = '$baseUrl$token';

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Instruction text
              Text("Scan to join Memory", style: textTheme.titleLarge),
              const SizedBox(height: 32),

              // The QR Code Area
              // To ensure scanability in dark mode, we wrap the QR code in a
              // container with high contrast (usually white or a very light surface).
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // Standard white for maximum scanability
                  borderRadius: BorderRadius.circular(24), // M3 XL radius
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: fullInviteUrl, // The full actionable URL
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                  // Force black foreground for consistent scanning reliability
                  foregroundColor: Colors.black,
                ),
              ),

              const SizedBox(height: 40),

              // Divider with color token
              Divider(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                thickness: 0.5,
              ),

              const SizedBox(height: 16),

              // Instruction text for manual sharing
              Text(
                "Alternatively, share a unique link:",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 12),

              // Material 3 FilledButton.icon, centered
              FilledButton.icon(
                onPressed: () {
                  // Use share_plus to open the native share sheet
                  Share.share(
                    'Hey! Join my shared memory on Memorise using this unique link: $fullInviteUrl',
                    subject: 'Shared Memory Invitation',
                  );
                },
                icon: const Icon(Icons.send_rounded), // Rounded M3 send icon
                label: const Text("Share Invite Link"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

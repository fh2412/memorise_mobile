import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
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
          _InternalAddTab(
            tabController: _tabController,
            memoryId: widget.memoryId,
          ),
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

class _InternalAddTab extends StatefulWidget {
  final TabController tabController;
  final String memoryId;

  const _InternalAddTab({required this.tabController, required this.memoryId});

  @override
  State<_InternalAddTab> createState() => _InternalAddTabState();
}

class _InternalAddTabState extends State<_InternalAddTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryInviteViewModel>().fetchPotentialFriends(
        widget.memoryId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MemoryInviteViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    if (!vm.isLoading && vm.hasNoPotentialFriends) {
      return _NoFriendsEmptyState(tabController: widget.tabController);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchBar(
            hintText: "Search ${vm.filteredFriends.length} friends...",
            leading: const Icon(Icons.search),
            onChanged: (value) => vm.searchUsers(value),
          ),
        ),

        Expanded(
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: vm.filteredFriends.length,
                  itemBuilder: (context, index) {
                    final user = vm.filteredFriends[index];
                    final isSelected = vm.selectedUsers.any(
                      (u) => u.userId == user.userId,
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profilePic != null
                            ? NetworkImage(user.profilePic!)
                            : null,
                        child: user.profilePic == null
                            ? Text(user.name[0])
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Text(user.email),
                      trailing: IconButton(
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                        ),
                        color: isSelected ? Colors.green : colorScheme.primary,
                        onPressed: () => vm.toggleUserSelection(user),
                      ),
                    );
                  },
                ),
        ),

        const Divider(height: 1),

        if (vm.selectedUsers.isNotEmpty)
          _AddedFriendsPreview(users: vm.selectedUsers),

        // Sticky Save Button
        _SaveButton(
          count: vm.selectedUsers.length,
          onPressed: () {
            // Implementation for save
          },
        ),
      ],
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

class _AddedFriendsPreview extends StatelessWidget {
  final List<MemoryMissingFriend> users;

  const _AddedFriendsPreview({required this.users});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 104, // Slightly taller to accommodate labels comfortably
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow, // Subtle tonal background
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar and Name
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: user.profilePic != null
                          ? NetworkImage(user.profilePic!)
                          : null,
                      child: user.profilePic == null
                          ? Text(
                              user.name[0],
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Text(
                        user.name.split(' ')[0],
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // The "X" Remove Badge
                Positioned(
                  right: -2,
                  top: -2,
                  child: GestureDetector(
                    onTap: () => context
                        .read<MemoryInviteViewModel>()
                        .toggleUserSelection(user),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _SaveButton({required this.count, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MemoryInviteViewModel>().isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          // Subtle shadow to show it's "above" the bottom tabs
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false, // Only padding for the bottom if needed
        child: SizedBox(
          width: double.infinity,
          height: 56, // Standard M3 button height
          child: FilledButton(
            onPressed: (count > 0 && !isLoading) ? onPressed : null,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    count == 0
                        ? "Select friends to add"
                        : "Add $count ${count == 1 ? 'Friend' : 'Friends'}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NoFriendsEmptyState extends StatelessWidget {
  final TabController tabController;

  const _NoFriendsEmptyState({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // M3 Container for the icon to give it some weight
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Everyone's already here!",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "All of your Memorise friends are already members of this memory. Want to invite someone new?",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: () {
                // Switch to the Social Share tab (Index 1)
                tabController.animateTo(1);
              },
              icon: const Icon(Icons.qr_code),
              label: const Text("Use Social Invite"),
            ),
          ],
        ),
      ),
    );
  }
}

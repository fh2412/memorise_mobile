import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
import 'package:memorise_mobile/ui/user/view_models/memory_invite_view_model.dart';
import 'package:provider/provider.dart';

class FriendsSelectionStep extends StatefulWidget {
  final String memoryId;

  const FriendsSelectionStep({super.key, required this.memoryId});

  @override
  State<FriendsSelectionStep> createState() => _FriendsSelectionStepState();
}

class _FriendsSelectionStepState extends State<FriendsSelectionStep> {
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
                      trailing: Checkbox(
                        // Use M3 Checkbox for a "selection" feel
                        value: isSelected,
                        onChanged: (_) => vm.toggleUserSelection(user),
                      ),
                    );
                  },
                ),
        ),
        // We removed the _SaveButton because the Stepper handles "Next"
        if (vm.selectedUsers.isNotEmpty)
          _AddedFriendsPreview(users: vm.selectedUsers),
      ],
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

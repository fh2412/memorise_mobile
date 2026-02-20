import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/user_model.dart';
import 'package:memorise_mobile/ui/user/view_models/friend_list_view_model.dart';
import 'package:provider/provider.dart';

class FriendList extends StatefulWidget {
  const FriendList({super.key});

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendListViewModel>().loadAllFriendData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use DefaultTabController here so we don't need a manual TabController
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: "Friends"),
              Tab(text: "Requests"),
            ],
          ),
          const SizedBox(height: 10),
          // TabBarView needs to be inside an Expanded when inside a Column
          Expanded(
            child: Consumer<FriendListViewModel>(
              builder: (context, vm, child) {
                if (vm.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (vm.error != null) return Center(child: Text(vm.error!));

                return TabBarView(
                  children: [
                    _buildFriendList(
                      vm.userFriends,
                      "No friends yet.",
                      isRequest: false,
                    ),
                    _buildFriendList(
                      vm.incomingRequests,
                      "No pending requests.",
                      isRequest: true,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendList(
    List<Friend> friends,
    String emptyMessage, {
    required bool isRequest,
  }) {
    if (friends.isEmpty) return Center(child: Text(emptyMessage));

    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: friend.profilePic.isNotEmpty
                ? NetworkImage(friend.profilePic)
                : null,
            child: friend.profilePic.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(friend.name),
          subtitle: Text(friend.email),
          trailing: isRequest
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () async {
                        final vm = context.read<FriendListViewModel>();
                        final success = await vm.handleRequest(
                          friend.userId,
                          true,
                        );

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "You are now friends with ${friend.name}!",
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () async {
                        final vm = context.read<FriendListViewModel>();
                        final success = await vm.handleRequest(
                          friend.userId,
                          false,
                        );

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Request from ${friend.name} declined.",
                              ),
                              backgroundColor: Colors.black87,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                )
              : PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'view') {
                      // TODO: Navigate to UserProfileScreen
                      print("Navigate to profile of ${friend.userId}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Navigation to profile coming soon!"),
                        ),
                      );
                    } else if (value == 'delete') {
                      final success = await context
                          .read<FriendListViewModel>()
                          .removeFriendship(friend.userId, isRequest: false);

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${friend.name} removed from friends.",
                            ),
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('View Profile'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(
                          Icons.person_remove,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Delete Friend',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

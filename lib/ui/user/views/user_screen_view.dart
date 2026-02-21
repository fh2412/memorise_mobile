import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/user/views/friend_add_row_view.dart';
import 'package:memorise_mobile/ui/user/views/friend_list_view.dart';
import 'package:memorise_mobile/ui/user/views/user_card_view.dart';
import 'package:provider/provider.dart';
import '../view_models/user_screen_view_model.dart';

class UserScreenView extends StatelessWidget {
  const UserScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Page"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => ''),
        ],
      ),
      body: Consumer<UserScreenViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            return Center(
              child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
            );
          }

          final user = vm.user;
          if (user == null) return const Center(child: Text("No user found"));

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const UserCard(),
                const SizedBox(height: 25),
                const FriendAddRow(),
                const SizedBox(height: 25),
                const Expanded(child: FriendList()),
              ],
            ),
          );
        },
      ),
    );
  }
}

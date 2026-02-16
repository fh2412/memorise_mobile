import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/user/views/friend_add_row_view.dart';
import 'package:memorise_mobile/ui/user/views/user_card_view.dart';
import 'package:provider/provider.dart';
import '../view_models/home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memorise"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<HomeViewModel>().logout(),
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
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
              children: [UserCard(), SizedBox(height: 25), FriendAddRow()],
            ),
          );
        },
      ),
    );
  }
}

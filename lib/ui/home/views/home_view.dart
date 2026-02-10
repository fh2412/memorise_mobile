import 'package:flutter/material.dart';
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.profilePic),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  "@${user.username}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 32),
                Text("Bio", style: Theme.of(context).textTheme.titleMedium),
                Text(user.bio),
                const SizedBox(height: 16),
                Text("Location: ${user.country}"),
              ],
            ),
          );
        },
      ),
    );
  }
}

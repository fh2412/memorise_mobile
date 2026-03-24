import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/user/view_models/memory_invite_view_model.dart';
import 'package:provider/provider.dart';

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
  const _SocialShareTab({this.token});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<MemoryInviteViewModel>().isTokenLoading;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else if (token != null) ...[
              const Icon(Icons.vpn_key_outlined, size: 48),
              const SizedBox(height: 16),
              const Text("Your Invite Token:"),
              SelectableText(
                token!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ] else
              const Text("Failed to load token."),
          ],
        ),
      ),
    );
  }
}

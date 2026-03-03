import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';
import 'package:memorise_mobile/ui/core/view/special_create_button_view.dart';
import 'package:memorise_mobile/ui/home/view_models/my_memories_screen_view_model.dart';

class MyMemoriesView extends StatefulWidget {
  const MyMemoriesView({super.key});

  @override
  State<MyMemoriesView> createState() => _MyMemoriesViewState();
}

class _MyMemoriesViewState extends State<MyMemoriesView> {
  late MemoryViewModel _viewModel;

  bool _showOnlyMine = true;
  bool _showShared = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize your repository and viewmodel here or inject them
    // _viewModel = MemoryViewModel(repository: ..., userId: ...);

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  void _refresh() {
    _viewModel.fetchMemories(showMine: _showOnlyMine, showShared: _showShared);
  }

  void _onSearchChanged(String query) {
    // TODO: Implement search logic
  }

  void _handleCreateNew() {
    // TODO: Navigate to creation flow
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF), // Your Surface Color
      body: CustomScrollView(
        slivers: [
          // 1. The Sticky Filter Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterBarDelegate(
              child: Container(
                color: const Color(
                  0xFFF9F9FF,
                ).withValues(alpha: 0.95), // Slight glass effect
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    SearchAnchor(
                      builder: (context, controller) {
                        return SearchBar(
                          controller: _searchController,
                          hintText: "Search your memories...",
                          onChanged: _onSearchChanged,
                          leading: const Icon(Icons.search),
                          elevation: WidgetStateProperty.all(0),
                          backgroundColor: WidgetStateProperty.all(
                            const Color(0xFF305EA0).withValues(alpha: 0.05),
                          ),
                        );
                      },
                      suggestionsBuilder: (context, controller) => [],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text("My Memories"),
                          selected: _showOnlyMine,
                          onSelected: (val) =>
                              setState(() => _showOnlyMine = val),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text("Shared with me"),
                          selected: _showShared,
                          onSelected: (val) =>
                              setState(() => _showShared = val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. The Main Content (Empty State)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_mosaic_outlined,
                    size: 80,
                    color: const Color(0xFF305EA0).withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No memories found",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF305EA0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "It's time to start Memorising! Capture your trips and share them with friends.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Our Animated Special Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnimatedMagicCreateButton(onTap: _handleCreateNew),
      ),
    );
  }
}

/// Helper class to make the filter bar stick to the top
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _FilterBarDelegate({required this.child});

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 130;
  @override
  double get minExtent => 130;

  @override
  bool shouldRebuild(covariant _FilterBarDelegate oldDelegate) => false;
}

class _MemoryCard extends StatelessWidget {
  final Memory memory;
  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Placeholder for Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, color: Colors.blueGrey),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "By ${memory.username} • ${memory.pictureCount} photos",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

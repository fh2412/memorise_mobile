import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/memory_model.dart';
import 'package:memorise_mobile/ui/core/view/special_create_button_view.dart';
import 'package:memorise_mobile/ui/home/view_models/my_memories_screen_view_model.dart';
import 'package:memorise_mobile/ui/home/views/memory_detail_screen_view.dart';
import 'package:provider/provider.dart';

class MyMemoriesView extends StatefulWidget {
  const MyMemoriesView({super.key});

  @override
  State<MyMemoriesView> createState() => _MyMemoriesViewState();
}

class _MyMemoriesViewState extends State<MyMemoriesView> {
  bool _showOnlyMine = true;
  bool _showShared = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to trigger the initial fetch after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  void _refresh() {
    // Use read here because we are calling a function, not rebuilding based on value changes
    context.read<MemoryViewModel>().fetchMemories(
      showMine: _showOnlyMine,
      showShared: _showShared,
    );
  }

  void _onSearchChanged(String query) {
    context.read<MemoryViewModel>().filterBySearch(query);
  }

  void _handleCreateNew() {
    // TODO: Navigate to creation flow
  }

  @override
  Widget build(BuildContext context) {
    // watch() makes this build method run every time notifyListeners() is called in the VM
    final viewModel = context.watch<MemoryViewModel>();
    final memories = viewModel.filteredMemories;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: CustomScrollView(
        slivers: [
          // 1. The Sticky Filter Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterBarDelegate(
              child: Container(
                color: const Color(0xFFF9F9FF).withValues(alpha: 0.95),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    SearchBar(
                      controller: _searchController,
                      hintText: "Search your memories...",
                      onChanged: _onSearchChanged,
                      leading: const Icon(Icons.search),
                      elevation: WidgetStateProperty.all(0),
                      backgroundColor: WidgetStateProperty.all(
                        const Color(0xFF305EA0).withValues(alpha: 0.05),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text("My Memories"),
                          selected: _showOnlyMine,
                          onSelected: (val) {
                            setState(() => _showOnlyMine = val);
                            _refresh(); // Fetch new data based on route
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text("Shared with me"),
                          selected: _showShared,
                          onSelected: (val) {
                            setState(() => _showShared = val);
                            _refresh(); // Fetch new data based on route
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Loading Indicator
          if (viewModel.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          // 3. Error State
          else if (viewModel.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text("Error: ${viewModel.error}")),
            )
          // 4. Memory List
          else if (memories.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // Use the 'sliver' named argument here
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _MemoryCard(memory: memories[index]),
                  childCount: memories.length,
                ),
              ),
            )
          // 5. Empty State
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_mosaic_outlined,
            size: 80,
            color: const Color(0xFF305EA0).withOpacity(0.2),
          ),
          const SizedBox(height: 24),
          const Text(
            "No memories found",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Text(
            "Capture your trips and share them with friends.",
            textAlign: TextAlign.center,
          ),
        ],
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
        side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: memory.titlePic,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.image, color: Colors.blueGrey),
                ),
              ),
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
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MemoryDetailScreen(memoryId: memory.memoryId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

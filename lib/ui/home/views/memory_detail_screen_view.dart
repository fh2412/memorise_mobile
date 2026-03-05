import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/home/view_models/memory_detail_screen_view_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MemoryDetailScreen extends StatefulWidget {
  final int memoryId; // Using int to match your Memory model

  const MemoryDetailScreen({super.key, required this.memoryId});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Use microtask or addPostFrameCallback to trigger the fetch after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryDetailViewModel>().fetchMemoryDetails(
        widget.memoryId.toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the ViewModel for changes
    final vm = context.watch<MemoryDetailViewModel>();

    if (vm.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (vm.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(vm.errorMessage!)),
      );
    }

    final memory = vm.selectedMemory;
    if (memory == null) return const Scaffold();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. COLLAPSING HEADER (Using titlePic)
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                memory.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(memory.titlePic, fit: BoxFit.cover),
                  // Dark overlay to make the title readable
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. PRIMARY ACTIONS (Add Photos & Invite)
                  Row(
                    children: [
                      _buildActionChip(
                        context,
                        icon: Icons.add_a_photo,
                        label: "Add Photos",
                        color: Colors.indigo,
                        onTap: () => print("Add Photos Tapped"),
                      ),
                      const SizedBox(width: 12),
                      _buildActionChip(
                        context,
                        icon: Icons.person_add,
                        label: "Invite",
                        color: Colors.teal,
                        onTap: () => print("Invite Tapped"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 3. DESCRIPTION & INFO
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(memory.memoryDate),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    memory.text,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const Divider(height: 48),

                  // 4. THE FRIENDS LIST
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "With ${memory.username}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Edit Memory"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Placeholder for the friends/users list
                  CircleAvatar(radius: 24, child: Text(memory.username[0])),

                  const SizedBox(height: 32),

                  // 5. MAP SECTION
                  if (memory.latitude != null) ...[
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.map,
                                size: 40,
                                color: Colors.grey,
                              ),
                              Text(
                                "Lat: ${memory.latitude}, Lng: ${memory.longitude}",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

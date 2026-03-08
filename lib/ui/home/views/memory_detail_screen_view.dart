import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/friends_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:memorise_mobile/ui/home/view_models/memory_detail_screen_view_model.dart';

class MemoryDetailScreen extends StatefulWidget {
  final int memoryId;

  const MemoryDetailScreen({super.key, required this.memoryId});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryDetailViewModel>().fetchMemoryDetails(
        widget.memoryId.toString(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Material 3 Theme Access
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            surfaceTintColor: colorScheme.surface,
            // HIER: Die Actions hinzufügen
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Deine Edit-Logik hier
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                memory.title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  decorationColor: colorScheme.surfaceContainer,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [Image.network(memory.titlePic, fit: BoxFit.cover)],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. PRIMARY ACTIONS (Using M3 Tonal Buttons)
                  Row(
                    children: [
                      _buildM3Action(
                        context,
                        icon: Icons.add_a_photo_outlined,
                        label: "Add Photos",
                        onTap: () => print("Add Photos Tapped"),
                      ),
                      const SizedBox(width: 12),
                      _buildM3Action(
                        context,
                        icon: Icons.camera,
                        label: "View Photos",
                        onTap: () => print("Invite Tapped"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 3. DESCRIPTION & INFO
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(memory.memoryDate),
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    memory.text,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),

                  const Divider(height: 64, thickness: 1),

                  // 4. THE ATTENDEES SECTION
                  Text(
                    "Who was there",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logic to check for null or empty list
                  (vm.attendees == null || vm.attendees!.isEmpty)
                      ? _buildEmptyAttendeesState(context)
                      : _buildAttendeesList(context, vm.attendees!),

                  // 5. MAP SECTION (M3 Container style)
                  if (memory.latitude != null) ...[
                    Text(
                      "Location",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        // M3 "Surface Container" color
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          24,
                        ), // M3 uses larger radii
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 40,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Lat: ${memory.latitude}, Lng: ${memory.longitude}",
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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

  Widget _buildM3Action(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Material(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: colorScheme.onSecondaryContainer),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildAttendeesList(
  BuildContext context,
  List<MemoryAttendee> attendees,
) {
  final textTheme = Theme.of(context).textTheme;
  final colorScheme = Theme.of(context).colorScheme;

  return SizedBox(
    height: 90,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      // Wir fügen +1 für den Invite-Button hinzu
      itemCount: attendees.length + 1,
      itemBuilder: (context, index) {
        if (index == attendees.length) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                InkWell(
                  onTap: () => print("Invite Tapped"),
                  borderRadius: BorderRadius.circular(28),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.person_add_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text("Invite", style: textTheme.labelMedium),
              ],
            ),
          );
        }

        final attendee = attendees[index];

        return Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: attendee.profilePic != null
                    ? NetworkImage(attendee.profilePic!)
                    : null,
                child: attendee.profilePic == null
                    ? Text(
                        attendee.initials,
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(attendee.name.split(' ')[0], style: textTheme.labelMedium),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildEmptyAttendeesState(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        style: BorderStyle.solid,
      ),
    ),
    child: Column(
      children: [
        Icon(Icons.group_add_outlined, size: 32, color: colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          "Memories are better together",
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Tag the friends who shared this moment with you.",
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

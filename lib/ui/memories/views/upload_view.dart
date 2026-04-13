import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memorise_mobile/ui/memories/view_models/upload_view_model.dart';

class UploadView extends StatefulWidget {
  final int memoryId;

  const UploadView({super.key, required this.memoryId});

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  @override
  Widget build(BuildContext context) {
    // We use select to only rebuild when the specific properties we need change
    final vm = context.watch<UploadViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Material 3 AppBars are usually transparent/flat by default
      appBar: AppBar(title: const Text("Add Photos")),
      body: Column(
        children: [
          Expanded(
            child: vm.selectedPhotos.isEmpty
                ? _buildEmptyState(vm, colorScheme)
                : _buildPhotoGrid(vm, colorScheme),
          ),
          // Only show actions if photos are selected
          if (vm.selectedPhotos.isNotEmpty)
            _buildBottomActions(vm, colorScheme),
        ],
      ),
    );
  }

  Widget _buildEmptyState(UploadViewModel vm, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: InkWell(
          onTap: vm.pickImages,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              // M3 uses surface variants for containers
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 2,
                style: BorderStyle
                    .solid, // You could also use a custom painter for dashed lines
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "Upload Photos",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tap to select photos from gallery",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(UploadViewModel vm, ColorScheme colorScheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: vm.selectedPhotos.length,
      itemBuilder: (context, index) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(
                        vm.selectedPhotos[index].path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Image.file(
                        File(vm.selectedPhotos[index].path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
              ),
            ),
            // The Remove Button
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: () => vm.removeImage(index),
                child: Material(
                  elevation: 2,
                  shape: const CircleBorder(),
                  color: colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomActions(UploadViewModel vm, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // M3 Outlined Button
          OutlinedButton.icon(
            onPressed: vm.isUploading ? null : vm.pickImages,
            icon: const Icon(Icons.add),
            label: const Text("Add more"),
          ),
          const SizedBox(width: 12),
          // M3 Filled Button (The Primary Action)
          Expanded(
            child: FilledButton(
              onPressed: (vm.isUploading)
                  ? null
                  : () async {
                      try {
                        await vm.executeUpload(widget.memoryId);
                        if (!mounted) return;

                        Navigator.of(context).pop();
                      } catch (_) {
                        // The ViewModel already showed the error
                      }
                    },
              child: vm.isUploading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Upload to Memorise"),
            ),
          ),
        ],
      ),
    );
  }
}

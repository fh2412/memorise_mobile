import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/ui/memories/view_models/upload_view_model.dart';
import 'package:provider/provider.dart';

class PhotoSelection extends StatelessWidget {
  final int memoryId;

  const PhotoSelection({super.key, required this.memoryId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UploadViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Content Area
        vm.selectedPhotos.isEmpty
            ? _buildEmptyState(context, vm, colorScheme)
            : _buildPhotoGrid(vm, colorScheme),

        const SizedBox(height: 16),

        // 2. The "Add More" Button (Internal to the step)
        if (vm.selectedPhotos.isNotEmpty)
          OutlinedButton.icon(
            onPressed: vm.isUploading ? null : vm.pickImages,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text("Add more photos"),
          ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    UploadViewModel vm,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: vm.pickImages,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: .3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant, width: 2),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              "Upload Photos",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              "Tap to select from gallery",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(UploadViewModel vm, ColorScheme colorScheme) {
    return GridView.builder(
      shrinkWrap: true, // Required for Stepper
      physics: const NeverScrollableScrollPhysics(), // Required for Stepper
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: vm.selectedPhotos.length,
      itemBuilder: (context, index) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
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
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: () => vm.removeImage(index),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: colorScheme.error,
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: colorScheme.onError,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

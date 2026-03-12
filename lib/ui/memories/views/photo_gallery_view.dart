import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:memorise_mobile/domain/models/photo_model.dart';
import 'package:memorise_mobile/ui/memories/view_models/photo_gallery_view_model.dart';
import 'package:memorise_mobile/ui/memories/views/full_screen_gallery_view.dart';
import 'package:provider/provider.dart';

class PhotoGalleryView extends StatefulWidget {
  final String imageId; // Parent now only passes this

  const PhotoGalleryView({super.key, required this.imageId});

  @override
  State<PhotoGalleryView> createState() => _PhotoGalleryViewState();
}

class _PhotoGalleryViewState extends State<PhotoGalleryView> {
  late PhotoGalleryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PhotoGalleryViewModel();
    _viewModel.fetchMemoryPhotos(widget.imageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text("Memory Photos"), elevation: 0),
      body: ChangeNotifierProvider<PhotoGalleryViewModel>.value(
        value: _viewModel,
        child: Consumer<PhotoGalleryViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.images.isEmpty) {
              return const Center(child: Text("No photos in this memory yet."));
            }

            return MasonryGridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemCount: vm.images.length,
              itemBuilder: (context, index) {
                final image = vm.images[index];
                return _PhotoTile(
                  image: image,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenGallery(
                          images: vm.images,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final MemoryPhoto image;
  final VoidCallback onTap;

  const _PhotoTile({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger navigation
      child: Hero(
        tag: image.url, // This matches the tag in FullScreenGallery
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: image.url,
                // Use the metadata aspect ratio to avoid layout jumps
                placeholder: (context, url) => AspectRatio(
                  aspectRatio: image.aspectRatio,
                  child: Container(color: Colors.grey[200]),
                ),
                fit: BoxFit.cover,
              ),
              if (image.isStarred)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

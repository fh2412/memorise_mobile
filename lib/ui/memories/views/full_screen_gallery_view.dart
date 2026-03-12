import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memorise_mobile/domain/models/photo_model.dart';

class FullScreenGallery extends StatelessWidget {
  final List<MemoryPhoto> images;
  final int initialIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    // We use a PageController to start at the clicked image
    final PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black, // Typical gallery feel
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final photo = images[index];
          return Hero(
            tag: photo.url, // Must match the tag in the Grid
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              maxScale: 4.0,
              child: CachedNetworkImage(
                imageUrl: photo.url,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

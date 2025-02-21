import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class PictureScreen extends StatefulWidget {
  const PictureScreen({super.key});

  @override
  State<PictureScreen> createState() => _PictureScreenState();
}

class _PictureScreenState extends State<PictureScreen> {
  // Commented out photo_manager-related field:
  // List<AssetEntity> _images = [];

  @override
  void initState() {
    super.initState();
    // _requestPermissionAndLoadImages();
  }

  /// Requests the necessary permission(s) and, if granted, loads all image assets.
  /*
  Future<void> _requestPermissionAndLoadImages() async {
    // For Android 13+, this may request READ_MEDIA_IMAGES automatically.
    final result = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        iosAccessLevel: IosAccessLevel.readWrite,
      ),
    );

    if (result.isAuth) {
      // Permission granted
      await _loadImages();
    } else {
      // Either show a dialog to navigate to settings or display a friendly message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage Permission not granted!')),
      );
    }
  }
  */

  /// Loads image assets and sets them to _images.
  /*
  Future<void> _loadImages() async {
    // Fetch all albums; the "All" type typically includes images and videos.
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image, // Only images
    );

    // Usually, the first album is the "Recent" or "All" album.
    if (albums.isNotEmpty) {
      final AssetPathEntity album = albums.first;
      // Get all images in this album.
      final List<AssetEntity> images = await album.getAssetListPaged(
        page: 0,
        size: 1000, // Adjust size as needed
      );

      setState(() {
        _images = images;
      });
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Picture Screen")),
      // For now, display a placeholder since photo_manager code is commented out.
      body: const Center(child: Text("Photo Manager code commented out")),
      /*
      body: _images.isEmpty
          ? const Center(child: Text("No images found"))
          : GridView.builder(
              padding: const EdgeInsets.all(4.0),
              itemCount: _images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 images per row
                crossAxisSpacing: 4, // spacing between columns
                mainAxisSpacing: 4, // spacing between rows
              ),
              itemBuilder: (context, index) {
                final asset = _images[index];
                return FutureBuilder<Uint8List?>(
                  future: asset.thumbnailDataWithSize(
                    const ThumbnailSize(200, 200),
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      final bytes = snapshot.data;
                      return GestureDetector(
                        onTap: () {
                          // When tapped, open fullscreen preview.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullImagePreview(asset: asset),
                            ),
                          );
                        },
                        child: Image.memory(bytes!, fit: BoxFit.cover),
                      );
                    } else {
                      return Container(color: Colors.grey.shade300);
                    }
                  },
                );
              },
            ),
      */
    );
  }
}

/*
class FullImagePreview extends StatelessWidget {
  final AssetEntity asset;

  const FullImagePreview({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Preview')),
      body: Center(
        child: FutureBuilder<Uint8List?>(
          future: asset.originBytes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final data = snapshot.data;
              if (data == null) {
                return const Text('Failed to load image');
              }
              return Image.memory(data, fit: BoxFit.contain);
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
// Uncomment the following line if you wish to open the captured file automatically
// import 'package:open_file/open_file.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera Awesome")),
      body: CameraAwesomeBuilder.awesome(
        // This configuration allows capturing both photos and videos.
        saveConfig: SaveConfig.photoAndVideo(),
        // When media is captured, this callback is called.
        onMediaTap: (mediaCapture) {
          // For example, print the captured file's path:
          debugPrint("Captured media path: ${mediaCapture.filePath}");
          // If you want to open the file immediately, you can use:
          // OpenFile.open(mediaCapture.filePath);
        },
      ),
    );
  }
}

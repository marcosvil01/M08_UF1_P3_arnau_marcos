import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../gallery.dart'; // Importa la llista global

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  XFile? _imageFile;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _selectedCameraIndex = 0;
      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.medium,
      );
      try {
        await _controller!.initialize();
      } catch (e) {
        print("Error inicialitzant la càmera: $e");
      }
      if (mounted) setState(() {});
    } else {
      print("No s'han trobat càmeres");
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      await _controller!.dispose();
      _controller = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.medium,
      );
      try {
        await _controller!.initialize();
        _isFlashOn = false;
      } catch (e) {
        print("Error canviant la càmera: $e");
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller != null) {
      _isFlashOn = !_isFlashOn;
      try {
        await _controller!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off,
        );
      } catch (e) {
        print("Error activant/desactivant el flash: $e");
      }
      setState(() {});
    }
  }

  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final file = await _controller!.takePicture();
        setState(() {
          _imageFile = file;
          // Afegeix la ruta de la imatge a la llista global.
          capturedImages.add(file.path);
        });
      } catch (e) {
        print("Error al capturar la imatge: $e");
      }
    }
  }

  void _openGallery() {
    if (_imageFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GalleryScreen(imagePath: _imageFile!.path),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.of(context).size;
    var scale = _controller!.value.aspectRatio * size.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    // Detectem si la càmera activa és frontal.
    final isFrontCamera =
        _cameras[_selectedCameraIndex].lensDirection ==
        CameraLensDirection.front;
    // Si és frontal, utilitzem -pi/2 i invertim verticalment; si no, pi/2.
    final rotationAngle = isFrontCamera ? -math.pi / 2 : math.pi / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Aplica una transformació per corregir la rotació i, si és frontal, invertir verticalment.
          Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..rotateZ(rotationAngle)
                  ..scale(1.0, isFrontCamera ? -1.0 : 1.0),
            child: Transform.scale(
              scale: scale,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
              ),
            ),
          ),
          // Botó per activar/desactivar el flash.
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleFlash,
            ),
          ),
          // Miniatura de l'última imatge capturada.
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: _openGallery,
              child:
                  _imageFile != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(_imageFile!.path),
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                      )
                      : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.photo, color: Colors.white),
                      ),
            ),
          ),
          // Botó per capturar la imatge.
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          // Botó per canviar de càmera.
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.switch_camera,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _switchCamera,
            ),
          ),
        ],
      ),
    );
  }
}

// Aquesta classe segueix sent per a la visualització d'una sola imatge en pantalla completa.
class GalleryScreen extends StatelessWidget {
  final String imagePath;
  const GalleryScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeria')),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}

import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Utilitza Transform.rotate per corregir la rotació de la preview.
          Transform.rotate(
            // Ajusta l'angle segons calgui (per exemple, math.pi/2 o -math.pi/2)
            angle: math.pi / 2,
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
          // Botó per activar/desactivar el flash a la part superior dreta.
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
          // Miniatura de la imatge capturada a la part inferior esquerra.
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
          // Botó per capturar la imatge a la part inferior central.
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
          // Botó per canviar de càmera a la part inferior dreta.
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

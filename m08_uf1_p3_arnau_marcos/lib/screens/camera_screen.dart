import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../gallery.dart'; // Importa la llista global

// Pantalla de la càmera
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller; // Controlador de la càmera
  XFile? _imageFile; // Fitxer de la imatge capturada
  List<CameraDescription> _cameras = []; // Llista de càmeres disponibles
  int _selectedCameraIndex = 0; // Índex de la càmera seleccionada
  bool _isFlashOn = false; // Estat del flash

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Inicialitzem la càmera
  }

  // Inicialitza la càmera seleccionada
  Future<void> _initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras(); // Obtenim les càmeres disponibles
    if (_cameras.isNotEmpty) {
      _selectedCameraIndex = 0; // Per defecte, seleccionem la primera càmera
      _controller = CameraController(
        _cameras[_selectedCameraIndex], // Assignem la càmera seleccionada
        ResolutionPreset.medium, // Resulució mitjana
      );
      try {
        await _controller!.initialize(); // Inicialitzem la càmera
      } catch (e) {
        print("Error inicialitzant la càmera: $e"); // Error si no es pot inicialitzar
      }
      if (mounted) setState(() {});
    } else {
      print("No s'han trobat càmeres");
    }
  }

  // Canvia entre càmeres (davant o darrere)
  Future<void> _switchCamera() async {
    if (_cameras.length > 1) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length; // Alterna l'índex de la càmera
      await _controller!.dispose(); // Destrueix el controlador actual
      _controller = CameraController(
        _cameras[_selectedCameraIndex], // Nova càmera seleccionada
        ResolutionPreset.medium, // Resulució mitjana
      );
      try {
        await _controller!.initialize(); // Inicialitza la nova càmera
        _isFlashOn = false; // Desactiva el flash al canviar de càmera
      } catch (e) {
        print("Error canviant la càmera: $e");
      }
      if (mounted) setState(() {});
    }
  }

  // Activa o desactiva el flash
  Future<void> _toggleFlash() async {
    if (_controller != null) {
      _isFlashOn = !_isFlashOn; // Alterna l'estat del flash
      try {
        await _controller!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off, // Activa o desactiva el flash
        );
      } catch (e) {
        print("Error activant/desactivant el flash: $e");
      }
      setState(() {});
    }
  }

  // Captura una imatge i la desa a la llista global
  Future<void> _takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final file = await _controller!.takePicture(); // Captura la imatge
        setState(() {
          _imageFile = file; // Desa el fitxer d'imatge capturat
          // Afegeix la ruta de la imatge a la llista global
          capturedImages.add(file.path);
        });
      } catch (e) {
        print("Error al capturar la imatge: $e");
      }
    }
  }

  // Obre la galeria per veure la imatge capturada
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
    _controller?.dispose(); // Destrueix el controlador de la càmera quan es surt de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()), // Mostra el carregament mentre s'inicia la càmera
      );
    }

    final size = MediaQuery.of(context).size;
    var scale = _controller!.value.aspectRatio * size.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    // Detectem si la càmera activa és frontal
    final isFrontCamera =
        _cameras[_selectedCameraIndex].lensDirection == CameraLensDirection.front;
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
                  child: CameraPreview(_controller!), // Mostra la vista de la càmera
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
                _isFlashOn ? Icons.flash_on : Icons.flash_off, // Icona del flash
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleFlash, // Funció per activar/desactivar el flash
            ),
          ),
          // Miniatura de l'última imatge capturada.
          Positioned(
            bottom: 20,
            left: 20,
            child: GestureDetector(
              onTap: _openGallery, // Obre la galeria en fer clic
              child: _imageFile != null
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
                onTap: _takePicture, // Funció per capturar la imatge
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
                Icons.switch_camera, // Icona per canviar entre càmeres
                color: Colors.white,
                size: 30,
              ),
              onPressed: _switchCamera, // Funció per canviar de càmera
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
      appBar: AppBar(title: const Text('Galeria')), // Títol de la galeria
      body: Center(child: Image.file(File(imagePath))), // Mostra la imatge seleccionada
    );
  }
}

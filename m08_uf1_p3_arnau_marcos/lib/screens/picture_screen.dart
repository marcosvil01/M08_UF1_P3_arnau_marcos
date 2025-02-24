import 'dart:io';
import 'package:flutter/material.dart';
import '../gallery.dart'; // Importa la llista global de rutes d'imatge

class PictureScreen extends StatelessWidget {
  const PictureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeria')),
      body:
          capturedImages.isNotEmpty
              ? GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 imatges per fila
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: capturedImages.length,
                itemBuilder: (context, index) {
                  final imagePath = capturedImages[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  FullScreenImage(imagePath: imagePath),
                        ),
                      );
                    },
                    child: Image.file(File(imagePath), fit: BoxFit.cover),
                  );
                },
              )
              : const Center(
                child: Text(
                  "No hi ha imatges capturades.",
                  style: TextStyle(fontSize: 18),
                ),
              ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}

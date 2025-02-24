import 'dart:io'; // Importa la llibreria per treballar amb fitxers
import 'package:flutter/material.dart'; // Importa els components bàsics de Flutter per crear la UI
import '../gallery.dart'; // Importa la llista global de rutes d'imatges capturades

// Classe que representa la pantalla principal de la galeria d'imatges
class PictureScreen extends StatelessWidget {
  const PictureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Galeria')), // Barra superior amb el títol "Galeria"
      body:
      capturedImages.isNotEmpty // Si hi ha imatges capturades
          ? GridView.builder( // Es crea una vista en graella per mostrar les imatges
        padding: const EdgeInsets.all(8), // Afegim espai al voltant de les imatges
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Mostrem 3 imatges per fila
          crossAxisSpacing: 4, // Espai entre columnes
          mainAxisSpacing: 4, // Espai entre files
        ),
        itemCount: capturedImages.length, // El nombre d'elements a mostrar és la longitud de la llista d'imatges
        itemBuilder: (context, index) { // Com es construeix cada element de la graella
          final imagePath = capturedImages[index]; // Obtenim el camí de l'arxiu de la imatge
          return GestureDetector( // Detecta quan l'usuari toca una imatge
            onTap: () { // Quan es toca la imatge
              Navigator.push( // Navega a la pantalla de la imatge en pantalla completa
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(imagePath: imagePath), // Passa la ruta de la imatge a la nova pantalla
                ),
              );
            },
            child: Image.file(File(imagePath), fit: BoxFit.cover), // Mostra la imatge
          );
        },
      )
          : const Center( // Si no hi ha imatges capturades, mostra un missatge
        child: Text(
          "No hi ha imatges capturades.", // Missatge quan no hi ha imatges
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// Classe que mostra una imatge a pantalla completa
class FullScreenImage extends StatelessWidget {
  final String imagePath; // Ruta de la imatge a mostrar
  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // Barra superior sense títol
      body: Center(child: Image.file(File(imagePath))), // Mostra la imatge en el centre de la pantalla
    );
  }
}

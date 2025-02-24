import 'package:flutter/material.dart';

// Classe BottomNavBar que crea un widget de tipus barra de navegació inferior (BottomNavigationBar)
class BottomNavBar extends StatelessWidget {
  // Índex de l'element seleccionat
  final int selectedIndex;
  // Funció callback que es crida quan es toca un element del menú
  final Function(int) onItemTapped;

  // Constructor de BottomNavBar que requereix l'índex seleccionat i la funció de toc
  const BottomNavBar({
    super.key,
    required this.selectedIndex,  // Requereix l'índex seleccionat
    required this.onItemTapped,   // Requereix la funció callback per gestionar el toc
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,  // Estableix l'índex actual del menú
      onTap: onItemTapped,          // Assigna la funció de toc quan es selecciona un element
      items: const [
        // Elements del menú amb icona i etiqueta
        BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),   // Element de la càmera
        BottomNavigationBarItem(icon: Icon(Icons.image), label: "Picture"),   // Element de les imatges
        BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Music"),// Element de la música
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/camera_screen.dart';
import 'screens/picture_screen.dart';
import 'screens/music_screen.dart';
import 'widgets/bottom_nav.dart';

// Funció principal de l'aplicació, que inicia el widget MyApp
void main() {
  runApp(const MyApp());
}

// Classe principal de l'aplicació, que és un widget sense estat (StatelessWidget)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Crea la interfície d'usuari de l'aplicació
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Awesome App', // Títol de l'aplicació
      debugShowCheckedModeBanner: false, // Desactiva la bandera de mode debug a la interfície
      theme: ThemeData(primarySwatch: Colors.blue), // Defineix el tema de l'aplicació amb un color primari blau
      home: const HomeScreen(), // Defineix la pantalla inicial de l'aplicació
    );
  }
}

// Widget amb estat que representa la pantalla principal (Home)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Estat associat a la pantalla HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Índex de la pestanya seleccionada al menú de navegació inferior

  // Llista de pantalles disponibles a l'aplicació
  final List<Widget> _screens = const [
    CameraScreen(),  // Pantalla de la càmera
    PictureScreen(), // Pantalla de les imatges
    MusicScreen(),   // Pantalla de la música
  ];

  // Actualitza l'índex seleccionat quan es toca un element del menú de navegació
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Canvia a la pantalla corresponent
    });
  }

  // Crea la interfície d'usuari per a la pantalla Home
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Mostra la pantalla segons l'índex seleccionat
      bottomNavigationBar: BottomNavBar( // Crea el menú de navegació inferior
        selectedIndex: _selectedIndex,   // Índex de l'element seleccionat
        onItemTapped: _onItemTapped,     // Defineix la funció per gestionar el toc en els elements del menú
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
        BottomNavigationBarItem(icon: Icon(Icons.image), label: "Picture"),
        BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Music"),
      ],
    );
  }
}

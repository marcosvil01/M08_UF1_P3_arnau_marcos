import 'package:flutter/material.dart'; // Importa els components bàsics de Flutter per crear la UI
import 'package:just_audio/just_audio.dart'; // Llibreria per gestionar la reproducció d'àudio
import 'package:rxdart/rxdart.dart'; // Llibreria per gestionar fluxos reactius (streams)

// Classe per representar una cançó amb el títol i el camí de l'asset
class Song {
  final String title; // Títol de la cançó
  final String assetPath; // Ruta de l'asset de la cançó

  Song({required this.title, required this.assetPath}); // Constructor de la classe Song
}

// Classe per emmagatzemar la informació de la posició i la durada de la cançó
class PositionData {
  final Duration position; // Posició actual de la cançó
  final Duration duration; // Durada total de la cançó
  PositionData(this.position, this.duration); // Constructor de PositionData
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState(); // Crea l'estat per a la pantalla de música
}

class _MusicScreenState extends State<MusicScreen> {
  late AudioPlayer _audioPlayer; // Instància per gestionar la reproducció d'àudio
  int _currentIndex = 0; // Índex de la cançó actual a la llista de reproducció

  // Llista de reproducció amb títols i camins als assets
  final List<Song> _playlist = [
    Song(
      title: 'Hold My Hand - Michael Jackson',
      assetPath: 'assets/audio/song.mp3',
    ),
    Song(
      title: 'Billie Jean - Michael Jackson',
      assetPath: 'assets/audio/song2.mp3',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Inicialitza el reproductor d'àudio
    _loadCurrentSong(); // Carrega la primera cançó de la llista
  }

  // Carrega la cançó actual dels assets
  Future<void> _loadCurrentSong() async {
    try {
      await _audioPlayer.setAsset(_playlist[_currentIndex].assetPath); // Carrega la cançó segons la ruta
    } catch (e) {
      print("Error carregant la cançó: $e"); // Mostra un error si no es pot carregar
    }
  }

  // Alterna entre reproduir i pausar la cançó
  void _togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause(); // Si està reproduint, pausa la cançó
    } else {
      _audioPlayer.play(); // Si no està reproduint, la reprodueix
    }
    setState(() {}); // Actualitza la interfície
  }

  // Reprodueix la cançó següent
  Future<void> _playNextSong() async {
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _playlist.length; // Canvia a la següent cançó
      await _loadCurrentSong(); // Carrega la nova cançó
      _audioPlayer.play(); // Reprodueix la nova cançó
      setState(() {}); // Actualitza la interfície
    }
  }

  // Reprodueix la cançó anterior
  Future<void> _playPreviousSong() async {
    if (_playlist.isNotEmpty) {
      _currentIndex--; // Canvia a la cançó anterior
      if (_currentIndex < 0) {
        _currentIndex = _playlist.length - 1; // Si arribes al principi, va a la última cançó
      }
      await _loadCurrentSong(); // Carrega la nova cançó
      _audioPlayer.play(); // Reprodueix la nova cançó
      setState(() {}); // Actualitza la interfície
    }
  }

  // Combina el positionStream i durationStream per obtenir la posició i la durada de la cançó
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration?, PositionData>(
        _audioPlayer.positionStream, // Posició de la cançó
        _audioPlayer.durationStream, // Durada de la cançó
            (position, duration) =>
            PositionData(position, duration ?? Duration.zero), // Retorna un objecte PositionData
      );

  // Dona format a una durada en format mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0'); // Afegir un zero davant si el número és menor que 10
    final minutes = twoDigits(duration.inMinutes.remainder(60)); // Obtenim els minuts
    final seconds = twoDigits(duration.inSeconds.remainder(60)); // Obtenim els segons
    return '$minutes:$seconds'; // Retorna el format final
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Allibera els recursos quan es tanca la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _playlist[_currentIndex]; // Obtenim la cançó actual

    return Scaffold(
      appBar: AppBar(title: const Text('Music Player')), // Barra superior amb el títol
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostra el títol de la cançó actual
            Text(
              currentSong.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // StreamBuilder per actualitzar el slider i mostrar el temps
            StreamBuilder<PositionData>(
              stream: _positionDataStream, // Subscripció al stream de la posició i durada
              builder: (context, snapshot) {
                final positionData =
                    snapshot.data ?? PositionData(Duration.zero, Duration.zero);
                final position = positionData.position; // Posició actual
                final duration = positionData.duration; // Durada total
                return Column(
                  children: [
                    Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1, // Si la durada és > 0, fem que el slider vagi fins a aquesta durada
                      value: position.inSeconds.toDouble().clamp(
                        0,
                        duration.inSeconds.toDouble(),
                      ), // Mantenim la posició dins dels límits
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt())); // Mou el reproductor a la nova posició
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position)), // Mostra la posició actual
                        Text(_formatDuration(duration)), // Mostra la durada total
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Botons per controlar la reproducció
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_previous), // Botó per la cançó anterior
                  onPressed: _playPreviousSong,
                ),
                IconButton(
                  iconSize: 64,
                  icon: Icon(
                    _audioPlayer.playing
                        ? Icons.pause_circle_filled // Botó de pausa
                        : Icons.play_circle_filled, // Botó de reproduir
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_next), // Botó per la cançó següent
                  onPressed: _playNextSong,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

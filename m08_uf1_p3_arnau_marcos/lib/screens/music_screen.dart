import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

/// Classe per representar una cançó amb títol i camí de l'asset
class Song {
  final String title;
  final String assetPath;

  Song({required this.title, required this.assetPath});
}

/// Classe per emmagatzemar la informació de la posició i la durada
class PositionData {
  final Duration position;
  final Duration duration;
  PositionData(this.position, this.duration);
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late AudioPlayer _audioPlayer;
  int _currentIndex = 0;

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
    _audioPlayer = AudioPlayer();
    _loadCurrentSong();
  }

  /// Carrega la cançó actual dels assets
  Future<void> _loadCurrentSong() async {
    try {
      await _audioPlayer.setAsset(_playlist[_currentIndex].assetPath);
    } catch (e) {
      print("Error carregant la cançó: $e");
    }
  }

  /// Alterna entre reproduir i pausar la cançó
  void _togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    setState(() {});
  }

  /// Reprodueix la cançó següent
  Future<void> _playNextSong() async {
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
      await _loadCurrentSong();
      _audioPlayer.play();
      setState(() {});
    }
  }

  /// Reprodueix la cançó anterior
  Future<void> _playPreviousSong() async {
    if (_playlist.isNotEmpty) {
      _currentIndex--;
      if (_currentIndex < 0) {
        _currentIndex = _playlist.length - 1;
      }
      await _loadCurrentSong();
      _audioPlayer.play();
      setState(() {});
    }
  }

  /// Combina el positionStream i durationStream per obtenir la posició i la durada
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.durationStream,
        (position, duration) =>
            PositionData(position, duration ?? Duration.zero),
      );

  /// Dona format a una durada en format mm:ss
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _playlist[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Music Player')),
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
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData =
                    snapshot.data ?? PositionData(Duration.zero, Duration.zero);
                final position = positionData.position;
                final duration = positionData.duration;
                return Column(
                  children: [
                    Slider(
                      min: 0,
                      max:
                          duration.inSeconds.toDouble() > 0
                              ? duration.inSeconds.toDouble()
                              : 1,
                      value: position.inSeconds.toDouble().clamp(
                        0,
                        duration.inSeconds.toDouble(),
                      ),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position)),
                        Text(_formatDuration(duration)),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Botons per a la reproducció: cançó anterior, play/pause, cançó següent
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_previous),
                  onPressed: _playPreviousSong,
                ),
                IconButton(
                  iconSize: 64,
                  icon: Icon(
                    _audioPlayer.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.skip_next),
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

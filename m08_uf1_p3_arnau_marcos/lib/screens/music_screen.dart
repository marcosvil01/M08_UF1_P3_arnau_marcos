import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  // Query local songs
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // List of songs
  List<SongModel> _songs = [];

  // Current index of the song being played
  int _currentIndex = -1;

  // Streams for real-time UI updates
  late Stream<Duration> _positionStream;
  late Stream<PlayerState> _playerStateStream;

  @override
  void initState() {
    super.initState();

    // Initialize the position & state streams
    _positionStream = _audioPlayer.positionStream;
    _playerStateStream = _audioPlayer.playerStateStream;

    _requestPermissionAndQuerySongs();
  }

  // Request permission and load songs if granted
  Future<void> _requestPermissionAndQuerySongs() async {
    // Request storage permission
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      // Query all songs on the device
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.DISPLAY_NAME,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );

      setState(() {
        _songs = songs;
      });
    } else {
      // Show a message or handle the case when permission is not granted
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage Permission not granted!')),
      );
    }
  }

  // Play or pause the current song
  Future<void> _playOrPauseSong(SongModel song, int index) async {
    if (_currentIndex == index) {
      // If tap again on the current song, just toggle pause/play
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } else {
      // If tapping a new song, set the audio source, then play
      _currentIndex = index;
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
      await _audioPlayer.play();
    }
    setState(() {});
  }

  // Move to previous track
  Future<void> _previousTrack() async {
    if (_songs.isEmpty || _currentIndex <= 0) return;
    _currentIndex--;
    _playSongByIndex(_currentIndex);
  }

  // Move to next track
  Future<void> _nextTrack() async {
    if (_songs.isEmpty || _currentIndex >= _songs.length - 1) return;
    _currentIndex++;
    _playSongByIndex(_currentIndex);
  }

  Future<void> _playSongByIndex(int index) async {
    if (index < 0 || index >= _songs.length) return;
    final song = _songs[index];
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
    await _audioPlayer.play();
    setState(() {});
  }

  // Convert Duration to mm:ss format
  String _formatDuration(Duration? duration) {
    if (duration == null) return "00:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // Build UI: a List of songs + player controls at the bottom
    return Scaffold(
      appBar: AppBar(title: const Text("Music Screen")),
      body: Column(
        children: [
          // Expanded for the list of songs
          Expanded(
            child:
                _songs.isEmpty
                    ? const Center(child: Text('No songs found on device'))
                    : ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        return ListTile(
                          leading: const Icon(Icons.music_note),
                          title: Text(song.title),
                          subtitle: Text(song.artist ?? "Unknown Artist"),
                          onTap: () => _playOrPauseSong(song, index),
                        );
                      },
                    ),
          ),

          // Player controls (only show if we have a song selected)
          if (_currentIndex != -1) _buildPlayerControls(),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    final currentSong = _songs[_currentIndex];

    return Container(
      color: Colors.grey.shade900,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          // Song Title
          Text(
            currentSong.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Artist
          Text(
            currentSong.artist ?? "Unknown Artist",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),

          // Slider + duration
          StreamBuilder<Duration>(
            stream: _positionStream,
            builder: (context, snapshot) {
              final currentPosition = snapshot.data ?? Duration.zero;
              final totalDuration = _audioPlayer.duration ?? Duration.zero;

              return Row(
                children: [
                  Text(
                    _formatDuration(currentPosition),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Expanded(
                    child: Slider(
                      activeColor: Colors.blueAccent,
                      inactiveColor: Colors.white24,
                      value: currentPosition.inSeconds.toDouble(),
                      max: totalDuration.inSeconds.toDouble(),
                      onChanged: (value) {
                        // Seek to specific position in track
                        _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Text(
                    _formatDuration(totalDuration),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              );
            },
          ),

          // Controls Row
          StreamBuilder<PlayerState>(
            stream: _playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final playing = playerState?.playing ?? false;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 36,
                    color: Colors.white,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: _previousTrack,
                  ),
                  IconButton(
                    iconSize: 48,
                    color: Colors.white,
                    icon: Icon(
                      playing ? Icons.pause_circle : Icons.play_circle,
                    ),
                    onPressed: () async {
                      if (playing) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play();
                      }
                      setState(() {});
                    },
                  ),
                  IconButton(
                    iconSize: 36,
                    color: Colors.white,
                    icon: const Icon(Icons.skip_next),
                    onPressed: _nextTrack,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Release resources when the screen is disposed
    _audioPlayer.dispose();
    super.dispose();
  }
}

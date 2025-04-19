import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Audio extends StatefulWidget {
  const Audio({super.key});

  @override
  State<Audio> createState() => _AudioState();
}

class _AudioState extends State<Audio> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final supabase = Supabase.instance.client;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isLoading = false;
  String? errorMessage;

  // Lists to store fetched data
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> audioList = [];
  String? selectedCategoryId;
  String? selectedAudioId;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchAudio();
    _setupAudioPlayer();
  }

  Future<void> _fetchCategories() async {
    try {
      setState(() {
        isLoading = true;
      });
      final response = await supabase
          .from('tbl_audiocat')
          .select('id, audio_name, audio_dis')
          .order('audio_name', ascending: true);
      print('Fetched categories: $response'); // Debug
      setState(() {
        categoryList = response;
        if (categoryList.isNotEmpty) {
          selectedCategoryId = categoryList.first['id'].toString();
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load categories: $e';
      });
    }
  }

  Future<void> _fetchAudio() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      final response = await supabase
          .from('tbl_audio')
          .select('id, audio_file, audio_url, audio_cat, tbl_audiocat(audio_name, audio_dis)')
          .order('audio_dt', ascending: false);
      print('Fetched audio: $response'); // Debug
      setState(() {
        audioList = response;
        selectedAudioId = null; // Reset audio selection
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching audio: $e");
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load audio: $e';
      });
    }
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  List<Map<String, dynamic>> get filteredAudioList {
    if (selectedCategoryId == null) return [];
    return audioList
        .where((audio) => audio['audio_cat'].toString() == selectedCategoryId)
        .toList();
  }

  String get selectedAudioUrl {
    if (selectedAudioId == null || audioList.isEmpty) return '';
    final selectedAudio = audioList.firstWhere(
        (audio) => audio['id'].toString() == selectedAudioId,
        orElse: () => {});
    final url = selectedAudio['audio_url'] ?? '';
    print('Selected audio URL: $url'); // Debug
    return url;
  }

  String get selectedName {
    if (selectedAudioId == null || audioList.isEmpty) return 'Select Audio';
    final selectedAudio = audioList.firstWhere(
        (audio) => audio['id'].toString() == selectedAudioId,
        orElse: () => {});
    return selectedAudio.isNotEmpty
        ? selectedAudio['tbl_audiocat']['audio_name'] ?? 'Unnamed'
        : 'Select Audio';
  }

  String get selectedDescription {
    if (selectedAudioId == null || audioList.isEmpty) return '';
    final selectedAudio = audioList.firstWhere(
        (audio) => audio['id'].toString() == selectedAudioId,
        orElse: () => {});
    return selectedAudio.isNotEmpty
        ? selectedAudio['tbl_audiocat']['audio_dis'] ?? 'No description'
        : '';
  }

  Future<void> _playPauseAudio() async {
    if (selectedAudioId == null || selectedAudioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid audio file'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    try {
      print('Attempting to play: $selectedAudioUrl'); // Debug
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(selectedAudioUrl));
      }
    } catch (e) {
      print("Playback error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _skipForward() async {
    final newPosition = position + const Duration(seconds: 10);
    if (newPosition < duration) {
      await _audioPlayer.seek(newPosition);
    }
  }

  Future<void> _skipBackward() async {
    final newPosition = position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await _audioPlayer.seek(newPosition);
    } else {
      await _audioPlayer.seek(Duration.zero);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        elevation: 0,
        title: const Text(
          'Calm & Comfort',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.purple,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _fetchCategories();
                          _fetchAudio();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : categoryList.isEmpty
                  ? const Center(
                      child: Text(
                        'No categories available.',
                        style: TextStyle(
                          color: Colors.purple,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple[200]!,
                                    Colors.pink[200]!
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.favorite,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              selectedCategoryId == null
                                  ? 'Select Category'
                                  : categoryList.firstWhere((cat) =>
                                          cat['id'].toString() ==
                                          selectedCategoryId)['audio_name'] ??
                                      'Unnamed',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedCategoryId == null
                                  ? ''
                                  : categoryList.firstWhere((cat) =>
                                          cat['id'].toString() ==
                                          selectedCategoryId)['audio_dis'] ??
                                      'No description',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.purple[700],
                              ),
                            ),
                            const SizedBox(height: 20),
                            DropdownButton<String>(
                              value: selectedCategoryId,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCategoryId = newValue;
                                  selectedAudioId = null; // Reset audio selection
                                  if (isPlaying) {
                                    _audioPlayer.stop();
                                    isPlaying = false;
                                  }
                                });
                              },
                              items: categoryList
                                  .map<DropdownMenuItem<String>>((category) {
                                return DropdownMenuItem<String>(
                                  value: category['id'].toString(),
                                  child: Text(category['audio_name']),
                                );
                              }).toList(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.purple,
                              ),
                              dropdownColor: Colors.purple[100],
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.purple),
                              isExpanded: true,
                              hint: const Text('Select Category'),
                            ),
                            const SizedBox(height: 20),
                            DropdownButton<String>(
                              value: selectedAudioId,
                              onChanged: (String? newValue) async {
                                setState(() {
                                  selectedAudioId = newValue;
                                });
                                if (isPlaying && newValue != null) {
                                  await _audioPlayer.stop();
                                  await _audioPlayer
                                      .play(UrlSource(selectedAudioUrl));
                                }
                              },
                              items: filteredAudioList
                                  .map<DropdownMenuItem<String>>((audio) {
                                return DropdownMenuItem<String>(
                                  value: audio['id'].toString(),
                                  child: Text(audio['audio_file']),
                                );
                              }).toList(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.purple,
                              ),
                              dropdownColor: Colors.purple[100],
                              underline: const SizedBox(),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.purple),
                              isExpanded: true,
                              hint: const Text('Select Audio'),
                            ),
                            const SizedBox(height: 30),
                            Slider(
                              activeColor: Colors.pinkAccent,
                              inactiveColor: Colors.purple[200],
                              value: position.inSeconds.toDouble(),
                              min: 0,
                              max: duration.inSeconds.toDouble(),
                              onChanged: (value) async {
                                final newPosition =
                                    Duration(seconds: value.toInt());
                                await _audioPlayer.seek(newPosition);
                              },
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: TextStyle(
                                      color: Colors.purple[700], fontSize: 12),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: TextStyle(
                                      color: Colors.purple[700], fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10,
                                      color: Colors.purple),
                                  iconSize: 36,
                                  onPressed: _skipBackward,
                                ),
                                const SizedBox(width: 20),
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.pinkAccent,
                                  child: IconButton(
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    iconSize: 36,
                                    onPressed: _playPauseAudio,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: const Icon(Icons.forward_10,
                                      color: Colors.purple),
                                  iconSize: 36,
                                  onPressed: _skipForward,
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'Let these gentle sounds ease your stress and discomfort.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.purple[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
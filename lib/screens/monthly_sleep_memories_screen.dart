import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonthlySleepMemoriesScreen extends StatefulWidget {
  const MonthlySleepMemoriesScreen({super.key});

  @override
  State<MonthlySleepMemoriesScreen> createState() =>
      _MonthlySleepMemoriesScreenState();
}

class _MonthlySleepMemoriesScreenState
    extends State<MonthlySleepMemoriesScreen> {
  static const String _defaultMusicPath = 'memories/the_mountain.mp3';

  final AudioPlayer _audioPlayer = AudioPlayer();
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();

  List<_MemoryPhoto> _photos = const <_MemoryPhoto>[];
  bool _loading = true;
  bool _playingMusic = false;
  Timer? _slideTimer;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _loadMonthlyPhotos();
    _startSlideTimer();
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _pageController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  DateTime get _targetMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1, 1);
  }

  String get _targetMonthLabel {
    const names = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[_targetMonth.month - 1]} ${_targetMonth.year}';
  }

  Future<void> _loadMonthlyPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final allPhotoKeys = prefs.getKeys().where((k) => k.startsWith('photo_'));
    final month = _targetMonth;

    final found = <_MemoryPhoto>[];
    for (final key in allPhotoKeys) {
      final photoPath = prefs.getString(key);
      if (photoPath == null || photoPath.isEmpty) {
        continue;
      }
      final parsedDate = _parsePhotoDateFromKey(key);
      if (parsedDate == null) {
        continue;
      }
      if (parsedDate.year != month.year || parsedDate.month != month.month) {
        continue;
      }
      if (!File(photoPath).existsSync()) {
        continue;
      }
      found.add(_MemoryPhoto(key: key, path: photoPath, date: parsedDate));
    }

    found.sort((a, b) => a.date.compareTo(b.date));

    if (!mounted) return;
    setState(() {
      _photos = found;
      _loading = false;
      _currentPage = 0;
    });

    if (found.isEmpty) {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() => _playingMusic = false);
      return;
    }

    await _startMusicIfNeeded();
  }

  DateTime? _parsePhotoDateFromKey(String key) {
    if (!key.startsWith('photo_')) {
      return null;
    }

    final raw = key.substring(6);
    final parts = raw.split('_');
    if (parts.length < 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  void _startSlideTimer() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _photos.length < 2 || !_pageController.hasClients) {
        return;
      }
      final nextIndex = (_currentPage + 1) % _photos.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _startMusicIfNeeded() async {
    if (_playingMusic || _photos.isEmpty) {
      return;
    }

    await _audioPlayer.play(AssetSource(_defaultMusicPath));
    if (!mounted) return;
    setState(() => _playingMusic = true);
  }

  Future<void> _toggleMusic() async {
    if (_playingMusic) {
      await _audioPlayer.pause();
      if (!mounted) return;
      setState(() => _playingMusic = false);
      return;
    }

    await _startMusicIfNeeded();
  }

  Future<void> _importFromGallery() async {
    final files = await _imagePicker.pickMultiImage(imageQuality: 90);
    if (files.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final appDir = await getApplicationDocumentsDirectory();
    final target = _targetMonth;

    int importedCount = 0;

    for (final pickedFile in files) {
      final source = File(pickedFile.path);
      final modified = await source.lastModified();
      final snappedDate = DateTime(modified.year, modified.month, modified.day);

      if (snappedDate.year != target.year ||
          snappedDate.month != target.month) {
        continue;
      }

      final fileName =
          'memory_${snappedDate.year}_${snappedDate.month}_${snappedDate.day}_${modified.millisecondsSinceEpoch}.jpg';
      final saved = await source.copy('${appDir.path}/$fileName');

      final key =
          'photo_${snappedDate.year}_${snappedDate.month}_${snappedDate.day}_${modified.millisecondsSinceEpoch}';
      await prefs.setString(key, saved.path);
      importedCount += 1;
    }

    await _loadMonthlyPhotos();

    if (!mounted) return;
    if (importedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No photos from $_targetMonthLabel were found in your selection.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Imported $importedCount photo(s) for $_targetMonthLabel.',
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const names = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${names[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141126),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1B2E),
        title: const Text('Sleep Memories'),
        actions: [
          IconButton(
            tooltip: 'Import from gallery',
            onPressed: _importFromGallery,
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
          IconButton(
            tooltip: _playingMusic ? 'Pause music' : 'Play music',
            onPressed: _toggleMusic,
            icon: Icon(_playingMusic ? Icons.pause : Icons.music_note),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _photos.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_album_outlined,
                      color: Color(0xFFB8B5D1),
                      size: 52,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No photos from $_targetMonthLabel yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Take Night Check-In photos this month or import matching gallery photos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFB8B5D1)),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: _importFromGallery,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Import Photos'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24213A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Your $_targetMonthLabel Sleep Journey • ${_photos.length} photos',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _photos.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final photo = _photos[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(File(photo.path), fit: BoxFit.cover),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  color: Colors.black.withValues(alpha: 0.35),
                                  child: Text(
                                    _dateLabel(photo.date),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_photos.length, (index) {
                    final active = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: active ? 20 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF7C6CFF)
                            : const Color(0xFFB8B5D1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

class _MemoryPhoto {
  final String key;
  final String path;
  final DateTime date;

  const _MemoryPhoto({
    required this.key,
    required this.path,
    required this.date,
  });
}

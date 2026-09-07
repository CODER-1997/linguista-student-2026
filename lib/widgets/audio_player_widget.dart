import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
 import 'package:http/http.dart' as http;

import '../controllers/auth_controller.dart';
import '../services/audio_cache_servise.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String title;
  final String url;

  const AudioPlayerWidget({super.key, required this.title, required this.url});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  static const _teal = Color(0xFF2E9E96);
  static const _speeds = [0.75, 1.0, 1.25, 1.5];

  final _player = AudioPlayer();
  Timer? _safetyTimer;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _state = PlayerState.stopped;
  double _speed = 1.0;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isDownloading = false;

  StreamSubscription? _durationSub, _positionSub, _stateSub, _completeSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() { _isLoading = true; _hasError = false; });

    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _safetyTimer?.cancel();

    _safetyTimer = Timer(const Duration(seconds: 25), () {
      if (mounted && _isLoading) {
        debugPrint('AUDIO LOAD TIMEOUT');
        setState(() { _isLoading = false; _hasError = true; });
      }
    });

    try {
      Uint8List? bytes = await AudioHiveCache.get(widget.url);

      if (bytes == null) {
        setState(() => _isDownloading = true);

        final response = await http.get(Uri.parse(widget.url)).timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw TimeoutException('Yuklab olish 25s ichida tugamadi'),
        );

        if (response.statusCode != 200) {
          throw Exception('Yuklab olishda xatolik: HTTP ${response.statusCode}');
        }

        bytes = response.bodyBytes;
        await AudioHiveCache.put(widget.url, bytes); // bir marta yuklab, Hive'ga yozamiz
      }

      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      await _player.setSource(BytesSource(bytes));

      _durationSub = _player.onDurationChanged.listen((d) {
        if (mounted) setState(() { _duration = d; _isLoading = false; });
      });
      _positionSub = _player.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _stateSub = _player.onPlayerStateChanged.listen((s) {
        if (mounted) setState(() => _state = s);
      });
      _completeSub = _player.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() { _state = PlayerState.stopped; _position = Duration.zero; });
        }
      });

      final d = await _player.getDuration();
      if (d != null && mounted) {
        setState(() { _duration = d; _isLoading = false; });
      }
    } catch (e) {
      debugPrint('AUDIO LOAD ERROR: $e');
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
    } finally {
      _safetyTimer?.cancel();
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  bool _hasRecordedPlay = false;

  void _togglePlay() {
    final wasPlaying = _state == PlayerState.playing;
    if (!wasPlaying) _recordPlayIfNeeded();
    wasPlaying ? _player.pause() : _player.resume();
  }

  /// Talaba birinchi marta "play" bosganda, o'sha talabaning tinglash sonini +1 qiladi.
  /// Bir ekran ochilishida faqat bir marta hisoblanadi (pauza/davom ettirish ko'paytirmaydi).
  void _recordPlayIfNeeded() {
    if (_hasRecordedPlay) return;
    _hasRecordedPlay = true;

    final studentId = Get.find<AuthController>().currentStudent.value?.id;
    if (studentId == null) return; // admin ko'rib chiqayotgan bo'lsa, hisoblanmaydi

    FirebaseFirestore.instance
        .collection('LinguistaStudents')
        .doc(studentId)
        .update({'items.audioPlayCount': FieldValue.increment(1)})
        .catchError((e) => debugPrint('PLAY COUNT ERROR: $e'));
  }

  void _seekBy(int seconds) {
    final target = _position + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _duration ? _duration : target);
    _player.seek(clamped);
  }

  void _cycleSpeed() {
    final next = _speeds[(_speeds.indexOf(_speed) + 1) % _speeds.length];
    setState(() => _speed = next);
    _player.setPlaybackRate(next);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: _teal),
            ),
            if (_isDownloading) ...[
              const SizedBox(height: 10),
              Text('Yuklab olinmoqda...',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
            ],
          ],
        ),
      );
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.grey.shade400, size: 32),
            const SizedBox(height: 10),
            Text('Audio yuklanmadi', style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _init,
              child: const Text('Qayta urinish', style: TextStyle(color: _teal)),
            ),
          ],
        ),
      );
    }

    final isPlaying = _state == PlayerState.playing;
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: _teal,
            inactiveTrackColor: _teal.withOpacity(0.15),
            thumbColor: _teal,
            overlayColor: _teal.withOpacity(0.15),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (v) => _player.seek(
              Duration(milliseconds: (v * _duration.inMilliseconds).round()),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_position), style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
              Text(_fmt(_duration), style: TextStyle(color: Colors.grey.shade500, fontSize: 12.5)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundIconButton(
              icon: Icons.replay_10_rounded,
              size: 44, iconSize: 22,
              color: Colors.grey.shade600,
              background: Colors.grey.shade100,
              onTap: () => _seekBy(-10),
            ),
            const SizedBox(width: 20),
            _RoundIconButton(
              icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 66, iconSize: 34,
              color: Colors.white,
              background: _teal,
              onTap: _togglePlay,
            ),
            const SizedBox(width: 20),
            _RoundIconButton(
              icon: Icons.forward_10_rounded,
              size: 44, iconSize: 22,
              color: Colors.grey.shade600,
              background: Colors.grey.shade100,
              onTap: () => _seekBy(10),
            ),
          ],
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: _cycleSpeed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${_speed}x',
                style: const TextStyle(color: _teal, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.color,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: size, height: size, child: Icon(icon, color: color, size: iconSize)),
      ),
    );
  }
}
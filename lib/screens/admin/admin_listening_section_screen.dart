import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/listening_controller.dart';
import '../../models/listening_section_model.dart';
import '../../models/listening_item_model.dart';
import '../../widgets/confirm_delete_dialog.dart';

const _teal = Color(0xFF2E9E96);
const _tealDark = Color(0xFF1A7A72);

class AdminListeningSectionScreen extends StatelessWidget {
  final ListeningSectionModel section;

  const AdminListeningSectionScreen({super.key, required this.section});

  Future<void> _pickAndUpload(BuildContext context, ListeningController controller, int nextOrder) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final defaultTitle = result.files.single.name.split('.').first;

    await Get.dialog(
      _UploadAudioDialog(
        file: file,
        defaultTitle: defaultTitle,
        onConfirm: (title, isPaid, onProgress) => controller.addAudioItem(
          sectionId: section.id,
          title: title,
          audioFile: file,
          order: nextOrder,
          isPaid: isPaid,
          onProgress: onProgress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ListeningController controller = Get.find();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(section.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A2E)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
      body: StreamBuilder<List<ListeningItemModel>>(
        stream: controller.itemsOf(section.id),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return Column(
            children: [
              Obx(() => controller.isUploading.value
                  ? Container(
                height: 4,
                decoration: const BoxDecoration(color: Color(0xFFF0F4F8)),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(_teal),
                ),
              )
                  : const SizedBox.shrink()),
              Expanded(
                child: items.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return _AudioCard(
                      item: item,
                      onDelete: () => showDeleteConfirmDialog(
                        title: 'Audioni o\'chirasizmi?',
                        message: '"${item.title}" butunlay o\'chiriladi.',
                        onConfirm: () => controller.deleteItem(section.id, item.id, item.audioUrl),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          heroTag: 'admin-listening-section-fab',
          onPressed: () => _pickAndUpload(context, controller, 0),
          backgroundColor: _teal,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: const Text('Audio qo\'shish',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        ),
      ),
    );
  }
}

class _UploadAudioDialog extends StatefulWidget {
  final File file;
  final String defaultTitle;
  final Future<void> Function(String title, bool isPaid, void Function(double) onProgress) onConfirm;

  const _UploadAudioDialog({
    required this.file,
    required this.defaultTitle,
    required this.onConfirm,
  });

  @override
  State<_UploadAudioDialog> createState() => _UploadAudioDialogState();
}

class _UploadAudioDialogState extends State<_UploadAudioDialog> {
  late final TextEditingController _titleCtrl;
  final _player = AudioPlayer();
  final _barHeights = List.generate(32, (i) {
    final rnd = Random(i * 7 + 3);
    return 0.25 + rnd.nextDouble() * 0.75;
  });

  bool _isPaid = false;
  bool _isPlaying = false;
  bool _isPreparing = false;
  bool _isUploading = false;
  double _uploadProgress = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.defaultTitle);

    _player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _isPlaying = false; _position = Duration.zero; });
    });
  }

  Future<void> _togglePreview() async {
    if (_isPlaying) {
      await _player.pause();
      return;
    }
    if (_duration == Duration.zero) {
      setState(() => _isPreparing = true);
      try {
        await _player.setPlayerMode(PlayerMode.mediaPlayer);
        await _player.setSource(DeviceFileSource(widget.file.path));
      } finally {
        if (mounted) setState(() => _isPreparing = false);
      }
    }
    await _player.resume();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _player.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playProgress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_teal, _tealDark]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.audiotrack_rounded, size: 30, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Yangi audio',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _titleCtrl,
                  enabled: !_isUploading,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    hintText: 'Audio nomi',
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 18),

              // Waveform + play tugmasi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _teal.withOpacity(0.06), borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _isPreparing || _isUploading ? null : _togglePreview,
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
                            child: _isPreparing
                                ? const Padding(
                              padding: EdgeInsets.all(13),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : Icon(_isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                                color: Colors.white, size: 26),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Waveform
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: LayoutBuilder(builder: (context, constraints) {
                              final litCount = (playProgress * _barHeights.length).floor();
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(_barHeights.length, (i) {
                                  final lit = i <= litCount && _duration > Duration.zero;
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 1.2),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        height: 36 * _barHeights[i],
                                        decoration: BoxDecoration(
                                          color: lit ? _teal : _teal.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    if (_duration > Duration.zero) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(_position), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          Text(_fmt(_duration), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Kirish turi',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _AccessChip(
                      label: 'Barcha uchun',
                      icon: Icons.public,
                      selected: !_isPaid,
                      color: _teal,
                      onTap: _isUploading ? null : () => setState(() => _isPaid = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AccessChip(
                      label: 'Faqat pullik',
                      icon: Icons.lock_outline,
                      selected: _isPaid,
                      color: const Color(0xFFB8863B),
                      onTap: _isUploading ? null : () => setState(() => _isPaid = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUploading ? null : () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Bekor qilish', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isUploading
                          ? null
                          : () async {
                        setState(() => _isUploading = true);
                        await widget.onConfirm(_titleCtrl.text, _isPaid, (p) {
                          if (mounted) setState(() => _uploadProgress = p);
                        });
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        disabledBackgroundColor: _teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: _isUploading
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              value: _uploadProgress > 0 ? _uploadProgress : null,
                              strokeWidth: 2.4,
                              color: Colors.white,
                              backgroundColor: Colors.white.withOpacity(0.25),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('${(_uploadProgress * 100).round()}%',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                        ],
                      )
                          : const Text('Yuklash',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccessChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;

  const _AccessChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(disabled ? 0.05 : 0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color.withOpacity(disabled ? 0.4 : 1) : Colors.grey.shade200, width: 1.4),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Colors.grey.shade400, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : Colors.grey.shade500,
                )),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: _teal.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.audiotrack, size: 44, color: _teal),
          ),
          const SizedBox(height: 20),
          const Text('Audio fayllar mavjud emas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 8),
          Text('Yangisini qo\'shish uchun pastdagi tugmani bosing',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _AudioCard extends StatelessWidget {
  final ListeningItemModel item;
  final VoidCallback onDelete;

  const _AudioCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final badgeColor = item.isPaid ? const Color(0xFFB8863B) : _teal;
    final badgeLabel = item.isPaid ? 'Pullik' : 'Bepul';
    final badgeIcon = item.isPaid ? Icons.lock_outline : Icons.public;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_teal, _tealDark]),
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, size: 11, color: badgeColor),
                            const SizedBox(width: 4),
                            Text(badgeLabel,
                                style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.08), shape: BoxShape.circle),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
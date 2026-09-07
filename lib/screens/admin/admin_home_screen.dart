import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/listening_controller.dart';
import '../../controllers/video_controller.dart';
import '../../widgets/confirm_delete_dialog.dart';
import 'admin_listening_section_screen.dart';
import 'admin_group_students_screen.dart';

const _indigoDark = Color(0xFF1E3C72);
const _indigo = Color(0xFF2A5298);
const _teal = Color(0xFF2E9E96);
const _gold = Color(0xFFB8863B);
const _bg = Color(0xFFF6F7FB);

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  final List<Widget> _tabs = const [
    _AdminVideosTab(),
    _AdminListeningTab(),
    _AdminAnalyticsTab(),
    _AdminProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: _indigo.withOpacity(0.12),
        backgroundColor: Colors.white,
        elevation: 0,
        height: 66,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.play_circle_outline, color: Colors.grey),
            selectedIcon: Icon(Icons.play_circle_fill, color: _indigo),
            label: 'Videos',
          ),
          NavigationDestination(
            icon: const Icon(Icons.headphones_outlined, color: Colors.grey),
            selectedIcon: Icon(Icons.headphones, color: _teal),
            label: 'Listening',
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined, color: Colors.grey),
            selectedIcon: const Icon(Icons.bar_chart_rounded, color: _gold),
            label: 'Analitika',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            selectedIcon: Icon(Icons.person, color: _indigoDark),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _SectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  const _SectionAppBar({required this.title, required this.subtitle});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600)),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade100),
      ),
    );
  }
}

/// Video/audio/guruh ro'yxatlari uchun umumiy karta.
/// onDelete null bo'lsa, o'chirish tugmasi umuman ko'rsatilmaydi (Analitikada shunday ishlatiladi).
class _AdminListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _AdminListCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailingText,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              if (trailingText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(trailingText!,
                      style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 21),
                  onPressed: onDelete,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool autofocus;

  const _DialogField({required this.controller, required this.label, this.autofocus = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: const TextStyle(fontSize: 15.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _indigo, width: 1.5)),
      ),
    );
  }
}

class _DialogShell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget content;
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final bool isSaving;

  const _DialogShell({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.confirmLabel,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                ],
              ),
              const SizedBox(height: 20),
              content,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Get.back(), child: Text('Bekor qilish', style: TextStyle(color: Colors.grey.shade600))),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSaving ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(confirmLabel, style: const TextStyle(color: Colors.white)),
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }
}

class _AdminVideosTab extends StatelessWidget {
  const _AdminVideosTab();

  void _showAddDialog(BuildContext context, VideoController controller) {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final isSaving = false.obs;

    Get.dialog(
      Obx(() => _DialogShell(
        icon: Icons.play_circle_fill,
        color: _indigo,
        title: 'Yangi video',
        content: Column(children: [
          _DialogField(controller: titleCtrl, label: 'Video nomi', autofocus: true),
          const SizedBox(height: 16),
          _DialogField(controller: urlCtrl, label: 'Video linki (URL)'),
        ]),
        confirmLabel: 'Qo\'shish',
        isSaving: isSaving.value,
        onConfirm: () async {
          isSaving.value = true;
          await controller.addVideo(titleCtrl.text, urlCtrl.text);
          isSaving.value = false;
          Get.back();
        },
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final VideoController controller = Get.find();
    return Scaffold(
      backgroundColor: _bg,
      appBar: const _SectionAppBar(title: 'Videos', subtitle: 'Video darslarni boshqarish'),
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin-videos-fab',
        backgroundColor: _indigo,
        onPressed: () => _showAddDialog(context, controller),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.videos.isEmpty) {
          return const _EmptyState(icon: Icons.videocam_off_outlined, message: 'Hozircha video yo\'q');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: controller.videos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final v = controller.videos[i];
              return _AdminListCard(
              icon: Icons.play_arrow_rounded,
              iconColor: _indigo,
              title: v.title,
              onTap: () {},
              onDelete: () => showDeleteConfirmDialog(
                title: 'Videoni o\'chirasizmi?',
                message: '"${v.title}" butunlay o\'chiriladi. Bu amalni ortga qaytarib bo\'lmaydi.',
                onConfirm: () => controller.deleteVideo(v.id),
              ),
            );
          },
        );
      }),
    );
  }
}

class _AdminListeningTab extends StatelessWidget {
  const _AdminListeningTab();

  void _showAddSectionDialog(BuildContext context, ListeningController controller) {
    final titleCtrl = TextEditingController();
    final isSaving = false.obs;

    Get.dialog(
      Obx(() => _DialogShell(
        icon: Icons.folder_rounded,
        color: _teal,
        title: 'Yangi bo\'lim',
        content: _DialogField(controller: titleCtrl, label: 'Bo\'lim nomi (masalan: Foundation)', autofocus: true),
        confirmLabel: 'Yaratish',
        isSaving: isSaving.value,
        onConfirm: () async {
          isSaving.value = true;
          final success = await controller.addSection(titleCtrl.text);
          isSaving.value = false;
          if (success) Get.back();
        },
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ListeningController controller = Get.find();
    return Scaffold(
      backgroundColor: _bg,
      appBar: const _SectionAppBar(title: 'Listening', subtitle: 'Audio bo\'limlarni boshqarish'),
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin-listening-fab',
        backgroundColor: _teal,
        onPressed: () => _showAddSectionDialog(context, controller),
        child: const Icon(Icons.create_new_folder, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.sections.isEmpty) {
          return const _EmptyState(icon: Icons.folder_off_outlined, message: 'Hozircha bo\'lim yo\'q');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: controller.sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final s = controller.sections[i];
            return _AdminListCard(
            icon: Icons.folder_rounded,
            iconColor: _teal,
            title: s.title,
            onTap: () => Get.to(() => AdminListeningSectionScreen(section: s)),
            onDelete: () => showDeleteConfirmDialog(
              title: 'Bo\'limni o\'chirasizmi?',
              message: '"${s.title}" bo\'limi va undagi barcha audiolar o\'chiriladi.',
              onConfirm: () => controller.deleteSection(s.id),
            ),
            );
          },
        );
      }),
    );
  }
}

// ---------------- ANALITIKA ----------------

class _StudentUsage {
  final String id;
  final String name;
  final String groupId;
  final bool hasUsedApp;
  final int playCount;

  _StudentUsage({
    required this.id,
    required this.name,
    required this.groupId,
    required this.hasUsedApp,
    required this.playCount,
  });
}

class _GroupUsage {
  final String uniqueId;
  final String name;
  final int totalStudents;
  final int activeStudents;

  _GroupUsage({
    required this.uniqueId,
    required this.name,
    required this.totalStudents,
    required this.activeStudents,
  });

  double get percent => totalStudents == 0 ? 0 : activeStudents / totalStudents;
}

class _AdminAnalyticsTab extends StatefulWidget {
  const _AdminAnalyticsTab();

  @override
  State<_AdminAnalyticsTab> createState() => _AdminAnalyticsTabState();
}

class _AdminAnalyticsTabState extends State<_AdminAnalyticsTab> {
  late Future<_AnalyticsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_AnalyticsData> _load() async {
    final groupsSnap = await FirebaseFirestore.instance.collection('LinguistaGroups').get();
    final studentsSnap = await FirebaseFirestore.instance.collection('LinguistaStudents').get();

    final groupNames = <String, String>{};
    for (final doc in groupsSnap.docs) {
      final items = doc.data()['items'] as Map<String, dynamic>? ?? {};
      final uid = items['uniqueId']?.toString() ?? '';
      groupNames[uid] = items['name']?.toString() ?? 'Nomsiz guruh';
    }

    final students = <_StudentUsage>[];
    for (final doc in studentsSnap.docs) {
      final items = doc.data()['items'] as Map<String, dynamic>? ?? {};
      if (items['isDeleted'] == true) continue;

      students.add(_StudentUsage(
        id: doc.id,
        name: '${items['name'] ?? ''} ${items['surname'] ?? ''}'.trim(),
        groupId: items['groupId']?.toString() ?? '',
        hasUsedApp: items['appLastLoginAt'] != null,
        playCount: items['audioPlayCount'] is int ? items['audioPlayCount'] as int : 0,
      ));
    }

    final byGroup = <String, List<_StudentUsage>>{};
    for (final s in students) {
      byGroup.putIfAbsent(s.groupId, () => []).add(s);
    }

    final groupUsages = byGroup.entries.map((e) {
      final active = e.value.where((s) => s.hasUsedApp).length;
      return _GroupUsage(
        uniqueId: e.key,
        name: groupNames[e.key] ?? 'Nomsiz guruh',
        totalStudents: e.value.length,
        activeStudents: active,
      );
    }).toList()
      ..sort((a, b) => b.percent.compareTo(a.percent));

    final topListeners = [...students]
      ..sort((a, b) => b.playCount.compareTo(a.playCount));

    final totalActive = students.where((s) => s.hasUsedApp).length;

    return _AnalyticsData(
      totalStudents: students.length,
      activeStudents: totalActive,
      groups: groupUsages,
      topListeners: topListeners.where((s) => s.playCount > 0).take(5).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: const _SectionAppBar(title: 'Analitika', subtitle: 'Guruhlar bo\'yicha ilova faolligi'),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future;
        },
        child: FutureBuilder<_AnalyticsData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Xatolik: ${snapshot.error}'));
            }
            final data = snapshot.data!;
            if (data.totalStudents == 0) {
              return const _EmptyState(icon: Icons.groups_outlined, message: 'Talabalar topilmadi');
            }

            final overallPercent = data.totalStudents == 0 ? 0.0 : data.activeStudents / data.totalStudents;
            final mostActiveGroup = data.groups.isNotEmpty ? data.groups.first : null;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.pie_chart_rounded,
                        color: _indigo,
                        label: 'Umumiy foydalanish',
                        value: '${(overallPercent * 100).round()}%',
                        sub: '${data.activeStudents}/${data.totalStudents} talaba',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events_rounded,
                        color: _gold,
                        label: 'Eng faol guruh',
                        value: mostActiveGroup != null ? mostActiveGroup.name : '—',
                        sub: mostActiveGroup != null
                            ? '${(mostActiveGroup.percent * 100).round()}% faol'
                            : '',
                      ),
                    ),
                  ],
                ),
                if (data.topListeners.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text('Eng ko\'p tinglovchilar',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...data.topListeners.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TopListenerRow(rank: e.key + 1, student: e.value),
                  )),
                ],
                const SizedBox(height: 20),
                const Text('Guruhlar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...data.groups.map((g) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AdminListCard(
                    icon: Icons.groups_rounded,
                    iconColor: _gold,
                    title: g.name,
                    trailingText: '${(g.percent * 100).round()}%',
                    onTap: () => Get.to(() => AdminGroupStudentsScreen(
                      groupUniqueId: g.uniqueId,
                      groupName: g.name,
                    )),
                    // onDelete berilmagan — guruhni o'chirish bu yerda mavjud emas
                  ),
                )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnalyticsData {
  final int totalStudents;
  final int activeStudents;
  final List<_GroupUsage> groups;
  final List<_StudentUsage> topListeners;

  _AnalyticsData({
    required this.totalStudents,
    required this.activeStudents,
    required this.groups,
    required this.topListeners,
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ],
      ),
    );
  }
}

class _TopListenerRow extends StatelessWidget {
  final int rank;
  final _StudentUsage student;

  const _TopListenerRow({required this.rank, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rank == 1 ? _gold.withOpacity(0.15) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Text('$rank',
                style: TextStyle(
                    color: rank == 1 ? _gold : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(student.name.isEmpty ? 'Ismsiz' : student.name,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
          ),
          Text('${student.playCount} marta',
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _AdminProfileTab extends StatelessWidget {
  const _AdminProfileTab();

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();
    return Scaffold(
      backgroundColor: _bg,
      appBar: const _SectionAppBar(title: 'Profil', subtitle: 'Hisob ma\'lumotlari'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_indigoDark, _indigo]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Administrator', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: auth.logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout, size: 19),
                  label: const Text('Chiqish', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminGroupStudentsScreen extends StatelessWidget {
  final String groupUniqueId;
  final String groupName;

  const AdminGroupStudentsScreen({
    super.key,
    required this.groupUniqueId,
    required this.groupName,
  });

  static const green = Color(0xFF2E9E66);
  static const grey = Color(0xFF9AA0A6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(groupName),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('LinguistaStudents')
            .where('items.groupId', isEqualTo: groupUniqueId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          }

          final docs = (snapshot.data?.docs ?? [])
              .where((d) => (d['items'] as Map<String, dynamic>)['isDeleted'] != true)
              .toList();

          if (docs.isEmpty) {
            return Center(
              child: Text('Bu guruhda talaba topilmadi',
                  style: TextStyle(color: Colors.grey.shade500)),
            );
          }

          docs.sort((a, b) {
            final aLogged = (a['items'] as Map)['appLastLoginAt'] != null;
            final bLogged = (b['items'] as Map)['appLastLoginAt'] != null;
            if (aLogged == bLogged) return 0;
            return aLogged ? -1 : 1;
          });

          final activeCount =
              docs.where((d) => (d['items'] as Map)['appLastLoginAt'] != null).length;

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: Colors.white,
                child: Row(
                  children: [
                    _StatChip(
                      label: 'Ilovadan foydalanadi',
                      value: '$activeCount',
                      color: green,
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      label: 'Hali kirmagan',
                      value: '${docs.length - activeCount}',
                      color: grey,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final items = docs[i]['items'] as Map<String, dynamic>;
                    final name = '${items['name'] ?? ''} ${items['surname'] ?? ''}'.trim();
                    final lastLogin = items['appLastLoginAt'] as Timestamp?;
                    final loginCount = items['appLoginCount'] is int ? items['appLoginCount'] as int : 0;

                    return _StudentUsageCard(
                      name: name.isEmpty ? 'Ismsiz' : name,
                      hasUsedApp: lastLogin != null,
                      lastLoginText: lastLogin != null
                          ? DateFormat('dd-MM-yyyy HH:mm').format(lastLogin.toDate())
                          : null,
                      loginCount: loginCount,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

class _StudentUsageCard extends StatelessWidget {
  final String name;
  final bool hasUsedApp;
  final String? lastLoginText;
  final int loginCount;

  const _StudentUsageCard({
    required this.name,
    required this.hasUsedApp,
    required this.lastLoginText,
    required this.loginCount,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = hasUsedApp ? AdminGroupStudentsScreen.green : AdminGroupStudentsScreen.grey;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  hasUsedApp
                      ? 'So\'nggi kirish: $lastLoginText, $loginCount marta kirgan'
                      : 'Ilovaga hali kirmagan',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasUsedApp ? 'Faol' : 'Kirmagan',
              style: TextStyle(color: statusColor, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
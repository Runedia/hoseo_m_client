import 'package:flutter/material.dart';
import 'new_dart/curriculum_home_screen.dart';
import 'new_dart/scadule_screen.dart';
import 'new_dart/class_screen.dart';
import 'new_dart/record_screen.dart';
import 'settings_screen.dart';

class AcademicHomePage extends StatelessWidget {
  const AcademicHomePage({super.key});

  final List<_FeatureItem> features = const [
    _FeatureItem('학사일정', Icons.schedule),
    _FeatureItem('교육과정', Icons.book),
    _FeatureItem('수업', Icons.class_),
    _FeatureItem('학적', Icons.assignment_ind),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color tileColor = isDark ? Colors.white : const Color(0xFFBE1924);
    final Color textColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('학사종합'),
        centerTitle: true,
        backgroundColor: const Color(0xFFBE1924),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: features.map((item) {
            return GestureDetector(
              onTap: () {
                if (item.title == '교육과정') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CurriculumHomePage()),
                  );
                  return;
                }

                if (item.title == '학사일정') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AcademicSchedulePage()),
                  );
                  return;
                }

                if (item.title == '수업') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClassInfoScreen(type: 'regist', title: '수업')),
                  );
                  return;
                }

                if (item.title == '학적') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecordInfoScreen(type: 'test', title: '학적')),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.title} 기능은 준비 중입니다.')),
                );
              },
              child: Card(
                elevation: 3,
                color: tileColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 36, color: textColor),
                      const SizedBox(height: 12),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(context, Icons.arrow_back, '이전', () {
              Navigator.pop(context);
            }),
            _buildNavButton(context, Icons.home, '홈', () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }),
            _buildNavButton(context, Icons.arrow_forward, '다음', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('원하시는 버튼을 눌러주시길 바랍니다.')),
              );
            }),
            _buildNavButton(context, Icons.settings, '설정', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
      BuildContext context,
      IconData icon,
      String label,
      VoidCallback onTap,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : Colors.black,
            foregroundColor: isDark ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(48, 48),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _FeatureItem {
  final String title;
  final IconData icon;
  const _FeatureItem(this.title, this.icon);
}

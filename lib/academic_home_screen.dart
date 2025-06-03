import 'package:flutter/material.dart';
import 'package:hoseo_m_client/vo/FeatureItem.dart';
import 'menu_6_screen/curriculum_home_screen.dart';
import 'menu_6_screen/schedule_screen.dart';
import 'menu_6_screen/class_screen.dart';
import 'menu_6_screen/record_screen.dart';
import 'settings_screen.dart';

class AcademicHomePage extends StatelessWidget {
  const AcademicHomePage({super.key});

  final List<FeatureItem> features = const [
    FeatureItem('학사일정', Icons.schedule),
    FeatureItem('교육과정', Icons.book),
    FeatureItem('수업', Icons.class_),
    FeatureItem('학적', Icons.assignment_ind),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color tileColor = theme.primaryColor.withOpacity(0.85);
    final Color textColor = theme.appBarTheme.foregroundColor ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('학사종합'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
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
                if (item.title == features[0].title) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AcademicSchedulePage(),
                    ),
                  );
                  return;
                }
                if (item.title == features[1].title) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CurriculumHomePage(),
                    ),
                  );
                  return;
                }
                if (item.title == features[2].title) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassInfoScreen(type: 'regist', title: features[2].title),
                    ),
                  );
                  return;
                }
                if (item.title == features[3].title) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecordInfoScreen(type: 'test', title: features[3].title),
                    ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

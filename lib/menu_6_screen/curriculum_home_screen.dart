import 'package:flutter/material.dart';
import '../settings_screen.dart';
import '../vo/FeatureItem.dart';
import 'curriculum_screen.dart';

class CurriculumHomePage extends StatelessWidget {
  const CurriculumHomePage({super.key});

  final List<FeatureItem> features = const [
    FeatureItem('교육과정', Icons.school, CurriculumPage(type: 'basic', title: '교육과정')),
    FeatureItem('부전공 안내', Icons.menu_book, CurriculumPage(type: 'minor', title: '부전공 안내')),
    FeatureItem('복수전공 안내', Icons.import_contacts, CurriculumPage(type: 'double', title: '복수전공 안내')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color tileColor = theme.primaryColor.withOpacity(0.85);
    final Color textColor = theme.appBarTheme.titleTextStyle?.color ?? Colors.white;
    final Color appBarColor = theme.appBarTheme.backgroundColor ?? theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('교육과정 정보', style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: textColor),
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
                Navigator.push(context, MaterialPageRoute(builder: (_) => item.page!));
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                        textAlign: TextAlign.center,
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
                const SnackBar(content: Text('다음 페이지는 존재하지 않습니다.')),
              );
            }),
            _buildNavButton(context, Icons.settings, '설정', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white : Colors.black,
            foregroundColor: isDark ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

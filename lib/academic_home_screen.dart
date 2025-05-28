import 'package:flutter/material.dart';
import 'settings_screen.dart';

class AcademicHomePage extends StatelessWidget {
  const AcademicHomePage({super.key});

  final List<_FeatureItem> features = const [
    _FeatureItem('학사일정', Icons.schedule),
    _FeatureItem('교육과정', Icons.book),
    _FeatureItem('수업', Icons.class_),
    _FeatureItem('학적', Icons.assignment_ind),
    _FeatureItem('취업지원', Icons.work),
    _FeatureItem('국제교류', Icons.public),
    _FeatureItem('증명서 발급', Icons.picture_as_pdf),
    _FeatureItem('기타', Icons.more_horiz),
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
              // 추후 기능
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

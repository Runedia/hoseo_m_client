import 'package:flutter/material.dart';
import '../settings_screen.dart';

class SubMajorPage extends StatelessWidget {
  const SubMajorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부전공 안내', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFBE1924),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            '📘 부전공이란?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '부전공 제도는 주전공 외에 관심 있는 다른 학문 분야의 기본 지식을 체계적으로 학습할 수 있도록 하는 제도입니다. 학생은 주전공 이수 외에도 일정 학점의 부전공 과목을 이수하여 졸업 요건을 충족할 수 있습니다.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          SizedBox(height: 20),
          Text(
            '✅ 주요 특징',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• 타 학부 또는 전공의 과목 중 필수/선택 교과목을 일정 학점 이수'),
          Text('• 부전공 이수 시 졸업증명서에 부전공 기재'),
          Text('• 졸업 요건 충족을 위한 필수 교과목 기준은 학사 운영 규정 참조'),
        ],
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
                SnackBar(content: Text('다음 기능은 준비 중입니다.')),
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

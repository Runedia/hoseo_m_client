import 'package:flutter/material.dart';
import '../settings_screen.dart';

class DoubleMajorPage extends StatelessWidget {
  const DoubleMajorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('복수전공 안내', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFBE1924),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            '📘 복수전공이란?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '복수전공 제도는 학생이 주전공 외에 다른 학문 분야를 추가로 전공하여 두 개의 전공 학위를 동시에 이수할 수 있도록 하는 제도입니다.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          SizedBox(height: 20),
          Text(
            '✅ 주요 특징',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• 주전공과 동일한 수준의 과목 및 학점 이수 필요'),
          Text('• 복수전공 이수 시 졸업증명서에 두 전공 명시'),
          Text('• 신청 자격, 승인 절차, 졸업 요건 등은 학사운영규정에 따름'),
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

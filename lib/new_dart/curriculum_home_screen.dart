import 'package:flutter/material.dart';
import '../settings_screen.dart';
import 'curriculum_screen.dart';

class CurriculumHomePage extends StatelessWidget {
const CurriculumHomePage({super.key});

// 기능 항목 리스트 정의
final List<_FeatureItem> features = const [
_FeatureItem('교육과정', Icons.school, CurriculumPage(type: 'basic', title: '교육과정')),
_FeatureItem('부전공 안내', Icons.menu_book, CurriculumPage(type: 'minor', title: '부전공 안내')),
_FeatureItem('복수전공 안내', Icons.import_contacts, CurriculumPage(type: 'double', title: '복수전공 안내')),
];

@override
Widget build(BuildContext context) {
// 다크 모드 여부 확인
final isDark = Theme.of(context).brightness == Brightness.dark;

// 타일 색상 및 텍스트 색상 설정
final Color tileColor = isDark ? Colors.white : const Color(0xFFBE1924);
final Color textColor = isDark ? Colors.black : Colors.white;

return Scaffold(
appBar: AppBar(
title: const Text('교육과정 정보'),
centerTitle: true,
backgroundColor: const Color(0xFFBE1924),
foregroundColor: Colors.white,
),
body: Padding(
padding: const EdgeInsets.all(16),
child: GridView.count(
crossAxisCount: 2, // 한 줄에 2개씩 표시
mainAxisSpacing: 16,
crossAxisSpacing: 16,
childAspectRatio: 1.3,
children: features.map((item) {
return GestureDetector(
onTap: () {
// 각 항목을 클릭 시 해당 페이지로 이동
Navigator.push(
context,
MaterialPageRoute(builder: (_) => item.page),
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
// 이전 버튼: 이전 페이지로 이동
_buildNavButton(context, Icons.arrow_back, '이전', () {
Navigator.pop(context);
}),
// 홈 버튼: 첫 페이지로 이동
_buildNavButton(context, Icons.home, '홈', () {
Navigator.popUntil(context, (route) => route.isFirst);
}),
// 다음 버튼: 다음 페이지가 없다는 안내
_buildNavButton(context, Icons.arrow_forward, '다음', () {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('다음 페이지는 존재하지 않습니다.')),
);
}),
// 설정 버튼: 설정 화면으로 이동
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

// 하단 네비게이션 버튼 빌더 함수
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

// 기능 항목 클래스 정의
class _FeatureItem {
final String title;
final IconData icon;
final Widget page;
const _FeatureItem(this.title, this.icon, this.page);
}

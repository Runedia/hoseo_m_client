import 'package:flutter/material.dart';
import 'notice_screen.dart';
import 'shuttle_select_screen.dart';
import 'settings_screen.dart';
import 'academic_home_screen.dart';
import 'department_screen.dart';
import 'meal_screen.dart';
import 'themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _currentTheme = HSColors.HsRed_Theme;

  void updateTheme(String themeName) {
    setState(() {
      switch (themeName) {
        case 'HS Blue':
          _currentTheme = HSColors.HsBlue_Theme;
          break;
        case 'HS Green':
          _currentTheme = HSColors.HsGreen_Theme;
          break;
        case 'HS Grey':
          _currentTheme = HSColors.HsGrey_Theme;
          break;
        case 'HS Red':
        default:
          _currentTheme = HSColors.HsRed_Theme;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => MaterialApp(
        title: '호서대학교 공지앱1',
        theme: _currentTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<_FeatureItem> topFeatures = const [
    _FeatureItem("공지사항", Icons.campaign),
    _FeatureItem("셔틀버스", Icons.directions_bus),
    _FeatureItem("학과정보", Icons.school),
    _FeatureItem("식단표", Icons.restaurant_menu),
    _FeatureItem("캠퍼스맵", Icons.map),
    _FeatureItem("학사종합", Icons.book),
  ];

  final List<_FeatureItem> bottomFeatures = const [
    _FeatureItem("LMS", Icons.laptop),
    _FeatureItem("통합포털", Icons.web),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double iconSize = size.width * 0.12;
    final double fontSize = size.width * 0.035;
    final double spacing = size.width * 0.025;

    return Scaffold(
      appBar: AppBar(
        title: const Text("호서대학교 앱"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(spacing),
          child: Column(
            children: [
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: topFeatures.map((item) {
                  return SizedBox(
                    width: (size.width - spacing * 4) / 3,
                    height: size.width * 0.25,
                    child: _buildCard(context, item, iconSize, fontSize),
                  );
                }).toList(),
              ),
              SizedBox(height: spacing * 2),
              Column(
                children: bottomFeatures.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: FractionallySizedBox(
                      widthFactor: 0.95,
                      child: _buildCard(context, item, iconSize, fontSize),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              context,
              icon: Icons.arrow_back,
              label: '이전',
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _buildNavButton(
              context,
              icon: Icons.home,
              label: '홈',
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            _buildNavButton(
              context,
              icon: Icons.arrow_forward,
              label: '다음',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('다음 기능은 준비 중입니다.')),
                );
              },
            ),
            _buildNavButton(
              context,
              icon: Icons.settings,
              label: '설정',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, _FeatureItem item, double iconSize, double fontSize) {
    return Card(
      color: Theme.of(context).primaryColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (item.title == "공지사항") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const NoticeScreen()));
          } else if (item.title == "셔틀버스") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ShuttleSelectScreen()));
          } else if (item.title == "학사종합") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AcademicHomePage()));
          } else if (item.title == "학과정보") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DepartmentPage()));
          } else if (item.title == "식단표") {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MealPage()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.title} 클릭됨')),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: iconSize, color: Colors.white),
              SizedBox(height: iconSize * 0.15),
              Text(item.title, style: TextStyle(fontSize: fontSize, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
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

import 'package:flutter/material.dart';
import 'main.dart';
import 'themes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String selectedTheme;

  final List<String> themeOptions = [
    'HS Red',
    'HS Blue',
    'HS Green',
    'HS Grey',
  ];

  @override
  void initState() {
    super.initState();
    selectedTheme = 'HS Red';
  }

  void changeTheme(String? newTheme) {
    if (newTheme == null) return;

    setState(() {
      selectedTheme = newTheme;
    });

    MyApp.of(context)?.updateTheme(newTheme);

    // 🔄 테마가 적용된 후 다시 빌드하도록 강제 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void resetPreferences() {
    // TODO: 추후 초기화 로직
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text('설정', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              Row(
                children: [
                  const Text('테마 선택: ', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedTheme,
                      items: themeOptions.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: changeTheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: resetPreferences,
                icon: const Icon(Icons.delete_forever),
                label: const Text('데이터 초기화'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              const Text('앱 버전: 1.0.0'),
              const Text('데이터 버전: 2025.05.23'),
              const Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(Icons.arrow_back, '이전', () {
              Navigator.pop(context);
            }),
            _buildNavButton(Icons.home, '홈', () {
              Navigator.popUntil(context, (route) => route.isFirst);
            }),
            _buildNavButton(Icons.arrow_forward, '다음', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('다음 기능은 준비 중입니다.')),
              );
            }),
            _buildNavButton(Icons.settings, '설정', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onTap) {
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

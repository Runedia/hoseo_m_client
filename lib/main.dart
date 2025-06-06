import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoseo_m_client/router/app_router.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';
import 'package:hoseo_m_client/utils/themes/theme_preferences.dart';
import 'package:hoseo_m_client/utils/themes/themes.dart';
import 'package:hoseo_m_client/vo/FeatureItem.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String>? _themeLoader;

  @override
  void initState() {
    super.initState();
    _themeLoader = ThemePreferences.getTheme();
  }

  // 테마 데이터 가져오기
  ThemeData _getThemeData(String themeName) {
    switch (themeName) {
      case 'HS Blue':
        return HSColors.hsBlueTheme;
      case 'HS Green':
        return HSColors.hsGreenTheme;
      case 'HS Grey':
        return HSColors.hsGreyTheme;
      case 'HS Red':
      default:
        return HSColors.hsRedTheme;
    }
  }

  // 테마 업데이트 및 저장
  void updateTheme(String themeName) async {
    await ThemePreferences.saveTheme(themeName);
    setState(() {
      _themeLoader = Future.value(themeName);
    });
  }

  // 현재 테마 이름 가져오기 (동기적으로)
  String getCurrentThemeName() {
    // FutureBuilder의 snapshot에서 현재 테마 이름을 가져오는 방법이 필요
    // 일시적으로 기본값 반환
    return 'HS Red';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _themeLoader,
      builder: (context, snapshot) {
        // 데이터가 로드되지 않았을 때 로딩 화면 표시
        if (!snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: HSColors.hsRedTheme.primaryColor,
              body: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
          );
        }

        final themeName = snapshot.data!;
        final themeData = _getThemeData(themeName);

        return MaterialApp.router(
          title: '호서대학교 모바일',
          theme: themeData,
          routerConfig: AppRouter.createRouter(themeName),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
          locale: const Locale('ko', 'KR'),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String currentThemeName;

  const HomeScreen({super.key, required this.currentThemeName});

  final List<FeatureItem> topFeatures = const [
    FeatureItem("공지사항", Icons.campaign),
    FeatureItem("셔틀버스", Icons.directions_bus),
    FeatureItem("학과정보", Icons.school),
    FeatureItem("식단표", Icons.restaurant_menu),
    FeatureItem("캠퍼스맵", Icons.map),
    FeatureItem("학사종합", Icons.book),
  ];

  final List<FeatureItem> bottomFeatures = const [FeatureItem("LMS", Icons.laptop), FeatureItem("통합포털", Icons.web)];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double iconSize = size.width * 0.12;
    final double fontSize = size.width * 0.035;
    final double spacing = size.width * 0.025;

    return CommonScaffold(
      title: "호서대학교 모바일",
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            GoRouterHistory.instance.pushWithHistory(context, '/settings');
          },
        ),
      ],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(spacing),
          child: Column(
            children: [
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children:
                    topFeatures.map((item) {
                      return SizedBox(
                        width: (size.width - spacing * 4) / 3,
                        height: size.width * 0.25,
                        child: _buildCard(context, item, iconSize, fontSize),
                      );
                    }).toList(),
              ),
              SizedBox(height: spacing * 2),
              Column(
                children:
                    bottomFeatures.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: spacing),
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          child: _buildCard(context, item, iconSize, fontSize),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, FeatureItem item, double iconSize, double fontSize) {
    return Card(
      color: Theme.of(context).primaryColor,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          if (item.title == "공지사항") {
            GoRouterHistory.instance.pushWithHistory(context, '/notice');
          } else if (item.title == "셔틀버스") {
            GoRouterHistory.instance.pushWithHistory(context, '/shuttle');
          } else if (item.title == "학과정보") {
            GoRouterHistory.instance.pushWithHistory(context, '/department');
          } else if (item.title == "식단표") {
            GoRouterHistory.instance.pushWithHistory(context, '/meal');
          } else if (item.title == "캠퍼스맵") {
            GoRouterHistory.instance.pushWithHistory(context, '/campus');
          } else if (item.title == "학사종합") {
            GoRouterHistory.instance.pushWithHistory(context, '/academic');
          } else if (item.title == "LMS") {
            var url = Uri.parse('https://learn.hoseo.ac.kr/');
            if (await canLaunchUrl(url)) {
              launchUrl(url);
            }
          } else if (item.title == "통합포털") {
            var url = Uri.parse('https://portal.hoseo.edu/');
            if (await canLaunchUrl(url)) {
              launchUrl(url);
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.title} 클릭됨')));
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
}

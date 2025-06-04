import 'package:flutter/material.dart';
import 'package:hoseo_m_client/menu_6_screen/schedule_calendar_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/schedule_list_screen.dart';
import 'package:hoseo_m_client/utils/animations/page_transitions.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/vo/FeatureItem.dart';

class ScheduleHomePage extends StatelessWidget {
  const ScheduleHomePage({super.key});

  final List<FeatureItem> features = const [
    FeatureItem('목록형', Icons.school, AcademicSchedulePage()),
    FeatureItem('달력형', Icons.menu_book, CalendarSchedulePage()),
  ];

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '학사일정',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children:
              features.map((item) {
                return GestureDetector(
                  onTap: () {
                    // 네비게이션 히스토리에 추가
                    if (item.title == '목록형') {
                      // NavigationHistory.instance.onNavigate('AcademicSchedulePage');
                    } else if (item.title == '달력형') {
                      // NavigationHistory.instance.onNavigate('CalendarSchedulePage');
                    }
                    
                    // PageAnimations를 사용하여 이동
                    Navigator.push(
                      context, 
                      PageAnimations.fade(item.page!)
                    );
                  },
                  child: Card(
                    elevation: 3,
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 36, color: Colors.white),
                          const SizedBox(height: 12),
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
    );
  }
}

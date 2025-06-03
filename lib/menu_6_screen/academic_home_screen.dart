import 'package:flutter/material.dart';
import 'package:hoseo_m_client/menu_6_screen/class_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/curriculum_home_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/record_screen.dart';
import 'package:hoseo_m_client/menu_6_screen/schedule_home_screen.dart';
import 'package:hoseo_m_client/utils/animations/page_transitions.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/vo/FeatureItem.dart';

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
    return CommonScaffold(
      title: '학사종합',
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
                    if (item.title == features[0].title) {
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => const AcademicSchedulePage()));
                      NavigationHistory.instance.onNavigate('ScheduleHomePage');
                      Navigator.push(context, PageAnimations.fade(const ScheduleHomePage()));
                      return;
                    }
                    if (item.title == features[1].title) {
                      NavigationHistory.instance.onNavigate('CurriculumHomePage');
                      Navigator.push(context, PageAnimations.fade(const CurriculumHomePage()));
                      return;
                    }
                    if (item.title == features[2].title) {
                      NavigationHistory.instance.onNavigate('ClassInfoScreen');
                      Navigator.push(
                        context,
                        PageAnimations.fade(ClassInfoScreen(type: 'regist', title: features[2].title)),
                      );
                      return;
                    }
                    if (item.title == features[3].title) {
                      NavigationHistory.instance.onNavigate('RecordInfoScreen');
                      Navigator.push(
                        context,
                        PageAnimations.fade(RecordInfoScreen(type: 'test', title: features[3].title)),
                      );
                      return;
                    }
                  },
                  child: Card(
                    elevation: 3,
                    color: Theme.of(context).primaryColor.withOpacity(0.85),
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

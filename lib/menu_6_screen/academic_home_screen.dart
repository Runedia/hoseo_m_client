import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';
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
                      GoRouterHistory.instance.pushWithHistory(context, '/academic/schedule');
                      return;
                    }
                    if (item.title == features[1].title) {
                      GoRouterHistory.instance.pushWithHistory(context, '/academic/curriculum');
                      return;
                    }
                    if (item.title == features[2].title) {
                      GoRouterHistory.instance.pushWithHistory(context, '/academic/class?type=regist&title=${features[2].title}');
                      return;
                    }
                    if (item.title == features[3].title) {
                      GoRouterHistory.instance.pushWithHistory(context, '/academic/record?type=test&title=${features[3].title}');
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

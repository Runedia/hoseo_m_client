import 'package:flutter/material.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';
import 'package:hoseo_m_client/vo/FeatureItem.dart';

class CurriculumHomePage extends StatelessWidget {
  const CurriculumHomePage({super.key});

  final List<FeatureItem> features = const [
    FeatureItem('교육과정', Icons.school),
    FeatureItem('부전공 안내', Icons.menu_book),
    FeatureItem('복수전공 안내', Icons.import_contacts),
  ];

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '교육과정 정보',
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
                    // 교육과정 상세 페이지로 이동
                    String type = '';
                    switch (item.title) {
                      case '교육과정':
                        type = 'basic';
                        break;
                      case '부전공 안내':
                        type = 'minor';
                        break;
                      case '복수전공 안내':
                        type = 'double';
                        break;
                    }

                    GoRouterHistory.instance.pushWithHistory(
                      context,
                      '/academic/curriculum/$type?title=${Uri.encodeComponent(item.title)}',
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

import 'package:flutter/material.dart';
import 'package:hoseo_m_client/menu_5_screen/campus_map_detail_screen.dart';
import 'package:hoseo_m_client/utils/animations/page_transitions.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';

class CampusMapPage extends StatelessWidget {
  const CampusMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '캠퍼스맵',
      body: Padding(padding: const EdgeInsets.all(16.0), child: _buildCampusButtons(context)),
    );
  }

  Widget _buildCampusButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _campusButton(context, '아산캠퍼스', 'asan', Icons.location_city),
        const SizedBox(height: 20),
        _campusButton(context, '천안캠퍼스', 'cheonan', Icons.school),
      ],
    );
  }

  Widget _campusButton(BuildContext context, String label, String code, IconData icon) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
      ),
      onPressed: () {
        // 네비게이션 히스토리에 추가
        NavigationHistory.instance.onNavigate('CampusMapDetailScreen');

        // PageAnimations를 사용하여 이동
        Navigator.push(context, PageAnimations.fade(CampusMapDetailScreen(campusName: label, campusCode: code)));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

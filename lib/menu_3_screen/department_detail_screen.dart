import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/utils/app_state.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';

class DepartmentDetailScreen extends StatelessWidget {
  const DepartmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AppState에서 현재 학과 정보 가져오기
    if (!AppState.hasCurrentDepartment()) {
      return const CommonScaffold(title: '학과 상세정보', body: Center(child: Text('학과 정보를 찾을 수 없습니다.')));
    }

    final departmentInfo = AppState.currentDepartmentInfo!;
    final primaryColor = Theme.of(context).primaryColor;

    final name = departmentInfo['name'] ?? '';
    final college = departmentInfo['college'] ?? '';
    final type = departmentInfo['type'] ?? '';
    final description = departmentInfo['description'] ?? '';
    final phone = departmentInfo['phone'];
    final email = departmentInfo['email'];
    final location = departmentInfo['location'];
    final localImages = departmentInfo['localImages'] ?? [];
    final localSingleImage = departmentInfo['localSingleImage'];

    return CommonScaffold(
      title: '학과 상세정보',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 학과명 표시
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // 이미지들 표시
            if (localImages.isNotEmpty)
              ...localImages.map<Widget>(
                (file) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(file as File)),
                ),
              ),
            if (localImages.isEmpty && localSingleImage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(localSingleImage as File)),
              ),

            // 정보 박스들
            if (college.isNotEmpty) _infoBox('단과대학: $college', primaryColor),
            if (type.isNotEmpty) _infoBox('구분: $type', primaryColor),
            if (description.isNotEmpty) _infoBox('설명: $description', primaryColor),
            if (phone != null && phone.toString().trim().isNotEmpty) _infoBox('대표번호: $phone', primaryColor),
            if (location != null && location.toString().trim().isNotEmpty) _infoBox('위치: $location', primaryColor),
            if (email != null && email.toString().trim().isNotEmpty) _infoBox('이메일: $email', primaryColor),

            // const SizedBox(height: 24),
            //
            // // 뒤로가기 버튼
            // ElevatedButton(
            //   onPressed: () {
            //     // AppState 클리어하고 뒤로가기
            //     AppState.clearCurrentDepartment();
            //     Navigator.pop(context);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: primaryColor,
            //     padding: const EdgeInsets.symmetric(vertical: 16),
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            //   ),
            //   child: const Text('목록으로 돌아가기', style: TextStyle(color: Colors.white, fontSize: 16)),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String text, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(border: Border.all(color: primaryColor), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}

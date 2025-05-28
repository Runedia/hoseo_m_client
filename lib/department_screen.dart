import 'package:flutter/material.dart';

class DepartmentPage extends StatefulWidget {
  const DepartmentPage({super.key});

  @override
  State<DepartmentPage> createState() => _DepartmentPageState();
}

class _DepartmentPageState extends State<DepartmentPage> {
  final Map<String, List<String>> departments = {
    '인문사회대학': [
      '기독교학과', '한국언어문화학과', '영어영문학과', '중국학과', '법경찰행정학과',
      '사회복지학과', '청소년문화상담학과', '유아교육과', '항공서비스학과', '산업심리학과',
      '미디어커뮤니케이션학과'
    ],
    '경영대학': ['글로벌통상학과', '경영학부', '디지털금융경영학과', '디지털기술경영학과'],
    '생명보건대학': [
      '식품공학과', '제약공학과', '화장품과학과', '생명공학과', '화장품생명공학부',
      '식품영양학과', '물리치료학과', '임상병리학과', '동물보건복지학과'
    ],
    '공과대학': [
      '전기공학과', '시스템제어공학과', '기계공학과', '미래자동차공학과', '화학공학과',
      '안전공학과', '소방방재학과', '건축학과(5년제)', '건축토목공학부', '환경공학과',
      '정보통신공학부', '자동차 ICT공학과', '신소재공학과', '전자재료공학과'
    ],
    'AI융합대학': [
      '빅데이터AI학부', '컴퓨터공학부', '게임소프트웨어학과',
      '지능로봇학과', '전자공학과', '반도체 공학과'
    ],
    '예체능대학': [
      '사회체육학과', '골프산업학과', '디자인스쿨(2025학년도 신입생 기준)',
      '시각디자인학과', '산업디자인학과', '디지털프로덕트디자인학과',
      '실내디자인학과', '문화영상학부', '애니메이션학과', '공연예술학부'
    ],
    '미래융합대학': [
      '사회복지상담학과', '스마트경영학과', '산업안전공학과', '기계반도체공학과',
      '안전공학과(신입 모집중지, 편입모집)', '기계ICT공학과(신입 모집중지, 편입모집)'
    ],
    '더:함교양대학': ['창의교양학부', '혁신융합학부'],
    '융합학부': ['교수소개', '연계전공', '융합트랙', '마이크로디그리', 'DSC 공유대학', '융합전공'],
    '국제학부': ['학부소개', '학사학위', '전공트랙', '교수소개'],
  };

  String? expandedCollege;
  String? selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학과정보', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFBE1924),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: selectedDepartment == null
            ? _buildCollegeList()
            : _buildDepartmentDetail(),
      ),
    );
  }

  Widget _buildCollegeList() {
    return ListView(
      children: departments.entries.map((entry) {
        final college = entry.key;
        final deptList = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBE1924),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                setState(() {
                  expandedCollege = expandedCollege == college ? null : college;
                });
              },
              child: Text(college, style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 4),
            if (expandedCollege == college)
              ...deptList.map((department) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBE1924)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedDepartment = department;
                    });
                  },
                  child: Text(department,
                      style: const TextStyle(color: Colors.black)),
                ),
              )),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDepartmentDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFBE1924)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: Text(selectedDepartment ?? '',
              style: const TextStyle(color: Colors.black)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFBE1924)),
          ),
          child: const Center(child: Text('학과 대표 이미지')),
        ),
        _infoBox('위치 | 대표번호'),
        _infoBox('학과 설명'),
        _infoBox('기타 이어지는 설명...'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedDepartment = null;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBE1924),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          child: const Text('뒤로가기', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _infoBox(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBE1924)),
      ),
      child: Text(text),
    );
  }
}

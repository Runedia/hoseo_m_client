import 'package:flutter/material.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  String? selectedCafeteria;
  Map<String, String>? selectedNotice;

  final noticesData = {
    '교직원회관 식당': [
      {'title': '4월 5주 주간식단표', 'author': '총무팀', 'date': '2025-04-28'},
      {'title': '4월 4주 주간식단표', 'author': '총무팀', 'date': '2025-04-21'},
      {'title': '4월 3주 주간식단표', 'author': '총무팀', 'date': '2025-04-14'},
      {'title': '4월 2주 주간식단표', 'author': '총무팀', 'date': '2025-04-07'},
      {'title': '4월 1주 주간식단표', 'author': '총무팀', 'date': '2025-03-31'},
    ],
    '행복기숙사 식당': [
      {'title': '행복 5주 식단표', 'author': '총무팀', 'date': '2025-04-28'},
      {'title': '행복 4주 식단표', 'author': '총무팀', 'date': '2025-04-21'},
      {'title': '행복 3주 식단표', 'author': '총무팀', 'date': '2025-04-14'},
      {'title': '행복 2주 식단표', 'author': '총무팀', 'date': '2025-04-07'},
      {'title': '행복 1주 식단표', 'author': '총무팀', 'date': '2025-03-31'},
    ],
    '후생관(생활관 식당)': [
      {'title': '후생 5주 식단표', 'author': '총무팀', 'date': '2025-04-28'},
      {'title': '후생 4주 식단표', 'author': '총무팀', 'date': '2025-04-21'},
      {'title': '후생 3주 식단표', 'author': '총무팀', 'date': '2025-04-14'},
      {'title': '후생 2주 식단표', 'author': '총무팀', 'date': '2025-04-07'},
      {'title': '후생 1주 식단표', 'author': '총무팀', 'date': '2025-03-31'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교내식당 식단표', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFBE1924), // ✅ 앱바 색 수정
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: selectedCafeteria == null
            ? _buildCafeteriaSelection()
            : selectedNotice == null
            ? _buildNoticeList()
            : _buildNoticeDetail(),
      ),
    );
  }

  Widget _buildCafeteriaSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: noticesData.keys.map((cafeteria) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBE1924),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => setState(() => selectedCafeteria = cafeteria),
            child: Text(cafeteria, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoticeList() {
    final notices = noticesData[selectedCafeteria!]!.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleButton(selectedCafeteria!),
        const SizedBox(height: 16),
        Table(
          border: TableBorder.all(),
          columnWidths: const {
            0: FixedColumnWidth(40),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(70),
            3: FixedColumnWidth(90)
          },
          children: [
            _headerRow(),
            ...notices.asMap().entries.map((entry) {
              final idx = entry.key;
              final notice = entry.value;
              return TableRow(
                children: [
                  _cell('${idx + 1}'),
                  InkWell(
                    onTap: () => setState(() => selectedNotice = notice),
                    child: _cell(notice['title']!),
                  ),
                  _cell(notice['author']!),
                  _cell(notice['date']!),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 20),
        _backButton(() => setState(() => selectedCafeteria = null)),
      ],
    );
  }

  Widget _buildNoticeDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleButton(selectedCafeteria!),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFBE1924)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(selectedNotice!['title']!, style: const TextStyle(fontSize: 14)),
              Text('${selectedNotice!['author']} / ${selectedNotice!['date']}',
                  style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFBE1924)),
            ),
            child: const Text('식단표 내용', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(height: 20),
        _backButton(() => setState(() => selectedNotice = null)),
      ],
    );
  }

  TableRow _headerRow() {
    const style = TextStyle(fontSize: 14, color: Colors.white);
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFBE1924)),
      children: ['번호', '제목', '작성자', '등록일자'].map((text) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(text, textAlign: TextAlign.center, style: style),
        );
      }).toList(),
    );
  }

  Widget _cell(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text, style: const TextStyle(fontSize: 14)),
  );

  Widget _titleButton(String title) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFBE1924),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    onPressed: () {},
    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
  );

  Widget _backButton(VoidCallback onTap) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFBE1924),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    child: const Text('뒤로가기', style: TextStyle(color: Colors.white, fontSize: 14)),
  );
}

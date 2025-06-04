import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';

class ShuttleSelectScreen extends StatefulWidget {
  const ShuttleSelectScreen({super.key});

  @override
  State<ShuttleSelectScreen> createState() => _ShuttleSelectScreenState();
}

class _ShuttleSelectScreenState extends State<ShuttleSelectScreen> {
  String _selectedRoute = '아산 → 천안';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 히스토리에 현재 페이지 추가 안함 (메인에서 이미 추가됨)
  }

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _goToShuttleScreen() {
    final isAsanToCheonan = _selectedRoute == '아산 → 천안';
    final dateStr = _selectedDate.toIso8601String();
    GoRouterHistory.instance.pushWithHistory(context, '/shuttle/detail?date=$dateStr&isAsan=$isAsanToCheonan');
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '셔틀 노선 및 날짜 선택',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('노선 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedRoute,
              items: const [
                DropdownMenuItem(value: '아산 → 천안', child: Text('아산캠퍼스 → 천안캠퍼스')),
                DropdownMenuItem(value: '천안 → 아산', child: Text('천안캠퍼스 → 아산캠퍼스')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedRoute = value;
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            const Text('날짜 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToShuttleScreen,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: const Text('셔틀 시간표 보기', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'shuttle_screen.dart';

class ShuttleSelectScreen extends StatefulWidget {
  const ShuttleSelectScreen({super.key});

  @override
  State<ShuttleSelectScreen> createState() => _ShuttleSelectScreenState();
}

class _ShuttleSelectScreenState extends State<ShuttleSelectScreen> {
  String _selectedRoute = '아산 → 천안';
  DateTime _selectedDate = DateTime.now();

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShuttleScreen(
          route: _selectedRoute,
          date: _selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('셔틀 노선 및 날짜 선택'),
        centerTitle: true,
      ),
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
                  backgroundColor: Colors.red,
                ),
                child: const Text('셔틀 시간표 보기', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

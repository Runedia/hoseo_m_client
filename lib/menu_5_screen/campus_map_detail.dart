import 'dart:io';
import 'package:flutter/material.dart';

class CampusMapDetail extends StatelessWidget {
  final String campusName;
  final String? campusImagePath;
  final List<String> buildingList;

  const CampusMapDetail({
    super.key,
    required this.campusName,
    required this.campusImagePath,
    required this.buildingList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 12),
              Text(campusName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor)),
          child:
              campusImagePath != null
                  ? GestureDetector(
                    onTap: () => _showFullScreenImage(context),
                    child: Image.file(File(campusImagePath!), fit: BoxFit.contain),
                  )
                  : const Center(child: Text('이미지를 불러오는 중...')),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children:
              buildingList
                  .map((building) => SizedBox(width: 160, child: Text(building, style: const TextStyle(fontSize: 14))))
                  .toList(),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context) {
    if (campusImagePath == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: Text(campusName, style: const TextStyle(color: Colors.white)),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.file(
                    File(campusImagePath!),
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                height: 60,
                color: Colors.black87,
                child: const Center(
                  child: Text('핑치하여 확대/축소 가능', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ),
            ),
      ),
    );
  }
}

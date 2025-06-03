import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notice;
  final List<String> imageUrls;
  final String cafeteriaName;

  const MealDetailScreen({super.key, required this.notice, required this.imageUrls, required this.cafeteriaName});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: '교내식당 식단표',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _titleButton(cafeteriaName, context),
            const SizedBox(height: 16),
            _borderBox(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notice['title'], style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '${notice['author']} / ${notice['create_dt'].substring(0, 10)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _borderBox(
                context,
                ListView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    final url = imageUrls[index];
                    final fileName = url.split('/').last;

                    return FutureBuilder<File>(
                      future: getImageFile(url, fileName),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final imageFile = snapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          FullScreenImageViewer(imageFile: imageFile, title: notice['title'] ?? ''),
                                ),
                              );
                            },
                            child: Image.file(imageFile),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _borderBox(BuildContext context, Widget child) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor)),
    child: child,
  );

  Widget _titleButton(String title, BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    onPressed: () {},
    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
  );
}

// 전체 화면 이미지 뷰어
class FullScreenImageViewer extends StatelessWidget {
  final File imageFile;
  final String title;

  const FullScreenImageViewer({super.key, required this.imageFile, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16), overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.file(
            imageFile,
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.black87,
        child: const Center(child: Text('확대/축소 가능', style: TextStyle(color: Colors.white70, fontSize: 14))),
      ),
    );
  }
}

Future<File> getImageFile(String url, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  final online = await isOnline();
  if (online && !(await file.exists())) {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
    }
  }
  return file;
}

Future<bool> isOnline() async {
  final connectivity = await Connectivity().checkConnectivity();
  return connectivity != ConnectivityResult.none;
}

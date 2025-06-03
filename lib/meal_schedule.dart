import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Color getPrimaryColor(BuildContext context) {
  final themeColor = Theme.of(context).primaryColor;
  return themeColor != null && themeColor != Colors.transparent
      ? themeColor
      : const Color(0xFFBE1924);
}

void main() {
  runApp(const MaterialApp(
    home: MealPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class MealPage extends StatefulWidget {
  const MealPage({super.key});
  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  String? selectedCafeteria;
  Map<String, dynamic>? selectedNotice;
  List<Map<String, dynamic>> noticeList = [];
  String? selectedNoticeContent;
  List<String> imageUrls = [];

  final cafeteriaActions = {
    '종합정보관 식당': 'MAPP_2312012408',
    '행복기숙사 식당': 'HAPPY_DORM_NUTRITION',
    '교직원회관 식당': 'MAPP_2312012409',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('교내식당 식단표', style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
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

  String fixImagePaths(String html, String basePath) {
    final baseUrl = 'http://rukeras.com:3000/$basePath';
    return html.replaceAllMapped(RegExp(r'src="([^"]+)"'), (match) {
      final filename = match.group(1)!;
      if (filename.startsWith('http')) return match.group(0)!;
      return 'src="$baseUrl/${Uri.encodeComponent(filename)}"';
    });
  }

  Future<void> fetchMenus(String action) async {
    final file = await _localFile('$action.json');
    final online = await isOnline();

    if (online) {
      final url = Uri.parse('http://rukeras.com:3000/menu/list?page=1&pageSize=10&action=$action');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final List data = body is List ? body : body['data'];
        noticeList = List<Map<String, dynamic>>.from(data);

        await file.writeAsString(json.encode(noticeList));

        for (var notice in noticeList) {
          final chidx = notice['chidx'];
          final detailFile = await _localFile('$action-$chidx.json');
          final detailUrl = Uri.parse('http://rukeras.com:3000/menu/idx/$chidx/$action');
          final detailRes = await http.get(detailUrl);
          if (detailRes.statusCode == 200) {
            await detailFile.writeAsString(detailRes.body);

            final detail = json.decode(detailRes.body);
            final List<dynamic>? attachmentsRaw = detail['attachments'];
            final List<dynamic>? assetsRaw = detail['assets'];
            final List<dynamic> effectiveAttachments =
            (attachmentsRaw == null || attachmentsRaw.isEmpty)
                ? (assetsRaw ?? [])
                : attachmentsRaw;

            for (var att in effectiveAttachments) {
              final fileName = (att['fileName'] ?? att['file_name'] ?? '')
                  .toString()
                  .toLowerCase();
              if (fileName.endsWith('.png') ||
                  fileName.endsWith('.jpg') ||
                  fileName.endsWith('.jpeg')) {
                final url = 'http://rukeras.com:3000/${att['localPath']}';
                final imageFile = File(
                    '${(await getApplicationDocumentsDirectory()).path}/${Uri.parse(url).pathSegments.last}');
                if (!(await imageFile.exists())) {
                  final imgRes = await http.get(Uri.parse(url));
                  if (imgRes.statusCode == 200) {
                    await imageFile.writeAsBytes(imgRes.bodyBytes);
                  }
                }
              }
            }
          }
        }

        setState(() {});
        return;
      }
    }

    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        noticeList = List<Map<String, dynamic>>.from(json.decode(content));
      });
    }
  }


  Future<void> fetchDetail(String chidx, String action) async {
    final file = await _localFile('$action-$chidx.json');
    final online = await isOnline();
    if (online) {
      final url = Uri.parse('http://rukeras.com:3000/menu/idx/$chidx/$action');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        await file.writeAsString(res.body);
        final detail = json.decode(res.body);
        return setDetail(detail);
      }
    }
    if (await file.exists()) {
      final content = await file.readAsString();
      final detail = json.decode(content);
      return setDetail(detail);
    }
  }

  void setDetail(Map<String, dynamic> detail) async {
    final List<dynamic>? attachmentsRaw = detail['attachments'];
    final List<dynamic>? assetsRaw = detail['assets'];
    final List<dynamic> effectiveAttachments =
    (attachmentsRaw == null || attachmentsRaw.isEmpty)
        ? (assetsRaw ?? [])
        : attachmentsRaw;

    imageUrls = effectiveAttachments
        .where((att) {
      final fileName = (att['fileName'] ?? att['file_name'] ?? '')
          .toString()
          .toLowerCase();
      return fileName.endsWith('.png') ||
          fileName.endsWith('.jpg') ||
          fileName.endsWith('.jpeg');
    })
        .map((att) => 'http://rukeras.com:3000/${att['localPath']}')
        .toList();

    final contentPath = detail['content'];
    final basePath = contentPath.contains('happy_dorm')
        ? 'download_happy_dorm/${detail['chidx']}'
        : contentPath.substring(0, contentPath.lastIndexOf('/'));
    final contentUrl = Uri.parse('http://rukeras.com:3000/$contentPath');
    final res = await http.get(contentUrl);
    final fixedHtml =
    res.statusCode == 200 ? fixImagePaths(res.body, basePath) : '';

    setState(() {
      selectedNotice = detail;
      selectedNoticeContent = fixedHtml;
    });
  }

  Future<File> _localFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  Widget _buildCafeteriaSelection() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: cafeteriaActions.keys.map((cafeteria) => _styledButton(
      text: cafeteria,
      onPressed: () async {
        final action = cafeteriaActions[cafeteria]!;
        setState(() {
          selectedCafeteria = cafeteria;
          selectedNotice = null;
          selectedNoticeContent = null;
          noticeList = [];
        });
        await fetchMenus(action);
      },
    )).toList(),
  );

  Widget _buildNoticeList() => Column(
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
          3: FixedColumnWidth(90),
        },
        children: [
          _headerRow(),
          ...noticeList.asMap().entries.map((entry) {
            final idx = entry.key;
            final notice = entry.value;
            return TableRow(children: [
              _cell('${idx + 1}'),
              InkWell(
                onTap: () => fetchDetail(notice['chidx'], cafeteriaActions[selectedCafeteria!]!),
                child: _cell(notice['title']),
              ),
              _cell(notice['author']),
              _cell(notice['create_dt'].substring(0, 10)),
            ]);
          })
        ],
      ),
      const SizedBox(height: 20),
      _backButton(() => setState(() => selectedCafeteria = null)),
    ],
  );

  Widget _buildNoticeDetail() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _titleButton(selectedCafeteria!),
      const SizedBox(height: 16),
      _borderBox(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(selectedNotice!['title'], style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('${selectedNotice!['author']} / ${selectedNotice!['create_dt'].substring(0, 10)}',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      Expanded(
        child: _borderBox(
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
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              panEnabled: true,
                              minScale: 1,
                              maxScale: 5,
                              child: Image.file(imageFile),
                            ),
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
      const SizedBox(height: 20),
      _backButton(() => setState(() => selectedNotice = null)),
    ],
  );

  Widget _styledButton({required String text, required VoidCallback onPressed}) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: getPrimaryColor(context),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    ),
  );

  Widget _borderBox(Widget child) => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(border: Border.all(color: getPrimaryColor(context))),
    child: child,
  );

  TableRow _headerRow() => TableRow(
    decoration: BoxDecoration(color: getPrimaryColor(context)),
    children: ['번호', '제목', '작성자', '등록일자']
        .map((text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.white)),
    ))
        .toList(),
  );

  Widget _cell(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(text, style: const TextStyle(fontSize: 14)),
  );

  Widget _titleButton(String title) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: getPrimaryColor(context),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    onPressed: () {},
    child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
  );

  Widget _backButton(VoidCallback onTap) => ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: getPrimaryColor(context),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
    child: const Text('뒤로가기', style: TextStyle(color: Colors.white, fontSize: 14)),
  );
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
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

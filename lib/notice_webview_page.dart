import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NoticeWebViewPage extends StatefulWidget {
  final String title;
  final String url;
  final String? userAgent;

  const NoticeWebViewPage({
    super.key,
    required this.title,
    required this.url,
    this.userAgent,
  });

  @override
  State<NoticeWebViewPage> createState() => _NoticeWebViewPageState();
}

class _NoticeWebViewPageState extends State<NoticeWebViewPage> {
  late final WebViewController _controller;
  bool _isPageLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(widget.userAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (!_isPageLoaded) {
              setState(() => _isPageLoaded = true);
              await _controller.runJavaScript('''
                var style = document.createElement('style');
                style.innerHTML = `
                  body {
                    margin: 0;
                    padding: 10px;
                    font-size: 14px;
                    line-height: 1.6;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                    text-align: left;
                  }
                  img {
                    display: block !important;
                    margin-left: auto !important;
                    margin-right: auto !important;
                    max-width: 100% !important;
                    height: auto !important;
                  }
                  table {
                    width: 100% !important;
                    table-layout: fixed;
                    border-collapse: collapse;
                  }
                  table td, table th {
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                    padding: 8px;
                    font-size: 13px;
                  }
                `;
                document.head.appendChild(style);
              ''');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFFBE1924),
      ),
      body: WebViewWidget(controller: _controller),
    );

  }
}

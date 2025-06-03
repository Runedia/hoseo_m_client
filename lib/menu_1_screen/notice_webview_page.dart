import 'package:flutter/material.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NoticeWebViewPage extends StatelessWidget {
  final String title;
  final String url;

  const NoticeWebViewPage({super.key, required this.title, required this.url});

  @override
  Widget build(BuildContext context) {
    final WebViewController controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url));

    return CommonScaffold(title: title, body: WebViewWidget(controller: controller));
  }
}

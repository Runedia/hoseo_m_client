import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NoticeWebViewControls {
  /// WebView 초기화
  static Future<WebViewController?> initializeWebView(
    String url, {
    required Function(double) onProgress,
    required Function(String) onPageStarted,
    required Function(String) onPageFinished,
    required Function(WebResourceError) onError,
  }) async {
    try {
      final controller = WebViewController();
      controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      controller.setBackgroundColor(Colors.white);

      controller.setUserAgent(
        'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
      );

      controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) => onProgress(progress / 100.0),
          onPageStarted: onPageStarted,
          onPageFinished: onPageFinished,
          onWebResourceError: onError,
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

      await controller.loadRequest(Uri.parse(url));
      return controller;
    } catch (e) {
      print('WebView 초기화 실패: $e');
      return null;
    }
  }

  /// 페이지 크기 조정 JavaScript
  static Future<void> adjustPageSize(WebViewController controller) async {
    try {
      await controller.runJavaScript('''
        var viewport = document.querySelector('meta[name="viewport"]');
        if (!viewport) {
          viewport = document.createElement('meta');
          viewport.name = 'viewport';
          document.head.appendChild(viewport);
        }
        viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes';
        
        var style = document.createElement('style');
        style.innerHTML = `
          body {
            margin: 0;
            padding: 10px;
            font-size: 14px;
            line-height: 1.4;
            word-wrap: break-word;
            overflow-wrap: break-word;
          }
          
          img {
            max-width: 100% !important;
            height: auto !important;
            display: block;
            margin: 0 auto;
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
          
          dl, dd {
            margin: 0;
            padding: 5px;
          }
          
          .both {
            width: 100%;
            overflow: hidden;
          }
          
          * {
            max-width: 100%;
            box-sizing: border-box;
          }
        `;
        document.head.appendChild(style);
        
        var images = document.querySelectorAll('img');
        var imagePromises = Array.from(images).map(function(img) {
          return new Promise(function(resolve) {
            if (img.complete) {
              resolve();
            } else {
              img.onload = resolve;
              img.onerror = resolve;
            }
          });
        });
        
        Promise.all(imagePromises).then(function() {
          window.scrollTo(0, 0);
        });
      ''');
    } catch (e) {
      print('페이지 크기 조정 실패: $e');
    }
  }

  /// 오류 페이지 위젯
  static Widget buildErrorPage({required String errorMessage, required VoidCallback onRetry}) {
    return Builder(
      builder:
          (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                const Text('오류가 발생했습니다'),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ),
                ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
              ],
            ),
          ),
    );
  }

  /// 초기화 중 페이지 위젯
  static Widget buildInitializingPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CircularProgressIndicator(), SizedBox(height: 16), Text('WebView 초기화 중...')],
      ),
    );
  }
}

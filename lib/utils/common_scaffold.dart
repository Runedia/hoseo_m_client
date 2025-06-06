import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';

class CommonScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final FloatingActionButton? floatingActionButton;

  const CommonScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.floatingActionButton,
  });

  // "이전" 이동 - GoRouterHistory 사용
  static void _navigateBack(BuildContext context) {
    GoRouterHistory.instance.navigateBack(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading:
            showBackButton
                ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => _navigateBack(context))
                : null,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: const CommonBottomNavigation(),
    );
  }
}

class CommonBottomNavigation extends StatelessWidget {
  const CommonBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.3), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            context,
            icon: Icons.arrow_back,
            label: '이전',
            onTap: () => CommonScaffold._navigateBack(context),
          ),
          _buildNavButton(
            context,
            icon: Icons.home,
            label: '홈',
            onTap: () => GoRouterHistory.instance.navigateHome(context),
          ),
          _buildNavButton(context, icon: Icons.arrow_forward, label: '다음', onTap: () => _navigateForward(context)),
        ],
      ),
    );
  }

  // "다음" 이동 - GoRouterHistory 사용
  void _navigateForward(BuildContext context) {
    if (GoRouterHistory.instance.canGoForward()) {
      GoRouterHistory.instance.navigateForward(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('다음 페이지가 없습니다.'), duration: Duration(seconds: 2)));
    }
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black.withAlpha(180),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(48, 48),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }
}

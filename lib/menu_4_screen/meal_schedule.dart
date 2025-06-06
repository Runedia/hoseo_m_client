import 'package:flutter/material.dart';
import 'package:hoseo_m_client/utils/common_scaffold.dart';
import 'package:hoseo_m_client/utils/go_router_history.dart';

class MealPage extends StatefulWidget {
  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final cafeteriaActions = {
    '종합정보관 식당': 'MAPP_2312012408',
    '행복기숙사 식당': 'HAPPY_DORM_NUTRITION',
    '교직원회관 식당': 'MAPP_2312012409',
  };

  @override
  Widget build(BuildContext context) => CommonScaffold(
    title: '교내식당 식단표',
    body: Padding(padding: const EdgeInsets.all(16), child: _buildCafeteriaSelection()),
  );

  Widget _buildCafeteriaSelection() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children:
        cafeteriaActions.keys
            .map(
              (cafeteria) => _styledButton(
                text: cafeteria,
                onPressed: () {
                  final action = cafeteriaActions[cafeteria]!;
                  GoRouterHistory.instance.pushWithHistory(
                    context,
                    '/meal/list?cafeteriaName=$cafeteria&action=$action',
                  );
                },
              ),
            )
            .toList(),
  );

  Widget _styledButton({required String text, required VoidCallback onPressed}) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    ),
  );
}

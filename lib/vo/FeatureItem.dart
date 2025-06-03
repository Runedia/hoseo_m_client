import 'package:flutter/material.dart';

class FeatureItem {
  final String title;
  final IconData icon;
  final Widget? page;

  const FeatureItem(this.title, this.icon, [this.page]);

  String get getTitle => title;

  IconData get getIcon => icon;

  Widget? get getPage => page;
}

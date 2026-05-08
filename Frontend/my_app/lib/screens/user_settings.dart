import 'package:flutter/material.dart';
import 'app_theme.dart';

class UserSettings extends StatelessWidget {
  final Map<String, dynamic> userData;
  final AppColors colors;
  final void Function(Map<String, dynamic>)? onUserDataChanged;

  const UserSettings({
    super.key,
    required this.userData,
    required this.colors,
    this.onUserDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(color: colors.pageBg);
  }
}
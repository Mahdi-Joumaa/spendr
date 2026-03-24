import 'package:flutter/material.dart';
import '../utils/theme.dart';

class SpendrAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  const SpendrAppBar({
    Key? key,
    required this.title,
    this.onMenuTap,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu, color: AppColors.primary),
        onPressed: onMenuTap ?? () {},
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
          onPressed: onNotificationTap ?? () {},
        ),
      ],
    );
  }
}
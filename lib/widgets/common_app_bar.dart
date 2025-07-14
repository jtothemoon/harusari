import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// 앱 전체에서 사용되는 공통 AppBar 위젯
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;

  const CommonAppBar({
    super.key,
    required this.title,
    this.centerTitle = false, // 기본값을 false로 변경 (왼쪽 정렬)
    this.actions,
    this.leading,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppColors.getTextPrimaryColor(context),
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: AppColors.getBackgroundColor(context),
      surfaceTintColor: Colors.transparent,
      actions: actions,
      leading: leading,
      systemOverlayStyle: Theme.of(context).brightness == Brightness.light
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

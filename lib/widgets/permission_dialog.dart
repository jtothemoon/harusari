import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 사용자가 외부를 탭해도 닫히지 않음
      builder: (context) => const PermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.getCardBackgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.priorityMedium.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: AppColors.priorityMedium,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '알림 권한 요청',
              style: TextStyle(
                color: AppColors.getTextPrimaryColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '하루살이가 더 나은 서비스를 제공하기 위해 알림 권한이 필요합니다.',
            style: TextStyle(
              color: AppColors.getTextPrimaryColor(context),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.priorityLow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: AppColors.priorityLow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '하루 시작 알림',
                      style: TextStyle(
                        color: AppColors.getTextPrimaryColor(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '설정한 시간에 새로운 하루 시작을 알려드립니다',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '나중에 설정에서 변경할 수 있습니다.',
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.getTextSecondaryColor(context),
          ),
          child: const Text('나중에'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.priorityMedium,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('허용'),
        ),
      ],
    );
  }
}

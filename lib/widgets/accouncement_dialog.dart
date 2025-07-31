import 'package:flutter/material.dart';
import 'package:harutodo/models/announcement.dart';
import 'package:harutodo/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccouncementDialog extends StatefulWidget {
  final Announcement announcement;

  const AccouncementDialog({super.key, required this.announcement});

  static const String _viewAnnoucementsKey = 'view_announcements';

  static Future<void> _setViewed(int announcementId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedIds = prefs.getStringList(_viewAnnoucementsKey) ?? [];
    if (!viewedIds.contains(announcementId.toString())) {
      viewedIds.add(announcementId.toString());
    }
    await prefs.setStringList(_viewAnnoucementsKey, viewedIds);
  }

  static Future<bool> _isViewed(int announcementId) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedIds = prefs.getStringList(_viewAnnoucementsKey) ?? [];
    return viewedIds.contains(announcementId.toString());
  }

  static Future<void> show(
    BuildContext context,
    Announcement announcement,
  ) async {
    if (await _isViewed(announcement.id)) return;

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (context) => AccouncementDialog(announcement: announcement),
      );
    }
  }

  @override
  State<AccouncementDialog> createState() => _AccouncementDialogState();
}

class _AccouncementDialogState extends State<AccouncementDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.getBackgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Text(widget.announcement.title,
        style: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.getTextPrimaryColor(context),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      content: SingleChildScrollView(
        child: Text(
          widget.announcement.content,
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.getTextPrimaryColor(context),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Checkbox(
              value: _dontShowAgain,
              onChanged: (value) {
                setState(() {
                  _dontShowAgain = value ?? false;
                });
              },
            ),
            Text(
              '다시 보지 않기',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.getTextSecondaryColor(context),
                fontSize: 14,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (_dontShowAgain) {
                  await AccouncementDialog._setViewed(widget.announcement.id);
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.priorityLow,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                '확인',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../providers/settings_provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/feedback_dialog.dart';
import '../clients/discord_webhook.dart';
import '../services/notification_service.dart';
import '../services/onboarding_service.dart';
import '../router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _dayStartTime = const TimeOfDay(hour: 6, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadDayStartTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDayStartTime();
  }

  Future<void> _loadDayStartTime() async {
    final settingsProvider = context.read<SettingsProvider>();
    final startTime = settingsProvider.dayStartTime;
    setState(() {
      _dayStartTime = startTime;
    });
  }

  Future<PackageInfo> _loadPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dayStartTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dayStartTime) {
      setState(() {
        _dayStartTime = picked;
      });

      if (!mounted) return;

      final settingsProvider = context.read<SettingsProvider>();
      final todoProvider = context.read<TodoProvider>();

      // 설정 저장
      await settingsProvider.setDayStartTime(picked);

      if (!mounted) return;

      // TodoProvider의 타이머도 업데이트
      await todoProvider.updateDayTransitionTimer(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '하루 시작 시간이 변경되었습니다',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.priorityLow,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          // 앱 버전 표시
          FutureBuilder<PackageInfo>(
            future: _loadPackageInfo(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'v${snapshot.data!.version}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 하루 시작 시간 설정
          Container(
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '하루 시작 시간',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '설정한 시간이 되면 이전 날의 미완료 할 일이 자동으로 삭제됩니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(_dayStartTime),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Icon(
                            LucideIcons.clock,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 알림 설정
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.getShadowColor(context),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '알림 설정',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 푸시 알림 설정
                      Row(
                        children: [
                          Icon(
                            LucideIcons.bell,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '푸시 알림',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '하루 시작 시 알림을 받습니다',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.getTextSecondaryColor(
                                          context,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: settingsProvider.isNotificationEnabled,
                            onChanged: (value) async {
                              if (value) {
                                // 알림 켜기 - 권한 요청
                                final hasPermission =
                                    await NotificationService()
                                        .requestPermissions();
                                if (hasPermission) {
                                  await settingsProvider.setNotificationEnabled(
                                    true,
                                  );
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '알림 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: AppColors.error,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                // 알림 끄기
                                await settingsProvider.setNotificationEnabled(
                                  false,
                                );
                              }
                            },
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 진동 설정
                      Row(
                        children: [
                          Icon(
                            LucideIcons.smartphone,
                            color: settingsProvider.isNotificationEnabled
                                ? AppColors.primary
                                : AppColors.getTextSecondaryColor(context),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '진동',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color:
                                            settingsProvider
                                                .isNotificationEnabled
                                            ? AppColors.getTextPrimaryColor(
                                                context,
                                              )
                                            : AppColors.getTextSecondaryColor(
                                                context,
                                              ),
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '알림과 함께 진동을 받습니다',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.getTextSecondaryColor(
                                          context,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: settingsProvider.isVibrationEnabled,
                            onChanged: settingsProvider.isNotificationEnabled
                                ? (value) async {
                                    await settingsProvider.setVibrationEnabled(
                                      value,
                                    );
                                  }
                                : null,
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // 고객 문의/제안
          Container(
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '고객 지원',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _showFeedbackDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.mail,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '문의 및 제안',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '개선사항이나 문제점을 알려주세요',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.getTextSecondaryColor(
                                          context,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            color: AppColors.getTextSecondaryColor(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 온보딩 다시 보기
          Container(
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '앱 도움말',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _showOnboardingAgain,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.helpCircle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '온보딩 다시 보기',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '앱 사용법을 다시 확인해보세요',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.getTextSecondaryColor(
                                          context,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            color: AppColors.getTextSecondaryColor(context),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 앱 정보
          Container(
            decoration: BoxDecoration(
              color: AppColors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getShadowColor(context),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.info,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '앱 정보',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<PackageInfo>(
                    future: _loadPackageInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final packageInfo = snapshot.data!;
                        return Column(
                          children: [
                            _buildInfoRow('앱 이름', packageInfo.appName),
                            _buildInfoRow('버전', packageInfo.version),
                            _buildInfoRow('개발자', '설이아빠'),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          children: [
                            _buildInfoRow('앱 이름', '하루살이'),
                            _buildInfoRow('버전', '알 수 없음'),
                            _buildInfoRow('개발자', '설이아빠'),
                          ],
                        );
                      } else {
                        return const Column(
                          children: [
                            Center(child: CircularProgressIndicator()),
                            SizedBox(height: 16),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1-3-5 법칙으로 하루에 집중하는 할 일 관리 앱',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showOnboardingAgain() async {
    // 온보딩 상태 초기화
    await OnboardingService.resetOnboarding();

    if (mounted) {
      // 온보딩 화면으로 이동
      context.go(Routes.onboarding);
    }
  }

  Future<void> _showFeedbackDialog() async {
    final feedback = await FeedbackDialog.show(context);
    if (feedback == null) {
      return;
    }

    // 마지막 사용자로부터 받은 메시지를 디스코드로 전송
    // 1. 타이틀: 문의 카테고리, 앱 이름, 앱 버전
    final packageInfo = await _loadPackageInfo();
    final title =
        '${feedback['category']} :: ${packageInfo.appName} :: v${packageInfo.version}';
    // 2. 메시지: 문의 내용 + 기기 정보 + 이메일
    final deviceInfo =
        '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    String message = '💬 ${feedback['message']}';
    message +=
        '\n\n✉️ ${feedback['email']!.isNotEmpty ? feedback['email'] : '제공하지 않음'}';
    message += '\n\n📱 $deviceInfo';
    // 3. 우선순위: 문의 카테고리에 따라 스위치 문으로 우선순위 지정
    final priority = switch (feedback['category']) {
      '기능제안' => Priority.medium,
      '버그 신고' => Priority.high,
      _ => Priority.low,
    };
    // 4. 메시지 전송
    DiscordWebhookClient().sendMessage(
      title: title,
      message: message,
      priority: priority,
    );

    // 스낵바를 올려서 전송이 성공했다는 것을 알려준다.
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('문의가 성공적으로 전송되었습니다.')));
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? '오전' : '오후';

    return '$period $hour:$minute';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Flexible(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

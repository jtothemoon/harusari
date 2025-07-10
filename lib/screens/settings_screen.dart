import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_colors.dart';
import '../providers/todo_provider.dart';
import '../widgets/feedback_dialog.dart';
import '../clients/discord_webhook.dart';

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
    final todoProvider = context.read<TodoProvider>();
    final startTime = todoProvider.getCurrentDayStartTime();
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

      final todoProvider = context.read<TodoProvider>();
      await todoProvider.setDayStartTime(picked);

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
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 하루 시작 시간 설정
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '하루 시작 시간',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '설정한 시간이 되면 이전 날의 미완료 할 일이 자동으로 삭제됩니다.',
                    style: Theme.of(context).textTheme.bodySmall,
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
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(_dayStartTime),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Icon(
                            Icons.access_time,
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
          // 고객 문의/제안
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('고객 지원', style: Theme.of(context).textTheme.titleLarge),
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
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mail_outline,
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '개선사항이나 문제점을 알려주세요',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.textSecondary,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('앱 정보', style: Theme.of(context).textTheme.titleLarge),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('문의가 성공적으로 전송되었습니다.')));
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

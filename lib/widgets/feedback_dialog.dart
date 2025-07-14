import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  static Future<Map<String, String>?> show(BuildContext context) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const FeedbackDialog(),
    );
  }

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _currentStep = 0;
  String _category = '기능 제안';
  String? _messageError;
  String? _emailError;
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  // 타이틀 가져오기
  String _getTitle() {
    switch (_currentStep) {
      case 0:
        return '문의 유형';
      case 1:
        return '내용 입력';
      case 2:
        return '이메일 주소(선택 사항)';
      default:
        return '';
    }
  }

  // 카테고리별 placeholder 텍스트 가져오기
  String _getPlaceholderText() {
    switch (_category) {
      case '기능 제안':
        return '예시) 공지사항이나 알림 같은게 있으면 좋겠어요요.';
      case '버그 신고':
        return '예시) 특정 상황시 앱이 멈춥니다.';
      case '기타 문의':
        return '예시) 앱 사용 방법이 궁금해요.';
      default:
        return '문의 내용을 자세히 적어주세요.';
    }
  }

  // 컨텐츠 가져오기
  Widget _buildContent() {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStepContent();
      case 1:
        return _buildMessageStepContent();
      case 2:
        return _buildEmailStepContent();
      default:
        return const SizedBox();
    }
  }

  Widget _buildCategoryStepContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCategoryTile(
          icon: LucideIcons.lightbulb,
          iconColor: AppColors.priorityMedium,
          title: '기능 제안',
          subtitle: '원하는 기능을 말씀해주세요.',
          category: '기능 제안',
        ),
        const SizedBox(height: 8),
        _buildCategoryTile(
          icon: LucideIcons.bug,
          iconColor: AppColors.priorityHigh,
          title: '버그 신고',
          subtitle: '불편한 점을 말씀해주세요.',
          category: '버그 신고',
        ),
        const SizedBox(height: 8),
        _buildCategoryTile(
          icon: LucideIcons.helpCircle,
          iconColor: AppColors.priorityLow,
          title: '기타 문의',
          subtitle: '궁금한 점을 말씀해주세요.',
          category: '기타 문의',
        ),
      ],
    );
  }

  Widget _buildCategoryTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String category,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getTextSecondaryColor(
            context,
          ).withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.getTextSecondaryColor(context),
          ),
        ),
        onTap: () {
          setState(() {
            _category = category;
            _currentStep++;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildMessageStepContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _messageController,
          autofocus: true,
          maxLength: 300,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.getTextPrimaryColor(context),
          ),
          decoration: InputDecoration(
            hintText: _getPlaceholderText(),
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.getTextSecondaryColor(context),
            ),
            errorText: _messageError,
            filled: true,
            fillColor: AppColors.getCardBackgroundColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.getTextSecondaryColor(
                  context,
                ).withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.getTextSecondaryColor(
                  context,
                ).withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.priorityMedium, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStepContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _emailController,
          autofocus: true,
          maxLength: 100,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.getTextPrimaryColor(context),
          ),
          decoration: InputDecoration(
            hintText: 'example@email.com',
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.getTextSecondaryColor(context),
            ),
            errorText: _emailError,
            filled: true,
            fillColor: AppColors.getCardBackgroundColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.getTextSecondaryColor(
                  context,
                ).withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.getTextSecondaryColor(
                  context,
                ).withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.priorityMedium, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.priorityLow.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.info, size: 16, color: AppColors.priorityLow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '답변을 받으시려면 이메일 주소를 입력해주세요. 이메일 주소는 답변 용도 외에 사용되지 않습니다.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.getTextSecondaryColor(context),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 액션 가져오기
  List<Widget> _buildActions() {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStepActions();
      case 1:
        return _buildMessageStepActions();
      case 2:
        return _buildEmailStepActions();
      default:
        return [];
    }
  }

  List<Widget> _buildCategoryStepActions() {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.getTextSecondaryColor(context),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          '닫기',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
        ),
      ),
    ];
  }

  List<Widget> _buildMessageStepActions() {
    return [
      TextButton(
        onPressed: () => setState(() {
          _currentStep--;
        }),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.getTextSecondaryColor(context),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          '이전',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {
          final message = _messageController.text.trim();
          if (message.length < 5) {
            setState(() {
              _messageError = '5자 이상 입력해주세요.';
            });
            return;
          }
          setState(() {
            _messageError = null;
            _currentStep++;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.priorityMedium,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          '다음',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }

  List<Widget> _buildEmailStepActions() {
    return [
      TextButton(
        onPressed: () => setState(() {
          _currentStep--;
        }),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.getTextSecondaryColor(context),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          '이전',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () {
          final email = _emailController.text.trim();
          if (email.isNotEmpty && !email.contains('@')) {
            setState(() {
              _emailError = '올바른 이메일 주소를 입력해주세요.';
            });
            return;
          }
          Navigator.pop(context, {
            'category': _category,
            'message': _messageController.text.trim(),
            'email': _emailController.text.trim(),
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.priorityLow,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: Text(
          '제출',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.getBackgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Text(
        _getTitle(),
        style: TextStyle(
          fontFamily: 'Inter',
          color: AppColors.getTextPrimaryColor(context),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }
}

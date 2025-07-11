import 'package:flutter/material.dart';
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
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.lightbulb_outline,
            color: AppColors.priorityMedium,
          ),
          title: const Text('기능 제안'),
          subtitle: const Text('원하는 기능을 말씀해주세요.'),
          onTap: () {
            setState(() {
              _category = '기능 제안';
              _currentStep++;
            });
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.bug_report_outlined,
            color: AppColors.priorityHigh,
          ),
          title: const Text('버그 신고'),
          subtitle: const Text('불편한 점을 말씀해주세요.'),
          onTap: () {
            setState(() {
              _category = '버그 신고';
              _currentStep++;
            });
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(
            Icons.question_mark_outlined,
            color: AppColors.priorityLow,
          ),
          title: const Text('기타 문의'),
          subtitle: const Text('궁금한 점을 말씀해주세요.'),
          onTap: () {
            setState(() {
              _category = '기타 문의';
              _currentStep++;
            });
          },
        ),
      ],
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
          decoration: InputDecoration(
            hintText: '예시) 할 일 완료 시 알림음이 들렸으면 좋겠어요.',
            hintStyle: TextStyle(
              color: AppColors.getTextSecondaryColor(context),
            ),
            errorText: _messageError,
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
          decoration: InputDecoration(
            hintText: 'example@email.com',
            hintStyle: TextStyle(
              color: AppColors.getTextSecondaryColor(context),
            ),
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '답변을 받으시려면 이메일 주소를 입력해주세요. 이메일 주소는 답변 용도 외에 사용되지 않습니다.',
          style: TextStyle(
            color: AppColors.getTextSecondaryColor(context),
            fontSize: 12,
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
        child: const Text('닫기'),
      ),
    ];
  }

  List<Widget> _buildMessageStepActions() {
    return [
      TextButton(
        onPressed: () => setState(() {
          _currentStep--;
        }),
        child: const Text('이전'),
      ),
      TextButton(
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
        child: const Text('다음'),
      ),
    ];
  }

  List<Widget> _buildEmailStepActions() {
    return [
      TextButton(
        onPressed: () => setState(() {
          _currentStep--;
        }),
        child: const Text('이전'),
      ),
      TextButton(
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
        child: const Text('제출'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.getCardBackgroundColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        _getTitle(),
        style: TextStyle(
          color: AppColors.getTextPrimaryColor(context),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }
}

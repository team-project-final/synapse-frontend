import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:synapse_frontend/core/theme/app_colors.dart';
import 'package:synapse_frontend/core/theme/app_spacing.dart';

/// AI 생성/응답 대기 중 표시하는 챗봇 로띠 로더.
///
/// 카드 생성·Q&A 의 로딩 상태에서 실제 백엔드 응답을 기다리는 동안 재생된다.
/// [speed] 로 재생 속도를 조절한다(1.0 = 원본, 1.5 = 1.5배 빠름).
class AiThinkingLoader extends StatefulWidget {
  const AiThinkingLoader({
    this.message = '생각하는 중…',
    this.size = 88,
    this.speed = 1.5,
    super.key,
  });

  final String message;
  final double size;
  final double speed;

  @override
  State<AiThinkingLoader> createState() => _AiThinkingLoaderState();
}

class _AiThinkingLoaderState extends State<AiThinkingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/lottie/chatbot_loading.json',
          controller: _controller,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            // 원본 길이를 speed 로 나눠 재생 속도를 높인 뒤 반복.
            _controller
              ..duration = composition.duration * (1 / widget.speed)
              ..repeat();
          },
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          widget.message,
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

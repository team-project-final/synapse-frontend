part of '../home_board_section.dart';

// ── 타일 chrome (흰 카드 · border · 헤더 + content) ───────────────────────────

/// 모든 타일을 감싸는 tutor 카드 chrome. 헤더(이모지/orb + 라벨) + content.
class _BoardTile extends StatelessWidget {
  const _BoardTile({required this.spec});

  final _BoardSpec spec;

  void _go(BuildContext context, String route) => context.go(route);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Widget header = Row(
      children: <Widget>[
        if (spec.kind == _BoardKind.ask)
          const SynapseOrb(size: 22, glyphScale: 0.5)
        else
          Text(spec.emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: AppSpacing.sm),
        Text(
          spec.label,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    final Widget body = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          header,
          const SizedBox(height: AppSpacing.sm + 4),
          _content(context),
        ],
      ),
    );

    return body;
  }

  Widget _content(BuildContext context) {
    switch (spec.kind) {
      case _BoardKind.ask:
        return _AskContent(onTap: () => _go(context, AppRoutes.qa));
      case _BoardKind.todayReview:
        return _TodayReviewContent(onTap: () => _go(context, AppRoutes.review));
      case _BoardKind.suggest:
        return _SuggestContent(onTap: () => _go(context, AppRoutes.review));
      case _BoardKind.insight:
        return _InsightContent(
          onTap: () => _go(context, AppRoutes.dashboardStats),
        );
      case _BoardKind.streak:
        return _StreakContent(onTap: () => _go(context, AppRoutes.review));
      case _BoardKind.level:
        return const _LevelContent();
      case _BoardKind.graph:
        return _GraphContent(onTap: () => _go(context, AppRoutes.graph));
      case _BoardKind.recentChat:
        return _RecentChatContent(onTap: () => _go(context, AppRoutes.qa));
      case _BoardKind.recentNotes:
        return _RecentNotesContent(onTap: () => _go(context, AppRoutes.notes));
      case _BoardKind.onboarding:
        return const OnboardingChecklist();
      case _BoardKind.ranking:
        return _RankingContent(
          onTap: () => _go(context, AppRoutes.communityGroups),
        );
    }
  }
}

// ── 타일 content: AI 질문 (greeting + _AskBox 변형) ──────────────────────────

class _AskContent extends StatelessWidget {
  const _AskContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '무엇을 학습해 볼까요?',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        // _AskBox 질문 바.
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.primary, width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      '질문하거나, 노트를 붙여넣거나, 주제를 입력하세요…',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.mic_none,
                        color: AppColors.muted,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.muted,
                        size: 20,
                      ),
                      const Spacer(),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: AppColors.primaryFg,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 타일 content: 오늘 복습 (그라데이션 강조 + 시작 버튼) ──────────────────────

class _TodayReviewContent extends StatelessWidget {
  const _TodayReviewContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$_kReviewCardCount장',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '복습 대기 12 · 학습 중 4 · 새 카드 2',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('시작하기', style: TextStyle(fontSize: 12.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 타일 content: AI 추천 (_SuggestCard 변형) ────────────────────────────────

class _SuggestContent extends StatelessWidget {
  const _SuggestContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm - 1),
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
            alignment: Alignment.center,
            child: const Text('🩺', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '\'과적합\' 개념이 약해 보여요',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '최근 3번 중 2번 틀렸어요. 관련 노트 3개로 미니 퀴즈를 만들어 드릴까요?',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.sm + 1),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm - 3),
                    ),
                  ),
                  child: const Text(
                    '퀴즈 시작 →',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 타일 content: 이번 주 인사이트 (_InsightStat 3개) ────────────────────────

class _InsightContent extends StatelessWidget {
  const _InsightContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Row(
          children: <Widget>[
            Expanded(
              child: _InsightStat(
                value: '$_kWeeklyReviews',
                label: '복습',
                color: AppColors.text,
              ),
            ),
            SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: _InsightStat(
                value: '$_kWeeklyAccuracy%',
                label: '정답률',
                color: AppColors.success,
              ),
            ),
            SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: _InsightStat(
                value: '+$_kWeeklyXp',
                label: 'XP',
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('통계 더보기', style: TextStyle(fontSize: 12.5)),
          ),
        ),
      ],
    );
  }
}

/// tutor 대시보드의 _InsightStat 변형 (값/라벨/색).
class _InsightStat extends StatelessWidget {
  const _InsightStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md - 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 타일 content: 스트릭 ──────────────────────────────────────────────────────

class _StreakContent extends StatelessWidget {
  const _StreakContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '$_kStreakDays일',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.streak,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '최고 $_kStreakBest일',
            style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

// ── 타일 content: 레벨 (진행 바) ─────────────────────────────────────────────

class _LevelContent extends StatelessWidget {
  const _LevelContent();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '지식 탐험가',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: const LinearProgressIndicator(
            value: 0.9,
            minHeight: 8,
            backgroundColor: AppColors.surface2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Lv8까지 360 XP',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );
  }
}

// ── 타일 content: 지식 그래프 (mini graph painter) ──────────────────────────

class _GraphContent extends StatelessWidget {
  const _GraphContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: const SizedBox(
        height: 150,
        width: double.infinity,
        child: CustomPaint(painter: _MiniGraphPainter()),
      ),
    );
  }
}

// ── 타일 content: 최근 AI 대화 (_RecentChatCard 변형) ────────────────────────

class _RecentChatContent extends StatelessWidget {
  const _RecentChatContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const SynapseOrb(size: 32, glyphScale: 0.47),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'AI 튜터',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '● 답변 완료',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const _ChatBubble(text: '트랜스포머 노트로 복습 카드 만들어줘', isMe: true),
        const SizedBox(height: AppSpacing.sm),
        const _ChatBubble(
          text: '「트랜스포머」 노트에서 핵심 4장을 만들었어요. 추가할 카드를 골라주세요 👇',
          isMe: false,
        ),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('대화 이어가기', style: TextStyle(fontSize: 12.5)),
          ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.text, required this.isMe});

  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md - 2,
            vertical: AppSpacing.sm + 3,
          ),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primary : AppColors.bg,
            border: isMe ? null : Border.all(color: AppColors.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppRadius.lg),
              topRight: const Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(isMe ? AppRadius.lg : 5),
              bottomRight: Radius.circular(isMe ? 5 : AppRadius.lg),
            ),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isMe ? AppColors.primaryFg : AppColors.text,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ── 타일 content: 최근 노트 (compact rows) ───────────────────────────────────

class _RecentNotesContent extends StatelessWidget {
  const _RecentNotesContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        for (int i = 0; i < _kMockNotes.length; i++)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.sm - 4),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                border: i < _kMockNotes.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.border))
                    : null,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.description_outlined,
                    size: 17,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _kMockNotes[i].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _kMockNotes[i].timeAgo,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── 타일 content: 그룹 랭킹 (순위 rows) ──────────────────────────────────────

class _RankingContent extends StatelessWidget {
  const _RankingContent({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: <Widget>[
        for (final _RankRow row in _kRanking)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.sm - 4),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              decoration: BoxDecoration(
                color: row.highlight
                    ? AppColors.accent.withValues(alpha: 0.10)
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.sm - 4),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${row.rank}',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: row.highlight
                            ? AppColors.accent
                            : AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      row.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: row.highlight
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  Text(
                    '+${row.xp}',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: row.highlight ? AppColors.accent : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

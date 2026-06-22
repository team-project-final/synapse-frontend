import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:synapse_frontend/services/learning/features/cards/providers/learning_review_providers.dart';
import 'package:synapse_frontend/services/platform/features/tenant/data/tenant_api.dart';

import 'fake_learning_review_api.dart';

void main() {
  test(
    'ReviewNotifier completes session after all queued cards are rated',
    () async {
      final api = FakeLearningReviewApi();
      final container = ProviderContainer(
        overrides: [
          learningReviewApiProvider.overrideWithValue(api),
          currentTenantProvider.overrideWith(
            (ref) async => const CurrentTenant(
              id: 'tenant-1',
              name: 'Synapse',
              plan: 'FREE',
              status: 'ACTIVE',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(reviewNotifierProvider.notifier);

      await notifier.start();
      expect(container.read(reviewNotifierProvider).cards.length, 2);
      expect(
        container.read(reviewNotifierProvider).currentCard?.frontContent,
        '스택이란?',
      );

      final firstCompleted = await notifier.submitRating(3, timeSpentMs: 1000);
      expect(firstCompleted, isFalse);
      expect(
        container.read(reviewNotifierProvider).currentCard?.frontContent,
        '큐란?',
      );

      final secondCompleted = await notifier.submitRating(4, timeSpentMs: 900);
      final state = container.read(reviewNotifierProvider);

      expect(secondCompleted, isTrue);
      expect(state.isCompleted, isTrue);
      expect(state.reviewedCards, 2);
      expect(state.accuracy, 1);
      expect(api.submittedRatings, [3, 4]);
    },
  );
}

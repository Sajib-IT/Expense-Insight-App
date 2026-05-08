import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:expense_insight/app/data/models/ai_extract_model.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/features/ai_extract/widgets/ai_review_dialog.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('AI review dialog shows editable popup overview', (WidgetTester tester) async {
    final categories = [
      CategoryModel(
        id: 'food',
        name: 'Food',
        type: TransactionType.EXPENSE,
        icon: '🍔',
        colour: '#EF4444',
        isDefault: true,
        userId: 'user-1',
        createdAt: DateTime(2026, 5, 8),
        updatedAt: DateTime(2026, 5, 8),
      ),
    ];

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: AiReviewDialog(
            data: AiExtractModel(
              amount: 12.5,
              description: 'Lunch at cafe',
              date: '2026-05-08',
              type: 'EXPENSE',
              category: 'Food',
              merchant: 'Cafe',
              confidence: 0.92,
            ),
            categories: categories,
            isSaving: false.obs,
            onConfirm: (_) async {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Confirm & Save'), findsOneWidget);
    expect(find.text('Review, edit, and confirm before saving.'), findsOneWidget);
    expect(find.text('🍔 Food'), findsOneWidget);
    expect(find.text('92% confidence'), findsOneWidget);
    expect(find.text('Cafe'), findsOneWidget);
  });

  testWidgets('AI review dialog validates category selection before confirm', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: AiReviewDialog(
            data: AiExtractModel(
              amount: 25,
              description: 'Freelance payment',
              date: '2026-05-08',
              type: 'INCOME',
              category: 'Salary',
            ),
            categories: const [],
            isSaving: false.obs,
            onConfirm: (_) async {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Confirm & Save'));
    await tester.pump();

    expect(find.text('No categories available for this type yet. Please create one first.'), findsOneWidget);
    expect(find.text('Please select a category'), findsOneWidget);
  });
}

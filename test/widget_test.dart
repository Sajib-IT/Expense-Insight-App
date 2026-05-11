import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:expense_insight/app/data/models/ai_extract_model.dart';
import 'package:expense_insight/app/data/models/category_model.dart';
import 'package:expense_insight/app/data/network/dio_client.dart';
import 'package:expense_insight/features/ai_extract/widgets/ai_review_dialog.dart';
import 'package:expense_insight/features/category/controllers/category_controller.dart';
import 'package:expense_insight/features/expense/controllers/expense_controller.dart';
import 'package:expense_insight/features/expense/views/add_expense_screen.dart';

class TestExpenseController extends ExpenseController {
  @override
  Future<void> fetchExpenses({bool loadMore = false, bool isRefresh = false}) async {}
}

class TestCategoryController extends CategoryController {
  @override
  Future<void> fetchCategories({String? type}) async {}

  @override
  Future<CategoryModel?> createQuickCategory({
    required String name,
    required TransactionType type,
    required String icon,
    required String colour,
  }) async {
    final category = CategoryModel(
      id: name.toLowerCase(),
      name: name,
      type: type,
      icon: icon,
      colour: colour,
      isDefault: false,
      userId: 'user-1',
      createdAt: DateTime(2026, 5, 8),
      updatedAt: DateTime(2026, 5, 8),
    );

    categories.add(category);
    if (type == TransactionType.EXPENSE) {
      expenseCategories.add(category);
    } else {
      incomeCategories.add(category);
    }

    return category;
  }
}

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
            onCreateCategory: ({
              required String name,
              required TransactionType type,
              required String icon,
              required String colour,
            }) async => null,
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
    expect(find.text('Create Category'), findsOneWidget);
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
            onCreateCategory: ({
              required String name,
              required TransactionType type,
              required String icon,
              required String colour,
            }) async => null,
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

  testWidgets('AI review dialog can create and select a category instantly', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: AiReviewDialog(
            data: AiExtractModel(
              amount: 15,
              description: 'Snacks at store',
              date: '2026-05-08',
              type: 'EXPENSE',
              category: 'Snacks',
            ),
            categories: const [],
            isSaving: false.obs,
            onConfirm: (_) async {},
            onCreateCategory: ({
              required String name,
              required TransactionType type,
              required String icon,
              required String colour,
            }) async => CategoryModel(
              id: 'snacks',
              name: name,
              type: type,
              icon: icon,
              colour: colour,
              isDefault: false,
              userId: 'user-1',
              createdAt: DateTime(2026, 5, 8),
              updatedAt: DateTime(2026, 5, 8),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Create Category'));
    await tester.tap(find.widgetWithText(TextButton, 'Create Category'));
    await tester.pumpAndSettle();

    expect(find.text('Create category instantly'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'Snacks');
    await tester.ensureVisible(find.text('Create Now'));
    await tester.tap(find.text('Create Now'));
    await tester.pumpAndSettle();

    expect(find.text('📦 Snacks'), findsOneWidget);
  });

  testWidgets('manual transaction screen can create and auto-select a category instantly', (WidgetTester tester) async {
    Get.put(DioClient(), permanent: true);
    Get.put<ExpenseController>(TestExpenseController(), permanent: true);
    Get.put<CategoryController>(TestCategoryController(), permanent: true);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: AddExpenseScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(TextButton, 'Create Category'));
    await tester.tap(find.widgetWithText(TextButton, 'Create Category'));
    await tester.pumpAndSettle();

    expect(find.text('Create category instantly'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'Snacks');
    await tester.ensureVisible(find.text('Create Now'));
    await tester.tap(find.text('Create Now'));
    await tester.pumpAndSettle();

    final chip = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '📦 Snacks'));
    expect(chip.selected, isTrue);
  });
}

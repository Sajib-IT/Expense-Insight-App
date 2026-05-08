import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:expense_insight/app/data/models/ai_extract_model.dart';
import 'package:expense_insight/app/data/network/dio_client.dart';
import 'package:expense_insight/features/ai_extract/controllers/ai_extract_controller.dart';
import 'package:expense_insight/features/ai_extract/views/ai_extract_screen.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(Get.reset);

  testWidgets('AI extract screen shows editable overview entry point', (WidgetTester tester) async {
    Get.put(DioClient(), permanent: true);
    final controller = Get.put(AiExtractController());
    controller.extractedData.value = AiExtractModel(
      amount: 12.5,
      description: 'Lunch at cafe',
      date: '2026-05-08',
      type: 'EXPENSE',
      category: 'Food',
      merchant: 'Cafe',
      confidence: 0.92,
    );

    await tester.pumpWidget(
      const GetMaterialApp(
        home: AiExtractScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('AI Extract'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Review & Confirm'), findsOneWidget);
    expect(find.text('Nothing is saved yet. Review these values, edit if needed, then confirm on the next step.'), findsOneWidget);
  });
}

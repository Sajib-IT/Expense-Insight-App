import 'package:get/get.dart';
import 'package:expense_insight/features/ai_extract/controllers/ai_extract_controller.dart';

class AiExtractBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiExtractController>(() => AiExtractController());
  }
}


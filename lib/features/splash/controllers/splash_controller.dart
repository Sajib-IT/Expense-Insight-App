import 'package:get/get.dart';
import 'package:expense_insight/app/routes/app_pages.dart';
import 'package:expense_insight/app/data/services/storage_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));

    final storageService = Get.find<StorageService>();
    final token = await storageService.getToken();

    if (token != null && token.isNotEmpty) {
      Get.offAllNamed(Routes.home);
    } else {
      Get.offAllNamed(Routes.login);
    }
  }
}


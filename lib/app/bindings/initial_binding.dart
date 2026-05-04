import 'package:get/get.dart';
import 'package:expense_insight/app/data/network/dio_client.dart';
import 'package:expense_insight/app/data/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<DioClient>(DioClient(), permanent: true);
  }
}


import 'package:expense_insight/app/data/network/dio_client.dart';
import 'package:get/get.dart';

/// Base repository class that all feature repositories should extend.
/// Provides access to the DioClient for API calls.
abstract class BaseRepository {
  final DioClient dioClient = Get.find<DioClient>();
}


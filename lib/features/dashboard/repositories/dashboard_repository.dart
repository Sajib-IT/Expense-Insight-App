import 'package:expense_insight/app/data/network/api_endpoints.dart';
import 'package:expense_insight/app/data/repositories/base_repository.dart';

class DashboardRepository extends BaseRepository {
  Future<Map<String, dynamic>> getDashboard({int? month, int? year}) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();

    final response = await dioClient.get(
      ApiEndpoints.dashboard,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return response.data;
  }
}


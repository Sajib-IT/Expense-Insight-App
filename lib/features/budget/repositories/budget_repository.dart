import 'package:expense_insight/app/data/network/api_endpoints.dart';
import 'package:expense_insight/app/data/repositories/base_repository.dart';

class BudgetRepository extends BaseRepository {
  Future<Map<String, dynamic>> getBudgets({int? month, int? year}) async {
    final queryParams = <String, dynamic>{};
    if (month != null) queryParams['month'] = month.toString();
    if (year != null) queryParams['year'] = year.toString();

    final response = await dioClient.get(
      ApiEndpoints.budgets,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getBudgetById(String id) async {
    final response = await dioClient.get(ApiEndpoints.budgetById(id));
    return response.data;
  }

  Future<Map<String, dynamic>> createBudget({
    required double amount,
    required int month,
    required int year,
    required String categoryId,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.budgets,
      data: {
        'amount': amount,
        'month': month,
        'year': year,
        'categoryId': categoryId,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateBudget(String id, {required double amount}) async {
    final response = await dioClient.patch(
      ApiEndpoints.budgetById(id),
      data: {'amount': amount},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteBudget(String id) async {
    final response = await dioClient.delete(ApiEndpoints.budgetById(id));
    return response.data;
  }
}


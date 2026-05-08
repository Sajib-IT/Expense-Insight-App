import 'package:dio/dio.dart' as dio;
import 'package:expense_insight/app/data/network/api_endpoints.dart';
import 'package:expense_insight/app/data/repositories/base_repository.dart';

class ExpenseRepository extends BaseRepository {
  Future<Map<String, dynamic>> getExpenses({
    int page = 1,
    int limit = 10,
    String sortBy = 'date',
    String sortOrder = 'desc',
    String? type,
    String? categoryId,
    String? startDate,
    String? endDate,
    String? searchTerm,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
    if (type != null) queryParams['type'] = type;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (searchTerm != null && searchTerm.isNotEmpty) {
      queryParams['searchTerm'] = searchTerm;
    }

    final response = await dioClient.get(
      ApiEndpoints.expenses,
      queryParameters: queryParams,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getExpenseById(String id) async {
    final response = await dioClient.get(ApiEndpoints.expenseById(id));
    return response.data;
  }

  Future<Map<String, dynamic>> createExpense({
    required double amount,
    String? description,
    required String date,
    String type = 'EXPENSE',
    required String categoryId,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.expenses,
      data: {
        'amount': amount,
        'description': description,
        'date': date,
        'type': type,
        'categoryId': categoryId,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateExpense(
    String id, {
    double? amount,
    String? description,
    String? date,
    String? type,
    String? categoryId,
  }) async {
    final data = <String, dynamic>{};
    if (amount != null) data['amount'] = amount;
    if (description != null) data['description'] = description;
    if (date != null) data['date'] = date;
    if (type != null) data['type'] = type;
    if (categoryId != null) data['categoryId'] = categoryId;

    final response = await dioClient.patch(
      ApiEndpoints.expenseById(id),
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteExpense(String id) async {
    final response = await dioClient.delete(ApiEndpoints.expenseById(id));
    return response.data;
  }

  /// Upload receipt image/PDF for an expense
  Future<Map<String, dynamic>> uploadReceipt(String expenseId, String filePath) async {
    final formData = dio.FormData.fromMap({
      'receipt': await dio.MultipartFile.fromFile(filePath),
    });
    final response = await dioClient.post(
      ApiEndpoints.expenseReceipt(expenseId),
      data: formData,
      options: dio.Options(contentType: 'multipart/form-data'),
    );
    return response.data;
  }
}




import 'package:expense_insight/app/data/network/api_endpoints.dart';
import 'package:expense_insight/app/data/repositories/base_repository.dart';

class CategoryRepository extends BaseRepository {
  Future<Map<String, dynamic>> getCategories({String? type}) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;

    final response = await dioClient.get(
      ApiEndpoints.categories,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getCategoryById(String id) async {
    final response = await dioClient.get(ApiEndpoints.categoryById(id));
    return response.data;
  }

  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String type,
    String? icon,
    String? colour,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'type': type,
    };
    if (icon != null) data['icon'] = icon;
    if (colour != null) data['colour'] = colour;

    final response = await dioClient.post(
      ApiEndpoints.categories,
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> updateCategory(
    String id, {
    String? name,
    String? type,
    String? icon,
    String? colour,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (type != null) data['type'] = type;
    if (icon != null) data['icon'] = icon;
    if (colour != null) data['colour'] = colour;

    final response = await dioClient.patch(
      ApiEndpoints.categoryById(id),
      data: data,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> deleteCategory(String id) async {
    final response = await dioClient.delete(ApiEndpoints.categoryById(id));
    return response.data;
  }
}


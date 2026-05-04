import 'package:expense_insight/app/data/network/api_endpoints.dart';
import 'package:expense_insight/app/data/repositories/base_repository.dart';

class AuthRepository extends BaseRepository {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await dioClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await dioClient.post(
      ApiEndpoints.register,
      data: data,
    );
    return response.data;
  }

  Future<void> logout() async {
    await dioClient.post(ApiEndpoints.logout);
  }
}


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

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await dioClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.resetPassword,
      data: {'token': token, 'password': password},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await dioClient.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await dioClient.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );
    return response.data;
  }
}

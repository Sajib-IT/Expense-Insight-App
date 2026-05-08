import 'package:dio/dio.dart' as dio;
import 'package:expense_insight/app/data/network/api_endpoints.dart';
import 'package:expense_insight/app/data/repositories/base_repository.dart';

class UserRepository extends BaseRepository {
  Future<Map<String, dynamic>> getProfile() async {
    final response = await dioClient.get(ApiEndpoints.profile);
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? avatar,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (avatar != null) data['avatar'] = avatar;

    final response = await dioClient.patch(
      ApiEndpoints.profile,
      data: data,
    );
    return response.data;
  }

  /// Upload profile picture (first time)
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    final formData = dio.FormData.fromMap({
      'avatar': await dio.MultipartFile.fromFile(filePath),
    });
    final response = await dioClient.post(
      ApiEndpoints.profileAvatar,
      data: formData,
      options: dio.Options(contentType: 'multipart/form-data'),
    );
    return response.data;
  }

  /// Update profile picture (replace existing)
  Future<Map<String, dynamic>> updateAvatar(String filePath) async {
    final formData = dio.FormData.fromMap({
      'avatar': await dio.MultipartFile.fromFile(filePath),
    });
    final response = await dioClient.patch(
      ApiEndpoints.profileAvatar,
      data: formData,
      options: dio.Options(contentType: 'multipart/form-data'),
    );
    return response.data;
  }

  /// Delete profile picture
  Future<Map<String, dynamic>> deleteAvatar() async {
    final response = await dioClient.delete(ApiEndpoints.profileAvatar);
    return response.data;
  }
}



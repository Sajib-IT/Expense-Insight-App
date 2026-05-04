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
}


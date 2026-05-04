import 'package:dio/dio.dart' as dio;
import 'package:expense_insight/app/data/network/api_endpoints.dart';
import 'package:expense_insight/app/data/repositories/base_repository.dart';

class AiExtractRepository extends BaseRepository {
  Future<Map<String, dynamic>> extractFromReceipt(String filePath) async {
    final formData = dio.FormData.fromMap({
      'receipt': await dio.MultipartFile.fromFile(filePath),
    });

    final response = await dioClient.post(
      ApiEndpoints.aiExtractReceipt,
      data: formData,
      options: dio.Options(contentType: 'multipart/form-data'),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> extractFromText(String text) async {
    final response = await dioClient.post(
      ApiEndpoints.aiExtractText,
      data: {'text': text},
    );
    return response.data;
  }
}


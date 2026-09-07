
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Audio fayllarni ImageKit'ga yuklaydi (bepul, 25MB/fayl).
class StorageService {
  static const _privateKey = 'private_pgXifnlwHfSGijLvH4soF2xZWlU=';
  static const _publicKey = 'public_yhjwdPeE2gv4TnfEbcrnRGg0a9U=';

  final _dio = Dio();

  Future<String> uploadAudio({
    required String sectionId,
    required String fileName,
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}';

    final formData = FormData.fromMap({
      'publicKey': _publicKey,
      'fileName': fileName,
      'folder': '/listening_audio/$sectionId',
      'useUniqueFileName': 'false',
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _dio.post(
      'https://upload.imagekit.io/api/v1/files/upload',
      data: formData,
      options: Options(headers: {'Authorization': basicAuth}),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );

    if (response.statusCode != 200) {
      throw Exception('ImageKit upload xatosi: ${response.data}');
    }

    final url = response.data['url'] as String?;
    if (url == null) {
      throw Exception('ImageKit javobida URL topilmadi: ${response.data}');
    }
    return url;
  }

  Future<void> deleteAudio(String audioUrl) async {}
}
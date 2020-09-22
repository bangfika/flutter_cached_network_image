import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class S3CacheManager extends BaseCacheManager {
  static const key = 's3_cache_manager';

  static S3CacheManager _instance;

  factory S3CacheManager() {
    if (_instance == null) {
      _instance = S3CacheManager._();
    }
    return _instance;
  }

  S3CacheManager._()
      : super(
          key,
          fileService: CustomHttpFileService(),
          maxAgeCacheObject: Duration(days: 7),
        );

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }

  Future<File> getSingleS3File(
    String url, {
    Map<String, String> headers,
  }) async {
    final key = _getKeyFromUrl(url);
    return await getSingleFile(url, key: key, headers: headers);
  }

  Stream<FileResponse> getS3FileStream(String url,
      {String key, Map<String, String> headers, bool withProgress}) {
    final key = _getKeyFromUrl(url);
    return getFileStream(
      url,
      key: key,
      headers: headers,
      withProgress: withProgress,
    );
  }

  String _getKeyFromUrl(String url) {
    return p.basename(url).split("?")[0] ?? url;
  }
}

class CustomHttpFileService extends HttpFileService {
  CustomHttpFileService() : super();

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String> headers = const {}}) {
    if (url.startsWith('https')) {
      url = url.replaceFirst('https', 'http');
    }
    return super.get(url, headers: headers);
  }
}

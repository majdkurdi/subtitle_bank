import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

class Downloader {
  Future downloadFile(String url, String filename) async {
    String dir = (await DownloadsPathProvider.downloadsDirectory).path;
    Dio dio = Dio();
    var perStatus = await Permission.storage.isDenied;
    if (perStatus) {
      await Permission.storage.request().then((value) {
        if (value == PermissionStatus.denied) return;
      });
    }
    await dio.download(url, '$dir/$filename.zip');

    print('done!');
  }
}

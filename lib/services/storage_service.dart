import 'dart:io';

import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const _appFolder = 'AI Video Studio Pro';

  static Future<Directory> _projectDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory('${base.path}/Projects');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  static Future<String> createOutputPath(String prefix, String extension) async {
    final directory = await _projectDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return '${directory.path}/${prefix}_$timestamp.$extension';
  }

  static Future<List<FileSystemEntity>> listProjects() async {
    final directory = await _projectDirectory();
    final files = await directory.list().where((entity) => entity is File).toList();
    files.sort((first, second) => second.statSync().modified.compareTo(first.statSync().modified));
    return files;
  }

  static Future<void> saveToGallery(String filePath, {required bool isVideo}) async {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = _appFolder;
    final store = MediaStore();
    final source = File(filePath);
    if (!await source.exists()) throw Exception('The output file does not exist.');
    final temporary = await source.copy('${(await getTemporaryDirectory()).path}/${source.uri.pathSegments.last}');
    try {
      final result = await store.saveFile(
        tempFilePath: temporary.path,
        dirType: isVideo ? DirType.video : DirType.audio,
        dirName: isVideo ? DirName.movies : DirName.music,
      );
      if (result == null) throw Exception('The media file could not be saved to device storage.');
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
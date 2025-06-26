import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

abstract class ShadersUtil {
  static late Directory shadersDirectory;

  static Future<void> copyShadersToExternalDirectory() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = assetManifest.listAssets();
    final directory = await getApplicationSupportDirectory();
    shadersDirectory = Directory(path.join(directory.path, 'anime_shaders'));

    if (!await shadersDirectory.exists()) {
      await shadersDirectory.create(recursive: true);
      log('Create GLSL Shader: ${shadersDirectory.path}');
    }

    final shaderFiles = assets.where(
      (String asset) =>
          asset.startsWith('assets/shaders/') && asset.endsWith('.glsl'),
    );

    int copiedFilesCount = 0;

    for (var filePath in shaderFiles) {
      final fileName = filePath.split('/').last;
      final targetFile = File(path.join(shadersDirectory.path, fileName));
      if (await targetFile.exists()) {
        log('GLSL Shader exists, skip: ${targetFile.path}');
        continue;
      }

      try {
        final data = await rootBundle.load(filePath);
        final List<int> bytes = data.buffer.asUint8List();
        await targetFile.writeAsBytes(bytes);
        copiedFilesCount++;
        log('Copy: ${targetFile.path}');
      } catch (e) {
        log('Copy: ($filePath): $e');
      }
    }

    log('$copiedFilesCount GLSL files copied to ${shadersDirectory.path}');
  }

  static Future<String> getPlayerTempPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  static String buildShadersAbsolutePath(
    String baseDirectory,
    List<String> shaders,
  ) {
    List<String> absolutePaths = shaders.map((shader) {
      return path.join(baseDirectory, shader);
    }).toList();
    if (Platform.isWindows) {
      return absolutePaths.join(';');
    }
    return absolutePaths.join(':');
  }
}

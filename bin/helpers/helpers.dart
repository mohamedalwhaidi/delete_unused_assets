import 'dart:io';

import 'package:path/path.dart' as path;

class Helpers {
  static T callWithStopwatch<T>(
    T Function() function, {
    required Function(int) whenDone,
  }) {
    final sw = Stopwatch()..start();
    final result = function.call();
    whenDone.call(sw.elapsedMilliseconds);

    return result;
  }

  static Map<String, String> getFilesNameWithPath(
    Directory dir,
    Map<String, String> map, {
    List<String> ignoreDirectories = const [],
  }) {
    final list = dir.listSync();
    //return like this {"app_icon.png":"projectPAth/assets/app_icon.png"}
    for (final fileOrDir in list) {
      final isDirectory = fileOrDir is Directory;
      final basename = path.basename(fileOrDir.path);
      if (isDirectory && !ignoreDirectories.contains(basename)) {
        //Stay safe recursion function.
        getFilesNameWithPath(
          fileOrDir,
          map,
          ignoreDirectories: ignoreDirectories,
        );
      }

      if (!isDirectory) {
        map[basename] = fileOrDir.path;
      }
    }

    return map;
  }

  ///change file path EX. assets/images/icon.ong to assets_deleted/images/icon.ong
  static Future<void> deleteFilesByPaths({
    required Iterable<String> paths,
    required String assetFolderName,
    required String deletedAssetFolderName,
  }) async {
    if (paths.isEmpty) return;

    for (final path in paths) {
      await _moveFile(
        path,
        path.replaceFirst(assetFolderName, deletedAssetFolderName),
      );
    }
  }

  static Future<File> _moveFile(String sourcePath, String newPath) async {
    final sourceFile = File(sourcePath);
    try {
      //create Directory if not exist
      await Directory(path.dirname(newPath)).create(recursive: true);

      return await sourceFile.rename(newPath);
    } on FileSystemException catch (_) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();

      return newFile;
    }
  }

  /// try to run a function that may be throws an exception
  /// by default if an exception is thrown null value will be returned
  /// also u have the ability to handle exceptions and return a custom value
  /// Ex.  print(tryDo(() => DateTime.parse('')));
  static T? tryDo<T>(
    T Function()? function, {
    T? whenNull,
    T Function(dynamic exception, StackTrace stacktrace)? orElse,
  }) {
    try {
      return function?.call() ?? whenNull;
    } catch (e, stacktrace) {
      return orElse?.call(e, stacktrace);
    }
  }
}

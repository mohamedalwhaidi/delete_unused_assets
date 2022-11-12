import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;

import 'helpers/console.dart';
import 'helpers/helpers.dart';

void main(List<String> arguments) async {
  if (arguments.firstOrNull == '-h') {
    write(
      'Hi,\nYou Can use me like this\nflutter pub run delete_un_used_assets:start assetsPath',
      colorType: ConsoleColorType.info,
    );
    return;
  }
  try {
    await Helpers.callWithStopwatch(
      () async {
        final flutterProjectPath = Directory.current.path;
        final assetsFolder = arguments.firstOrNull ?? 'assets';

        final assetsFolderPath = '$flutterProjectPath/$assetsFolder';
        final deletedAssetFolderName = 'deleted_$assetsFolderPath';

        write(
          '\nDon\'t worry I\'m not deleting any asset,\nI just moving it to $deletedAssetFolderName\n',
          colorType: ConsoleColorType.info,
        );

        final assetsPath = path.join(flutterProjectPath, assetsFolderPath);

        //Skip searching for asset using in this folders
        final ignoreDirectories = [
          assetsFolderPath,
          deletedAssetFolderName,
          'assets',
          'android',
          'build',
          'ios',
          'web',
          '.dart_tool',
          '.git',
          '.gradle',
        ];

        final assetsFiles = Helpers.callWithStopwatch(
          () => Helpers.getFilesNameWithPath(Directory(assetsPath), {}),
          whenDone: (milliseconds) => write(
            'collect assetsFiles: $milliseconds ms',
          ),
        );

        final projectFiles = Helpers.callWithStopwatch(
          () => Helpers.getFilesNameWithPath(
            Directory(flutterProjectPath),
            {},
            ignoreDirectories: ignoreDirectories,
          ),
          whenDone: (milliseconds) =>
              write('collect projectFiles: $milliseconds ms'),
        );

        final usedAssetsNames = <String>{};
        Helpers.callWithStopwatch(
          () {
            final projectFilesPaths = projectFiles.values;
            for (final path in projectFilesPaths) {
              //if file can't read as string return empty value
              final fileString = Helpers.tryDo(
                    () => File(path).readAsStringSync(),
                    orElse: (__, _) => '',
                  ) ??
                  '';

              final assetsFilesNames = assetsFiles.keys;
              final assetsFilesNamesWithoutAlreadyUsed = assetsFilesNames.where(
                (element) => !usedAssetsNames.contains(element),
              );
              for (final assetFileName in assetsFilesNamesWithoutAlreadyUsed) {
                if (fileString.contains(assetFileName)) {
                  usedAssetsNames.add(assetFileName);
                }
              }
            }
          },
          whenDone: (milliseconds) => write('search: $milliseconds ms'),
        );

        final unUsedAssets = assetsFiles.entries
            .where((element) => !usedAssetsNames.contains(element.key));
        final unUsedAssetsNames = unUsedAssets.map((asset) => asset.key);
        final unUsedAssetsPaths = unUsedAssets.map((asset) => asset.value);

        write('Assets Files count: ${assetsFiles.length}',
            colorType: ConsoleColorType.attention);
        write('Used Assets count: ${usedAssetsNames.length}',
            colorType: ConsoleColorType.attention);
        write('UnUsed Assets count: ${unUsedAssetsNames.length}',
            colorType: ConsoleColorType.attention);

        await Helpers.callWithStopwatch(
          () async => await Helpers.deleteFilesByPaths(
            paths: unUsedAssetsPaths,
            assetFolderName: assetsFolderPath,
            deletedAssetFolderName: deletedAssetFolderName,
          ),
          whenDone: (milliseconds) => write('delete: $milliseconds ms'),
        );
      },
      whenDone: (milliseconds) => write('Total Time: $milliseconds ms'),
    );

    write(
      'Make sure that the paths of these deleted files are not used in pubspec.yaml',
      colorType: ConsoleColorType.attention,
    );
  } on Exception catch (e) {
    stdout.addError('$e');
  }
}

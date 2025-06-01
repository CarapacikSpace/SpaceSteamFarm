import 'dart:developer' as dev show log;
import 'dart:io' show File, Platform, Process;

import 'package:space_farm/src/common/utils.dart';

class SteamKitService {
  SteamKitService();

  Future<int> getApps(String login, String password) async {
    final platform = Platform.operatingSystem;
    final arch = await Utils.getCPUArchitecture();
    final ext = platform == 'windows' ? '.exe' : '';
    final normalizedPlatform = switch (platform) {
      'macos' => 'osx',
      'windows' => 'win',
      _ => platform,
    };
    final fileName =
        'process${Platform.pathSeparator}get_steam_apps${Platform.pathSeparator}GetSteamApps_${normalizedPlatform}_$arch$ext';
    final file = File(fileName);

    if (!file.existsSync()) {
      throw Exception('Executable not found: $fileName');
    }

    dev.log('Running $fileName');
    final process = await Process.run(file.path, [login, password], runInShell: true);

    dev.log('stdout');
    dev.log(process.stdout.toString());

    dev.log('stderr');
    dev.log(process.stderr.toString());

    final exitCode = process.exitCode;
    dev.log('Process exited with code $exitCode');

    if (exitCode != 0) {
      throw Exception('Process exited with code $exitCode\nprocess.stderr.toString()');
    }
    return exitCode;
  }

  Future<int> logout() async {
    final platform = Platform.operatingSystem;
    final arch = await Utils.getCPUArchitecture();
    final ext = platform == 'windows' ? '.exe' : '';
    final normalizedPlatform = switch (platform) {
      'macos' => 'osx',
      'windows' => 'win',
      _ => platform,
    };
    final fileName =
        'process${Platform.pathSeparator}get_steam_apps${Platform.pathSeparator}GetSteamApps_${normalizedPlatform}_$arch$ext';
    final file = File(fileName);

    if (!file.existsSync()) {
      throw Exception('Executable not found: $fileName');
    }

    dev.log('Running $fileName');
    final process = await Process.run(file.path, ['--logout'], runInShell: true);

    dev.log('stdout');
    dev.log(process.stdout.toString());

    dev.log('stderr');
    dev.log(process.stderr.toString());

    final exitCode = process.exitCode;
    dev.log('Process exited with code $exitCode');
    return exitCode;
  }
}

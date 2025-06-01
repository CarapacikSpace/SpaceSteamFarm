import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/common/persisted_entry.dart';

abstract interface class ILocalAppsDataSource {
  Future<List<LocalApp>> getData();

  Future<void> setData(List<LocalApp> data);

  Future<void> remove();
}

final class LocalAppsDataSource implements ILocalAppsDataSource {
  LocalAppsDataSource({required this.sharedPreferences});

  final SharedPreferencesAsync sharedPreferences;

  late final _data = StringPreferencesEntry(sharedPreferences: sharedPreferences, key: 'local_apps.data');

  @override
  Future<List<LocalApp>> getData() => _data.read().then((v) {
    if (v == null) {
      return [];
    }
    return (json.decode(v) as List<dynamic>)
        .map((e) => LocalApp.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  });

  @override
  Future<void> setData(List<LocalApp> newData) async {
    // final existingData = await getData();
    //
    // final mergedById = <int, LocalApp>{for (final app in existingData) app.appid: app};
    //
    // for (final app in newData) {
    //   final old = mergedById[app.appid];
    //
    //   final hasNewTime = app.playtimeMinutes != null && app.playtimeMinutes! > 0;
    //   final isNewApp = old == null;
    //
    //   if (hasNewTime || isNewApp) {
    //     mergedById[app.appid] = app;
    //   }
    // }
    //
    // final mergedList = mergedById.values.toList();
    await _data.set(json.encode(newData.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> remove() async {
    await _data.remove();
  }
}

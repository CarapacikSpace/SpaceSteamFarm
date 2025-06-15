import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/steam/model/steam_app_info.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';
import 'package:space_farm/src/steam/model/steam_hour_info.dart';

List<LocalApp> mergeAppsLists({
  required List<LocalApp> cachedApps,
  required List<SteamAppInfo> steamKitApps,
  required List<SteamHourInfo> ownedGames,
  required List<SteamHourInfo> recentlyPlayedGames,
}) {
  final cachedMap = {for (final a in cachedApps) a.appId: a};
  final steamKitMap = {for (final a in steamKitApps) a.appId: a};
  final ownedMap = {for (final h in ownedGames) h.appid: h};
  final recentMap = {for (final h in recentlyPlayedGames) h.appid: h};

  final allAppIds = <int>{...cachedMap.keys, ...steamKitMap.keys, ...ownedMap.keys, ...recentMap.keys};

  final result = <LocalApp>[];

  for (final id in allAppIds) {
    final cached = cachedMap[id];
    final steamKit = steamKitMap[id];
    final owned = ownedMap[id];
    final recent = recentMap[id];

    final playtime = recent?.playtimeMinutes ?? owned?.playtimeMinutes ?? cached?.playtimeMinutes;
    final lastPlayed = recent?.lastPlayed ?? owned?.lastPlayed ?? cached?.lastPlayed;

    final stopAt = _resolveStopAtMinutes(playtime, cached?.stopAtMinutes);
    final name =
        (recent?.name.nullIFEmpty ??
                owned?.name.nullIFEmpty ??
                steamKit?.name.nullIFEmpty ??
                cached?.name.nullIFEmpty ??
                id.toString())
            .trim();
    final type = steamKit?.type ?? cached?.type ?? SteamAppType.other;
    final reviewPercentage = steamKit?.reviewPercentage ?? cached?.reviewPercentage;
    final isHidden = steamKit?.isHidden ?? cached?.isHidden ?? false;

    result.add(
      LocalApp(
        appId: id,
        name: name,
        type: type,
        reviewPercentage: reviewPercentage,
        logo: steamKit?.logo ?? cached?.logo,
        icon: steamKit?.icon ?? cached?.icon,
        playtimeMinutes: playtime,
        lastPlayed: lastPlayed,
        stopAtMinutes: stopAt,
        isHidden: isHidden,
      ),
    );
  }

  result.sortByPlaytimeTypeName();
  return result;
}

int? _resolveStopAtMinutes(int? playtime, int? cachedStopAt) {
  if (cachedStopAt == null) {
    return null;
  }
  if ((playtime ?? 0) >= cachedStopAt) {
    return null;
  }
  return cachedStopAt;
}

extension on String? {
  String? get nullIFEmpty {
    return this == null || this!.isEmpty ? null : this;
  }
}

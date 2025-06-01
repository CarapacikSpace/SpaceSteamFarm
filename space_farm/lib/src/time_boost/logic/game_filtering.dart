import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';
import 'package:space_farm/src/time_boost/model/game_filter_type.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class GameFilterController {
  const GameFilterController({
    required this.searchController,
    required this.minController,
    required this.maxController,
    required this.timeFilterType,
    required this.gameFilterType,
    required this.selectedTypes,
    required this.launchedAppIds,
  });

  final TextEditingController searchController;
  final TextEditingController minController;
  final TextEditingController maxController;
  final TimeFilterType timeFilterType;
  final GameFilterType gameFilterType;
  final Set<SteamAppType> selectedTypes;
  final Set<int> launchedAppIds;

  List<LocalApp> apply(List<LocalApp> apps) {
    final query = searchController.text.trim().toLowerCase();
    final min = int.tryParse(minController.text.trim());
    final max = int.tryParse(maxController.text.trim());

    return apps.where((a) {
      final matchName = a.name.toLowerCase().contains(query);
      final matchId = a.appId.toString() == query;

      final playtime = a.playtimeMinutes ?? -1;
      final playtimeInUnits = timeFilterType == TimeFilterType.hours ? playtime / 60 : playtime;
      final minOk = min == null || playtimeInUnits >= min;
      final maxOk = max == null || playtimeInUnits < max;

      final matchCategory = selectedTypes.contains(a.type);

      final matchFilter = switch (gameFilterType) {
        GameFilterType.all => true,
        GameFilterType.running => launchedAppIds.contains(a.appId),
        GameFilterType.marked => a.stopAtMinutes != null && (a.playtimeMinutes ?? 0) < a.stopAtMinutes!,
        GameFilterType.hidden => a.isHidden,
        GameFilterType.favorite => a.isFavorite,
      };

      return (matchName || matchId) && minOk && maxOk && matchCategory && matchFilter;
    }).toList();
  }
}

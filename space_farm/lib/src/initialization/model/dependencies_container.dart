import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/steam/data/steam_game.dart';

class DependenciesContainer {
  const DependenciesContainer({required this.appsRepository, required this.steamGameService});

  final IAppsRepository appsRepository;
  final SteamGameService steamGameService;
}

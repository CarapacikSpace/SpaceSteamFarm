import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/apps/screen/load_apps_data_screen.dart';
import 'package:space_farm/src/common/components/extensions/context_extension.dart';
import 'package:space_farm/src/shared/dropdown.dart';
import 'package:space_farm/src/shared/elevated_button.dart';
import 'package:space_farm/src/shared/filled_button.dart';
import 'package:space_farm/src/shared/segmented_button.dart';
import 'package:space_farm/src/shared/snackbar.dart';
import 'package:space_farm/src/shared/text_field.dart';
import 'package:space_farm/src/steam/data/steam_game.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';
import 'package:space_farm/src/time_boost/logic/game_filtering.dart';
import 'package:space_farm/src/time_boost/logic/game_launcher.dart';
import 'package:space_farm/src/time_boost/logic/game_marking.dart';
import 'package:space_farm/src/time_boost/model/game_filter_type.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';
import 'package:space_farm/src/time_boost/widget/apps_grid.dart';
import 'package:space_farm/src/time_boost/widget/launched_games_info.dart';

class TimeBoostScreen extends StatefulWidget {
  const TimeBoostScreen({super.key});

  @override
  State<TimeBoostScreen> createState() => _TimeBoostScreenState();
}

class _TimeBoostScreenState extends State<TimeBoostScreen> {
  late final IAppsRepository _appsRepository = context.dependencies.appsRepository;
  late final SteamGameService _steamGameService = context.dependencies.steamGameService;

  final _searchController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  late Listenable _filterListenable;

  final SplayTreeSet<SteamAppType> _selectedTypes = SplayTreeSet.from(
    SteamAppType.values,
    (a, b) => a.index.compareTo(b.index),
  );
  TimeFilterType _timeFilterType = TimeFilterType.hours;
  GameFilterType _gameFilterType = GameFilterType.all;

  late final GameLauncher _launcher;
  late final GameMarking _marker;

  List<LocalApp> _apps = [];

  @override
  void initState() {
    super.initState();
    _launcher = GameLauncher(
      context: context,
      appsRepository: _appsRepository,
      steamGame: _steamGameService,
      onUpdateAppList: _updateAppInList,
    );
    _marker = GameMarking(appsRepository: _appsRepository);
    _filterListenable = Listenable.merge([_searchController, _minController, _maxController]);
    unawaited(_initialAppsLoading());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<void> _initialAppsLoading() async {
    try {
      final apps = await _appsRepository.getApps$FromCacheAndUpdate();
      apps.sortByPlaytimeTypeName();
      setState(() {
        _apps = apps;
      });
    } on Object catch (e, st) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnack(context, 'Ошибка при загрузке игр: $e\n$st');
      });
    }
  }

  void _updateAppInList(LocalApp updated) {
    final index = _apps.indexWhere((a) => a.appId == updated.appId);
    if (index != -1) {
      setState(() {
        _apps[index] = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF171D25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            const Text('SPACE FARM', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            LaunchedGamesInfo(
              total: _launcher.launchedGames.length,
              batch: _launcher.batchLaunchedAppIds.length,
              onStopBatch: () => _stopMany(_launcher.batchLaunchedAppIds),
              onStopManual: () => _stopMany(
                _launcher.launchedGames
                    .map((g) => g.app.appId)
                    .where((id) => !_launcher.batchLaunchedAppIds.contains(id))
                    .toSet(),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'HARD STOP',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: const Color(0xFF171D25),
                  surfaceTintColor: const Color(0xFF171D25),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Остановить ВСЕ Steam-игры?'.toUpperCase(),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          const Text('Это остановит все процессы, включая те, что не отображаются в приложении'),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: SteamFilledButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Отмена', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SteamElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Stop', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              if (confirm ?? false) {
                await _steamGameService.killAllSteamGames();
                _launcher.launchedGames.clear();
                _launcher.batchLaunchedAppIds.clear();
                _launcher.gameStartTimes.clear();
                for (final t in _launcher.gameTimers.values) {
                  t.cancel();
                }
                _launcher.gameTimers.clear();
                setState(() {});
              }
            },
            icon: const Icon(Icons.power_settings_new),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Загрузить/обновить список игр',
            onPressed: () => _openFetchScreen(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SteamDropdown(
                    types: SteamAppType.values.toSet(),
                    selectedTypes: _selectedTypes,
                    onChanged: (type) {
                      setState(() {
                        if (_selectedTypes.contains(type)) {
                          _selectedTypes.remove(type);
                        } else {
                          _selectedTypes.add(type);
                        }
                      });
                    },
                  ),
                  SizedBox(
                    width: 180,
                    child: SteamSegmentedButton(
                      values: TimeFilterType.values,
                      selectedValue: _timeFilterType,
                      onSelected: (selected) {
                        var min = double.tryParse(_minController.text.trim());
                        var max = double.tryParse(_maxController.text.trim());

                        if (min != null || max != null) {
                          if (_timeFilterType == TimeFilterType.minutes && selected == TimeFilterType.hours) {
                            if (min != null) {
                              min = min / 60;
                            }
                            if (max != null) {
                              max = max / 60;
                            }
                          } else if (_timeFilterType == TimeFilterType.hours && selected == TimeFilterType.minutes) {
                            if (min != null) {
                              min = min * 60;
                            }
                            if (max != null) {
                              max = max * 60;
                            }
                          }
                          _minController.text = min?.toStringAsFixed(0) ?? '';
                          _maxController.text = max?.toStringAsFixed(0) ?? '';
                        } else {
                          _minController.clear();
                          _maxController.clear();
                        }

                        setState(() {
                          _timeFilterType = selected;
                        });
                      },
                      labelBuilder: (type, context) => type.localizedText(context),
                    ),
                  ),
                  SteamSegmentedButton(
                    values: GameFilterType.values,
                    selectedValue: _gameFilterType,
                    expandedItems: false,
                    onSelected: (selected) {
                      setState(() {
                        _gameFilterType = selected;
                      });
                    },
                    labelBuilder: (type, context) => type.localizedText(context),
                  ),
                  SizedBox(
                    width: 200,
                    child: SteamTextField(controller: _searchController, hintText: 'Поиск по названию'),
                  ),
                  Row(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 100,
                        child: SteamTextField(
                          controller: _minController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          hintText: 'min',
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: SteamTextField(
                          controller: _maxController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          hintText: 'max',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SteamElevatedButton(
                    onPressed: () async => _launchMarked(),
                    child: Text(
                      'Запустить отмеченные игры'.toUpperCase(),
                      style: const TextStyle(fontSize: 12, height: 1, color: Colors.white),
                    ),
                  ),
                  SteamElevatedButton(
                    onPressed: () async => _launchFavorite(),
                    child: Text(
                      'Запустить избранные'.toUpperCase(),
                      style: const TextStyle(fontSize: 12, height: 1, color: Colors.white),
                    ),
                  ),
                  SteamFilledButton(
                    onPressed: () => _marker.showMarkDialog(
                      context: context,
                      timeFilterType: _timeFilterType,
                      onSubmit: (min, max, target) => _marker.markBatchCandidates(
                        context: context,
                        apps: _apps,
                        min: min,
                        max: max,
                        target: target,
                        timeFilterType: _timeFilterType,
                        onUpdateApp: _updateAppInList,
                      ),
                    ),
                    child: Text(
                      'Отметить игры'.toUpperCase(),
                      style: const TextStyle(fontSize: 12, height: 1, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF17191B), thickness: 2, height: 2),
            Expanded(
              child: ListenableBuilder(
                listenable: _filterListenable,
                builder: (context, child) {
                  final filter = GameFilterController(
                    searchController: _searchController,
                    minController: _minController,
                    maxController: _maxController,
                    timeFilterType: _timeFilterType,
                    gameFilterType: _gameFilterType,
                    selectedTypes: _selectedTypes,
                    launchedAppIds: _launcher.launchedGames.map((g) => g.app.appId).toSet(),
                  );
                  final filteredApps = filter.apply(_apps);
                  return DecoratedBox(
                    decoration: const BoxDecoration(color: Color(0xFF2D333C)),
                    child: _apps.isEmpty
                        ? const Center(
                            child: Text(
                              'Список игр пуст',
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                          )
                        : AppsGridWidget(
                            apps: filteredApps,
                            launchedAppIds: _launcher.launchedGames.map((g) => g.app.appId).toSet(),
                            timeFilterType: _timeFilterType,
                            onTap: (app) => _launcher.toggleGame(app),
                            onUpdateApp: _updateAppInList,
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFetchScreen(BuildContext context) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute<bool>(builder: (_) => const LoadAppsDataScreen()));
    if (result == null) {
      return;
    }
    if (result) {
      await _initialAppsLoading();
    }
  }

  Future<void> _stopMany(Set<int> appIds) async {
    final random = Random();
    for (final id in appIds.toList()) {
      final app = _apps.firstWhere(
        (a) => a.appId == id,
        orElse: () => LocalApp(appId: id, name: id.toString(), type: SteamAppType.other),
      );
      await _launcher.toggleGame(app);
      if (mounted) {
        setState(() {});
      }
      await Future<void>.delayed(Duration(milliseconds: 1000 + random.nextInt(500)));
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _launchMarked() async {
    final random = Random();

    final marked = _apps.where((a) {
      final stop = a.stopAtMinutes;
      final played = a.playtimeMinutes ?? 0;
      return stop != null && played <= stop;
    }).toList()..sort((a, b) => (b.playtimeMinutes ?? 0).compareTo(a.playtimeMinutes ?? 0));

    _launcher.batchQueue.clear();
    final toLaunch = marked
        .take(80)
        .where((app) => !_launcher.launchedGames.any((g) => g.app.appId == app.appId))
        .toList();

    _launcher.batchQueue.addAll(toLaunch);

    if (mounted) {
      setState(() {});
    }

    for (var i = 0; i < 30 && _launcher.batchQueue.isNotEmpty; i++) {
      final app = _launcher.batchQueue.removeFirst();
      _launcher.batchLaunchedAppIds.add(app.appId);
      await _launcher.toggleGame(app);
      if (mounted) {
        setState(() {});
      }
      await Future<void>.delayed(Duration(milliseconds: 500 + random.nextInt(500)));
    }
  }

  Future<void> _launchFavorite() async {
    final random = Random();

    final favorites = _apps.where((a) => a.isFavorite).toList()
      ..sort((a, b) => (b.playtimeMinutes ?? 0).compareTo(a.playtimeMinutes ?? 0));

    _launcher.batchQueue.clear();
    final toLaunch = favorites
        .take(60)
        .where((app) => !_launcher.launchedGames.any((g) => g.app.appId == app.appId))
        .toList();

    _launcher.batchQueue.addAll(toLaunch);

    if (mounted) {
      setState(() {});
    }

    for (var i = 0; i < 30 && _launcher.batchQueue.isNotEmpty; i++) {
      final app = _launcher.batchQueue.removeFirst();
      _launcher.batchLaunchedAppIds.add(app.appId);
      await _launcher.toggleGame(app);
      if (mounted) {
        setState(() {});
      }
      await Future<void>.delayed(Duration(milliseconds: 500 + random.nextInt(500)));
    }
  }
}

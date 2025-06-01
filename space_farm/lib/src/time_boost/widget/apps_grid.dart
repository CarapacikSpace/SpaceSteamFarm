import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';
import 'package:space_farm/src/time_boost/widget/app_card.dart';

class AppsGridWidget extends StatelessWidget {
  const AppsGridWidget({
    required this.apps,
    required this.launchedAppIds,
    required this.timeFilterType,
    required this.onTap,
    required this.onUpdateApp,
    super.key,
  });

  final List<LocalApp> apps;
  final Set<int> launchedAppIds;
  final TimeFilterType timeFilterType;
  final ValueChanged<LocalApp> onTap;
  final ValueChanged<LocalApp> onUpdateApp;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: 190,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 2,
        maxCrossAxisExtent: 230,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final isRunning = launchedAppIds.contains(app.appId);
        return AppCard(
          app: app,
          isRunning: isRunning,
          onTap: onTap,
          timeFilterType: timeFilterType,
          onUpdateApp: onUpdateApp,
        );
      },
    );
  }
}

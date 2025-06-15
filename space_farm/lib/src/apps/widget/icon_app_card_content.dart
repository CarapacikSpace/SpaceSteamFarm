import 'package:flutter/material.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/common/extensions/context_extension.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class IconAppCardContent extends StatelessWidget {
  const IconAppCardContent({
    required this.app,
    required this.onTap,
    required this.isRunning,
    required this.onRightClick,
    required this.timeFilterType,
    super.key,
  });

  final LocalApp app;
  final TimeFilterType timeFilterType;
  final bool isRunning;
  final VoidCallback onTap;
  final void Function(PointerDownEvent event) onRightClick;

  @override
  Widget build(BuildContext context) {
    final time = app.playtimeMinutes == null
        ? null
        : timeFilterType == TimeFilterType.hours
        ? '${app.hours.toStringAsFixed(1)} ${context.l10n.hoursShort}'
        : '${app.playtimeMinutes} ${context.l10n.minutesShort}';

    return SizedBox(
      height: 32,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: isRunning ? const Color(0xFF7CB719) : Colors.transparent),
            borderRadius: BorderRadius.circular(2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: onRightClick,
            child: InkWell(
              onTap: onTap,
              child: Row(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: Center(
                      child: Image.network(
                        app.iconUrl,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: Colors.black26,
                          child: Center(
                            child: Text(
                              app.name.characters.first.toUpperCase(),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    app.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isRunning ? const Color(0xFF7CB719) : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (time != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Material(
                        color: const Color(0xFF3D4450),
                        elevation: 16,
                        shadowColor: Colors.black,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                          child: Text(time, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    ),
                  if (app.stopAtMinutes != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Material(
                        color: const Color(0xFF1A9FFF),
                        elevation: 16,
                        shadowColor: Colors.black,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          child: Text(
                            timeFilterType == TimeFilterType.hours
                                ? '${(app.stopAtMinutes! / 60).toStringAsFixed(1)} ${context.l10n.hoursShort}'
                                : '${app.stopAtMinutes} ${context.l10n.minutesShort}',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

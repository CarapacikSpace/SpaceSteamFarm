import 'dart:async';

import 'package:flutter/gestures.dart' show PointerDeviceKind, kSecondaryMouseButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, FilteringTextInputFormatter;
import 'package:space_farm/src/apps/data/apps_repository.dart';
import 'package:space_farm/src/apps/model/local_app.dart';
import 'package:space_farm/src/apps/model/optional.dart';
import 'package:space_farm/src/common/components/extensions/context_extension.dart';
import 'package:space_farm/src/shared/elevated_button.dart';
import 'package:space_farm/src/shared/filled_button.dart';
import 'package:space_farm/src/shared/text_field.dart';
import 'package:space_farm/src/time_boost/logic/pop_up_menu_controller.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    required this.app,
    required this.onTap,
    required this.timeFilterType,
    required this.onUpdateApp,
    this.isRunning = false,
    super.key,
  });

  final LocalApp app;
  final bool isRunning;
  final ValueChanged<LocalApp> onTap;
  final ValueChanged<LocalApp> onUpdateApp;
  final TimeFilterType timeFilterType;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with TickerProviderStateMixin {
  late final IAppsRepository _appsRepository = context.dependencies.appsRepository;

  @override
  Widget build(BuildContext context) {
    String? time;
    if (widget.app.playtimeMinutes != null) {
      time = widget.timeFilterType == TimeFilterType.hours
          ? '${widget.app.hours.toStringAsFixed(1)} ч'
          : '${widget.app.playtimeMinutes} мин';
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            elevation: 8,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: widget.isRunning ? const Color(0xFF7CB719) : Colors.transparent, width: 2),
              borderRadius: BorderRadius.circular(2),
            ),
            shadowColor: widget.isRunning ? const Color(0xFF7CB719) : Colors.transparent,
            clipBehavior: Clip.antiAlias,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) async {
                if (event.kind == PointerDeviceKind.mouse && event.buttons == kSecondaryMouseButton) {
                  await PopUpMenuController.instance.show(
                    vsync: this,
                    context: context,
                    position: event.position,
                    timeFilterType: widget.timeFilterType,
                    items: [
                      MenuItem(
                        text: widget.app.isFavorite ? 'Убрать из избранного' : 'Добавить в избранное',
                        onTap: () async {
                          await PopUpMenuController.instance.hide();
                          final updated = widget.app.copyWith(isFavorite: !widget.app.isFavorite);
                          widget.onUpdateApp.call(updated);
                          await _appsRepository.updateApp(updated);
                        },
                      ),
                      MenuItem(
                        text: 'Сменить текущее время',
                        onTap: () async {
                          await PopUpMenuController.instance.hide();
                          await _showSetTimeDialog(widget.app);
                        },
                      ),
                      MenuItem(
                        text: 'Пометить конечное время',
                        onTap: () async {
                          await PopUpMenuController.instance.hide();
                          await _showAutoStopDialog(widget.app);
                        },
                      ),
                      MenuItem(
                        text: 'Скопировать ID',
                        onTap: () async {
                          await PopUpMenuController.instance.hide();
                          await Clipboard.setData(ClipboardData(text: widget.app.appId.toString()));
                        },
                      ),
                    ],
                  );
                }
              },
              child: InkWell(
                onTap: () => widget.onTap.call(widget.app),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 230 / 100,
                      child: Image.network(
                        widget.app.headerUrl,
                        width: 230,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.network(
                          widget.app.logoUrl,
                          width: 230,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Text(
                                widget.app.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.app.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(widget.app.type.localizedText(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (time != null)
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
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
            ),
          ),
        if (widget.app.stopAtMinutes != null)
          Positioned(
            right: 4,
            top: 4,
            child: IgnorePointer(
              child: Material(
                color: const Color(0xFF1A9FFF),
                elevation: 16,
                shadowColor: Colors.black,
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                  child: Text(
                    widget.timeFilterType == TimeFilterType.hours
                        ? '${(widget.app.stopAtMinutes! / 60).toStringAsFixed(1)} ч'
                        : '${widget.app.stopAtMinutes} мин',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showSetTimeDialog(LocalApp app) async {
    final controller = TextEditingController(text: '${app.playtimeMinutes ?? 0}');
    final result = await showDialog<int?>(
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
                  'Установить время для "${app.name}"',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Text('Время в минутах', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                SteamTextField(
                  controller: controller,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  hintText: 'Время в минутах',
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SteamFilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Отмена', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SteamElevatedButton(
                        onPressed: () {
                          final minutes = int.tryParse(controller.text.trim());
                          if (minutes != null && minutes >= 0) {
                            Navigator.of(context).pop(minutes);
                          }
                        },
                        child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
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
    controller.dispose();

    if (result != null) {
      final updated = app.copyWith(playtimeMinutes: result);
      widget.onUpdateApp.call(updated);
      await _appsRepository.updateApp(updated);
    }
  }

  Future<void> _showAutoStopDialog(LocalApp app) async {
    final controller = TextEditingController(text: app.stopAtMinutes?.toString() ?? '');

    final result = await showDialog<int?>(
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
                  'Автоостановка для "${app.name}"',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                const Text('Время в минутах', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                SteamTextField(
                  controller: controller,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  hintText: 'Время в минутах',
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: SteamFilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Отмена', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SteamElevatedButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) {
                            Navigator.of(context).pop();
                          } else {
                            final minutes = int.tryParse(text);
                            if (minutes != null && minutes > 0) {
                              Navigator.of(context).pop(minutes);
                            }
                          }
                        },
                        child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
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

    controller.dispose();

    if (result != null || controller.text.trim().isEmpty) {
      final currentMinutes = app.playtimeMinutes ?? 0;
      final stopAtMinutes = (result != null && result > currentMinutes) ? Optional.of(result) : const Optional.of(null);

      final updated = app.copyWith(stopAtMinutes: stopAtMinutes);
      widget.onUpdateApp.call(updated);
      await _appsRepository.updateApp(updated);
    }
  }
}

class MenuItem extends StatefulWidget {
  const MenuItem({required this.text, required this.onTap, super.key});

  final String text;
  final VoidCallback onTap;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isHovered ? const Color(0xFFDCDEDF) : Colors.transparent;
    final textColor = _isHovered ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: DecoratedBox(
            decoration: BoxDecoration(color: backgroundColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.text, style: TextStyle(color: textColor)),
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

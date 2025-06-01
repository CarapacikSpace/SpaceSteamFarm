import 'dart:async';

import 'package:flutter/material.dart';
import 'package:space_farm/src/time_boost/model/time_filter_type.dart';

class PopUpMenuController {
  PopUpMenuController._internal();

  static final PopUpMenuController instance = PopUpMenuController._internal();

  OverlayEntry? _menuEntry;
  OverlayEntry? _barrierEntry;
  AnimationController? _animationController;

  Future<void> show({
    required BuildContext context,
    required TickerProvider vsync,
    required Offset position,
    required TimeFilterType timeFilterType,
    required List<Widget> items,
    double width = 220,
    double height = 150,
  }) async {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    await _remove();

    final left = (position.dx + width > screenSize.width) ? screenSize.width - width - 16 : position.dx;
    final top = (position.dy + height > screenSize.height) ? screenSize.height - height - 16 : position.dy;

    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: vsync);
    final animation = CurvedAnimation(parent: _animationController!, curve: Curves.easeOut);

    _barrierEntry = OverlayEntry(
      builder: (_) =>
          GestureDetector(onTap: _remove, behavior: HitTestBehavior.translucent, child: const SizedBox.expand()),
    );

    _menuEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: left,
        top: top,
        child: FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            alignment: Alignment.topLeft,
            child: Material(
              borderRadius: BorderRadius.circular(4),
              color: const Color(0XFF3D4450),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: width,
                child: Column(mainAxisSize: MainAxisSize.min, children: items),
              ),
            ),
          ),
        ),
      ),
    );

    overlay
      ..insert(_barrierEntry!)
      ..insert(_menuEntry!);
    await _animationController!.forward();
  }

  Future<void> _remove() async {
    await _animationController?.reverse().then((_) {
      _menuEntry?.remove();
      _barrierEntry?.remove();
      _menuEntry = null;
      _barrierEntry = null;
      _animationController?.dispose();
      _animationController = null;
    });
  }

  Future<void> hide() async => _remove();
}

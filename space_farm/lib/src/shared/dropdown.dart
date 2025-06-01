import 'package:flutter/material.dart';
import 'package:space_farm/src/common/widget/popup/popup.dart';
import 'package:space_farm/src/steam/model/steam_app_type.dart';

class SteamDropdown extends StatefulWidget {
  const SteamDropdown({required this.selectedTypes, required this.types, required this.onChanged, super.key});

  final Set<SteamAppType> selectedTypes;
  final Set<SteamAppType> types;
  final ValueChanged<SteamAppType> onChanged;

  @override
  State<SteamDropdown> createState() => _SteamDropdownState();
}

class _SteamDropdownState extends State<SteamDropdown> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return PopupBuilder(
      followerAnchor: Alignment.bottomCenter,
      followerBuilder: (context, controller) {
        return PopupFollower(
          constraints: const BoxConstraints(maxWidth: 190),
          onDismiss: () => controller.hide(),
          child: Material(
            elevation: 8,
            shadowColor: Colors.black,
            clipBehavior: Clip.antiAlias,
            color: const Color(0xFF3D4450),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.types
                    .map((e) {
                      return DropdownCheckboxItem(
                        title: e.localizedText(context),
                        value: widget.selectedTypes.contains(e),
                        onChanged: (v) => widget.onChanged.call(e),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
          ),
        );
      },
      targetBuilder: (context, controller) {
        return SizedBox(
          width: 190,
          height: 32,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => controller.show(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: _hovering ? const Color(0xFF3E4047) : const Color(0xFF26282D),
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.selectedTypes.length == widget.types.length
                                ? 'Все'
                                : widget.selectedTypes.map((e) => e.localizedText(context)).join(', '),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: _hovering ? const Color(0xFFF5F5F6) : const Color(0xFFA3A3A3),
                              fontSize: 12,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: _hovering ? const Color(0xFFF5F5F6) : const Color(0xFFA3A3A3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DropdownCheckboxItem extends StatefulWidget {
  const DropdownCheckboxItem({required this.title, required this.value, required this.onChanged, super.key});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<DropdownCheckboxItem> createState() => _DropdownCheckboxItemState();
}

class _DropdownCheckboxItemState extends State<DropdownCheckboxItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        height: 25,
        child: GestureDetector(
          onTap: () => widget.onChanged.call(!widget.value),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  CustomPaint(
                    painter: _InsetCheckboxPainter(
                      isChecked: widget.value,
                      backgroundColor: _hovering ? const Color(0xFF090909) : const Color(0xFF2B2E34),
                    ),
                    size: const Size(16, 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(widget.title, style: const TextStyle(color: Color(0xFFC8CBCE), fontSize: 14)),
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

class _InsetCheckboxPainter extends CustomPainter {
  _InsetCheckboxPainter({required this.isChecked, required this.backgroundColor});

  final bool isChecked;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, backgroundPaint);

    final shadowPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.black45, Colors.transparent],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect.deflate(0.75), shadowPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF55585D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);

    if (isChecked) {
      final checkPaint = Paint()
        ..color = const Color(0xFF1C96FF)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(size.width * 0.25, size.height * 0.5)
        ..lineTo(size.width * 0.45, size.height * 0.7)
        ..lineTo(size.width * 0.75, size.height * 0.3);
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _InsetCheckboxPainter oldDelegate) =>
      isChecked != oldDelegate.isChecked || backgroundColor != oldDelegate.backgroundColor;
}

import 'package:flutter/material.dart';

class LaunchedGamesInfo extends StatelessWidget {
  const LaunchedGamesInfo({
    required this.total,
    required this.batch,
    required this.onStopBatch,
    required this.onStopManual,
    super.key,
  });

  final int total;
  final int batch;
  final VoidCallback onStopBatch;
  final VoidCallback onStopManual;

  @override
  Widget build(BuildContext context) {
    final manual = total - batch;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        SizedBox(
          height: 32,
          child: Material(
            borderRadius: BorderRadius.circular(2),
            color: const Color(0xFF7CB719),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('$total игр', style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 6),
                    Text('($batch авто, $manual вручную)', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'STOP авто запущенные',
          onPressed: onStopBatch,
          icon: const Icon(Icons.power_settings_new, color: Color(0xFF1A9FFF)),
        ),
        IconButton(
          tooltip: 'STOP вручную  запущенные',
          onPressed: onStopManual,
          icon: const Icon(Icons.power_settings_new, color: Color(0xFF7CB719)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

enum SteamAppType {
  game,
  demo,
  music,
  application,
  video,
  tool,
  dlc,
  other;

  factory SteamAppType.fromString(String? type, {required bool isOwnerOnly}) => switch (type?.toLowerCase()) {
    'game' when !isOwnerOnly => game,
    'demo' => demo,
    'music' => music,
    'application' => application,
    'video' => video,
    'tool' || 'game' when isOwnerOnly => tool,
    'dlc' => dlc,
    _ => other,
  };

  String localizedText(BuildContext context) => switch (this) {
    game => 'Игры',
    demo => 'Demo',
    music => 'Саундтреки',
    application => 'Программы',
    video => 'Видео',
    tool => 'Инструменты',
    dlc => 'DLC',
    _ => 'Другие',
  };
}

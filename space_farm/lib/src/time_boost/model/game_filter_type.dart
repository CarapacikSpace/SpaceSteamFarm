import 'package:flutter/widgets.dart';

enum GameFilterType {
  all,
  running,
  marked,
  hidden,
  favorite;

  String localizedText(BuildContext context) => switch (this) {
    all => 'Все',
    running => 'Запущенные',
    marked => 'Помеченные',
    hidden => 'Скрытые',
    favorite => 'Избранные',
  };
}

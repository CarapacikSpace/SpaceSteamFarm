import 'package:flutter/widgets.dart';

enum TimeFilterType {
  hours,
  minutes;

  String localizedText(BuildContext context) => switch (this) {
    hours => 'Часы',
    minutes => 'Минуты',
  };
}

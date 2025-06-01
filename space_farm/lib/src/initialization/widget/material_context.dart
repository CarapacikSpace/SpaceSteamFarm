import 'package:flutter/material.dart';
import 'package:space_farm/src/common/resources/theme.dart' as t;
import 'package:space_farm/src/time_boost/screen/time_boost_screen.dart';

class MaterialContext extends StatelessWidget {
  const MaterialContext({super.key});

  static final _globalKey = GlobalKey(debugLabel: 'MaterialContext');

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);

    final theme = t.theme;

    return MaterialApp(
      theme: theme,
      // localizationsDelegates: Localization.localizationDelegates,
      // supportedLocales: Localization.supportedLocales,
      onGenerateTitle: (context) => 'Space Farm',
      home: const TimeBoostScreen(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        key: _globalKey,
        data: mediaQueryData.copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
    );
  }
}

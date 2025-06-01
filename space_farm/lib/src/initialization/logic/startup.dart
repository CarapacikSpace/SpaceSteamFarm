import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:space_farm/src/initialization/logic/composition_root.dart';
import 'package:space_farm/src/initialization/widget/initialization_failed_app.dart';
import 'package:space_farm/src/initialization/widget/root_context.dart';

Future<void> startup() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Configure global error interception
      // FlutterError.onError = logger.logFlutterError;
      // WidgetsBinding.instance.platformDispatcher.onError = logger.logPlatformDispatcherError;

      Future<void> composeAndRun() async {
        try {
          final compositionResult = await composeDependencies();

          runApp(RootContext(compositionResult: compositionResult));
        } on Object catch (e, st) {
          log('Initialization failed', error: e, stackTrace: st);
          runApp(InitializationFailedApp(error: e, stackTrace: st, onRetryInitialization: composeAndRun));
        }
      }

      await composeAndRun();
    },
    (e, st) {
      log('E:', error: e, stackTrace: st);
    },
  );
}

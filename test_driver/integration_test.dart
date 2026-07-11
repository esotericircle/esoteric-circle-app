import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Driver dei test di integrazione: riceve i byte dello screenshot dal test e
/// li scrive su disco, cosi' il workflow li carica come artifact.
Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
  );
}

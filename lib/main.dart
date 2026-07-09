import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

/// Punto di ingresso di Esoteric Circle.
///
/// L'app parte in tema scuro immersivo a schermo intero. I servizi (Maestro
/// attivo, feature flag, entitlement, qualita') sono registrati in `app.dart`.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dati di formattazione delle date in italiano (nomi dei mesi).
  await initializeDateFormatting('it');

  // Barre di sistema trasparenti per l'esperienza full-bleed.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const EsotericCircleApp());
}

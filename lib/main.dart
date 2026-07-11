import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/app_services.dart';

/// Punto di ingresso di Esoteric Circle.
///
/// L'app parte in tema scuro immersivo a schermo intero. I servizi di stato
/// (Maestro attivo, feature flag, entitlement, qualita') sono registrati in
/// `app.dart`. Qui si montano i servizi a runtime (AI dei Maestri su Gemini via
/// Firebase, memoria su Firestore), in modo tollerante ai guasti: se la
/// configurazione manca, l'app parte comunque e la chat lo segnala con garbo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barre di sistema trasparenti per l'esperienza full-bleed.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final services = await AppServices.bootstrap();

  runApp(EsotericCircleApp(services: services));
}

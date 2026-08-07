import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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

  // GLI OCCHI SUI CRASH, dal 7 agosto 2026. La 2157 iOS moriva MUTA
  // sull'iPhone di Mauro, crash deterministico all'ingresso del trionfo
  // dell'Animale Guida, e il telefono non esponeva rapporti leggibili:
  // correggere senza occhi sarebbe stato correggere alla cieca.
  //
  // Tre canali: gli errori del framework (FlutterError.onError), quelli
  // fuori dal framework (PlatformDispatcher.onError), e i crash NATIVI, che
  // Crashlytics raccoglie da solo una volta che il pod e' nell'app.
  //
  // **La guardia su Firebase.apps non e' un vezzo**: le prove montano l'app
  // senza Firebase e il bootstrap ripiega su offline; toccare
  // FirebaseCrashlytics.instance senza un'app Firebase solleverebbe. Il ramo
  // di prova non passa di qui, perche' le prove non chiamano main(), e anche
  // se un giorno lo facessero la guardia le tiene fuori.
  if (Firebase.apps.isNotEmpty) {
    FlutterError.onError = (dettagli) {
      // Prima il comportamento di sempre a console, poi il rapporto: gli
      // occhi nuovi non spengono quelli vecchi.
      FlutterError.presentError(dettagli);
      FirebaseCrashlytics.instance.recordFlutterFatalError(dettagli);
    };
    PlatformDispatcher.instance.onError = (errore, pila) {
      FirebaseCrashlytics.instance.recordError(errore, pila, fatal: true);
      return true;
    };
  }

  runApp(EsotericCircleApp(services: services));
}

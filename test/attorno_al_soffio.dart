import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// L'IMPALCATURA MINIMA ATTORNO AL SOFFIO DEL DESTINO. Ordine P voce 26.
///
/// **Perche' questo file esiste, ed e' il costo vero della voce 26.** Il prato
/// del Soffio non era un fondale: era un livello dentro il pittore della scena,
/// e la sua destinazione, `CosmosBackground`, pretende un `MaestroScope` che a
/// sua volta pretende un `Provider<MaestroController>`. Le quattro prove del
/// Soffio montavano la schermata NUDA, dentro un `MaterialApp` e nient'altro:
/// togliere il prato le faceva cadere tutte e quattro.
///
/// **La voce e' stata scritta e rimessa indietro una volta proprio per questo.**
/// Il prato si toglieva in dieci minuti; i quattro file di prova erano il
/// lavoro. Adesso l'impalcatura vive in un punto solo: se domani la scena
/// chiedera' un provider in piu', si aggiunge qui e le quattro prove non se ne
/// accorgono. Scritta quattro volte, avrebbe divergito al primo cambiamento.
///
/// Non e' un mock e non finge niente: sono i controller veri, quelli che l'app
/// monta in `app.dart`, allo stato iniziale.
Widget attornoAlSoffio(
  Widget scena, {
  bool riduciMovimento = false,
  Size? finestra,
  EdgeInsets rientri = EdgeInsets.zero,
}) {
  final dati = MediaQueryData(
    size: finestra ?? const Size(360, 797),
    padding: rientri,
    disableAnimations: riduciMovimento,
  );
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      // **LA CARTA NATALE, ordine CQ voce 6.03.** Senza questo provider la
      // schermata scrive *Soffio, carta natale non raggiungibile* e **il
      // riquadro della risposta non compare affatto**: le prove che si
      // fermavano al respiro non se ne accorgevano, e nessuna arrivava mai
      // a guardare la risposta. Sta qui e non nelle singole prove, che e'
      // la ragione per cui questo file esiste.
      ChangeNotifierProvider(create: (_) => NatalChartController()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: dati,
        // LO SCOPE SENZA MAESTRO DICHIARATO: il Soffio e' il dominio di Aura e
        // la palette se la prende da se', come fa nell'app vera. Forzarne uno
        // qui vorrebbe dire che la prova decide un colore che la schermata
        // dovrebbe decidere.
        child: MaestroScope(child: scena),
      ),
    ),
  );
}

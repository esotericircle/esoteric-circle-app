import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// **LE STESE DAL TOCCO DI "LEGGI LE CARTE", PER MISURARE IL CRASH.** Ordine
/// GC voce GC.01, 22 ottobre 2026.
///
/// Il fondatore: *"La stesa a 10 carte, al click su pulsante \"leggi le
/// carte\" rallenta tantissimo, va a scatti e poi manda in crash l'app che
/// si chiude da sola."* L'account di collaudo e' sul Viandante e la Croce
/// Celtica si apre dall'Adepto: il piano lo decide il server, e cambiarlo
/// vorrebbe dire scrivere dati di produzione (R4). Questo ingresso apre una
/// scelta delle quattro stese (una, tre, quattro e dieci carte) e monta
/// soltanto la schermata della stesa con le carte ancora coperte, come il
/// gemello `la_croce_celtica_per_la_misura.dart` dell'ordine FS: si scelgono
/// le carte dal ventaglio e si tocca "Leggi le Carte", lo stesso percorso
/// della persona. La stessa scelta sul codice di prima e su quello di dopo
/// da' la misura delle stese che non devono peggiorare.
///
/// **Nessuna chiamata al modello (R2)**: la chiamata qui sotto non esce dal
/// telefono e torna un errore, quindi parla la lettura di casa, la stessa
/// che la persona vede quando la rete manca. Non entra nell'app: si
/// costruisce a parte e sostituisce l'app di collaudo finche' non si
/// reinstalla quella vera.
///
/// ```
/// flutter build apk --release -t tool/la_croce_celtica_dal_tocco.dart
/// ```
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(create: (_) => ZodiacController()),
    ],
    // Il tema del Maestro sta sopra il navigatore, cosi' copre anche la
    // stesa aperta dalla scelta: sotto la sola `home` la rotta nuova
    // nasceva senza palette, e in rilascio si vedeva grigia.
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, figlio) => MaestroScope(child: figlio!),
      home: const _LaScelta(),
    ),
  ));
}

/// Le quattro stese, una per riga, grandi: si toccano senza mirare.
class _LaScelta extends StatelessWidget {
  const _LaScelta();

  static const List<TarotSpreadType> stese = [
    TarotSpreadType.unaCarta,
    TarotSpreadType.treCarte,
    TarotSpreadType.croceQuattro,
    TarotSpreadType.dieciCarte,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          for (final tipo in stese)
            Expanded(
              child: InkWell(
                key: Key('banco_${tipo.name}'),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => StesaTreCarteScreen(
                    seed: 2,
                    topic: TarotTopic.momentoCheVivo,
                    tipo: tipo,
                    chiamata: (istruzione, richiesta, campi) async =>
                        throw StateError(
                            'banco GC.01: nessuna chiamata al modello'),
                  ),
                )),
                child: Center(
                  child: Text('${tipo.posizioni.length}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 64)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

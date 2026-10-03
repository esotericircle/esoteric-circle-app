// Il banco della prova a video dell'ordine DP, voce 04.
//
// **PERCHE' UN BANCO A PARTE.** Sul telefono di collaudo l'onboarding del
// fondatore e' gia' compiuto, e le animazioni di sistema sono spente: la
// Carta di Nascita salta all'ultimo momento e il video del Maestro non nasce
// nemmeno, come vuole Riduci Movimento. Rifare l'onboarding vorrebbe dire
// cancellare i dati dell'app del fondatore, e cambiare le animazioni vorrebbe
// dire toccare le impostazioni del telefono: nessuna delle due si fa.
//
// Questo banco monta **le stesse schermate vere** dell'onboarding, col
// movimento acceso: la Carta di Nascita col suo pulsante e la rivelazione dei
// tre Maestri col loro video. Non scrive niente e non legge niente dell'app.
//
// Uso: flutter run --profile -d <telefono> -t tool/banco_del_risveglio.dart
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/immersive_scaffold.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/maestro_reveal_screen.dart';
import 'package:esoteric_circle/features/onboarding/rivelazione_carta_di_nascita.dart';
import 'package:esoteric_circle/features/onboarding/widgets/pulsante_del_risveglio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => IdentityController()),
      ChangeNotifierProvider(create: (_) => NatalChartController()),
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        // **IL MOVIMENTO ACCESO**, solo qui: e' la persona che non ha chiesto
        // meno movimento, cioe' quella che il fondatore e' stato provando.
        data: MediaQuery.of(context).copyWith(disableAnimations: false),
        child: MaestroScope(child: child!),
      ),
      home: const _Menu(),
    ),
  ));
}

class _Menu extends StatelessWidget {
  const _Menu();

  @override
  Widget build(BuildContext context) {
    Widget voce(String testo, Widget Function() pagina) => Padding(
          padding: const EdgeInsets.all(8),
          child: PulsanteDelRisveglio(
            chiave: Key('banco_$testo'),
            testo: testo,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => pagina())),
          ),
        );
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              voce('Carta', () => const _Carta()),
              for (final m in Maestro.values)
                // Dentro lo stesso fondo del percorso del risveglio.
                voce(
                    m.id,
                    () => ImmersiveScaffold(
                          seed: 14,
                          child: MaestroRevealScreen(
                            maestro: m,
                            onRevealed: (_) {},
                          ),
                        )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Carta extends StatefulWidget {
  const _Carta();

  @override
  State<_Carta> createState() => _CartaState();
}

class _CartaState extends State<_Carta> {
  bool _finita = false;

  @override
  Widget build(BuildContext context) => ImmersiveScaffold(
        seed: 14,
        child: SafeArea(
          child: RivelazioneCartaDiNascita(
            nascita: DateTime(1979, 3, 24),
            onFinita: () => setState(() => _finita = true),
            azione: PulsanteDelRisveglio(
              chiave: const Key('carta_di_nascita_continua'),
              onPressed: _finita ? () {} : null,
              testo: 'Guarda il cielo della tua nascita',
            ),
          ),
        ),
      );
}

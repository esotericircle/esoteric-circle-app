// La misura dei fotogrammi del giro delle settantotto carte, ordine DP voce
// 01.3: "La fluidita' va misurata sul telefono e riportata: se scende sotto i
// cinquanta fotogrammi al secondo, si riduce il numero delle carte visibili
// contemporaneamente e non il numero delle carte che passano."
//
// **PERCHE' UN PUNTO D'INGRESSO A PARTE.** Il telefono di collaudo ha le
// animazioni di sistema spente, e la schermata vera, giustamente, salta
// all'ultimo momento: li' il giro non si vede. Questo ingresso monta la stessa
// scena col movimento acceso e conta i fotogrammi dal motore, in profilo.
//
// Uso: flutter run --profile -d <telefono> -t tool/misura_del_mazzo.dart
// e si legge nel registro la riga che comincia con MISURA DEL MAZZO.

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/immersive_scaffold.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/rivelazione_carta_di_nascita.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

// Zero e' il giro di controllo: un quadrato che ruota, per sapere quanti
// fotogrammi al secondo il telefono consegna quando la scena non costa niente.
const List<int> _quante = [0, 78, 78, 78, 56, 40, 0];

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Banco());
}

class _Banco extends StatefulWidget {
  const _Banco();

  @override
  State<_Banco> createState() => _BancoState();
}

class _BancoState extends State<_Banco> {
  int _giro = 0;
  final List<FrameTiming> _tempi = [];
  final Stopwatch _orologio = Stopwatch();
  int _costruiti = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_tempi.addAll);
    // **OGNI FOTOGRAMMA COSTRUITO SI CONTA QUI**: i tempi del motore
    // arrivano a pacchetti, e l'ultimo pacchetto di un giro arriva dopo la
    // sua fine.
    SchedulerBinding.instance.addPersistentFrameCallback((_) => _costruiti++);
    _orologio.start();
  }

  Future<void> _finito() async {
    final secondi = _orologio.elapsedMicroseconds / 1e6;
    final costruiti = _costruiti;
    // Si aspetta che il motore consegni gli ultimi tempi del giro.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    // Il primo giro scalda la cache delle immagini e degli shader: si
    // riporta, ma la misura che conta e' la seconda a settantotto.
    final lenti =
        _tempi.where((t) => t.totalSpan.inMicroseconds > 16667).length;
    final peggiore = _tempi.isEmpty
        ? 0
        : _tempi
            .map((t) => t.totalSpan.inMicroseconds)
            .reduce((a, b) => a > b ? a : b);
    final raster = _tempi.isEmpty
        ? 0
        : _tempi
                .map((t) => t.rasterDuration.inMicroseconds)
                .reduce((a, b) => a + b) ~/
            _tempi.length;
    debugPrint('MISURA DEL MAZZO: giro ${_giro + 1}, carte visibili '
        '${_quante[_giro]}, fotogrammi ${_tempi.length} in '
        '${secondi.toStringAsFixed(2)} s, '
        'costruiti $costruiti, ${(costruiti / secondi).toStringAsFixed(1)} '
        'al secondo, '
        'oltre 16,7 ms $lenti, peggiore ${peggiore ~/ 1000} ms, '
        'raster medio ${(raster / 1000).toStringAsFixed(1)} ms');
    if (_giro + 1 >= _quante.length) {
      debugPrint('MISURA DEL MAZZO: FINE');
      return;
    }
    setState(() {
      _giro++;
      _tempi.clear();
      _costruiti = 0;
      _orologio
        ..reset()
        ..start();
    });
  }

  @override
  Widget build(BuildContext context) {
    // **LE CONDIZIONI VERE**: lo stesso fondo cosmico della fase dell'onboarding,
    // `ImmersiveScaffold` col seme 14, coi suoi controllori.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ImmersiveScaffold(
            seed: 14,
            child: SafeArea(
              child: _quante[_giro] == 0
                  ? _Controllo(key: ValueKey(_giro), onFinita: _finito)
                  : RivelazioneCartaDiNascita(
                      key: ValueKey(_giro),
                      nascita: DateTime(1979, 3, 24),
                      visibiliInsieme: _quante[_giro],
                      onFinita: _finito,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Controllo extends StatefulWidget {
  const _Controllo({super.key, required this.onFinita});

  final VoidCallback onFinita;

  @override
  State<_Controllo> createState() => _ControlloState();
}

class _ControlloState extends State<_Controllo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: RivelazioneCartaDiNascita.quantoDura,
    animationBehavior: AnimationBehavior.preserve,
  )
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onFinita();
    })
    ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Transform.rotate(
            angle: _c.value * 20,
            child: const SizedBox(
              width: 80,
              height: 80,
              child: ColoredBox(color: Color(0xFFE9C87A)),
            ),
          ),
        ),
      );
}

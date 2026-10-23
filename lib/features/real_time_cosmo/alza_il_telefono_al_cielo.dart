import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **"ALZA IL TELEFONO AL CIELO", TRE SECONDI E POI IN DISSOLVENZA.** Ordine
/// GD voce GD.25, 23 ottobre 2026. Il fondatore: *"quando si accede al cielo
/// in tempo reale deve comparire una scritta che scompare dopo 3 secondi in
/// disoolvenza «Alza il telefono al Cielo», questo anche nell'onboarding"*.
///
/// **IL PUNTO UNICO DELLA SCRITTA.** La monta `CieloRealeScreen`, che e'
/// anche il passaggio dell'onboarding che mostra il cielo (la macchina del
/// tempo di `RisveglioJourney`, fase `heaven`): una sola scritta, un solo
/// tempo, nelle due schermate.
///
/// **IL TEMPO, DALL'INGRESSO.** Compare in un quarto di secondo, resta piena
/// fino a tre secondi, poi in un secondo sfuma a zero e si toglie
/// dall'albero. Il tempo parte quando la schermata entra, non quando il cielo
/// ha finito di caricarsi: la persona legge la scritta mentre il cielo
/// arriva. Non prende tocchi: il cielo sotto resta toccabile.
class AlzaIlTelefonoAlCielo extends StatefulWidget {
  const AlzaIlTelefonoAlCielo({super.key});

  /// Le parole del fondatore, alla lettera.
  static const String testo = 'Alza il telefono al Cielo';

  /// Quanto ci mette a comparire.
  static const Duration comparsa = Duration(milliseconds: 250);

  /// Fin quando resta piena: tre secondi dall'ingresso.
  static const Duration piena = Duration(seconds: 3);

  /// Quanto dura la dissolvenza, dopo i tre secondi.
  static const Duration dissolvenza = Duration(seconds: 1);

  /// L'opacita' della scritta all'istante [t] dall'ingresso.
  static double opacitaA(Duration t) {
    if (t <= Duration.zero) return 0;
    if (t < comparsa) return t.inMicroseconds / comparsa.inMicroseconds;
    if (t <= piena) return 1;
    final dopo = t - piena;
    if (dopo >= dissolvenza) return 0;
    return 1 -
        Curves.easeInOut
            .transform(dopo.inMicroseconds / dissolvenza.inMicroseconds);
  }

  @override
  State<AlzaIlTelefonoAlCielo> createState() => _AlzaIlTelefonoAlCieloState();
}

class _AlzaIlTelefonoAlCieloState extends State<AlzaIlTelefonoAlCielo>
    with SingleTickerProviderStateMixin {
  static final Duration _tutto =
      AlzaIlTelefonoAlCielo.piena + AlzaIlTelefonoAlCielo.dissolvenza;

  // **LA SCRITTA E' IL CONTENUTO, NON UNA TRANSIZIONE**: senza `preserve`
  // Flutter accorcia l'animazione quando il telefono ha la scala delle
  // animazioni a zero, e la scritta sparirebbe prima di essere letta.
  late final AnimationController _tempo = AnimationController(
    vsync: this,
    duration: _tutto,
    animationBehavior: AnimationBehavior.preserve,
  )
    ..addListener(() => setState(() {}))
    ..forward();

  @override
  void dispose() {
    _tempo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tempo.isCompleted) return const SizedBox.shrink();
    final t = _tutto * _tempo.value;
    final palette = MaestroScope.of(context);
    return IgnorePointer(
      child: Center(
        child: Opacity(
          key: const Key('alza_il_telefono_al_cielo'),
          opacity: AlzaIlTelefonoAlCielo.opacitaA(t),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              AlzaIlTelefonoAlCielo.testo,
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloSezione().copyWith(
                color: palette.goldSoft,
                shadows: const [
                  Shadow(color: Color(0xE6000000), blurRadius: 12),
                  Shadow(color: Color(0x99000000), blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

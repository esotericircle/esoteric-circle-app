import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../widgets/busto_del_maestro.dart';

/// Apertura della chat prima del primo messaggio: IL MAESTRO E IL SUO
/// BENVENUTO, e nient'altro.
///
/// ORDINE 2164, VOCI 3 E 4. Qui vivevano due altre porte ai suggerimenti: il
/// pulsante "Tocca per tutte le domande" e la riga orizzontale di tre domande
/// d'assaggio. Parole di Mauro: bolle inutili e ripetitive, e il pulsante e'
/// una ripetizione dell'icona a stelline accanto al campo. Sono state TOLTE,
/// non nascoste: **resta una porta sola ai suggerimenti, l'icona a stelline**,
/// e una prova enumerante conta quella porta e cade se qualcuno ne riapre una
/// seconda.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.maestro,
    required this.greeting,
    this.spazioInFondo = 0,
  });

  final Maestro maestro;
  final String greeting;

  /// IL FONDO PORTA IL COMPOSITORE E LA BARRA, come nella lista dei
  /// messaggi: la misura arriva dalla schermata, che e' l'unica a conoscere
  /// l'altezza vera del suo compositore.
  final double spazioInFondo;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.lg,
        SpacingTokens.lg,
        SpacingTokens.lg + spazioInFondo,
      ),
      child: Column(
        children: [
          // IL BUSTO DALLA PORTA UNICA, ordine I voce 1, alla grandezza
          // canonica della Stesa: la figura intera in alto non esiste piu'.
          // La misura 220 del 2164 apparteneva alla figura intera; il busto
          // canonico e' piu' alto ma ritagliato, e il benvenuto resta il
          // primo testo sotto di lui.
          BustoDelMaestro(maestro: maestro),
          const SizedBox(height: SpacingTokens.md),
          Text(
            greeting,
            key: const Key('chat_benvenuto'),
            textAlign: TextAlign.center,
            // AL PRIMARIO, ordine 2163 voce 9: il benvenuto era grigio
            // (textSecondary) sul fondale scuro, la prima cosa che si legge
            // ed era la meno leggibile. Il minimo dichiarato per il testo
            // d'apertura e' 7 di contrasto, misurato dalla prova.
            style: TypographyTokens.body(size: 18).copyWith(
              color: ColorTokens.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

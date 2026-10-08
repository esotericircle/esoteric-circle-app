/// REAL TIME COSMO, la voce temporanea del menu utente. Ordine FG parte 6.
///
/// **VOCE TEMPORANEA: si toglie quando il fondatore avra' deciso sulla
/// sostituzione del Cielo esistente** (voce 6.2), dopo aver provato le tre
/// opzioni sul telefono. Con lei esce anche questa schermata, e dei due
/// cataloghi ne resta uno solo (vedi `catalogo_delle_stelle.dart`).
///
/// Le tre scelte sono separate di proposito (voce 6.1), cosi' si giudicano
/// una per una: il cielo di adesso, il cielo della nascita, il ritorno
/// indietro nel tempo. **Nessun limite di piano** (voce 6.3): nessuna delle
/// tre chiede un abbonamento, per decisione del fondatore dell'8 ottobre
/// 2026. **Nessuna domanda all'ingresso** (voce 6.4).
library;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import 'cielo_reale_screen.dart';
import 'lo_stile_del_cielo.dart';

class RealTimeCosmoScreen extends StatelessWidget {
  const RealTimeCosmoScreen({super.key});

  static Route<void> route() =>
      PassaggioDelCerchio.rotta<void>((_) => const MaestroScope(
            maestro: Maestro.medora,
            child: RealTimeCosmoScreen(),
          ));

  @override
  Widget build(BuildContext context) {
    final titolo = TypographyTokens.titoloDiRiga()
        .copyWith(color: ColorTokens.goldBright);
    final testo =
        TypographyTokens.corpo().copyWith(color: ColorTokens.textSecondary);
    return Scaffold(
      backgroundColor: kFondoDelCielo,
      appBar: AppBar(
        backgroundColor: kFondoDelCielo,
        foregroundColor: ColorTokens.textPrimary,
        title: Text('Real Time Cosmo',
            style: TypographyTokens.titoloDiSchermata()
                .copyWith(color: ColorTokens.textPrimary)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Prova temporanea: tre modi di entrare nel cielo vero, da '
              'giudicare uno per uno.',
              style: testo,
            ),
            const SizedBox(height: 16),
            for (final s in _scelte)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: ColorTokens.medoraDeep,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    key: Key('real_time_cosmo_${s.modo.name}'),
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context)
                        .push(CieloRealeScreen.route(s.modo)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(s.icona, color: ColorTokens.goldLight, size: 30),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.titolo, style: titolo),
                                const SizedBox(height: 4),
                                Text(s.testo, style: testo),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: ColorTokens.textSecondary),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const List<_SceltaDelCielo> _scelte = [
    _SceltaDelCielo(
      ModoDelCielo.adesso,
      Icons.explore_rounded,
      'Il cielo di adesso',
      'Le stelle vere sopra di te in questo momento: alza il telefono o '
          'esplora col dito.',
    ),
    _SceltaDelCielo(
      ModoDelCielo.nascita,
      Icons.auto_awesome_rounded,
      'Il cielo della tua nascita',
      'Le stelle, la Luna e i pianeti di quell\'istante, dal luogo della tua '
          'nascita.',
    ),
    _SceltaDelCielo(
      ModoDelCielo.ritorno,
      Icons.history_rounded,
      'Il ritorno indietro nel tempo',
      'Gli anni scendono fino a zero mentre il cielo gira all\'indietro, '
          'fino alla tua nascita.',
    ),
  ];
}

class _SceltaDelCielo {
  const _SceltaDelCielo(this.modo, this.icona, this.titolo, this.testo);
  final ModoDelCielo modo;
  final IconData icona;
  final String titolo;
  final String testo;
}

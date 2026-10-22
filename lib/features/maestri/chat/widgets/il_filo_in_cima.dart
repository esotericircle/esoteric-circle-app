import 'package:flutter/material.dart';

import '../../../../core/chat/il_filo_del_consulto.dart';
import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// **IL FILO IN CIMA ALLA CHAT. Ordine FE voce 22**, la richiesta del
/// fondatore del 6 ottobre 2026: *"ad ogni nuova apertura di conversazione,
/// in alto la domanda dell'utente venga ripetuta tipo: hai chiesto a [nome
/// maestro] quando riceverò una promozione, e magari aggiungere cosa ha
/// risposto il maestro precedente"*.
///
/// Compare quando il consulto in corso e' passato da un altro Maestro: la
/// domanda iniziale, a chi e' stata fatta, e il parere di ogni Maestro gia'
/// consultato. Chiusa occupa due righe, perche' chi scrive non deve perdere
/// lo spazio della conversazione; un tocco la apre. Legge la stessa scheda
/// che il Maestro riceve ([IlFiloDelConsulto]): cio' che la persona legge e'
/// cio' che il Maestro sa. Oltre l'ora del filo non compare.
class IlFiloInCima extends StatefulWidget {
  const IlFiloInCima({super.key, required this.maestro});

  /// Il Maestro della chat aperta.
  final Maestro maestro;

  /// Vero quando la scheda va mostrata nella chat di [maestro]: c'e' un
  /// consulto in corso, [maestro] ne fa parte (gli e' stata posta la
  /// domanda o ha gia' detto il suo parere) e c'e' almeno un altro Maestro
  /// da ricordare.
  ///
  /// **SOLO NELLA CHAT GIUSTA. Ordine GB voce 05, 22 ottobre 2026.** Prima
  /// la condizione guardava solo se ESISTEVA un altro Maestro nel consulto,
  /// non se [maestro] vi avesse mai preso parte: nella chat di Aura
  /// compariva "Hai chiesto a Calìgo" anche quando il consulto era tutto e
  /// solo di Calìgo, e Aura non lo aveva mai toccato. Padre: rapporto
  /// dell'ordine GA, punto 5 ("la carta non filtra per Maestro").
  static bool siMostra(SchedaDeiPuntiFermi? s, Maestro maestro) {
    if (s == null) return false;
    final neFaParte =
        s.daMaestro == maestro || s.pareri.any((p) => p.maestro == maestro);
    if (!neFaParte) return false;
    return s.daMaestro != maestro || s.pareri.any((p) => p.maestro != maestro);
  }

  @override
  State<IlFiloInCima> createState() => _IlFiloInCimaState();
}

class _IlFiloInCimaState extends State<IlFiloInCima> {
  bool _aperta = false;

  @override
  Widget build(BuildContext context) {
    final s = IlFiloDelConsulto.scheda;
    if (!IlFiloInCima.siMostra(s, widget.maestro)) {
      return const SizedBox.shrink();
    }
    final palette = MaestroScope.forse(context) ?? MaestroPalette.neutral;
    final scheda = s!;
    final pareri = scheda.pareri;
    final quanti = pareri.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.xs,
          SpacingTokens.lg, SpacingTokens.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('filo_in_cima'),
          enableFeedback: false,
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _aperta = !_aperta),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hai chiesto a ${scheda.daMaestro.nomeAVideo}: '
                  '«${scheda.tema}»',
                  key: const Key('filo_in_cima_domanda'),
                  maxLines: _aperta ? null : 2,
                  overflow: _aperta ? null : TextOverflow.ellipsis,
                  style: TypographyTokens.corpo()
                      .copyWith(color: palette.goldSoft, height: 1.3),
                ),
                if (!_aperta && quanti > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      quanti == 1
                          ? 'Il parere di ${pareri.first.maestro.nomeAVideo}. '
                              'Tocca per leggerlo.'
                          : 'I pareri di ${_iNomi([
                                  for (final p in pareri) p.maestro.nomeAVideo
                                ])}. Tocca per leggerli.',
                      key: const Key('filo_in_cima_chiusa'),
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary),
                    ),
                  ),
                if (_aperta)
                  for (final p in pareri)
                    Padding(
                      padding: const EdgeInsets.only(top: SpacingTokens.xs),
                      child: Text(
                        '${p.maestro.nomeAVideo}: «${p.parere}»',
                        key: Key('filo_in_cima_${p.maestro.name}'),
                        style: TypographyTokens.corpo().copyWith(
                            color: ColorTokens.textPrimary, height: 1.35),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// I nomi come si dicono: "Medora e Calìgo", "Medora, Calìgo e Aura". Visto
/// sul Realme con la build 2299 il 6 ottobre 2026: con tre Maestri il filo
/// diceva "Medora e Calìgo e Aura".
String _iNomi(List<String> nomi) => nomi.length < 3
    ? nomi.join(' e ')
    : '${nomi.sublist(0, nomi.length - 1).join(', ')} e ${nomi.last}';

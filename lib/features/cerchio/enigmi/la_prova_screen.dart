import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/cerchio/gli_enigmi_del_cerchio.dart';
import '../../../core/cerchio/i_tempi_dei_giochi.dart';
import '../../../core/cerchio/il_cerchio_sociale.dart';
import '../../../core/cerchio/il_testo_degli_enigmi.dart';
import '../../../core/cerchio/la_prova.dart';
import '../../../core/chat/la_marca_del_genere.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../widgets/disegni_del_cerchio.dart';
import 'i_mattoni_degli_enigmi.dart';

/// **LA PROVA DELLA SETTIMANA.** Ordine FF voce 05, 8 ottobre 2026.
///
/// Il fondatore: *"proponiamo al cerchio un test di personalità il cui
/// punteggio determina la personalità o altra caratteristica dell'utente"*.
/// Il tema lo sceglie il cielo del lunedi' (`LaProva`), le dieci domande
/// vengono dal corpus dell'Architetto, il punteggio lo calcola il server coi
/// pesi del corpus e si accompagna alla figura della sua fascia. La Prova
/// vive sette giorni: il tempo che resta si vede sempre (voce FF.07).
class LaProvaScreen extends StatefulWidget {
  const LaProvaScreen({super.key, this.adesso, this.temaFissato});

  /// L'istante, per le prove e le anteprime; nullo vuol dire adesso.
  final DateTime? adesso;

  /// Il tema che il server ha gia' fissato per la settimana, se c'e'.
  final int? temaFissato;

  static Route<void> route({int? temaFissato}) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
          neutro: true, child: LaProvaScreen(temaFissato: temaFissato)));

  @override
  State<LaProvaScreen> createState() => _LaProvaScreenState();
}

class _LaProvaScreenState extends State<LaProvaScreen> {
  late final DateTime _adesso = widget.adesso ?? DateTime.now();
  late final TemaDellaProva _tema = widget.temaFissato != null
      ? LaProva.temi[widget.temaFissato! - 1]
      : LaProva.temaDi(_adesso);
  late final List<DomandaDellaProva> _domande = [
    for (final d in LaProva.domandeDi(_adesso)) _tema.domande[d.numero - 1],
  ];
  late final List<int?> _scelte = List.filled(_domande.length, null);
  bool _scrivo = false;
  int? _punteggio;
  String? _riga;

  Future<void> _consegna() async {
    setState(() => _scrivo = true);
    final esito = await context
        .read<IlCerchioSociale>()
        .consegnaLaProva(_tema.numero, [for (final s in _scelte) s!]);
    if (!mounted) return;
    setState(() {
      _scrivo = false;
      if (esito.ok && esito.dati['punteggio'] is num) {
        _punteggio = (esito.dati['punteggio'] as num).toInt();
      } else if (esito.motivo == 'tema') {
        _riga =
            'La Prova di questa settimana è cambiata: riaprila dal Cerchio.';
      } else {
        _riga = esito.riga ?? EsitoDelGesto.silenzio.riga;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final forma = LaMarcaDelGenere.formaCorrente;
    final scade = ITempiDeiGiochi.scadenza(GiocoDelCerchio.prova, _adesso)!;
    final resta = ilTempoCheResta(ITempiDeiGiochi.resta(scade, _adesso));
    final punteggio = _punteggio;
    final fascia = punteggio == null ? null : LaProva.fascia(_tema, punteggio);
    return conIPulsantiDOro(
        context,
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: palette.goldSoft),
            title: Text('La Prova della settimana',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: palette.goldSoft)),
          ),
          body: ListView(
            key: const Key('la_prova'),
            padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md, 0, SpacingTokens.md, SpacingTokens.xl),
            children: [
              Text(_tema.nome,
                  key: const Key('prova_tema'),
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: palette.goldSoft)),
              Text('Finisce fra $resta.',
                  key: const Key('prova_tempo'),
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
              if (fascia != null) ...[
                const SizedBox(height: SpacingTokens.lg),
                Text('$punteggio',
                    key: const Key('prova_punteggio'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.cerimoniale()
                        .copyWith(color: palette.goldSoft, fontSize: 56)),
                Text(fascia.figura,
                    textAlign: TextAlign.center,
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: ColorTokens.textPrimary)),
                const SizedBox(height: SpacingTokens.sm),
                RigaDegliEnigmi(IlTestoDegliEnigmi.perChiCompila(
                    fascia.testoMarcato, forma)),
              ] else ...[
                for (var i = 0; i < _domande.length; i++) ...[
                  SezioneDegliEnigmi('Domanda ${i + 1} di 10'),
                  Text(
                      IlTestoDegliEnigmi.perChiCompila(
                          _domande[i].testoMarcato, forma),
                      style: TypographyTokens.titoloDiRiga()
                          .copyWith(color: ColorTokens.textPrimary)),
                  for (var r = 0; r < _domande[i].risposte.length; r++)
                    InkWell(
                      key: Key('prova_${i}_$r'),
                      enableFeedback: false,
                      onTap: () => setState(() => _scelte[i] = r),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.xs),
                        child: Row(children: [
                          Icon(
                              _scelte[i] == r
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 22,
                              color: _scelte[i] == r
                                  ? palette.goldSoft
                                  : ColorTokens.textSecondary),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: Text(
                                IlTestoDegliEnigmi.perChiCompila(
                                    _domande[i].risposte[r].testoMarcato,
                                    forma),
                                style: TypographyTokens.corpo()
                                    .copyWith(color: ColorTokens.textPrimary)),
                          ),
                        ]),
                      ),
                    ),
                ],
                const SizedBox(height: SpacingTokens.lg),
                if (_riga != null) RigaDegliEnigmi(_riga!, oro: true),
                PulsanteDegliEnigmi(
                  key: const Key('prova_consegna'),
                  etichetta:
                      _scrivo ? 'Un momento...' : 'Scopri il tuo punteggio',
                  onPressed:
                      !_scelte.contains(null) && !_scrivo ? _consegna : null,
                ),
              ],
            ],
          ),
        ));
  }
}

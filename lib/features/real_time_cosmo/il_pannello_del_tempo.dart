/// IL PANNELLO DEL TEMPO: il selettore della data della Macchina del tempo.
/// Aggiunta all'ordine FH, voci D1-D10.
///
/// Sale dal basso sopra la schermata, col cielo visibile dietro (D7). In cima
/// le due scorciatoie, "La tua nascita" e "Adesso" (D6), sotto tre ruote
/// affiancate, giorno, mese e anno, nella cornice d'oro delle ruote della
/// data di nascita dell'onboarding, poi la riga del luogo (D5) e il pulsante
/// che fa partire la corsa: le scorciatoie e le ruote scelgono il giorno, la
/// corsa parte solo dal pulsante (frase del fondatore del 10 ottobre 2026,
/// "voglio un pulsante per l'utente che premera' quando vuole fare partire
/// l'animazione"). Si chiude col gesto di sistema, col dito che scende e col
/// tocco fuori (D9). L'ora non compare e non si sceglie (D4).
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../core/astro/data_italiana.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'il_tempo_del_cosmo.dart';

/// La scelta fatta nel pannello.
class SceltaDelTempo {
  const SceltaDelTempo(this.giorno, this.luogo, {this.adesso = false});

  /// Il giorno del calendario scelto.
  final DateTime giorno;
  final LuogoDelTempo luogo;

  /// Vero se la scelta e' "Adesso": l'istante di adesso, non un'ora di
  /// nascita portata su oggi.
  final bool adesso;
}

/// L'etichetta del pulsante della schermata che fa partire la corsa: un
/// invito (Architetto, 10 ottobre 2026).
const String kEtichettaDelViaggio = 'Viaggia nel tempo';

/// L'etichetta del pulsante del pannello che conferma il giorno scelto: dice
/// che porta li' (Architetto, 10 ottobre 2026).
const String kEtichettaDellaConferma = 'Portami lì';

/// L'altezza di una voce delle ruote: l'area di tocco minima delle Linee
/// Guida, 48 punti (D9).
const double kVoceDellaRuota = 48;

class PannelloDelTempo extends StatefulWidget {
  const PannelloDelTempo({
    super.key,
    required this.scelta,
    required this.nascita,
    required this.oggi,
    required this.nomeDelLuogoDiNascita,
    required this.nomeDelLuogoAttuale,
    required this.onParti,
  });

  /// La scelta di partenza: la nascita, se c'e' (D2), oppure oggi (D3).
  final SceltaDelTempo scelta;

  /// Il giorno di nascita, o nessuno.
  final DateTime? nascita;
  final DateTime oggi;

  /// I nomi dei due luoghi; nessuno se quel luogo non c'e'.
  final String? nomeDelLuogoDiNascita;
  final String? nomeDelLuogoAttuale;

  final ValueChanged<SceltaDelTempo> onParti;

  @override
  State<PannelloDelTempo> createState() => _PannelloDelTempoState();
}

class _PannelloDelTempoState extends State<PannelloDelTempo> {
  late DateTime _giorno = widget.scelta.giorno;
  late LuogoDelTempo _luogo = widget.scelta.luogo;
  late bool _adesso = widget.scelta.adesso;
  late final FixedExtentScrollController _ruotaDelGiorno =
      FixedExtentScrollController(initialItem: _giorno.day - 1);
  late final FixedExtentScrollController _ruotaDelMese =
      FixedExtentScrollController(initialItem: _giorno.month - 1);
  late final FixedExtentScrollController _ruotaDellAnno =
      FixedExtentScrollController(
          initialItem: _giorno.year - kPrimoAnnoDellaMacchina);

  @override
  void dispose() {
    _ruotaDelGiorno.dispose();
    _ruotaDelMese.dispose();
    _ruotaDellAnno.dispose();
    super.dispose();
  }

  bool _stesso(DateTime a, DateTime? b) =>
      b != null && a.year == b.year && a.month == b.month && a.day == b.day;

  /// Il luogo segue la regola della D5 quando cambia il giorno: la nascita
  /// sul giorno di nascita, il luogo attuale su ogni altro giorno, se c'e'.
  LuogoDelTempo _luogoDelGiorno(DateTime g) {
    if (_stesso(g, widget.nascita) && widget.nomeDelLuogoDiNascita != null) {
      return LuogoDelTempo.nascita;
    }
    if (widget.nomeDelLuogoAttuale != null) return LuogoDelTempo.attuale;
    return LuogoDelTempo.nascita;
  }

  void _cambia(int anno, int mese, int giorno) {
    final nuovo = giornoValido(anno, mese, giorno);
    if (nuovo == _giorno) return;
    setState(() {
      _giorno = nuovo;
      _adesso = false;
      _luogo = _luogoDelGiorno(nuovo);
    });
    // Il giorno che scala all'ultimo valido del mese (D8) si vede anche
    // sulla ruota.
    if (_ruotaDelGiorno.hasClients &&
        _ruotaDelGiorno.selectedItem != nuovo.day - 1) {
      _ruotaDelGiorno.jumpToItem(nuovo.day - 1);
    }
  }

  void _porta(DateTime g, {required bool adesso}) {
    setState(() {
      _giorno = g;
      _adesso = adesso;
      _luogo = _luogoDelGiorno(g);
    });
    _ruotaDellAnno.jumpToItem(g.year - kPrimoAnnoDellaMacchina);
    _ruotaDelMese.jumpToItem(g.month - 1);
    _ruotaDelGiorno.jumpToItem(g.day - 1);
    SemanticsService.sendAnnouncement(
        View.of(context), dataItalianaEstesa(g), TextDirection.ltr);
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.of(context);
    final altro = _luogo == LuogoDelTempo.nascita
        ? widget.nomeDelLuogoAttuale
        : widget.nomeDelLuogoDiNascita;
    final nome = _luogo == LuogoDelTempo.nascita
        ? widget.nomeDelLuogoDiNascita
        : widget.nomeDelLuogoAttuale;
    final rigaDelLuogo = _luogo == LuogoDelTempo.nascita
        ? 'Cielo su ${nome ?? 'il luogo di nascita'}, il tuo luogo di nascita.'
        : 'Cielo su ${nome ?? 'dove sei ora'}, dove sei ora.';
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scegli il giorno',
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloScheda()
                  .copyWith(color: palette.goldSoft),
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: [
                Expanded(
                  child: _Scorciatoia(
                    key: const Key('macchina_scorciatoia_nascita'),
                    testo: 'La tua nascita',
                    attiva: _stesso(_giorno, widget.nascita) && !_adesso,
                    onTocco: widget.nascita == null
                        ? null
                        : () => _porta(widget.nascita!, adesso: false),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: _Scorciatoia(
                    key: const Key('macchina_scorciatoia_adesso'),
                    testo: 'Adesso',
                    attiva: _adesso,
                    onTocco: () => _porta(widget.oggi, adesso: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            SizedBox(
              height: kVoceDellaRuota * 3,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _Ruota(
                      key: const Key('macchina_ruota_giorno'),
                      etichetta: 'Giorno',
                      controllo: _ruotaDelGiorno,
                      voci: [
                        for (var d = 1;
                            d <= giorniDelMese(_giorno.year, _giorno.month);
                            d++)
                          '$d'
                      ],
                      scelta: _giorno.day - 1,
                      onScelta: (i) =>
                          _cambia(_giorno.year, _giorno.month, i + 1),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    flex: 4,
                    child: _Ruota(
                      key: const Key('macchina_ruota_mese'),
                      etichetta: 'Mese',
                      controllo: _ruotaDelMese,
                      voci: mesiInItaliano,
                      scelta: _giorno.month - 1,
                      onScelta: (i) =>
                          _cambia(_giorno.year, i + 1, _giorno.day),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    flex: 3,
                    child: _Ruota(
                      key: const Key('macchina_ruota_anno'),
                      etichetta: 'Anno',
                      controllo: _ruotaDellAnno,
                      voci: [
                        for (var a = kPrimoAnnoDellaMacchina;
                            a <= kUltimoAnnoDellaMacchina;
                            a++)
                          '$a'
                      ],
                      scelta: _giorno.year - kPrimoAnnoDellaMacchina,
                      onScelta: (i) => _cambia(kPrimoAnnoDellaMacchina + i,
                          _giorno.month, _giorno.day),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              key: const Key('macchina_riga_del_luogo'),
              children: [
                Expanded(
                  child: Text(
                    rigaDelLuogo,
                    style: TypographyTokens.corpo().copyWith(
                        color: palette.goldSoft.withValues(alpha: 0.85)),
                  ),
                ),
                if (altro != null)
                  TextButton(
                    key: const Key('macchina_cambia_luogo'),
                    onPressed: () => setState(() => _luogo =
                        _luogo == LuogoDelTempo.nascita
                            ? LuogoDelTempo.attuale
                            : LuogoDelTempo.nascita),
                    child: Text(
                      _luogo == LuogoDelTempo.nascita
                          ? 'Usa dove sei ora'
                          : 'Usa il luogo di nascita',
                      // Lo stile delle azioni di casa: l'oro in corpo non
                      // arrivava al contrasto di 7 sui fondi dei Maestri.
                      style: TypographyTokens.etichetta()
                          .copyWith(color: ColorTokens.goldLight),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            FilledButton(
              key: const Key('macchina_viaggia'),
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                minimumSize: const Size.fromHeight(kVoceDellaRuota),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
                ),
              ),
              onPressed: () => widget
                  .onParti(SceltaDelTempo(_giorno, _luogo, adesso: _adesso)),
              child: Text(
                kEtichettaDellaConferma,
                style: TypographyTokens.corpo(weight: 600)
                    .copyWith(color: palette.deepest),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Scorciatoia extends StatelessWidget {
  const _Scorciatoia({
    super.key,
    required this.testo,
    required this.attiva,
    required this.onTocco,
  });
  final String testo;
  final bool attiva;
  final VoidCallback? onTocco;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.of(context);
    return OutlinedButton(
      onPressed: onTocco,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(kVoceDellaRuota),
        backgroundColor:
            attiva ? palette.gold.withValues(alpha: 0.18) : Colors.transparent,
        side: BorderSide(color: palette.gold.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        ),
      ),
      child: Text(
        testo,
        style: TypographyTokens.corpo(weight: 600)
            .copyWith(color: palette.goldSoft),
      ),
    );
  }
}

/// Una ruota: la cornice d'oro delle ruote della data dell'onboarding, la
/// voce scelta al centro in oro, le altre piu' tenui. L'etichetta si legge
/// a voce, e la scelta si annuncia quando la ruota si ferma (D9).
class _Ruota extends StatelessWidget {
  const _Ruota({
    super.key,
    required this.etichetta,
    required this.controllo,
    required this.voci,
    required this.scelta,
    required this.onScelta,
  });

  final String etichetta;
  final FixedExtentScrollController controllo;
  final List<String> voci;
  final int scelta;
  final ValueChanged<int> onScelta;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroScope.of(context);
    final i = scelta.clamp(0, voci.length - 1);
    return Semantics(
      label: etichetta,
      value: voci[i],
      increasedValue: i + 1 < voci.length ? voci[i + 1] : null,
      decreasedValue: i > 0 ? voci[i - 1] : null,
      onIncrease:
          i + 1 < voci.length ? () => controllo.jumpToItem(i + 1) : null,
      onDecrease: i > 0 ? () => controllo.jumpToItem(i - 1) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
          color: palette.deepest.withValues(alpha: 0.4),
        ),
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (_) {
            SemanticsService.sendAnnouncement(
                View.of(context),
                '$etichetta ${voci[controllo.selectedItem.clamp(0, voci.length - 1)]}',
                TextDirection.ltr);
            return false;
          },
          child: ListWheelScrollView.useDelegate(
            controller: controllo,
            itemExtent: kVoceDellaRuota,
            physics: const FixedExtentScrollPhysics(),
            diameterRatio: 1.6,
            onSelectedItemChanged: onScelta,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: voci.length,
              builder: (context, k) => Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    voci[k],
                    style: TypographyTokens.titoloScheda().copyWith(
                      color: k == i
                          ? palette.gold
                          : palette.goldSoft.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

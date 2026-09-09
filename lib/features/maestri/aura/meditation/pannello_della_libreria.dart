import 'package:flutter/material.dart';

import '../../../../core/maestro/libreria_dei_respiri.dart';
import '../../../../core/maestro/sequenza_di_aura.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';

/// **LA LIBRERIA E IL RITO CHE TI COSTRUISCI.** Ordine DB voci 01, 02 e 05,
/// 9 settembre 2026.
///
/// **STA SOTTO, E NON DAVANTI.** La porta principale resta quella decisa
/// dall'ordine CZ voce 06: la pratica di oggi la sceglie Aura dal centro
/// acceso, perche' *"un menu' davanti a chi non ha criterio per scegliere e'
/// la forma sbagliata"*. Questo pannello e' chiuso finche' non lo si apre, ed
/// e' per chi vuole cercare.
///
/// **L'AMPIEZZA SI DICHIARA, e non si gonfia.** Ordine DB voce 01: *"la
/// libreria dichiara la propria ampiezza, come fa la Z-App con il numero in
/// home"*. Qui il numero e' doppio e onesto: quante sono pronte e quante ne
/// sono previste. Dichiarare millecinquecento pratiche avendone dieci e'
/// esattamente cio' che rende inaffidabile l'app di riferimento.
class PannelloDellaLibreria extends StatefulWidget {
  const PannelloDellaLibreria({
    super.key,
    required this.palette,
    required this.centroDiOggi,
    this.sequenze,
  });

  final MaestroPalette palette;

  /// L'indice del centro acceso oggi: le sue pratiche vengono per prime.
  final int centroDiOggi;

  /// Le sequenze conservate. Nulla nelle prove che non le vogliono.
  final SequenzeDiAura? sequenze;

  @override
  State<PannelloDellaLibreria> createState() => _PannelloDellaLibreriaState();
}

class _PannelloDellaLibreriaState extends State<PannelloDellaLibreria> {
  bool _aperto = false;

  /// Gli id scelti per la sequenza che si sta componendo, **nell'ordine in cui
  /// si fanno**: la sequenza e' una fila, non un insieme.
  final List<String> _inComposizione = [];

  final TextEditingController _nome = TextEditingController();

  SequenzeDiAura? get _sequenze => widget.sequenze;

  /// Il perche' del rifiuto, o nulla se la sequenza va. **Mai un rifiuto
  /// muto**, ordine DB voce 05.
  String? get _perCheNonVa => Sequenza(
        nome: _nome.text,
        pratiche: _inComposizione,
      ).perCheNonVa;

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _tocca(String id) {
    setState(() {
      if (_inComposizione.contains(id)) {
        _inComposizione.remove(id);
      } else if (_inComposizione.length < SequenzeDiAura.massimo) {
        _inComposizione.add(id);
      }
    });
  }

  Future<void> _salva() async {
    final quali = _sequenze;
    if (quali == null) return;
    final perche = await quali.aggiungi(
        Sequenza(nome: _nome.text.trim(), pratiche: List.of(_inComposizione)));
    if (!mounted) return;
    setState(() {
      if (perche == null) {
        _inComposizione.clear();
        _nome.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    // Le pratiche del centro di oggi per prime, poi tutte le altre: chi apre
    // la libreria oggi trova in cima quelle che c'entrano con oggi.
    final sue = LibreriaDeiRespiri.perCentro(widget.centroDiOggi);
    final altre = [
      for (final r in LibreriaDeiRespiri.pronte)
        if (!sue.contains(r)) r,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          key: const Key('meditazione_apri_libreria'),
          onPressed: () => setState(() => _aperto = !_aperto),
          child: Text(
            _aperto
                ? 'Chiudi la libreria'
                : 'La libreria dei respiri, '
                    '${LibreriaDeiRespiri.pronte.length} pratiche',
            style: TypographyTokens.didascalia()
                .copyWith(color: palette.goldSoft),
          ),
        ),
        if (_aperto) ...[
          // **IL NUMERO ONESTO**, ordine DB voce 01: quante ci sono e quante
          // ne arriveranno, dette separate. Un numero solo che le somma
          // sarebbe una promessa travestita da conto.
          Text(
            '${LibreriaDeiRespiri.pronte.length} pratiche pronte, '
            '${LibreriaDeiRespiri.previste} previste.',
            key: const Key('meditazione_ampiezza_libreria'),
            textAlign: TextAlign.center,
            style: TypographyTokens.didascalia()
                .copyWith(color: ColorTokens.textSecondary),
          ),
          const SizedBox(height: SpacingTokens.sm),
          for (final r in [...sue, ...altre])
            _RigaDelRespiro(
              respiro: r,
              palette: palette,
              scelto: _inComposizione.contains(r.id),
              posto: _inComposizione.indexOf(r.id),
              onTap: _sequenze == null ? null : () => _tocca(r.id),
            ),
          if (_sequenze != null) ...[
            const SizedBox(height: SpacingTokens.md),
            _ilMioRito(palette),
          ],
        ],
      ],
    );
  }

  /// **IL RITO CHE TI COSTRUISCI.** Ordine DB voce 05.
  Widget _ilMioRito(MaestroPalette palette) {
    final mie = _sequenze?.mie ?? const <Sequenza>[];
    final perche = _inComposizione.isEmpty ? null : _perCheNonVa;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Il mio rito',
          key: const Key('meditazione_il_mio_rito'),
          style: TypographyTokens.etichetta().copyWith(color: palette.gold),
        ),
        const SizedBox(height: SpacingTokens.xs),
        ParagrafiDiLettura(
          testo: 'Tocca da ${SequenzeDiAura.minimo} a '
              '${SequenzeDiAura.massimo} pratiche qui sopra, dagli un nome, '
              'e lo ritrovi.',
          stile: TypographyTokens.didascalia()
              .copyWith(color: ColorTokens.textSecondary),
        ),
        if (_inComposizione.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.sm),
          TextField(
            key: const Key('meditazione_nome_del_rito'),
            controller: _nome,
            onChanged: (_) => setState(() {}),
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textPrimary),
            decoration: InputDecoration(
              hintText: 'Il nome del tuo rito',
              hintStyle: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary),
              isDense: true,
            ),
          ),
          // **IL PERCHE' DEL RIFIUTO SI VEDE PRIMA DI PREMERE**, e non dopo:
          // un pulsante spento senza spiegazione e' lo stesso rifiuto muto che
          // la voce 05 vieta, solo silenzioso invece che sordo.
          if (perche != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              perche,
              key: const Key('meditazione_perche_il_rito_non_va'),
              style: TypographyTokens.didascalia()
                  .copyWith(color: palette.goldSoft),
            ),
          ],
          const SizedBox(height: SpacingTokens.sm),
          OutlinedButton(
            key: const Key('meditazione_salva_il_rito'),
            onPressed: perche == null ? _salva : null,
            style: OutlinedButton.styleFrom(
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.6))),
            child: Text('Tieni questo rito',
                style: TypographyTokens.etichetta()),
          ),
        ],
        for (final s in mie) ...[
          const SizedBox(height: SpacingTokens.xs),
          Row(
            children: [
              Icon(Icons.spa_outlined, size: 14, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.xs),
              Expanded(
                child: Text(
                  '${s.nome}, ${s.pratiche.length} pratiche, '
                  '${s.durata.inMinutes} minuti',
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 16),
                color: ColorTokens.textSecondary,
                tooltip: 'Togli questo rito',
                onPressed: () async {
                  await _sequenze?.togli(s.nome);
                  if (mounted) setState(() {});
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Una pratica della libreria, con la sua durata e la sua tradizione.
///
/// **LA DURATA STA IN PRIMA RIGA**, ordine DB voce 01: chi entra sa quanto
/// dura prima di cominciare, non dopo.
class _RigaDelRespiro extends StatelessWidget {
  const _RigaDelRespiro({
    required this.respiro,
    required this.palette,
    required this.scelto,
    required this.posto,
    this.onTap,
  });

  final Respiro respiro;
  final MaestroPalette palette;
  final bool scelto;

  /// Il posto nella fila, meno uno quando non e' scelta. **La fila conta**:
  /// una sequenza e' un ordine, non un insieme.
  final int posto;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: scelto
                  ? Text('${posto + 1}',
                      style: TypographyTokens.etichetta()
                          .copyWith(color: palette.gold))
                  : Icon(Icons.circle_outlined,
                      size: 12,
                      color: ColorTokens.textSecondary.withValues(alpha: 0.6)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${respiro.nome}, ${respiro.quantoDura}',
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textPrimary),
                  ),
                  Text(
                    respiro.cosaSiFa,
                    style: TypographyTokens.didascalia()
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                  // **LA FONTE STA SOTTO OGNI PRATICA**, ordine DB voce 02:
                  // *"ogni pratica porta la sua fonte"*. Non un tooltip che
                  // confessa mancanze: la tradizione col suo autore e il suo
                  // anno, e cio' che riferisce chi la pratica.
                  Text(
                    respiro.tradizione.fonte,
                    style: TypographyTokens.didascalia().copyWith(
                        color: palette.goldSoft.withValues(alpha: 0.75),
                        height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

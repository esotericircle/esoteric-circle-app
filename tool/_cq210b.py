# -*- coding: utf-8 -*-
"""CQ2.10: a una runa sola il corpo della scheda sta dietro una porta."""
NL = chr(10)
CR = chr(13)
P = 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo


def cambia(vecchio, nuovo, quante=1):
    global s
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:70])
    s = s.replace(vecchio, nuovo)


# --- il corpo lungo entra in una porta quando la runa e' sola ----------
VECCHIO = """            Text(runa.rune.meaning,
                key: Key('rune_meaning_$indice'),
                style: TypographyTokens.didascalia()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
            const SizedBox(height: SpacingTokens.xs),"""
NUOVO = """            // **A UNA RUNA SOLA IL CORPO STA DIETRO UNA PORTA.**
            // Ordine CQ voce 2.10, 4 settembre 2026. La descrizione del
            // simbolo, la Voce della Runa e la strofa attestata sono il corpo
            // della lettura quando le rune sono tre o cinque; con una sola
            // diventano tutto cio' che c'e' a schermo, e la risposta si perde
            // in mezzo. **Non spariscono: si aprono.**
            if (sola)
              _IlRestoDellaRuna(
                indice: indice,
                palette: palette,
                simbolo: runa.rune.meaning,
                voce: voce,
                strofa: kRuneLore[runa.rune.name] == null
                    ? null
                    : '${kRuneLore[runa.rune.name]!.strofe.first.fonte}: '
                        '\\u00ab${kRuneLore[runa.rune.name]!.strofe.first.traduzione}\\u00bb',
              )
            else
              Text(runa.rune.meaning,
                  key: Key('rune_meaning_$indice'),
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
            const SizedBox(height: SpacingTokens.xs),"""
cambia(VECCHIO, NUOVO)

# la Voce e la strofa non si ripetono fuori dalla porta
cambia("""            if (voce != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              ParagrafiDiLettura(
                  key: Key('rune_voce_$indice'),
                  testo: voce!,
                  stile: TypographyTokens.lettura()
                      .copyWith(color: palette.goldSoft)),
            ],""",
       """            if (voce != null && !sola) ...[
              const SizedBox(height: SpacingTokens.sm),
              ParagrafiDiLettura(
                  key: Key('rune_voce_$indice'),
                  testo: voce!,
                  stile: TypographyTokens.lettura()
                      .copyWith(color: palette.goldSoft)),
            ],""")

cambia("""            if (kRuneLore[runa.rune.name] != null) ...[""",
       """            if (kRuneLore[runa.rune.name] != null && !sola) ...[""")

# --- la porta, che e' un pezzo suo -------------------------------------
PORTA = """
/// **IL RESTO DELLA RUNA, quando la runa e' una sola.**
/// Ordine CQ voce 2.10, 4 settembre 2026.
///
/// Tiene il simbolo, la Voce della Runa e la strofa attestata dietro una riga
/// che si apre. **Chi vuole solo la risposta l'ha gia' letta sopra**, e chi
/// vuole sapere da dove nasce apre e trova tutto, nello stesso ordine di
/// prima.
///
/// **E' un pezzo con uno stato suo** e non un campo in piu' sulla scheda: la
/// scheda e' senza stato e lo resta, cosi' la stessa classe continua a servire
/// le gettate a tre e a cinque rune senza sapere niente di questa porta.
class _IlRestoDellaRuna extends StatefulWidget {
  const _IlRestoDellaRuna({
    required this.indice,
    required this.palette,
    required this.simbolo,
    this.voce,
    this.strofa,
  });

  final int indice;
  final MaestroPalette palette;
  final String simbolo;
  final String? voce;
  final String? strofa;

  @override
  State<_IlRestoDellaRuna> createState() => _IlRestoDellaRunaState();
}

class _IlRestoDellaRunaState extends State<_IlRestoDellaRuna> {
  bool _aperto = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          key: Key('rune_apri_il_resto_${widget.indice}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _aperto = !_aperto),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _aperto ? 'Chiudi' : 'Da dove nasce questa runa',
                  style: TypographyTokens.corpo()
                      .copyWith(color: widget.palette.goldSoft),
                ),
                const SizedBox(width: SpacingTokens.xxs),
                Icon(
                    _aperto
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: widget.palette.goldSoft),
              ],
            ),
          ),
        ),
        Collassabile(
          aperto: _aperto,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.simbolo,
                  key: Key('rune_meaning_${widget.indice}'),
                  style: TypographyTokens.didascalia().copyWith(
                      color: ColorTokens.textSecondary, height: 1.4)),
              if (widget.voce != null) ...[
                const SizedBox(height: SpacingTokens.sm),
                ParagrafiDiLettura(
                    key: Key('rune_voce_${widget.indice}'),
                    testo: widget.voce!,
                    stile: TypographyTokens.lettura()
                        .copyWith(color: widget.palette.goldSoft)),
              ],
              if (widget.strofa != null) ...[
                const SizedBox(height: SpacingTokens.sm),
                Text(widget.strofa!,
                    key: Key('rune_strofa_${widget.indice}'),
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textSecondary, height: 1.45)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
"""
s = s.rstrip(NL) + NL + PORTA

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('FATTO: la porta esiste e la scheda la monta a una runa sola')

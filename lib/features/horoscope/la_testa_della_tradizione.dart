import 'package:flutter/material.dart';

import '../../core/arts/gli_sfondi_delle_schede.dart';
import '../../core/horoscope/astro_tradition.dart';
import '../../core/horoscope/i_segni_delle_tradizioni.dart';
import '../../core/horoscope/le_note_delle_tradizioni.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **IN CIMA IL SEGNO DELLA TRADIZIONE SCELTA, ordine ES voci 07, 10 e 11.**
///
/// Scegliendo una tradizione, in testa alla schermata dell'Oroscopo compare
/// il segno della persona in quella tradizione al posto dell'occidentale:
/// - Cinese: la figura dell'animale, in bronzo come i dodici occidentali;
/// - Vedica: la figura occidentale del rashi, o quella propria per Mithuna e
///   Makara, col nome sanscrito e l'italiano accanto;
/// - Maya, Celtica, Egizia e Araba: l'emblema della tradizione e il segno
///   calcolato davvero, con la scritta "In arrivo" e nessuna lettura.
///
/// Accanto al nome c'e' il punto interrogativo che apre la nota della
/// tradizione ([LeNoteDelleTradizioni]).
class LaTestaDellaTradizione extends StatelessWidget {
  const LaTestaDellaTradizione({
    super.key,
    required this.tradizione,
    required this.segno,
    required this.palette,
    this.rivela = false,
  });

  /// **LA PRIMA VOLTA IL SEGNO SI RIVELA**, ordine EU voce 13: la figura
  /// arriva con la sua luce, il nome e la frase dopo. Vero solo alla prima
  /// apertura di questa tradizione ([LaRivelazioneInTesta]).
  final bool rivela;

  final AstroTradition tradizione;

  /// Null quando l'app non conosce la data di nascita.
  final SegnoDellaTradizione? segno;
  final MaestroPalette palette;

  /// La figura in testa: l'animale, il rashi o l'emblema della tradizione.
  static String? figura(AstroTradition t, SegnoDellaTradizione? s) {
    // Un segno incerto non ha una figura sola: si mostra l'emblema.
    if (s == null || (!s.certo && t != AstroTradition.occidentale)) {
      return GliSfondiDelleSchede.emblemaDellaTradizione(
          t.name, FormatoDellaScheda.quadrata);
    }
    switch (t) {
      case AstroTradition.occidentale:
        return s.zodiaco == null ? null : ZodiacArt.emblemPath(s.zodiaco!);
      case AstroTradition.cinese:
        final i = s.animale;
        if (i == null) {
          return GliSfondiDelleSchede.emblemaDellaTradizione(
              t.name, FormatoDellaScheda.quadrata);
        }
        final nome = ISegniDelleTradizioni.animali[i].$1.toLowerCase();
        return 'assets/img/zodiac/zod_cinese_$nome.webp';
      case AstroTradition.vedica:
        if (s.zodiaco != null) return ZodiacArt.emblemPath(s.zodiaco!);
        final propria = s.nome.startsWith('Mithuna') ? 'mithuna' : 'makara';
        return 'assets/img/zodiac/zod_vedica_$propria.webp';
      case AstroTradition.maya:
      case AstroTradition.celtica:
      case AstroTradition.egizia:
      case AstroTradition.araba:
        return GliSfondiDelleSchede.emblemaDellaTradizione(
            t.name, FormatoDellaScheda.quadrata);
    }
  }

  /// Se la figura e' un emblema quadrato su fondo, e non una figura
  /// scontornata: si disegna con gli angoli arrotondati e piu' piccola.
  static bool eUnEmblema(AstroTradition t, SegnoDellaTradizione? s) =>
      s == null ||
      !s.certo ||
      (t == AstroTradition.cinese && s.animale == null) ||
      t == AstroTradition.maya ||
      t == AstroTradition.celtica ||
      t == AstroTradition.egizia ||
      t == AstroTradition.araba;

  @override
  Widget build(BuildContext context) {
    final s = segno;
    final percorso = figura(tradizione, s);
    final emblema = eUnEmblema(tradizione, s);
    final nome = s?.nome ?? 'Serve la data di nascita';
    return Column(
      key: Key('oroscopo_testa_${tradizione.name}'),
      children: [
        NomeConLaNota(
          nome: nome,
          tradizione: tradizione,
          palette: palette,
          chiave: const Key('oroscopo_sign_name'),
        ),
        const SizedBox(height: SpacingTokens.xs),
        LaRivelazioneInTesta(
          key: Key('oroscopo_rivelazione_${tradizione.name}_$rivela'),
          attiva: rivela,
          palette: palette,
          figura: SizedBox(
            height: 268,
            child: Center(
              child: percorso == null
                  ? const SizedBox.shrink()
                  : emblema
                      ? ClipRRect(
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusLg),
                          child: Image.asset(percorso,
                              key: Key('oroscopo_figura_${tradizione.name}'),
                              width: 220,
                              height: 220,
                              fit: BoxFit.cover),
                        )
                      : Image.asset(percorso,
                          key: Key('oroscopo_figura_${tradizione.name}'),
                          height: 264,
                          fit: BoxFit.contain),
            ),
          ),
          frase: s == null
              ? null
              : Text(s.frase,
                  key: Key('oroscopo_frase_${tradizione.name}'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: palette.goldSoft, height: 1.35)),
        ),
        if (s?.nota != null) ...[
          const SizedBox(height: SpacingTokens.xs),
          Text(s!.nota!,
              key: Key('oroscopo_nota_segno_${tradizione.name}'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.35)),
        ],
        if (!tradizione.unlocked) ...[
          const SizedBox(height: SpacingTokens.sm),
          Container(
            key: Key('oroscopo_in_arrivo_${tradizione.name}'),
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.surfaceElevated.withValues(alpha: 0.6),
              border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_bottom_rounded,
                    size: 14, color: palette.goldSoft),
                const SizedBox(width: 6),
                Text('In arrivo',
                    style: TypographyTokens.etichetta()
                        .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// **LA RIVELAZIONE DEL SEGNO IN TESTA, ordine EU voce 13.** Il fondatore:
/// *"quando l'utente fa click per la prima volta su vedica o cinese o altro,
/// serve un'animazione di rivelazione del segno, non possono comparire di
/// botto."* La rivelazione della voce ES.35 era un foglio che si apriva dopo
/// la scelta, solo per la Cinese e la Vedica e solo col segno certo: sotto,
/// la figura in testa era gia' comparsa di colpo.
///
/// Adesso, la prima volta che una tradizione si apre (Vedica, Cinese, Maya,
/// Egizia, Celtica, Araba, e quelle di un amico), la figura in testa arriva
/// con la sua luce: un alone d'oro che si accende, la figura che sale da
/// piccola e trasparente, poi la frase del segno. Dalla seconda volta e'
/// gia' al suo posto. **Con Riduci Movimento** la figura e la frase sono
/// subito intere, senza animazione.
class LaRivelazioneInTesta extends StatefulWidget {
  const LaRivelazioneInTesta({
    super.key,
    required this.attiva,
    required this.palette,
    required this.figura,
    this.frase,
  });

  final bool attiva;
  final MaestroPalette palette;
  final Widget figura;
  final Widget? frase;

  /// Quanto dura la rivelazione.
  static const Duration durata = Duration(milliseconds: 1600);

  @override
  State<LaRivelazioneInTesta> createState() => _LaRivelazioneInTestaState();
}

class _LaRivelazioneInTestaState extends State<LaRivelazioneInTesta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: LaRivelazioneInTesta.durata);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.attiva || MediaQuery.of(context).disableAnimations) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final figura = CurvedAnimation(
        parent: _c, curve: const Interval(0, 0.7, curve: Curves.easeOutBack));
    final luce = CurvedAnimation(parent: _c, curve: const Interval(0, 0.6));
    final frase = CurvedAnimation(
        parent: _c, curve: const Interval(0.45, 1, curve: Curves.easeOut));
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // L'alone si spegne a rivelazione finita: resta solo la figura.
              if (widget.attiva && _c.value < 1)
                Opacity(
                  key: const Key('oroscopo_rivelazione_luce'),
                  opacity: (luce.value * (1 - _c.value) * 2).clamp(0.0, 1.0),
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        p.gold.withValues(alpha: 0.35),
                        p.gold.withValues(alpha: 0),
                      ]),
                    ),
                  ),
                ),
              Opacity(
                key: const Key('oroscopo_rivelazione_figura'),
                opacity: figura.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.6 + 0.4 * figura.value,
                  child: widget.figura,
                ),
              ),
            ],
          ),
          if (widget.frase != null)
            Opacity(
              key: const Key('oroscopo_rivelazione_frase'),
              opacity: frase.value.clamp(0.0, 1.0),
              child: widget.frase,
            ),
        ],
      ),
    );
  }
}

/// Il nome del segno, grande, col punto interrogativo della nota accanto.
class NomeConLaNota extends StatelessWidget {
  const NomeConLaNota({
    super.key,
    required this.nome,
    required this.tradizione,
    required this.palette,
    this.chiave,
  });

  final String nome;
  final AstroTradition tradizione;
  final MaestroPalette palette;
  final Key? chiave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lo spazio del punto interrogativo anche a sinistra: il nome resta
        // al centro della schermata.
        const SizedBox(width: 44),
        // Un nome lungo ("Ptibiou, terzo decano dei Pesci") nel carattere
        // piu' grande andrebbe su tre righe: sopra i diciotto caratteri si
        // scrive nel cerimoniale normale.
        //
        // **E UNA PAROLA NON SI SPEZZA.** Visto sul Realme il 30 settembre
        // 2026, nell'oroscopo di un'amica del Capricorno: "CAPRICORN / O".
        // Fra i due spazi del punto interrogativo restano 224 punti, e nel
        // carattere grande "Capricorno" e "Sagittario" ne vogliono di piu'.
        // Padre: ordine ES voce 10, che ha messo il punto interrogativo
        // accanto al nome. La misura si sceglie misurando la parola piu'
        // lunga: se nel grande non entra si scrive nel normale, e se non
        // entra nemmeno li' la riga si rimpicciolisce intera.
        Flexible(
          child: LayoutBuilder(builder: (context, vincoli) {
            final scala = MediaQuery.textScalerOf(context);
            double parolaPiuLunga(TextStyle stile) {
              var massima = 0.0;
              for (final parola in nome.split(' ')) {
                final pittore = TextPainter(
                  text: TextSpan(text: parola, style: stile),
                  textDirection: TextDirection.ltr,
                  textScaler: scala,
                  maxLines: 1,
                )..layout();
                if (pittore.width > massima) massima = pittore.width;
                pittore.dispose();
              }
              return massima;
            }

            final grande = TypographyTokens.cerimonialeGrande();
            final normale = TypographyTokens.cerimoniale();
            // Due punti di margine: una parola che entra per un decimo di
            // punto sul telefono va a capo lo stesso.
            final spazio = vincoli.maxWidth - 2;
            final stile = nome.length > 18 || parolaPiuLunga(grande) > spazio
                ? normale
                : grande;
            final testo = Text(nome,
                key: chiave,
                textAlign: TextAlign.center,
                style: stile.copyWith(color: palette.goldSoft));
            if (parolaPiuLunga(stile) <= spazio) return testo;
            return FittedBox(fit: BoxFit.scaleDown, child: testo);
          }),
        ),
        SizedBox(
          width: 44,
          height: 44,
          child: IconButton(
            key: Key('oroscopo_nota_${tradizione.name}'),
            tooltip: 'Che cos\'è la tradizione ${tradizione.label}',
            padding: EdgeInsets.zero,
            icon: Icon(Icons.help_outline_rounded,
                size: 20, color: palette.goldSoft.withValues(alpha: 0.85)),
            onPressed: () => apriLaNota(context, tradizione, palette),
          ),
        ),
      ],
    );
  }
}

/// Apre la nota della [tradizione] in un foglio dal basso.
Future<void> apriLaNota(
    BuildContext context, AstroTradition tradizione, MaestroPalette palette) {
  final nota = LeNoteDelleTradizioni.di(tradizione);
  Widget parte(String titolo, String testo) => Padding(
        padding: const EdgeInsets.only(bottom: SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titolo.toUpperCase(),
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text(testo,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textPrimary, height: 1.45)),
          ],
        ),
      );
  // Dalla porta comune dei fogli, col velo del Cerchio e sotto le barre.
  return foglioDelCerchio<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: palette.deepest,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusLg))),
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: SingleChildScrollView(
          key: Key('oroscopo_foglio_nota_${tradizione.name}'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
              SpacingTokens.lg, SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('La tradizione ${tradizione.label}',
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.md),
              parte('Che cos\'è', nota.cheCose),
              parte('Un po\' di storia', nota.storia),
              parte('Come si calcola il tuo segno', nota.calcolo),
              Text('FONTI',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.2)),
              const SizedBox(height: 4),
              for (final f in nota.fonti)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(f,
                      style: TypographyTokens.didascalia().copyWith(
                          color: ColorTokens.textSecondary, height: 1.4)),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

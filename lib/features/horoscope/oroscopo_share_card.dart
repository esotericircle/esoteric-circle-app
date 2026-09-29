import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/brand/brand.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/astro/zodiac.dart';
import '../../core/horoscope/horoscope.dart';
import '../../design_system/components/brand_mark.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'horoscope_visuals.dart';
import 'oroscopo_colors.dart';
import 'riquadro_del_numero.dart';
import '../../core/arts/gli_sfondi_delle_schede.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../design_system/components/card_a_misura_fissa.dart';

/// La card verticale condivisibile dell'Oroscopo, formato storia social:
/// emblema e nome del segno, la riga di sintesi (ancora del Generale), le quattro
/// schede in forma compatta con la loro forma a tema e il livello col numero,
/// numero fortunato e colore del giorno, marchio e deep link. Tutto
/// deterministico.
/// LA RIGA DEL CIELO DENTRO LA CARD. Ordine P voce 25, chiusa il 12 agosto 2026.
///
/// **Il difetto che questa riga chiude.** La card mostrava la sola frase del
/// segno: il transito vero, nel solo posto in cui l'Oroscopo diventa un'immagine
/// che la gente manda agli altri, non compariva. Cio' che si condivideva era la
/// parte generica, e la parte che nessun'altra app puo' dare restava dentro
/// l'app.
///
/// **Come e' stata scelta la composizione, e da chi.** Farlo entrare era una
/// scelta di composizione visiva, quindi di Mauro, non di chi costruisce: sono
/// state montate DUE proposte alla larghezza vera e col cielo vero, la riga in
/// oro sotto la sintesi e una fascia sopra l'emblema con la sua etichetta.
/// **Mauro ha scelto la prima**, e questa e' quella: l'emblema resta il colpo
/// d'occhio, la sintesi resta la frase che si legge, e il cielo e' la firma che
/// dice da dove viene quella frase. La seconda cambiava la gerarchia mettendo il
/// segno al secondo posto, e portava anche un doppione, perche' sotto la sua
/// etichetta la giuntura ripeteva a parole cio' che il titolo diceva sopra.
///
/// **La giuntura NON e' stata toccata.** "Il cielo di oggi lo dice cosi'" e' del
/// corpus di Mauro e resta fuori dall'ordine, come le quarantotto ancore: qui si
/// dispone il testo, non si riscrive.
///
/// **L'EMBLEMA DEL PERIODO E CHI E' NATO, ordine ES voci 05 e 13.** In testa
/// l'emblema del periodo (il Giorno tiene quello dell'Oroscopo). Sotto, il
/// nome o lo pseudonimo, **mai il cognome**, e i dati di nascita che l'app
/// conosce; il segno e' quello della tradizione scelta, con la sua figura.
/// In fondo il link per scaricare l'app. Il fondatore: *"Io nella card da
/// condividere inserirei i dati di nascita e il nome o lo pseudonimo. Non
/// serve il cognome"*.
class OroscopoShareCard extends StatelessWidget {
  const OroscopoShareCard({
    super.key,
    required this.sign,
    required this.cards,
    required this.palette,
    this.width = 360,
    this.periodo = 'giorno',
    this.etichettaDelPeriodo = 'del giorno',
    this.nome,
    this.nascita,
    this.nomeDelSegno,
    this.figuraDelSegno,
  });

  final Zodiac sign;
  final List<HoroscopeCard> cards;
  final MaestroPalette palette;
  final double width;

  /// Il nome del periodo (`HoroscopePeriod.name`), per l'emblema.
  final String periodo;

  /// "del giorno", "della settimana": va dopo OROSCOPO.
  final String etichettaDelPeriodo;

  /// Il nome gia' senza cognome ([soloIlNome]); null se non c'e'.
  final String? nome;

  /// I dati di nascita gia' scritti ([laNascitaScritta]); null se mancano.
  final String? nascita;

  /// Il segno nella tradizione scelta; null vale l'occidentale.
  final String? nomeDelSegno;

  /// La figura del segno nella tradizione scelta; null vale l'occidentale.
  final String? figuraDelSegno;

  /// **IL COGNOME NON COMPARE MAI.** Del nome si tiene la prima parola: chi
  /// ha dato "Mario Rossi" esce "Mario". Un nome doppio ("Anna Maria") esce
  /// "Anna": si perde meta' del nome, ma non esce mai un cognome.
  static String? soloIlNome(String? completo) {
    final pulito = completo?.trim() ?? '';
    if (pulito.isEmpty) return null;
    return pulito.split(RegExp(r'\s+')).first;
  }

  static const List<String> _mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', //
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];

  /// I dati di nascita come si leggono sulla card: "15 marzo 1990, ore
  /// 08:30, Roma". L'ora e il luogo solo se ci sono.
  static String laNascitaScritta(DateTime data,
      {int? ora, int? minuto, String? luogo}) {
    final pezzi = <String>['${data.day} ${_mesi[data.month - 1]} ${data.year}'];
    if (ora != null) {
      pezzi.add('ore ${ora.toString().padLeft(2, '0')}:'
          '${(minuto ?? 0).toString().padLeft(2, '0')}');
    }
    if (luogo != null && luogo.trim().isNotEmpty) pezzi.add(luogo.trim());
    return pezzi.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final fortuna =
        cards.firstWhere((c) => c.domain == HoroscopeDomain.fortuna);
    // La sintesi arriva dalla scheda che questa card ha gia' in mano, non dal
    // corpus riletto per conto proprio: era l'unica porta dell'Oroscopo che
    // scavalcava `Horoscope`, e sostituire la composizione avrebbe lasciato
    // indietro proprio l'immagine che la gente condivide.
    final synthesis =
        cards.firstWhere((c) => c.domain == HoroscopeDomain.generale).synthesis;
    // LA RIGA DEL CIELO, dalla scheda Generale: la stessa che l'app mostra
    // dentro, non una seconda composizione.
    final rigaDelCielo = cards
        .firstWhere((c) => c.domain == HoroscopeDomain.generale)
        .rigaDelCielo;
    const still = AlwaysStoppedAnimation<double>(0.5);
    // La larghezza che il titolo di una tessera possiede DAVVERO, ricavata
    // dagli stessi valori del layout qui sotto: il padding esterno `lg`, il
    // bordo di 2, la meta' della riga, il margine di 3 per lato della
    // tessera e il suo padding orizzontale `xs`. Serve al rimpicciolimento
    // del titolo, che dentro `IntrinsicHeight` non puo' usare un
    // `LayoutBuilder`: le dimensioni intrinseche non lo ammettono.
    final larghezzaDelTitolo = (width - 2 * SpacingTokens.lg - 2 * 2) / 2 -
        2 * 3 -
        2 * SpacingTokens.xs;

    // **UNA CARD CHE ESCE DAL TELEFONO SI DISEGNA A MISURA FISSA.**
    // Ordine CN voce 12: la scala del testo di chi la crea non entra
    // nell'immagine, perche' l'immagine la guardano altri.
    return CardAMisuraFissa(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(SpacingTokens.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.deepest,
              Color.lerp(palette.deepest, palette.primary, 0.55)!,
              palette.deepest,
            ],
          ),
          border:
              Border.all(color: palette.gold.withValues(alpha: 0.8), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // L'EMBLEMA DEL PERIODO, ordine ES voce 05.
            ClipRRect(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  GliSfondiDelleSchede.emblemaDelPeriodo(
                      periodo, FormatoDellaScheda.orizzontale),
                  key: Key('share_emblema_$periodo'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text('OROSCOPO ${etichettaDelPeriodo.toUpperCase()}',
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 3.0)),
            // CHI E' NATO, ordine ES voce 13: il nome senza cognome e i
            // dati di nascita.
            if (nome != null) ...[
              const SizedBox(height: SpacingTokens.xs),
              Text(nome!,
                  key: const Key('share_nome'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: ColorTokens.textPrimary)),
            ],
            if (nascita != null)
              Text(nascita!,
                  key: const Key('share_nascita'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            const SizedBox(height: SpacingTokens.sm),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        palette.gold.withValues(alpha: 0.26),
                        Colors.transparent,
                      ]),
                    ),
                    child: figuraDelSegno == null
                        ? ZodiacEmblem(
                            sign: sign, size: 92, art: ZodiacEmblemArt.emblem)
                        : Image.asset(figuraDelSegno!,
                            key: const Key('share_figura_del_segno'),
                            width: 92,
                            height: 92,
                            fit: BoxFit.contain),
                  ),
                  Text(nomeDelSegno ?? sign.italianName,
                      style: TypographyTokens.cerimoniale()
                          .copyWith(color: palette.goldSoft)),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            // Riga di sintesi in evidenza: l'ancora del Generale.
            Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                color: palette.primary.withValues(alpha: 0.4),
                border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
              ),
              child: Text(synthesis,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.4)),
            ),
            // LA RIGA DEL CIELO, la composizione scelta da Mauro il 12 agosto 2026.
            //
            // Compare solo quando il cielo e' stato letto davvero: con la corrente
            // presa dalla hash `rigaDelCielo` e' nulla, e una card che scrivesse
            // comunque una riga direbbe il falso nel posto piu' pubblico che
            // l'Oroscopo abbia.
            if (rigaDelCielo != null) ...[
              const SizedBox(height: SpacingTokens.sm),
              Row(
                key: const Key('share_transito_riga'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: palette.goldSoft),
                  const SizedBox(width: SpacingTokens.xxs),
                  Expanded(
                    child: Text(rigaDelCielo,
                        style: TypographyTokens.didascalia()
                            .copyWith(color: palette.goldSoft, height: 1.35)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: SpacingTokens.md),
            // Le quattro bolle, ognuna con la sua forma a tema e il livello.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final c in cards.take(2))
                    Expanded(
                        child: _LevelTile(
                            card: c,
                            palette: palette,
                            pulse: still,
                            larghezzaDelTitolo: larghezzaDelTitolo)),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final c in cards.skip(2))
                    Expanded(
                        child: _LevelTile(
                            card: c,
                            palette: palette,
                            pulse: still,
                            larghezzaDelTitolo: larghezzaDelTitolo)),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            // Numero e Colore: due bolle della stessa misura, col titolo sopra.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // IL NUMERO AL CENTRO DEL SUO RIQUADRO, ordine ES voce
                  // 13, come nella schermata dalla voce ES.14: la bolla di
                  // prima teneva la cifra in alto quando la riga la stirava.
                  Expanded(
                    child: RiquadroDelNumero(
                        numero: fortuna.luckyNumber ?? 0,
                        palette: palette,
                        etichetta: fortuna.numeriDelGiorno == null
                            ? 'Numero'
                            : 'Numeri',
                        cifre: fortuna.numeriDelGiorno?.join(' · ')),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: _InfoBubble(
                      label: 'Colore',
                      palette: palette,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: oroscopoColor(fortuna.dayColor) ??
                                  palette.goldSoft,
                              border: Border.all(
                                  color: palette.gold.withValues(alpha: 0.6)),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(fortuna.dayColor ?? '',
                                maxLines: 1,
                                style: TypographyTokens.didascalia()
                                    .copyWith(color: ColorTokens.textPrimary)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            // Marchio: il logo vero se c'e', altrimenti il sigillo provvisorio.
            const Center(child: BrandLogo(size: 42)),
            const SizedBox(height: 4),
            Text(BrandMark.wordmark,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta()
                    .copyWith(color: palette.goldSoft, letterSpacing: 2.4)),
            // IL LINK PER SCARICARE L'APP, ordine ES voce 13.
            Text('Scarica l\'app: ${Brand.domain}',
                key: const Key('share_scarica'),
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                    color: ColorTokens.textSecondary, letterSpacing: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// Una bolla di scheda: la forma a tema col livello e il titolo per intero, mai
/// troncato coi puntini.
class _LevelTile extends StatelessWidget {
  const _LevelTile(
      {required this.card,
      required this.palette,
      required this.pulse,
      required this.larghezzaDelTitolo});

  final HoroscopeCard card;
  final MaestroPalette palette;
  final Animation<double> pulse;

  /// Quanta larghezza possiede il titolo, calcolata dal genitore sugli
  /// stessi valori del suo layout: qui un `LayoutBuilder` non puo' vivere,
  /// perche' le tessere stanno dentro `IntrinsicHeight`.
  final double larghezzaDelTitolo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.sm, horizontal: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.surfaceElevated.withValues(alpha: 0.35),
        border: Border.all(color: palette.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stesso linguaggio della schermata: cinque icone col numero.
          DomainLevel(
            domain: card.domain,
            value: card.indicator,
            palette: palette,
            pulse: pulse,
            iconSize: 13,
            gap: 2,
            animateFill: false,
          ),
          const SizedBox(height: 4),
          Text(card.domain.label.toUpperCase(),
              maxLines: 1,
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          // Titolo intero: va a capo e si rimpicciolisce, nessuna ellissi.
          //
          // **E IL RIMPICCIOLIMENTO ADESSO ESISTE.** Ordine BD voce 07, coda:
          // la promessa qui sopra era scritta ma non mantenuta, e sulla card
          // del Toro "L'abbondanza concreta" usciva spezzata in mezzo alla
          // parola, "L'ABBONDANZ A". Andare a capo fra le parole va bene;
          // dentro una parola mai: quando la parola piu' lunga non ci sta,
          // il corpo scende di quel tanto che la fa stare.
          Builder(builder: (context) {
            var stile = TypographyTokens.titoloDiRiga()
                .copyWith(color: palette.goldSoft, height: 1.15);
            var piuLarga = 0.0;
            for (final parola in card.title.split(' ')) {
              final metro = TextPainter(
                  text: TextSpan(text: parola, style: stile),
                  textDirection: TextDirection.ltr)
                ..layout();
              if (metro.width > piuLarga) piuLarga = metro.width;
            }
            // **COL RESPIRO, NON AL PAREGGIO.** Misurato: "L'abbondanza" fa
            // 132,63 punti su una soglia di 132. Scalare esattamente alla
            // soglia lascia la parola a un decimo di punto dal bordo, e basta
            // l'arrotondamento dell'Expanded a spezzarla di nuovo: si scala a
            // quattro punti dal bordo, che non si vedono e non tradiscono.
            const respiro = 4.0;
            if (piuLarga > larghezzaDelTitolo - respiro && piuLarga > 0) {
              // La misura di partenza e' quella del ruolo, non un numero
              // scritto qui: si scala il corpo del token, qualunque sia.
              stile = stile.copyWith(
                  fontSize: (stile.fontSize ?? 16) *
                      (larghezzaDelTitolo - respiro) /
                      piuLarga);
            }
            return Text(card.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: stile);
          }),
        ],
      ),
    );
  }
}

/// Una bolla informativa col titolo sopra e il contenuto sotto, di misura
/// uguale alle sue sorelle.
class _InfoBubble extends StatelessWidget {
  const _InfoBubble(
      {required this.label, required this.child, required this.palette});

  final String label;
  final Widget child;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TypographyTokens.etichetta().copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 4),
          Center(child: child),
        ],
      ),
    );
  }
}

/// Genera la card come immagine dal boundary e apre il foglio di condivisione.
/// Il PNG va in un file temporaneo del dispositivo, non su un server.
Future<bool> shareOroscopoCard({
  required GlobalKey boundaryKey,
  required String text,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/oroscopo_card.png');
  await file.writeAsBytes(png, flush: true);
  // Ordine BG voce 04: l'esito VERO della porta risale al chiamante,
  // che a condivisione avvenuta paga il premio dichiarato sul pulsante.
  return PortaDellaCondivisione.daFile(file.path, testo: text);
}

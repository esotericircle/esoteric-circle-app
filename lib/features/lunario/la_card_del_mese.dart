import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/brand/brand.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../core/lunario/il_giorno_lunare.dart';
import '../../core/lunario/le_attivita_del_lunario.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/brand_mark.dart';
import '../../design_system/components/card_a_misura_fissa.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'la_luce_in_fusione.dart';
import 'la_luna_nel_castone.dart';

/// **LA CARD DEL MESE.** Ordine FV voce FV.11, 15 ottobre 2026 (Linee Guida
/// V13 sezione 3: formato unico verticale, palette di Medora, sigillo del
/// Maestro, logo, collegamento diretto; il fondatore: "la luna risplende di
/// notte").
///
/// **Lo sfondo** e' la tavola notturna dipinta `card_mese_sfondo_v1`
/// (768x1376). **Il campo centrale vuoto, rimisurato da Code sui pixel**
/// della tavola (le due linee d'argento della cornice interna): dalla
/// colonna 101 alla 666 e dalla riga 333 alla 1097, cioe' dal 13,2
/// all'86,8 per cento della larghezza e dal 24,2 al 79,8 dell'altezza
/// (l'Architetto: 13 e 87, 24 e 80). Li' vanno le lune vere del mese e, se
/// c'e' un'attivita' scelta, i suoi giorni d'oro.
///
/// **COSA NON C'E', E NON E' UNA DIMENTICANZA**: i giorni tuoi (FV.07) e
/// l'intenzione alla Luna nuova (FV.09). La card esce dal telefono e la
/// guardano altri; i giorni tuoi direbbero la Luna e il Sole della nascita,
/// l'intenzione e' privata. Per costruzione questa classe non ha un campo
/// per riceverli: la guardia `test/la_card_del_mese_test.dart` cade se uno
/// dei due entra.
class LaCardDelMese extends StatelessWidget {
  const LaCardDelMese({
    super.key,
    required this.anno,
    required this.mese,
    required this.giorni,
    required this.ruota,
    this.attivita,
    this.giorniDOro = const {},
    this.width = 384,
  });

  final int anno;
  final int mese;
  final List<GiornoLunare> giorni;

  /// Le lune ruotate per l'emisfero sud.
  final bool ruota;

  /// L'attivita' scelta in "Trova il giorno", se c'e'.
  final AttivitaDelLunario? attivita;

  /// I giorni d'oro dell'attivita' (numeri del giorno nel mese).
  final Set<int> giorniDOro;
  final double width;

  static const String sfondo =
      'assets/img/calendario_lunare/card_mese_sfondo_v1.webp';

  /// La tavola, in pixel.
  static const Size tavola = Size(768, 1376);

  /// Il campo centrale vuoto, in pixel della tavola (misurato da Code).
  static const Rect campo = Rect.fromLTRB(101, 333, 667, 1098);

  /// La riga del titolo, fra il medaglione e il campo.
  static const Rect fasciaDelTitolo = Rect.fromLTRB(101, 205, 667, 325);

  /// La fascia della firma, sotto il fregio d'argento.
  static const Rect fasciaDellaFirma = Rect.fromLTRB(101, 1180, 667, 1310);

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final s = width / tavola.width;
    final h = tavola.height * s;
    Rect px(Rect r) =>
        Rect.fromLTRB(r.left * s, r.top * s, r.right * s, r.bottom * s);
    return CardAMisuraFissa(
      child: SizedBox(
        key: const Key('card_mese'),
        width: width,
        height: h,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(sfondo,
                  fit: BoxFit.fill,
                  errorBuilder: (_, __, ___) =>
                      ColoredBox(color: palette.deepest)),
            ),
            Positioned.fromRect(
              rect: px(fasciaDelTitolo),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(IlMeseInItaliano.titolo(anno, mese),
                      key: const Key('card_mese_titolo'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.titoloSezione()
                          .copyWith(color: palette.goldSoft)),
                  Text(
                      attivita == null
                          ? 'Le lune del mese'
                          : 'I giorni d\'oro per ${attivita!.nome.toLowerCase()}',
                      key: const Key('card_mese_sottotitolo'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textPrimary)),
                ],
              ),
            ),
            Positioned.fromRect(
              rect: px(campo).deflate(8 * s * 2),
              child: _LeLuneDelMese(
                anno: anno,
                mese: mese,
                giorni: giorni,
                ruota: ruota,
                giorniDOro: giorniDOro,
                palette: palette,
              ),
            ),
            Positioned.fromRect(
              rect: px(fasciaDellaFirma),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IL SIGILLO DI MEDORA: la sua figura dipinta col suo nome,
                  // la Maestra che firma l'almanacco.
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(Maestro.medora.avatarAsset,
                          height: 40 * s * 2,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              SizedBox(height: 40 * s * 2)),
                      Text('MEDORA',
                          style: TypographyTokens.etichetta().copyWith(
                              color: palette.goldSoft, letterSpacing: 2)),
                    ],
                  ),
                  SizedBox(width: 24 * s * 2),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandLogo(size: 36),
                      Text(BrandMark.wordmark,
                          style: TypographyTokens.etichetta().copyWith(
                              color: palette.goldSoft, letterSpacing: 2)),
                      Text(Brand.domain,
                          key: const Key('card_mese_collegamento'),
                          style: TypographyTokens.etichetta()
                              .copyWith(color: ColorTokens.textSecondary)),
                    ],
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

/// Le lune del mese nel campo, in sette colonne dal lunedi'.
class _LeLuneDelMese extends StatelessWidget {
  const _LeLuneDelMese({
    required this.anno,
    required this.mese,
    required this.giorni,
    required this.ruota,
    required this.giorniDOro,
    required this.palette,
  });

  final int anno;
  final int mese;
  final List<GiornoLunare> giorni;
  final bool ruota;
  final Set<int> giorniDOro;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, v) {
      final colonna = v.maxWidth / 7;
      const testata = 18.0;
      final righe = IlMeseInItaliano.righe(anno, mese);
      final riga = (v.maxHeight - testata) / righe;
      final lato = (riga - 16).clamp(0.0, colonna);
      final vuote = IlMeseInItaliano.vuoteIniziali(anno, mese);
      Rect cella(int i) {
        final p = vuote + i;
        return Rect.fromLTWH(
            (p % 7) * colonna, testata + (p ~/ 7) * riga, colonna, riga);
      }

      return Stack(
        children: [
          for (var c = 0; c < 7; c++)
            Positioned(
              left: c * colonna,
              width: colonna,
              top: 0,
              height: testata,
              child: Text(IlMeseInItaliano.giorni[c],
                  textAlign: TextAlign.center,
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft)),
            ),
          // GLI ALONI D'ORO, sotto le lune e in fusione schermo.
          for (var i = 0; i < giorni.length; i++)
            if (giorniDOro.contains(giorni[i].giorno.day))
              Positioned.fromRect(
                rect: cella(i).inflate(colonna * 0.2),
                child: LaLuceInFusione(
                  key: Key('card_mese_oro_${giorni[i].giorno.day}'),
                  child: Image.asset(
                      'assets/img/calendario_lunare/luce_alone_oro_v1.webp',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                ),
              ),
          for (var i = 0; i < giorni.length; i++)
            Positioned.fromRect(
              rect: cella(i),
              child: Column(
                children: [
                  Text('${giorni[i].giorno.day}',
                      style: TypographyTokens.etichetta().copyWith(
                          color: giorniDOro.contains(giorni[i].giorno.day)
                              ? palette.goldSoft
                              : ColorTokens.textPrimary)),
                  LaLunaNelCastone(
                    key: Key('card_mese_luna_${giorni[i].giorno.day}'),
                    elongazione: giorni[i].elongazione,
                    ruota: ruota,
                    lato: lato,
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

/// Genera la card come immagine e apre il foglio di condivisione. Il PNG va
/// in un file temporaneo del dispositivo, non su un server. L'esito vero
/// risale al chiamante, che paga il premio dichiarato.
Future<bool> shareCardDelMese({
  required GlobalKey boundaryKey,
  required String text,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/calendario_lunare.png');
  await file.writeAsBytes(png, flush: true);
  return PortaDellaCondivisione.daFile(file.path, testo: text);
}

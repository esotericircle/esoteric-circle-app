import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/condivisione/porta_della_condivisione.dart';
import '../../../../core/rituals/animal_catalog.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;

/// **LA CARD DELLA RIVELAZIONE.** Ordine DE voce 08, 11 settembre 2026.
///
/// *"Alla quarta discesa, l'animale in piena luce con il suo nome e la data in
/// cui ti ha trovato. E' l'unica card dell'app che una persona pubblica per
/// dire chi e' invece che per mostrare un risultato."*
///
/// **E QUELLA RIGA DECIDE TUTTA LA FORMA.** Le altre card del Cerchio
/// raccontano **cosa e' successo**: il respiro di oggi, la stesa di stamattina,
/// l'arcano del giorno. Questa racconta **chi sei**, e una cosa del genere si
/// impagina come un ritratto, non come un referto: l'animale grande, il nome
/// grande, e tutto il resto piccolo e in fondo.
///
/// **PER QUESTO NON C'E' NESSUNA FRASE DESCRITTIVA.** Nessun significato,
/// nessuna riga di lettura, nessun consiglio. Chi la riceve in una chat deve
/// capire in un colpo d'occhio, e cio' che c'e' da capire sono tre cose: che
/// animale, di chi, e da quando. E' anche la lezione dell'ordine DD voce 17,
/// dove il fondatore ha chiesto di **non esagerare col testo descrittivo**.
///
/// **E LA DATA NON E' UN TIMBRO.** *"La data in cui ti ha trovato"*: il verbo
/// e' suo, e cambia di chi e' il gesto. Non e' il giorno in cui hai completato
/// quattro discese, e' il giorno in cui qualcuno ti ha trovato.
class CardDellaRivelazione extends StatelessWidget {
  const CardDellaRivelazione({
    super.key,
    required this.animale,
    required this.quando,
    this.larghezza = 320,
  });

  final GuideAnimal animale;

  /// Il giorno in cui l'animale ha trovato questa persona.
  final DateTime quando;

  final double larghezza;

  /// **IL TITOLO, e si legge senza sapere cos'e' questa app.**
  ///
  /// Non *"il mio animale guida"*, che e' il nome della funzione, ma la frase
  /// che una persona direbbe: e' il verbo dell'ordine, al passato.
  static String titolo(GuideAnimal animale) =>
      'MI HA TROVATO ${animale.name.toUpperCase()}';

  /// La riga della data, per esteso e in italiano.
  static String laData(DateTime giorno) {
    const mesi = [
      'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
      'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
    ];
    return '${giorno.day} ${mesi[giorno.month - 1]} ${giorno.year}';
  }

  @override
  Widget build(BuildContext context) => Container(
        key: const Key('card_della_rivelazione'),
        width: larghezza,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0B10),
              Color(0xFF0A0408),
            ],
          ),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          border: Border.all(color: const Color(0x55D6A868)),
        ),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              titolo(animale),
              key: const Key('card_rivelazione_titolo'),
              textAlign: TextAlign.center,
              style: TypographyTokens.titoloScheda().copyWith(
                color: const Color(0xFFF0DDB0),
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            // **L'ANIMALE IN PIENA LUCE, e occupa la card.** E' il ritratto:
            // se fosse un'icona accanto a un testo, questa tornerebbe a essere
            // una card di risultato come tutte le altre.
            Stack(
              alignment: Alignment.center,
              children: [
                // L'alone caldo dietro, che stacca la figura dal fondo scuro.
                SizedBox(
                  width: larghezza * 0.86,
                  height: larghezza * 0.72,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0x55F0DDB0),
                          Color(0x1AB08A4E),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: larghezza * 0.78,
                  height: larghezza * 0.70,
                  child: Image.asset(
                    animale.fullPath,
                    key: const Key('card_rivelazione_animale'),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'mi ha trovato il ${laData(quando)}',
              key: const Key('card_rivelazione_data'),
              textAlign: TextAlign.center,
              style: TypographyTokens.didascalia()
                  .copyWith(color: const Color(0xFFD6A868)),
            ),
            const SizedBox(height: SpacingTokens.md),
            // La firma, piccola: chi riceve la card deve sapere da dove viene,
            // e non deve leggerlo prima del nome.
            Text(
              'ESOTERIC CIRCLE',
              style: TypographyTokens.didascalia().copyWith(
                color: const Color(0x66D6A868),
                letterSpacing: 3.0,
                fontSize: 9,
              ),
            ),
          ],
        ),
      );
}

/// **CONDIVIDE LA CARD, DAL PUNTO UNICO.** Ordine DE voce 08: *"passa dal
/// punto unico della condivisione, quello a cui l'ordine P voce 28 ha
/// ricondotto i gesti sparsi. Non se ne scrive un altro."*
///
/// E' la stessa identica strada della card del respiro: il PNG nasce dal
/// boundary, finisce in un file temporaneo del telefono e va alla porta.
/// **Nessun server**, e l'esito vero risale a chi ha chiamato, perche' il
/// premio della condivisione si paga solo a condivisione avvenuta.
Future<bool> condividiLaRivelazione({
  required GlobalKey boundaryKey,
  required String testo,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/card_della_rivelazione.png');
  await file.writeAsBytes(png, flush: true);
  return PortaDellaCondivisione.daFile(file.path, testo: testo);
}

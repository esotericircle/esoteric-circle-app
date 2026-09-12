import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../core/rituals/rune_cast.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../synastry/sinastria_share_card.dart' show captureBoundaryPng;
import 'bindrune.dart';
import '../../../../core/condivisione/porta_della_condivisione.dart';
import '../../../../design_system/components/card_da_mandare.dart';

/// La card condivisibile dell'Estrazione Rune, cornice oro e rossa di Caligo:
/// la gettata, le rune nelle loro posizioni col verso, e il presagio in sintesi.
class RuneShareCard extends StatelessWidget {
  const RuneShareCard({
    super.key,
    required this.esito,
    required this.presagio,
  });

  final EsitoGettata esito;

  /// Il presagio in sintesi, mostrato in coda alla card.
  final String presagio;

  static const double larghezza = 400;

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
    // **LA CARD PASSA DALLA PORTA COMUNE. Ordine CQ voce 6.26, 4 settembre
    // 2026.**
    //
    // La domanda del fondatore era: *perche' l'utente dovrebbe condividere il
    // contenuto? cosa dovrebbe esserci d'impatto?* La risposta e' scritta per
    // esteso su `CardDaMandare`, e in breve e' questa: si condivide una frase
    // che dice qualcosa di se', dentro un'immagine che regge il confronto con
    // le foto degli altri.
    //
    // **Cosa c'era qui prima.** Il nome dell'arte, il nome della gettata, il
    // sigillo, una didascalia sulla bindrune, un'altra riga sulla tradizione
    // e il presagio in coda: sei blocchi di testo attorno a un simbolo. Chi
    // la riceveva non sapeva dove guardare.
    //
    // **Cosa resta.** Il sigillo, che e' il simbolo di quella gettata e di
    // nessun'altra, e la prima frase del presagio, che e' cio' che la persona
    // vuole far sapere. Il resto sta nella schermata, dietro il tocco.
    return CardDaMandare(
      palette: palette,
      arte: 'Estrazione Rune',
      frase: _laFrase(),
      parola: esito.rune.first.rune.keyword,
      invito: 'Le tue rune di oggi ti aspettano',
      simbolo: _ilSimbolo(palette),
    );
  }

  /// **IL SIMBOLO DELLA CARD: la pietra quando la runa e' una, il sigillo
  /// quando sono piu' di una.**
  ///
  /// La card si manda perche' porta il simbolo di CHI la manda, e a una
  /// runa sola quel simbolo e' la pietra che gli e' uscita, con la sua
  /// incisione e il suo verso: il sigillo di un glifo solo e' lo stesso
  /// glifo ridisegnato, cioe' l'arte di Caligo tolta di mezzo per niente.
  /// Da due rune in su l'intreccio esiste davvero, ed e' quello a essere
  /// suo e di nessun altro.
  ///
  /// **IN MERKSTAVE LA PIETRA SI CAPOVOLGE**, come nella schermata: il
  /// verso d'ombra e' parte del responso e una card che lo perde dice
  /// un'altra cosa.
  Widget _ilSimbolo(MaestroPalette palette) {
    final prima = esito.rune.first;
    if (esito.rune.length == 1 && prima.rune.hasImage) {
      final pietra = SizedBox(
        width: 190,
        height: 190,
        child: Image.asset(prima.rune.thumbPath!,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.diamond_outlined,
                size: 96, color: palette.goldSoft)),
      );
      return prima.inOmbra
          ? Transform.rotate(angle: math.pi, child: pietra)
          : pietra;
    }
    return BindruneSigillo(
      runeNames: [for (final r in esito.rune.take(3)) r.rune.name],
      oro: palette.gold,
      alone: palette.goldSoft,
      lato: 190,
    );
  }

  /// **LA PRIMA FRASE DEL PRESAGIO, e nient'altro.**
  ///
  /// Il presagio intero e' tre paragrafi: dentro una card diventerebbe un
  /// muro, e un muro non si manda. La prima frase e' quella che risponde, ed
  /// e' scritta per stare da sola.
  ///
  /// **Se anche quella e' lunga si taglia sulla virgola**, che e' il primo
  /// respiro della frase: tagliare a caratteri spezzerebbe una parola a meta',
  /// e una card con una parola tronca non la manda nessuno.
  String _laFrase() {
    final prima = presagio.split(RegExp(r'(?<=[.!?])\s')).first.trim();
    if (prima.length <= 90) return prima;
    final virgola = prima.indexOf(',');
    if (virgola > 30 && virgola < 90) {
      return '${prima.substring(0, virgola)}.';
    }
    return prima;
  }
}

Future<bool> shareRuneCard({
  required GlobalKey boundaryKey,
  required EsitoGettata esito,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/estrazione_rune_${esito.gettata.id}.png');
  await file.writeAsBytes(png, flush: true);
  final nomi = esito.rune.map((r) => r.rune.name).join(', ');
  // Ordine BG voce 04: l'esito VERO della porta risale al chiamante,
  // che a condivisione avvenuta paga il premio dichiarato sul pulsante.
  return PortaDellaCondivisione.daFile(file.path,
      testo: 'Ho gettato le rune con ${esito.gettata.nome}: $nomi. '
          'Scopri il tuo presagio con Caligo, su Esoteric Circle.');
}

// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/il_filo_del_consulto.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_voce_vera_di_gemini.dart';

/// **IL FILO NON MESCOLA I TEMI, COL MODELLO VERO.** Ordine del 14 ottobre
/// 2026.
///
/// Il fondatore, sul telefono: una stesa a quattro carte sulla domanda
/// "quando partorirò un bambino" aveva aperto il filo del consulto; un'ora
/// dopo (senza chiuderlo: il filo vive un'ora intera, e la riapertura
/// dell'app non lo chiude) una stesa del tutto diversa, una carta sola su
/// "fiducia e tradimento", ha ricevuto quella domanda come punto fermo, e
/// la risposta parlava ancora del bambino. La cura: `IlFiloDelConsulto.
/// conIlFilo` non inietta piu' il filo quando la domanda nuova non
/// condivide nemmeno una radice di parola col tema del consulto in corso
/// (`il_filo_del_consulto_test.dart`, col modello finto). Qui si misura col
/// modello vero, due chiamate: la prima apre il filo, la seconda e' quella
/// che prima del 14 ottobre mescolava i temi.
///
/// ```
/// flutter test -r expanded tool/collaudo_il_filo_non_mescola_i_temi.dart
/// ```
void main() {
  test('il filo non mescola i temi, col modello vero', () async {
    HttpOverrides.global = null;
    IlFiloDelConsulto.dimentica();
    final voce = VoceVeraDiGemini();
    final righe = <String>[
      'IL FILO NON MESCOLA I TEMI, ordine del 14 ottobre 2026',
      'Modello: ${LaLetturaDellaStesa.modello}, regione europe-west1, '
          '${DateTime.now().toUtc().toIso8601String()}',
      '',
    ];

    Future<String?> chiama(String istruzione, String richiesta, campi) async {
      final esito = await voce.genera(
        istruzione: istruzione,
        richiesta: richiesta,
        campi: campi.keys.toList(),
        modello: LaLetturaDellaStesa.modello,
      );
      return esito.testo;
    }

    // **LA PRIMA STESA non si rifa' col modello vero**: quello che conta
    // per questa prova e' il filo gia' aperto sul tema del bambino, non il
    // testo esatto che glielo ha scritto. Si apre allo stesso modo in cui
    // `LaLetturaDellaStesa.leggi` lo apre davvero, con `IlFiloDelConsulto.
    // annota` (la stessa chiamata che fa lei a lettura riuscita), cosi' la
    // seconda chiamata vede esattamente il filo che il fondatore ha visto.
    IlFiloDelConsulto.annota(
      maestro: Maestro.medora,
      domanda: 'quando partorirò un bambino',
      risposta: 'Il Cavaliere di Bastoni ti mostra che il tuo desiderio di '
          'partorire un bambino è accompagnato da un\'energia ardente e '
          'dalla voglia di agire.\n'
          '✦ Agisci con determinazione per i prossimi trenta giorni.',
    );
    righe
      ..add('== IL FILO, aperto senza chiamata, come lo apre leggi()')
      ..add(
          '  filo aperto: ${IlFiloDelConsulto.scheda != null}, tema: «${IlFiloDelConsulto.scheda?.tema}»')
      ..add('');

    // **LA SECONDA STESA, una carta sola, il tema del tutto diverso.** Il
    // filo e' ancora aperto (non e' passata un'ora, e nessuno l'ha
    // chiuso): e' esattamente il caso del fondatore.
    final secondaSpread = TarotSpread.draw(
        seed: 702, posizioni: TarotSpreadType.unaCarta.posizioni);
    final seconda = await LaLetturaDellaStesa.leggi(
      spread: secondaSpread,
      domanda: TarotTopic.fiducia.label,
      argomento: TarotTopic.fiducia.label,
      forma: CourtesyForm.neutral,
      chiamata: chiama,
    );
    final rispostaSeconda = '${seconda?.risposta ?? ''} '
        '${seconda?.cosaFare ?? ''}';
    final mescolato = rispostaSeconda.toLowerCase().contains('bambino') ||
        rispostaSeconda.toLowerCase().contains('partorir');
    righe
      ..add('== SECONDA STESA, una carta, "${TarotTopic.fiducia.label}"')
      ..add('  esito: ${seconda == null ? 'LETTURA DI CASA' : 'dal modello'}')
      ..add('  risposta: ${seconda?.risposta}')
      ..add('  consiglio: ${seconda?.cosaFare}')
      ..add('  MESCOLA IL TEMA DEL BAMBINO: $mescolato')
      ..add('');

    final testo = righe.join('\n');
    print(testo);
    Directory('docs/collaudo/il_filo_non_mescola_i_temi')
        .createSync(recursive: true);
    File('docs/collaudo/il_filo_non_mescola_i_temi/giro.txt')
        .writeAsStringSync('$testo\n');

    expect(mescolato, isFalse,
        reason: 'la seconda risposta nomina ancora il bambino: il filo ha '
            'mescolato i temi');
  }, timeout: const Timeout(Duration(minutes: 5)));
}

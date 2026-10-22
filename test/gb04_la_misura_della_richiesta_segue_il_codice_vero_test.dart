// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA STIMA DEL COSTO DELLE STESE SEGUE IL TESTO VERO, ORDINE GB VOCE 04,
/// 22 OTTOBRE 2026.**
///
/// `tool/i_limiti_degli_annuali.py` non usa piu' un costo uniforme per ogni
/// stesa (la vecchia `STESA`, 1950 gettoni "per ogni piano, prudente"): dal
/// 22 ottobre separa la stesa fino a quattro carte (`INGRESSO_STESA_PICCOLA`)
/// dalla Croce Celtica (`INGRESSO_STESA_DIECI`), misurate sul testo VERO che
/// [LaLetturaDellaStesa.istruzione] e [LaLetturaDellaStesa.richiesta]
/// costruiscono, non su una stima a occhio: nessuna chiamata al modello
/// (R2 dell'ordine GB), solo il conteggio delle parole che il codice scrive
/// davvero, a 1,5 gettoni a parola (la stessa resa dell'uscita, nello stesso
/// file Python).
///
/// **SENZA QUESTA PROVA I DUE NUMERI DEL PYTHON POSSONO INVECCHIARE IN
/// SILENZIO**: se domani l'istruzione o il corpus delle posizioni cambiano
/// lunghezza, i gettoni scritti a mano in `tool/i_limiti_degli_annuali.py`
/// restano quelli di oggi e il conto del 30 per cento comincia a mentire.
/// Questa prova rifa' la misura vera e la confronta con quella scritta nello
/// strumento, con una tolleranza (il conto in gettoni arrotonda le parole,
/// e la resa parola/gettone stessa e' una stima, non una tokenizzazione
/// vera): oltre il 15 per cento di scarto la prova cade col numero giusto da
/// scrivere al posto di quello vecchio.
int parole(String s) =>
    s.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

void main() {
  test('i gettoni della stesa piccola e della Croce Celtica sono quelli '
      'del testo vero', () {
    final fisse =
        LaLetturaDellaStesa.istruzione(CourtesyForm.neutral, profonda: true);
    final paroleFisse = parole(fisse);

    int paroleTotaliPer(TarotSpreadType t) {
      final spread = TarotSpread.draw(seed: 13, posizioni: t.posizioni);
      final richiesta = LaLetturaDellaStesa.richiesta(spread,
          domanda: 'Devo cambiare lavoro adesso o aspettare ancora un po?',
          argomento: 'Lavoro',
          gruppo: TarotTopic.lavoroTrovare.group);
      return paroleFisse + parole(richiesta);
    }

    final paroleQuattro = paroleTotaliPer(TarotSpreadType.croceQuattro);
    final paroleDieci = paroleTotaliPer(TarotSpreadType.dieciCarte);
    final gettoniQuattroVeri = (paroleQuattro * 1.5).round();
    final gettoniDieciVeri = (paroleDieci * 1.5).round();

    final strumento =
        File('tool/i_limiti_degli_annuali.py').readAsStringSync();
    int costanteDelPython(String nome) {
      final m = RegExp('$nome = round\\((\\d+) \\* 1\\.5\\)')
          .firstMatch(strumento);
      expect(m, isNotNull,
          reason: '$nome non si legge piu\' con la forma "round(N * 1.5)" '
              'in tool/i_limiti_degli_annuali.py: aggiorna la prova insieme '
              'allo strumento');
      return int.parse(m!.group(1)!);
    }

    final paroleQuattroDelPython =
        costanteDelPython('INGRESSO_STESA_PICCOLA');
    final paroleDieciDelPython = costanteDelPython('INGRESSO_STESA_DIECI');

    print('GB.04 MISURA: quattro carte, parole vere $paroleQuattro '
        '(~$gettoniQuattroVeri gettoni) contro $paroleQuattroDelPython '
        'nello strumento; dieci carte, parole vere $paroleDieci '
        '(~$gettoniDieciVeri gettoni) contro $paroleDieciDelPython');

    void vicino(int vero, int scritto, String nome) {
      final scarto = (vero - scritto).abs() / vero;
      expect(scarto, lessThan(0.15),
          reason: '$nome: il testo vero porta $vero parole, lo strumento '
              'ne scrive $scritto, scarto ${(scarto * 100).toStringAsFixed(1)}'
              ' per cento. Aggiorna INGRESSO_STESA_PICCOLA o '
              'INGRESSO_STESA_DIECI in tool/i_limiti_degli_annuali.py a '
              '$vero e rilancia il conto.');
    }

    vicino(paroleQuattro, paroleQuattroDelPython, 'quattro carte');
    vicino(paroleDieci, paroleDieciDelPython, 'dieci carte');
  });
}

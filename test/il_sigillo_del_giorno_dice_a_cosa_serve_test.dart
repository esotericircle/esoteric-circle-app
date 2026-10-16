import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'codice_senza_testo.dart';

/// **IL SIGILLO DEL GIORNO DICE A COSA SERVE, E LA RUNA SOLA NON E' UNA
/// LEZIONE.** Ordine CQ voci 2.07 e 2.10, 4 settembre 2026.
///
/// **La voce 2.07 era stata dichiarata in attesa di una decisione, e non lo
/// era.** Il manifesto diceva che nell'app non esiste nessuno "Sigillo del
/// Giorno" e che serviva sapere quale dei tre Sigilli il fondatore
/// intendesse. **Era una ricerca fatta male**: il Sigillo del Giorno esiste,
/// e' la bindrune che chiude ogni gettata di rune, e sta in
/// `rune_draw_screen.dart` con la sua chiave. Cercarlo fra i nomi delle
/// schermate invece che dentro le schermate ha prodotto una fermata dove
/// c'era lavoro.
///
/// **Cosa c'era scritto sotto il disegno.** La nota della tradizione, che dice
/// bene che cosa E' una bindrune e non dice niente su cosa te ne fai: chi
/// legge riceve una definizione dove si aspettava un uso.
void main() {
  final schermata =
      File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
          .readAsStringSync();

  test('sotto il Sigillo c e scritto a cosa serve, prima della tradizione',
      () {
    // I due numeri si leggono sullo STESSO testo, o il confronto stampato
    // direbbe una cosa e la pretesa un'altra.
    final aCosaServe = schermata.indexOf("Key('rune_sigillo_a_cosa_serve')");
    final tradizione = schermata.indexOf('kRuneBindruneNota');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.07: la riga dell uso sta al carattere '
        '$aCosaServe, la nota della tradizione al $tradizione');
    expect(aCosaServe, greaterThanOrEqualTo(0),
        reason: 'sotto il Sigillo del Giorno non c e nessuna riga che dica a '
            'cosa serve: chi legge riceve una definizione dove si aspettava '
            'un uso');
    expect(schermata.indexOf('kRuneBindruneNota'), greaterThan(aCosaServe),
        reason: 'la nota della tradizione viene PRIMA della riga che dice a '
            'cosa serve: la fonte sta in fondo, e questa e la legge dei testi '
            'del pezzo secondo');
  });

  test('la riga dell uso non promette niente', () {
    // **NON PROMETTE UN ESITO**, che e' la legge di ogni testo di questa app.
    //
    // **LA RIGA HA CAMBIATO CASA, ordine CQ voce 6.17.** Stava scritta a
    // mano nella schermata; adesso la compone `SigilloDelGiorno`, perche'
    // deve rispondere alla domanda con quello che le rune intrecciate
    // portano insieme. La prova la cerca dove vive: **una prova che insegue
    // il testo invece della porta cade a ogni trasloco.**
    final porta = File('lib/core/rituals/rune_voce.dart').readAsStringSync();
    final inizio = porta.indexOf("'Le rune di questa gettata");
    expect(inizio, greaterThanOrEqualTo(0),
        reason: 'la riga dell uso e cambiata e questa prova non la trova piu');
    final riga = porta.substring(inizio, inizio + 200);
    for (final promessa in const [
      'otterrai',
      'ti portera',
      'vedrai',
      'sara tuo',
    ]) {
      expect(riga.toLowerCase().contains(promessa), isFalse,
          reason: 'la riga dell uso promette un esito con "$promessa"');
    }
  });

  test('a una runa sola il corpo della scheda sta dietro una porta', () {
    final codice = codiceSenzaTesto(schermata);
    expect(codice.contains('_IlRestoDellaRuna('), isTrue,
        reason: 'la porta che tiene il corpo della scheda non esiste piu: a '
            'una runa sola il responso torna a essere una pagina di manuale');
    expect(codice.contains('sola: esito.rune.length == 1'), isTrue,
        reason: 'la scheda non sa piu quando la runa e sola, quindi la porta '
            'non si monta mai oppure si monta sempre');
    // **E LA PORTA SI APRE**: un blocco che si nasconde e non si riapre
    // sarebbe una perdita di contenuto, non un accorciamento.
    expect(schermata.contains("Key('rune_apri_il_resto_"), isTrue,
        reason: 'la porta non ha nessun comando per aprirsi');
    var quanti = 0;
    for (final pezzo in const ['simbolo:', 'voce:', 'strofa:']) {
      if (codice.contains(pezzo)) quanti++;
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.10: dentro la porta entrano $quanti pezzi su 3');
    cardinaleMinimo(quanti, 3,
        cosa: 'pezzi del corpo della scheda che entrano nella porta',
        perche: 'Se la porta si svuotasse, la prova direbbe che il taglio c e '
            'mentre il contenuto e stato perso invece che spostato.');
  });
}

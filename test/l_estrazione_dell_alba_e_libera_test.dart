// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/rituals/arcano_dell_alba/stato_dell_alba.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ESTRAZIONE DELL'ARCANO DELL'ALBA E' LIBERA.** Ordine DU voce 11,
/// 17 settembre 2026.
///
/// Fino alla build 2267 al posto di questa prova ce n'era una opposta,
/// `il_sacchetto_dell_alba_test.dart`: pretendeva che ogni stato uscisse una
/// volta per ciclo e che una carta non tornasse prima di undici giorni.
/// **Il fondatore ha deciso il contrario**: *"alla roulette puo' uscire lo
/// stesso numero due volte"*. Una carta che non puo' tornare e' una carta
/// amministrata, e chi la riceve lo sente.
///
/// Qui si misura che l'estrazione sia davvero quella del caso: tutti gli stati
/// con la stessa probabilita', il verso che non segue la carta, il ritorno
/// immediato che capita con la frequenza giusta, **e nessun vincolo rimasto in
/// giro a impedirlo**, ne' nel codice ne' in un'altra prova.
void main() {
  test('i numeri vengono dalle carte: 22 carte, 44 stati', () {
    expect(StatoDellAlba.carte, 22);
    expect(StatoDellAlba.quanti, 44);
  });

  test('TUTTI E QUARANTAQUATTRO GLI STATI, con la stessa probabilita', () {
    // Su centomila giri ogni stato vale un quarantaquattresimo, cioe' 2273
    // uscite attese. La banda e' del venti per cento attorno all'atteso: piu'
    // stretta prenderebbe il caso, piu' larga non vedrebbe uno stato zoppo.
    const giri = 100000;
    final quante = List<int>.filled(StatoDellAlba.quanti, 0);
    final caso = Random(11);
    for (var i = 0; i < giri; i++) {
      quante[StatoDellAlba.aCaso(caso).id]++;
    }
    final atteso = giri / StatoDellAlba.quanti;
    final zoppi = <String>[];
    for (var id = 0; id < StatoDellAlba.quanti; id++) {
      if (quante[id] < atteso * 0.8 || quante[id] > atteso * 1.2) {
        zoppi.add('stato $id uscito ${quante[id]} volte invece di '
            '${atteso.round()}');
      }
    }
    print('ORDINE DU voce 11: su $giri giri il minimo e\' '
        '${quante.reduce(min)}, il massimo ${quante.reduce(max)}, atteso '
        '${atteso.round()}');
    expect(zoppi, isEmpty, reason: zoppi.join('\n'));
  });

  test('LA STESSA CARTA PUO\' USCIRE DUE VOLTE DI FILA, come alla roulette',
      () {
    // **E' la voce 11 in una riga.** Su centomila giri la stessa carta torna
    // il giro dopo una volta su ventidue, e lo stesso stato, verso compreso,
    // una volta su quarantaquattro. Se qualcuno rimettesse un vincolo, questi
    // due conti andrebbero a zero e questa prova lo direbbe.
    const giri = 100000;
    final caso = Random(5);
    var stato = StatoDellAlba.aCaso(caso);
    var cartaDiFila = 0, statoDiFila = 0;
    for (var i = 1; i < giri; i++) {
      final nuovo = StatoDellAlba.aCaso(caso);
      if (nuovo.carta == stato.carta) cartaDiFila++;
      if (nuovo == stato) statoDiFila++;
      stato = nuovo;
    }
    final quotaCarta = cartaDiFila / (giri - 1);
    final quotaStato = statoDiFila / (giri - 1);
    print('ORDINE DU voce 11: la stessa carta di fila nel '
        '${(quotaCarta * 1000).round() / 10} per cento dei giri, lo stesso '
        'stato nel ${(quotaStato * 1000).round() / 10} per cento');
    expect(quotaCarta, inInclusiveRange(1 / 22 * 0.85, 1 / 22 * 1.15),
        reason: 'la stessa carta torna il giorno dopo con una frequenza che '
            'non e\' quella del caso: qualcosa la governa');
    expect(quotaStato, inInclusiveRange(1 / 44 * 0.8, 1 / 44 * 1.2));
  });

  test('IL VERSO NON SEGUE LA CARTA: esce dal caso, non dal tocco', () {
    // Voce 07: chi tocca un dorso non puo' sapere se sara' dritto o rovescio.
    // Il verso si estrae qui insieme alla carta, e su ogni singola carta la
    // meta' delle uscite e' rovescia.
    const giri = 44000;
    final caso = Random(3);
    final rovesce = List<int>.filled(StatoDellAlba.carte, 0);
    final uscite = List<int>.filled(StatoDellAlba.carte, 0);
    for (var i = 0; i < giri; i++) {
      final s = StatoDellAlba.aCaso(caso);
      uscite[s.carta]++;
      if (s.rovescio) rovesce[s.carta]++;
    }
    final storte = <String>[];
    for (var c = 0; c < StatoDellAlba.carte; c++) {
      final quota = rovesce[c] / uscite[c];
      if (quota < 0.44 || quota > 0.56) {
        storte.add('carta $c rovescia nel ${(quota * 100).round()} per cento');
      }
    }
    expect(storte, isEmpty, reason: storte.join('\n'));
  });

  test('NESSUN VINCOLO RESTA IN GIRO, ne nel codice ne in un\'altra prova', () {
    // **La voce dice anche questo**: non basta togliere il sacchetto, deve
    // restare tolto. Una prova che pretendesse la distanza minima tornerebbe
    // a vietare cio' che il fondatore ha voluto permettere, e nessuno se ne
    // accorgerebbe finche' resta verde.
    // Si guardano **i file dell'Alba** e **le sole righe di codice**: la
    // storia del sacchetto sta scritta nei commenti di piu' di un file, qui
    // compreso, e una guardia che legge i commenti boccia il racconto di cio'
    // che e' stato tolto invece della cosa tolta.
    const proibite = ['Sacchetto', 'distanzaMinima', 'ultimeCarte'];
    final colpevoli = <String>[];
    final guardati = <String>[];
    for (final cartella in ['lib', 'test']) {
      for (final f in Directory(cartella)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final nome = f.path.split(RegExp(r'[\\/]')).last;
        if (!f.path.toLowerCase().contains('alba')) continue;
        if (nome == 'l_estrazione_dell_alba_e_libera_test.dart') continue;
        guardati.add(nome);
        final codice = f
            .readAsLinesSync()
            .where((r) => !r.trimLeft().startsWith('//'))
            .join('\n');
        for (final p in proibite) {
          if (codice.contains(p)) colpevoli.add('$nome: $p');
        }
      }
    }
    print('ORDINE DU voce 11: file dell\'Alba guardati ${guardati.length}');
    expect(guardati.length, greaterThan(10),
        reason: 'la prova ha guardato ${guardati.length} file: su un insieme '
            'vuoto sarebbe verde senza aver guardato niente');
    expect(colpevoli, isEmpty, reason: colpevoli.join('\n'));
  });
}

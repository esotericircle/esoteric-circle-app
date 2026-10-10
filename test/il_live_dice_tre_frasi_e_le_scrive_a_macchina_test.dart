import 'dart:io';

import 'package:esoteric_circle/features/maestri/live/la_macchina_da_scrivere.dart';
import 'package:esoteric_circle/features/maestri/live/le_tre_frasi_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL LIVE DICE TRE FRASI E LE SCRIVE A MACCHINA.** Ordine ER voci 12 e 13,
/// 27 settembre 2026.
///
/// ER.12: sul Realme le risposte del LIVE duravano da 20 a 50 secondi di
/// voce; il fondatore ha approvato il taglio alla terza frase, mai in mezzo a
/// una frase. ER.13: *"Un conto è aspettare Senza fare nulla e un'altro è
/// leggere mentre si compone la domanda fatta e la risposta ricevuta."*
void main() {
  const risposta =
      'Domani al colloquio porta con te una pietra liscia. Tienila in tasca '
      'e stringila prima di entrare. Il respiro lento farà il resto. Poi '
      'ascolta cosa ti dicono le mani.\n✦ Stasera prepara la pietra sul '
      'comodino.';

  group('Le tre frasi (ER.12)', () {
    test('con il gesto: due frasi del corpo e il gesto', () {
      expect(
          LeTreFrasiDelLive.di(risposta),
          'Domani al colloquio porta con te una pietra liscia. Tienila in '
          'tasca e stringila prima di entrare. Stasera prepara la pietra sul '
          'comodino.');
    });

    test('senza gesto: le prime tre frasi, intere', () {
      expect(LeTreFrasiDelLive.di('Uno. Due due. Tre tre tre. Quattro.'),
          'Uno. Due due. Tre tre tre.');
    });

    test('mai piu\' di tre frasi, mai un taglio a meta\'', () {
      for (final t in [
        risposta,
        'Una frase sola.',
        'Prima! Seconda? Terza… Quarta.\n✦ Il gesto.',
        '**Grassetto**. Corpo due. Corpo tre.',
      ]) {
        final dette = LeTreFrasiDelLive.di(t);
        final frasi = LeTreFrasiDelLive.frasiDi(dette);
        expect(frasi.length, lessThanOrEqualTo(LeTreFrasiDelLive.quante),
            reason: '«$dette» ha ${frasi.length} frasi');
        expect(RegExp(r'[.!?…]$').hasMatch(dette), isTrue,
            reason: '«$dette» finisce a meta\' di una frase');
      }
    });

    test('mentre arriva si ferma a due frasi, e cresce soltanto', () {
      final inArrivo = LeTreFrasiDelLive.di(
          'Domani al colloquio porta con te una pietra liscia. Tienila in '
          'tasca e stringila prima di entrare. Il respiro lento',
          inArrivo: true);
      expect(LeTreFrasiDelLive.di(risposta), startsWith(inArrivo),
          reason: 'quello che si scrive mentre arriva deve restare quando '
              'arriva il gesto');
    });
  });

  group('La macchina da scrivere (ER.13)', () {
    final t0 = DateTime(2026, 9, 27, 15);
    DateTime dopo(int ms) => t0.add(Duration(milliseconds: ms));

    test('la domanda si scrive a lettere, la risposta dopo di lei', () {
      final m = LaMacchinaDaScrivere()
        ..nuovaDomanda('Come mi preparo al colloquio?', t0)
        ..risposta('Porta una pietra liscia.', t0);
      expect(m.aVideo(t0).domanda, isEmpty);
      final meta = m.aVideo(dopo(250));
      expect(meta.domanda.length, inInclusiveRange(10, 20));
      expect(meta.risposta, isEmpty,
          reason: 'la risposta comincia quando la domanda e\' intera');
      final fine = m.aVideo(dopo(3000));
      expect(fine.domanda, 'Come mi preparo al colloquio?');
      expect(fine.risposta, 'Porta una pietra liscia.');
    });

    test('non scrive oltre cio\' che e\' arrivato', () {
      final m = LaMacchinaDaScrivere()
        ..nuovaDomanda('Ciao?', t0)
        ..risposta('Pr', t0);
      expect(m.aVideo(dopo(5000)).risposta, 'Pr');
    });

    test('mai indietro rispetto alla voce', () {
      final lunga = List.filled(40, 'parola').join(' ');
      final m = LaMacchinaDaScrivere()
        ..nuovaDomanda(List.filled(30, 'lunga').join(' '), t0)
        ..risposta(lunga, t0)
        ..voceIniziata(dopo(100));
      for (var ms = 200; ms < 6000; ms += 100) {
        final scritte = m.scritteDellaRisposta(dopo(ms));
        final dette = ((ms - 100) /
                1000 *
                LaMacchinaDaScrivere.letterePerSecondoDellaVoce)
            .floor();
        expect(scritte, greaterThanOrEqualTo(dette.clamp(0, lunga.length)),
            reason: 'a $ms ms la voce ha detto $dette lettere e a video ce '
                'ne sono $scritte');
      }
    });

    test('se le reti cambiano la risposta, resta solo il pezzo comune', () {
      final m = LaMacchinaDaScrivere()
        ..nuovaDomanda('A?', t0)
        ..risposta('Aspetta tre giorni.', t0);
      final prima = m.aVideo(dopo(600)).risposta;
      expect(prima, isNotEmpty);
      m.risposta('Scrivile stasera.', dopo(600));
      expect(m.aVideo(dopo(600)).risposta, isEmpty,
          reason: 'a video restano parole che il Maestro non dira\': le due '
              'risposte non hanno niente in comune');
      expect(m.aVideo(dopo(1200)).risposta, startsWith('Scrivile'));
    });
  });

  test('nella schermata la voce e il testo passano dalle tre frasi', () {
    final s = File('lib/features/maestri/live/schermata_live.dart')
        .readAsStringSync();
    // **LAPIDE, ordine FE voce 07 (commit ba5812cf).** `_dillo` dice adesso
    // se la voce e' uscita (`Future<bool>`), e il turno che non esce chiude
    // il LIVE: la firma cercata qui era `Future<void> _dillo(`.
    final dillo = s.substring(s.indexOf('Future<bool> _dillo('),
        s.indexOf('/// La voce composta in anticipo'));
    // **LAPIDE, ordine ET voce 06.** Qui si cercava
    // `conAttesa ? LeTreFrasiDelLive.di(scritto)`: dall'ordine ET il taglio
    // riceve la domanda del turno, che decide tre frasi o quattro.
    expect(dillo,
        contains('LeTreFrasiDelLive.di(scritto, domanda: _domandaDelTurno)'),
        reason: 'la voce del turno non si ferma alla terza frase');
    final turno = s.substring(s.indexOf('Future<void> _turno(String testo)'),
        s.indexOf('/// **LA VOCE DEL MAESTRO, VERSO IL VOLTO.**'));
    expect(turno, contains('_avviaLaMacchina(testo)'),
        reason: 'la domanda non si scrive a macchina');
    expect(turno, contains('_macchina.risposta('),
        reason: 'la risposta non passa dalla macchina da scrivere');
    expect(turno.indexOf('_avviaLaMacchina(testo)'),
        lessThan(turno.indexOf('await chat.send(testo)')),
        reason: 'la domanda parte al modello solo dopo la scrittura');
    expect(s, contains('_macchina.voceIniziata('),
        reason: 'la scrittura non sa quando la voce comincia');
  });
}

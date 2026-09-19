// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/sigilli/attesa_del_cielo.dart';
import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/core/sigilli/sentiero_albero.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL TRAMONTO DELLE DODICI LUNE. Ordine EA voce 05.
///
/// **Il fatto, dal fondatore**: *"la runa del tramonto e estrazione rune non
/// devono essere collegate all'astrologia"*, e poi, sul Sigillo in cima al
/// sentiero di Caligo: *"legalo solo alla luna piena"*.
///
/// **Perche' non basta togliere il segno.** Quel Sigillo chiedeva la Luna
/// piena NEL TUO SEGNO, che capita una volta l'anno, ed e' l'ultimo gradino
/// della fascia dell'anno, da centotrenta Eos. La sola Luna piena torna ogni
/// mese: chiederne una avrebbe messo in cima alla scala il gradino piu'
/// facile. Se ne chiedono **dodici**, un anno di lune.
///
/// **La fotografia del Cammino sa solo cosa c'e' in cielo OGGI**, quindi le
/// sere passate si contano sui dettagli del gesto: la Runa del Tramonto
/// scrive `luna_piena` quando la Luna e' piena davvero, e questa condizione
/// li conta.
void main() {
  StatoDelCammino stato({int lunePiene = 0, bool oggiPiena = false}) =>
      StatoDelCammino(
        gestiCompiuti: const {},
        giorniConGesto: const {},
        oggiHaFatto: const {},
        eventiDelCieloDiOggi:
            oggiPiena ? const {EventiDelCielo.lunaPiena} : const {},
        massimeRipetizioni: {'tramonto.${EventiDelCielo.lunaPiena}': lunePiene},
      );

  final dodici = sentieroDellAlbero.firstWhere((t) => t.id == 'cal_55');

  test('il Sigillo in cima a Caligo chiede dodici Lune piene col Tramonto',
      () {
    final c = dodici.condizione;
    expect(c, isA<FinestraDelCielo>(),
        reason: 'cal_55 non e\' piu\' una finestra del cielo');
    final finestra = c as FinestraDelCielo;
    expect(finestra.evento, EventiDelCielo.lunaPiena,
        reason: 'l\'evento e\' ${finestra.evento}: il segno e\' tornato '
            'dentro la Runa del Tramonto');
    expect(finestra.volte, 12);
    expect(finestra.conGesto, 'tramonto');
    // Il nome e la frase non nominano nessun segno.
    for (final testo in [dodici.nome, dodici.frase, dodici.cosaApre]) {
      expect(testo.toLowerCase().contains('tuo segno'), isFalse,
          reason: 'resta il segno in: $testo');
    }
  });

  test('si accende alla dodicesima Luna, non alla undicesima', () {
    final c = dodici.condizione;
    expect(c.raggiunto(stato(lunePiene: 11, oggiPiena: true)), isFalse,
        reason: 'undici Lune piene accendono un Sigillo che ne chiede dodici');
    expect(c.raggiunto(stato(lunePiene: 12)), isTrue,
        reason: 'dodici Lune piene non lo accendono, e nemmeno il giorno '
            'dopo: la memoria delle sere sta nei dettagli, non nel cielo di '
            'oggi');
    expect(c.raggiunto(stato()), isFalse);
  });

  test('il costo e\' l\'attesa della prima Luna piu\' undici ritorni', () {
    final atteso = attesaTipicaDelCielo[EventiDelCielo.lunaPiena]! +
        11 * ritornoDelCielo[EventiDelCielo.lunaPiena]!;
    print('ORDINE EA VOCE 05: cal_55 costa ${dodici.condizione.costoInGiorni} '
        'giorni, atteso $atteso');
    expect(dodici.condizione.costoInGiorni, atteso);
    // E sta dentro la fascia dell'anno, che va da 191 a 365: se il costo
    // uscisse dalla banda, la regola 4 dei traguardi cadrebbe altrove, e qui
    // si direbbe perche'.
    expect(dodici.condizione.costoInGiorni, inInclusiveRange(191, 365));
    expect(dodici.fascia, 'L\'anno');
  });

  test('una finestra normale non e\' toccata: una volta, e basta il cielo',
      () {
    const una = FinestraDelCielo(EventiDelCielo.lunaPiena, conGesto: 'soffio');
    expect(una.volte, 1);
    expect(una.costoInGiorni,
        attesaTipicaDelCielo[EventiDelCielo.lunaPiena]!);
    expect(una.raggiunto(stato(oggiPiena: true)), isFalse,
        reason: 'senza il gesto di oggi non si accende');
  });

  test('la Runa del Tramonto scrive la Luna piena nei dettagli del gesto', () {
    // **LA GUARDIA CAMMINA FINO ALLA SORGENTE.** Senza questa riga la
    // condizione conterebbe un dettaglio che nessuno scrive, cioe' un
    // Sigillo che non si accende mai.
    final sorgente = File('lib/features/rituals/sunset_rune_screen.dart')
        .readAsStringSync();
    expect(sorgente.contains('EventiDelCielo.lunaPiena'), isTrue,
        reason: 'il Tramonto non guarda piu\' la Luna piena');
    expect(sorgente.contains('if (lunaPiena) EventiDelCielo.lunaPiena:'),
        isTrue,
        reason: 'il Tramonto non scrive la Luna piena nei dettagli del '
            'gesto: il Sigillo delle dodici Lune non si accenderebbe mai');
  });
}

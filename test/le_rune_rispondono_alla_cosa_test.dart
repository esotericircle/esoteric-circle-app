// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/domande/cornici_del_presagio.dart';
import 'package:esoteric_circle/core/rituals/la_lettura_delle_rune.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE RUNE RISPONDONO ALLA COSA CHIESTA.** Ordine ET voce 07, 28 settembre
/// 2026.
///
/// Alla lettura alla cieca del giro 8 dell'ordine ER, e di nuovo sulla
/// partenza di quest'ordine, le letture non dirette erano quasi tutte
/// domande aperte a cui la prima frase rispondeva con un atteggiamento
/// (*"La scelta che ti blocca si scioglie riconoscendo il tuo vero
/// valore"*), le domande della cornice che ne ripetevano l'immagine (*"una
/// direzione c'è già, ma non è ancora chiara"*), le gettate senza domanda
/// che non sapevano di che giorno parlavano, e le pietre lette senza la
/// posizione o senza la cosa chiesta (*"Berkano suggerisce che un nuovo
/// inizio è pronto"*, alla domanda su Luca).
void main() {
  final norne = gettate.firstWhere((g) => g.id == 'norne');
  final esito = RuneCast.getta(norne, random: Random(1006));
  final nomi = [for (final p in esito.rune) p.rune.name];
  final posti = [for (final p in esito.rune) p.posizione.titolo];
  const domanda = 'Nel lavoro, quale passo fare?';

  Map<String, Object> lettura({
    String posizione = 'un passo da fare',
    String inBreve = 'chiedi al capo il progetto nuovo',
    String risposta = 'Nel lavoro chiedi al capo il progetto nuovo entro '
        'venerdì. Le pietre mostrano che il passo tocca a te.',
    List<Object>? pietre,
  }) =>
      {
        'posizione': posizione,
        'inBreve': inBreve,
        'risposta': risposta,
        'pietre': pietre ??
            [
              for (var i = 0; i < nomi.length; i++)
                {
                  'lettura': '${nomi[i]}, nella posizione ${posti[i]}, '
                      'parla di un passo preciso.',
                  'sullaDomanda': 'Nel lavoro indica il passo numero '
                      '${i + 1}.',
                }
            ],
        'legame': 'Le tre pietre vanno dal fermo al passo.',
        'cosaPuoiFare': 'Venerdì mattina chiedi dieci minuti al tuo capo.',
      };

  test('ET.07: la lettura buona passa', () {
    expect(
        LaLetturaDelleRune.scarto(lettura(), esito, domanda: domanda), isNull);
  });

  test('ET.07: la formula al posto del gesto non passa', () {
    final motivo = LaLetturaDelleRune.scarto(
        lettura(
            inBreve: 'riconosci il tuo vero valore nel lavoro',
            risposta: 'Nel lavoro riconosci il tuo vero valore. Le pietre '
                'lo chiedono.'),
        esito,
        domanda: domanda);
    print('ORDINE ET VOCE 7: la formula "$motivo"');
    expect(motivo, contains('atteggiamento'));
  });

  test('ET.07: la prima frase dice cio\' che "inBreve" ha scelto', () {
    final motivo = LaLetturaDelleRune.scarto(
        lettura(
            inBreve: 'chiedi un colloquio al capo',
            risposta: 'Nel lavoro scegli il progetto nuovo. Le pietre '
                'aprono.'),
        esito,
        domanda: domanda);
    expect(motivo, startsWith('"inBreve"'));
  });

  test('ET.07: ogni pietra nomina la cosa chiesta e la sua posizione', () {
    final senzaLaCosa = LaLetturaDelleRune.scarto(
        lettura(pietre: [
          for (var i = 0; i < nomi.length; i++)
            {
              'lettura': '${nomi[i]}, nella posizione ${posti[i]}, parla '
                  'di forza.',
              'sullaDomanda': 'Indica un nuovo inizio, il numero ${i + 1}.',
            }
        ]),
        esito,
        domanda: domanda);
    expect(senzaLaCosa, contains('non dice che cosa indica'));
    final senzaLaPosizione = LaLetturaDelleRune.scarto(
        lettura(pietre: [
          for (var i = 0; i < nomi.length; i++)
            {
              'lettura': '${nomi[i]} parla di forza.',
              'sullaDomanda': 'Nel lavoro indica il passo numero ${i + 1}.',
            }
        ]),
        esito,
        domanda: domanda);
    expect(senzaLaPosizione, contains('non dice la sua posizione'));
    // Senza domanda, la pietra dice la giornata.
    final senzaDomanda = LaLetturaDelleRune.scarto(
        lettura(
            posizione: 'nessuna domanda',
            inBreve: 'oggi chiama tua madre',
            risposta: 'Oggi chiama tua madre prima di sera. Le pietre '
                'lo mostrano.',
            pietre: [
              for (var i = 0; i < nomi.length; i++)
                {
                  'lettura': '${nomi[i]}, nella posizione ${posti[i]}, '
                      'parla di forza.',
                  'sullaDomanda': 'Indica un passo, il numero ${i + 1}.',
                }
            ]),
        esito);
    expect(senzaDomanda, contains('sulla giornata di oggi'));
  });

  test(
      'ET.07: le letture scartate per la forma si mostrano all\'ultima '
      'chiamata, quelle che non si possono mostrare no', () {
    for (final m in [
      'la prima frase della risposta dice un atteggiamento',
      'la prima frase della risposta parla per immagini',
      'la pietra 2 non dice la sua posizione (Verdhandi)',
      'la pietra 1 non dice che cosa indica su ciò che la persona ha chiesto',
      '"inBreve" dice "x", ma la prima frase della risposta non lo dice',
      'hai scelto la posizione "sì" ma la prima frase della risposta non la '
          'dice',
    ]) {
      expect(LaLetturaDelleRune.siMostraComunque(m), isTrue, reason: m);
    }
    for (final m in [
      'un pezzo manca, o le pietre non sono tutte',
      'supera il confine del responso',
      'nomina un astro o un segno',
      'la pietra 1 non nomina Fehu',
    ]) {
      expect(LaLetturaDelleRune.siMostraComunque(m), isFalse, reason: m);
    }
    expect(LaLetturaDelleRune.tentativi, 3);
  });

  test(
      'ET.07: la richiesta non porta la cornice, e senza domanda porta il '
      'giorno', () {
    const dellaCornice = 'In amore, dove sto andando?';
    final cornice = CorniciDelPresagio.perDomanda(dellaCornice)!;
    final r = LaLetturaDelleRune.richiesta(esito, dellaCornice);
    expect(r, isNot(contains(cornice.apertura)));
    expect(r, contains('ed è generale'));
    final giorno =
        LaLetturaDelleRune.richiesta(esito, '', oggi: DateTime(2026, 9, 28));
    expect(giorno, contains('lunedì 28 settembre'));
  });

  test('ET.07: la virgola fra il nome e il verbo si chiude', () {
    final r = LaLetturaDelleRune.daJson(
        lettura(pietre: [
          for (var i = 0; i < nomi.length; i++)
            {
              'lettura': '${nomi[i]} diritta nella posizione ${posti[i]}, '
                  'indica un passo preciso.',
              'sullaDomanda': 'Nel lavoro indica il passo numero ${i + 1}.',
            }
        ]),
        esito)!;
    expect(r.daDoveViene,
        contains('${nomi.first}, diritta nella posizione ${posti.first}, '));
  });
}

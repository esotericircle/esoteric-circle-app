import 'dart:io';

import 'package:esoteric_circle/core/maestro/libreria_dei_respiri.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/card_del_respiro.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/sigillo_della_sessione.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LA CARD DEL RESPIRO CAMBIA CON LA SESSIONE.** Ordine DB voce 10,
/// riscritta dall'ordine DD voce 17 il 10 settembre 2026.
///
/// **REGOLA D: COSA DIFENDEVA QUESTA GUARDIA, E COSA DIFENDE ADESSO.**
///
/// **Prima.** La card disegnava una figura costruita sui **tempi veri** di ogni
/// inspiro e di ogni espiro, misurati mentre il dito stava sullo schermo, e su
/// quella figura scriveva *"dodici respiri: nessuno uguale al precedente"*.
/// Questa guardia provava che due serie di millisecondi diverse davano figure
/// diverse, e che la stessa serie dava la stessa figura. **Erano pretese giuste
/// e sono restate verdi fino all'ultimo giorno.**
///
/// **Il fondatore ha tolto il dito**, ordine DD voce 17: *"elimina la
/// possibilita' di tenere il dito premuto, solo pulsante play e stop"*. Senza
/// il dito quei millisecondi non esistono piu' e il fiore va col ritmo
/// dell'app, **uguale per tutti**: tenere quella frase sarebbe stata la prima
/// bugia di questa funzione, e tenere queste prove avrebbe sorvegliato un
/// meccanismo che nessuna schermata monta.
///
/// **Adesso.** La card porta **il sigillo della sessione**, che nasce da
/// quattro dati veri: il sintomo scelto, la frequenza, il centro del giorno e
/// la **durata vera**. Questa guardia prova che quel sigillo cambia quando
/// cambia la sessione, che e' **deterministico** a parita' di sessione, e che
/// le righe della card dicono cosa hai fatto senza promettere niente.
///
/// **La promessa della card e' scesa di un gradino, e va detto.** Non e' piu'
/// *"nessuna figura come la tua al mondo"*: e' *"questa e' la tua sessione"*.
/// La prima non regge senza il dito, la seconda si'.
void main() {
  const giorno = 9;
  final settembre = DateTime(2026, 9, giorno);

  List<double> sigillo({
    Sintomo? sintomo = Sintomo.insonnia,
    int hertz = 396,
    int centro = 0,
    Duration durata = const Duration(minutes: 5),
  }) =>
      SigilloDellaSessione.figura(
          sintomo: sintomo, hertz: hertz, centro: centro, durata: durata);

  test('IL SIGILLO CAMBIA CON OGNUNO DEI QUATTRO DATI', () {
    final base = sigillo();
    final cambi = <String, List<double>>{
      'un altro sintomo': sigillo(sintomo: Sintomo.ansia),
      'un altra frequenza': sigillo(hertz: 639),
      'un altro centro': sigillo(centro: 3),
      'un minuto in piu': sigillo(durata: const Duration(minutes: 6)),
    };
    cardinaleMinimo(cambi.length, 4,
        cosa: 'dati della sessione che devono cambiare il sigillo',
        perche: 'Con meno di quattro questa prova direbbe che il sigillo '
            'segue la sessione per averne guardato un pezzo.');

    final uguali = <String>[];
    for (final e in cambi.entries) {
      final d = PittoreDellaFigura.distanzaFra(base, e.value);
      // ignore: avoid_print
      print('ORDINE DD VOCE 17: con ${e.key} il sigillo dista '
          '${d.toStringAsFixed(4)}');
      if (d == 0.0) uguali.add(e.key);
    }
    expect(uguali, isEmpty,
        reason: 'questi dati non cambiano il sigillo, quindi due sessioni '
            'diverse portano lo stesso segno: ${uguali.join(" | ")}');
  });

  test('REGOLA H: LA STESSA SESSIONE DA LO STESSO SIGILLO', () {
    // **E' voluto, e va provato.** Chi rifa la stessa pratica per lo stesso
    // tempo ritrova il suo segno: un sigillo che cambia a ogni ridisegno non
    // e' un sigillo, e' rumore.
    expect(PittoreDellaFigura.distanzaFra(sigillo(), sigillo()), 0.0,
        reason: 'la stessa sessione da due sigilli diversi: il segno e '
            'casuale e non appartiene a niente');
  });

  test('I RAGGI VENGONO DALLA DURATA VERA, e stanno fra sei e ventiquattro',
      () {
    final misure = <Duration, int>{
      const Duration(seconds: 20): SigilloDellaSessione.quantiRaggi(
          const Duration(seconds: 20)),
      const Duration(minutes: 2): SigilloDellaSessione.quantiRaggi(
          const Duration(minutes: 2)),
      const Duration(minutes: 5): SigilloDellaSessione.quantiRaggi(
          const Duration(minutes: 5)),
      const Duration(minutes: 30): SigilloDellaSessione.quantiRaggi(
          const Duration(minutes: 30)),
    };
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: raggi per durata '
        '${misure.map((k, v) => MapEntry(k.inSeconds, v))}');
    for (final e in misure.entries) {
      expect(e.value, greaterThanOrEqualTo(6),
          reason: 'a ${e.key.inSeconds} secondi il sigillo ha ${e.value} '
              'raggi: sotto sei non si legge come una figura');
      expect(e.value, lessThanOrEqualTo(24),
          reason: 'a ${e.key.inSeconds} secondi il sigillo ha ${e.value} '
              'raggi: oltre ventiquattro si toccano e diventa un cerchio');
    }
    // **E in mezzo il numero SEGUE il tempo**, o la durata non conterebbe.
    expect(
        SigilloDellaSessione.quantiRaggi(const Duration(minutes: 2)) <
            SigilloDellaSessione.quantiRaggi(const Duration(minutes: 3)),
        isTrue,
        reason: 'due sessioni di durata diversa hanno lo stesso numero di '
            'raggi: la durata non entra nel segno');
  });

  test('IL TITOLO PORTA IL NUMERO VERO, e sotto il minuto non lo porta', () {
    final casi = <Duration, String>{
      const Duration(seconds: 40): CardDelRespiro.titoloPer(
          const Duration(seconds: 40)),
      const Duration(minutes: 1): CardDelRespiro.titoloPer(
          const Duration(minutes: 1)),
      const Duration(minutes: 5): CardDelRespiro.titoloPer(
          const Duration(minutes: 5)),
      const Duration(minutes: 12): CardDelRespiro.titoloPer(
          const Duration(minutes: 12)),
    };
    for (final e in casi.entries) {
      // ignore: avoid_print
      print('ORDINE DD VOCE 17: a ${e.key.inSeconds} secondi il titolo dice '
          '"${e.value}"');
    }
    expect(casi[const Duration(seconds: 40)], isNot(contains('0')),
        reason: 'sotto il minuto il titolo scrive una cifra che suona misera');
    expect(casi[const Duration(minutes: 5)], contains('5'),
        reason: 'il titolo non porta i minuti veri');
    expect(casi[const Duration(minutes: 12)], contains('12'),
        reason: 'il titolo non porta i minuti veri');
    // **E si capisce senza sapere cos'e' questa app**, che e' la ragione per
    // cui il titolo e' cambiato: chi riceve la card in una chat parte da zero.
    for (final t in casi.values) {
      expect(t.toLowerCase().contains('respiro di oggi'), isFalse,
          reason: 'il titolo e tornato quello di prima, che parlava solo a '
              'chi era gia dentro: "$t"');
    }
  });

  test('LE RIGHE PORTANO SINTOMO E FREQUENZA, e sono al massimo tre', () {
    // **Ordine DD voce 17**: *"includendo il sintomo e la frequenza, ma non
    // esagerare con il testo descrittivo"*.
    final scelta = CardDelRespiro.righeDellaCard(
      sintomo: Sintomo.insonnia,
      pratica: 'Due toni che si incontrano',
      hertz: 210,
      giorno: settembre,
      giorniDiFila: 4,
    );
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: le righe sono\n- ${scelta.join("\n- ")}');
    expect(scelta.length, lessThanOrEqualTo(3),
        reason: 'le righe della card sono ${scelta.length}: una card si '
            'guarda due secondi, e in due secondi non si leggono quattro '
            'righe');
    expect(scelta.join(' ').toLowerCase(), contains('insonnia'),
        reason: 'la card non nomina il sintomo scelto');
    expect(scelta.join(' '), contains('210 Hz'),
        reason: 'la card non nomina la frequenza che ha suonato');
    expect(scelta.join(' '), contains('4 giorni di fila'),
        reason: 'la card non porta la striscia, che e la riga che fa tornare');
  });

  test('SENZA SINTOMO SCELTO LA CARD NON NE INVENTA UNO', () {
    // **Non si mette in bocca alla persona un sintomo che non ha scelto.**
    // Quando la pratica la propone Aura dal centro del giorno, la card dice
    // il centro.
    final aura = CardDelRespiro.righeDellaCard(
      sintomo: null,
      pratica: null,
      hertz: 639,
      giorno: settembre,
    );
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: senza sintomo la card dice "${aura.first}"');
    expect(aura.first.toLowerCase().startsWith('per '), isFalse,
        reason: 'la card apre con "Per ..." anche quando nessun sintomo e '
            'stato scelto: e un sintomo messo in bocca a chi non lo ha detto');
    expect(aura.join(' '), contains('639 Hz'),
        reason: 'senza sintomo la card perde anche la frequenza');
  });

  test('UNA STRISCIA DI UNO NON SI SCRIVE', () {
    // **Una striscia di uno non e una striscia**, e scriverla la sgonfia: chi
    // legge "1 giorno di fila" capisce che non ha ancora niente.
    final uno = CardDelRespiro.righeDellaCard(
      sintomo: Sintomo.ansia,
      pratica: 'Sei respiri al minuto',
      hertz: 432,
      giorno: settembre,
      giorniDiFila: 1,
    );
    final due = CardDelRespiro.righeDellaCard(
      sintomo: Sintomo.ansia,
      pratica: 'Sei respiri al minuto',
      hertz: 432,
      giorno: settembre,
      giorniDiFila: 2,
    );
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: con 1 giorno le righe sono ${uno.length}, con 2 '
        'sono ${due.length}');
    expect(uno.join(' ').contains('di fila'), isFalse,
        reason: 'la card scrive una striscia di un giorno solo');
    expect(due.join(' '), contains('2 giorni di fila'),
        reason: 'la card non scrive una striscia vera di due giorni');
  });

  test('NESSUNA RIGA DELLA CARD PROMETTE UN EFFETTO', () {
    // **Ordine DB voce 11 applicato al testo della card**, e su una card che
    // gira fra estranei vale doppio.
    //
    // **La parola "sintomo" non e' piu' fra le vietate**, ordine DD voce 12:
    // il confine sta nel verbo, non nel sostantivo. Qui restano i verbi.
    final testi = <String>[
      CardDelRespiro.titoloPer(const Duration(minutes: 5)),
      ...CardDelRespiro.righeDellaCard(
        sintomo: Sintomo.insonnia,
        pratica: 'Due toni che si incontrano',
        hertz: 210,
        giorno: settembre,
        giorniDiFila: 3,
      ),
      ...CardDelRespiro.righeDellaCard(
        sintomo: null,
        pratica: null,
        hertz: 639,
        giorno: settembre,
      ),
    ];
    cardinaleMinimo(testi.length, 5,
        cosa: 'testi della card guardati',
        perche: 'Con pochi testi questa prova direbbe che la card non '
            'promette niente per non aver quasi letto.');
    final sconfinamenti = <String>[];
    for (final riga in testi) {
      for (final vietata in const [
        'guarisc', 'cura ', 'curare', 'terapia', 'dolore', 'pressione', 'dna',
        'malattia', 'allevia', 'elimina', 'risolve', 'ti fara',
      ]) {
        if (riga.toLowerCase().contains(vietata)) {
          sconfinamenti.add('"$vietata" in "$riga"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DB VOCE 11: testi della card ${testi.length}, '
        'sconfinamenti ${sconfinamenti.length}');
    expect(sconfinamenti, isEmpty,
        reason: 'la card promette un effetto: ${sconfinamenti.join(" | ")}');
  });

  test('IL COLORE VIENE DAL CENTRO DI OGGI, e cambia', () {
    // Senza sintomo scelto la prima riga nomina il centro, e il centro gira di
    // giorno in giorno: e' il legame col giorno, ed e' un motivo per tornare
    // che non costa niente.
    final lunedi = CardDelRespiro.righeDellaCard(
        sintomo: null, pratica: null, hertz: 432, giorno: DateTime(2026, 9, 7));
    final martedi = CardDelRespiro.righeDellaCard(
        sintomo: null, pratica: null, hertz: 432, giorno: DateTime(2026, 9, 8));
    // ignore: avoid_print
    print('ORDINE DB VOCE 10: lunedi "${lunedi.first}", martedi '
        '"${martedi.first}"');
    expect(lunedi.first, isNot(martedi.first),
        reason: 'la card dice lo stesso centro in due giorni diversi: il '
            'legame col centro di oggi non c e');
  });

  test('LA CARD PASSA DAL PUNTO UNICO DELLA CONDIVISIONE', () {
    // Ordine DB voce 10: *"passa dal punto unico della condivisione. Non se
    // ne scrive un altro."* E' la regola che l ordine P voce 28 ha imposto
    // dopo che i gesti di condivisione erano sparsi in sei posti.
    final sorgente = File(
            'lib/features/maestri/aura/meditation/card_del_respiro.dart')
        .readAsStringSync();
    final codice = senzaCommenti(sorgente);
    expect(codice.contains('PortaDellaCondivisione.daFile'), isTrue,
        reason: 'la card non passa dalla porta unica: e un secondo punto di '
            'condivisione, e fra sei mesi i due si comporteranno diversamente');
    // **E non apre nessuna strada sua verso la rete.**
    for (final vietata in const ['http', 'Uri.parse', 'Storage']) {
      expect(codice.contains(vietata), isFalse,
          reason: 'la card del respiro conosce "$vietata": deve passare dalla '
              'porta e non parlare da sola');
    }
  });
}

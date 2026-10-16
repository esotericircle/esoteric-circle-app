// IL SIGILLO DEL SOGNO SI DIRADA SOLO CON L'ARIA. Richiesta del fondatore
// del 12 ottobre 2026: "il microfono del sigillo della notte e' troppo
// sensibile e 'diradare la nebbia' si sblocca con solo la musica di
// sottofondo o un leggero rumore di fondo", e "usa lo stesso parametro per il
// sigillo del sogno".
//
// Due cose, e tutte e due servono: che la misura separi l'aria dai suoni di
// una stanza, e che la schermata del Sigillo la usi davvero. La seconda
// manca a ogni prova che guarda solo la prima.

import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/core/rituals/forma_del_soffio.dart';
import 'package:esoteric_circle/core/sensi/l_aria_che_dirada.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

void main() {
  const frequenza = 16000;

  List<int> componi(double Function(double t) onda, double durata) {
    final quanti = (frequenza * durata).round();
    return [
      for (var i = 0; i < quanti; i++)
        (onda(i / frequenza) * 32767).round().clamp(-32768, 32767),
    ];
  }

  // Il fiato sul microfono: rumore rosa forte, un secondo e mezzo.
  List<int> fiato() {
    final rnd = math.Random(3);
    var b0 = 0.0, b1 = 0.0, b2 = 0.0;
    return componi((t) {
      final bianco = rnd.nextDouble() * 2 - 1;
      b0 = 0.99765 * b0 + bianco * 0.0990460;
      b1 = 0.96300 * b1 + bianco * 0.2965164;
      b2 = 0.57000 * b2 + bianco * 1.0526913;
      return 0.9 * (b0 + b1 + b2 + bianco * 0.1848) / 3.5;
    }, 1.5);
  }

  // La musica di sottofondo: un accordo che cambia, due secondi, piano.
  List<int> musica() => componi((t) {
        final f = t < 1 ? 440.0 : 392.0;
        return 0.3 *
            (math.sin(2 * math.pi * f * t) +
                math.sin(2 * math.pi * f * 1.26 * t) +
                math.sin(2 * math.pi * f * 1.5 * t)) /
            3;
      }, 2);

  // Una canzone che parte dopo mezzo secondo di quiete: il salto di volume
  // supera il fondo, e a fermarla resta soltanto la forma.
  List<int> musicaCheParte() {
    final rnd = math.Random(31);
    return [
      ...componi((t) => (rnd.nextDouble() * 2 - 1) * 0.005, 0.5),
      ...musica(),
    ];
  }

  // Una voce alla radio, due secondi.
  List<int> voce() {
    final rnd = math.Random(11);
    return componi((t) {
      var v = 0.0;
      for (var k = 1; k <= 10; k++) {
        v += math.sin(2 * math.pi * 130 * k * t) / k;
      }
      return 0.3 * v / 2.9 + (rnd.nextDouble() - 0.5) * 0.01;
    }, 2);
  }

  // Un leggero rumore di fondo: un ventilatore, rumore largo e continuo,
  // abbastanza forte da aprire la regola di prima (il volume sopra un
  // decimo) e largo come l'aria, cosi' la forma da sola non lo ferma.
  List<int> rumoreDiFondo() {
    final rnd = math.Random(23);
    return componi((t) => (rnd.nextDouble() * 2 - 1) * 0.15, 3);
  }

  // La stanza col ventilatore e poi il fiato sopra: il fiato deve passare
  // anche con quel fondo.
  List<int> fiatoSulFondo() => [
        for (final c in rumoreDiFondo().take(16000)) (c * 0.25).round(),
        ...fiato(),
      ];

  // Il fiato dopo mezzo secondo di stanza quieta, come quando la nebbia
  // compare e chi la guarda prende fiato.
  List<int> fiatoDopoLaQuiete() {
    final rnd = math.Random(29);
    return [
      ...componi((t) => (rnd.nextDouble() * 2 - 1) * 0.005, 0.5),
      ...fiato(),
    ];
  }

  /// Quante finestre il livello vale uno, cioe' quanti passi la nebbia si
  /// dirada, dando i campioni a pezzi come arrivano dal microfono.
  int passiDiAria(List<int> campioni) {
    final aria = LAriaCheDirada();
    var passi = 0;
    for (var i = 0;
        i + FormaDelSoffio.campioniPerFinestra <= campioni.length;
        i += FormaDelSoffio.campioniPerFinestra) {
      final pezzo = campioni.sublist(i, i + FormaDelSoffio.campioniPerFinestra);
      if (aria.livelloDegliInteri(pezzo) > 0) passi++;
    }
    return passi;
  }

  /// La regola di prima, per il confronto: il volume del pezzo, la radice
  /// quadratica media per due virgola due, sopra un decimo.
  int passiColVolume(List<int> campioni) {
    var passi = 0;
    for (var i = 0;
        i + FormaDelSoffio.campioniPerFinestra <= campioni.length;
        i += FormaDelSoffio.campioniPerFinestra) {
      var somma = 0.0;
      for (var k = i; k < i + FormaDelSoffio.campioniPerFinestra; k++) {
        final x = campioni[k] / 32768.0;
        somma += x * x;
      }
      final livello =
          (math.sqrt(somma / FormaDelSoffio.campioniPerFinestra) * 2.2)
              .clamp(0.0, 1.0);
      if (livello > 0.10) passi++;
    }
    return passi;
  }

  test(
      'la musica, la voce e un rumore di fondo leggero non diradano; il '
      'fiato si', () {
    final suoni = <String, (List<int>, bool)>{
      'musica di sottofondo': (musica(), false),
      'voce alla radio': (voce(), false),
      'musica che parte dopo la quiete': (musicaCheParte(), false),
      'rumore di fondo leggero': (rumoreDiFondo(), false),
      'fiato sul microfono, dopo la stanza quieta': (fiatoDopoLaQuiete(), true),
      'fiato sul microfono, sopra il ventilatore': (fiatoSulFondo(), true),
    };
    cardinaleMinimo(suoni.length, 6,
        cosa: 'suoni di una stanza provati',
        perche: 'le tre cose che il fondatore ha nominato, e il fiato');
    final sbagliati = <String>[];
    for (final e in suoni.entries) {
      final (campioni, diradano) = e.value;
      final passi = passiDiAria(campioni);
      // ignore: avoid_print
      print('RICHIESTA DEL 12 OTTOBRE: "${e.key}" dirada per $passi '
          'finestre; col volume di prima ${passiColVolume(campioni)}');
      if ((passi > 0) != diradano) sbagliati.add('${e.key}: $passi finestre');
    }
    expect(sbagliati, isEmpty, reason: sbagliati.join(' | '));
  });

  test('il Sigillo del Sogno ascolta solo l\'aria', () {
    final codice =
        File('lib/features/rituals/dream_rite_screen.dart').readAsStringSync();
    expect(codice, contains('BreathDetector(soloAria: true)'),
        reason: 'il Sigillo del Sogno ascolta il volume e non l\'aria: la '
            'musica di sottofondo dirada la nebbia');
  });
}

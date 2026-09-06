import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL RITO DELL'ALBA E' INDIVIDUALE.** Ordine CS, voce S4 della scansione,
/// 6 settembre 2026.
///
/// **IL CONTO CHE HA FATTO NASCERE QUESTA GUARDIA.** Il seme dell'Alba era
/// costruito su data, Maestro di turno e **solo segno solare**. Il Maestro di
/// turno e' lo stesso per tutti quel giorno, quindi in un dato giorno esistevano
/// al massimo **dodici Riti dell'Alba diversi in tutto il mondo**, e due persone
/// dello stesso segno leggevano la stessa identica cosa.
///
/// **PERCHE' NESSUNA GUARDIA LO AVEVA PRESO.** Le guardie dell'Alba provavano
/// che il rito fosse deterministico, cioe' che lo stesso ingresso desse la
/// stessa uscita. E' vero e resta vero, ma non dice niente su **quante uscite
/// diverse esistano**: un rito che desse la stessa cosa a tutti sarebbe
/// deterministico quanto uno individuale.
///
/// **L'Arcano del Giorno aveva gia' curato lo stesso difetto** con l'ordine CQ
/// voce 2.05. L'Alba era rimasta indietro perche' la correzione era stata fatta
/// su un'arte sola: **una cura che non si estende alle sorelle non e' una cura,
/// e' una toppa.**
void main() {
  final giorno = DateTime(2026, 9, 6);

  RitoDiOggi? rito({required DateTime nascita, Zodiac? segno}) =>
      RitoAlba.diOggi(giorno,
          soleNatale: segno ?? Zodiac.aries, nascita: nascita);

  test('due persone dello stesso segno, nate in giorni diversi, ricevono '
      'Albe diverse', () {
    // **IL FATTO CHE LA VOCE S4 MISURA.** Prima questa prova sarebbe stata
    // impossibile da far cadere: senza la nascita nel seme, le due Albe erano
    // identiche per costruzione.
    final a = rito(nascita: DateTime(1980, 4, 3, 9, 15));
    final b = rito(nascita: DateTime(1994, 4, 11, 22, 40));
    expect(a, isNotNull);
    expect(b, isNotNull);
    final diverse = a!.gesto != b!.gesto ||
        a.respiro != b.respiro ||
        a.parola != b.parola ||
        a.forma != b.forma;
    expect(diverse, isTrue,
        reason: 'due Arieti nati a quattordici anni di distanza ricevono il '
            'rito identico: la personalizzazione vale solo per il segno, e in '
            'un giorno esistono dodici Albe in tutto il mondo');
  });

  test('quante Albe diverse esistono in un giorno', () {
    // **SI CONTA, non si stima.** Con il solo segno il massimo era dodici.
    // Con la nascita intera si generano cento persone dello stesso segno, nate
    // in cento momenti diversi, e si contano le combinazioni distinte.
    final viste = <String>{};
    for (var i = 0; i < 100; i++) {
      final n = DateTime(1970 + i % 40, 4, 1 + i % 20, i % 24, (i * 7) % 60);
      final r = rito(nascita: n);
      if (r != null) viste.add('${r.forma}|${r.gesto}|${r.respiro}|${r.parola}');
    }
    expect(viste.length, greaterThan(12),
        reason: 'su cento nascite diverse escono solo ${viste.length} riti '
            'distinti: col solo segno il massimo era dodici, e questa cura '
            'non ha cambiato niente');
  });

  test('la stessa persona ritrova il suo rito, lo stesso giorno', () {
    // La personalizzazione non deve diventare casualita': il rito e'
    // deterministico, e chi riapre l'app ritrova cio' che aveva letto.
    final n = DateTime(1986, 7, 21, 6, 30);
    final a = rito(nascita: n);
    final b = rito(nascita: n);
    expect(a!.gesto, b!.gesto);
    expect(a.respiro, b.respiro);
    expect(a.parola, b.parola);
    expect(a.forma, b.forma);
  });

  test('senza data di nascita il rito esiste lo stesso', () {
    // **IL RIPIEGO E\' UNA COSA VERA, non un vuoto.** Chi non ha dato la
    // nascita riceve il rito del giorno, che e' completo: non si mostra un
    // buco e non si inventa una nascita.
    final r = RitoAlba.diOggi(giorno, soleNatale: Zodiac.aries);
    expect(r, isNotNull,
        reason: 'senza data di nascita il rito dell\'Alba non nasce piu\'');
  });


}

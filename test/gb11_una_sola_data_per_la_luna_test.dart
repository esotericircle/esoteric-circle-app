// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/prossimi_eventi.dart';
import 'package:esoteric_circle/core/lunario/il_motore_lunare.dart';
import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

/// **UNA SOLA DATA PER LA LUNA. Ordine GB voce 11, 22 ottobre 2026.** Il
/// rapporto dell'ordine GA, punto 4: il Calendario degli eventi mostrava il
/// giorno in cui la finestra d'illuminazione si apre (24 ottobre, 7
/// novembre), il Respiro della Luna e la Collana il picco esatto della
/// stessa Luna piena o nuova (26 ottobre, 9 novembre,
/// `IlMotoreLunare.lunePieneFra`/`luneNuoveFra`): due letture dello stesso
/// evento. Qui si prova che `ProssimiEventi` (il Calendario) legge adesso
/// la STESSA fonte del Respiro, per ogni Luna piena o nuova entro
/// l'orizzonte, non solo per il caso del rapporto.
void main() {
  test(
      'ogni Luna piena che il Calendario trova e\' il giorno del picco '
      'esatto dato da IlMotoreLunare', () {
    final sbagliati = <String>[];
    var controllati = 0;
    for (var giorno = 0; giorno < 120; giorno += 11) {
      final adesso = DateTime(2026, 1, 1 + giorno);
      final piena = ProssimiEventi.da(adesso: adesso, orizzonte: 45)
          .where((e) => e.evento == EventiDelCielo.lunaPiena)
          .firstOrNull;
      if (piena == null) continue;
      controllati++;
      final picchi = IlMotoreLunare.lunePieneFra(
          piena.quando.subtract(const Duration(days: 1)),
          piena.quando.add(const Duration(days: 1)));
      final giornoDelPicco = picchi.isEmpty
          ? null
          : DateTime(picchi.first.year, picchi.first.month, picchi.first.day);
      if (giornoDelPicco != piena.quando) {
        sbagliati.add('dal ${adesso.day}/${adesso.month}: il Calendario '
            'dice ${piena.quando}, il picco vero e\' $giornoDelPicco');
      }
    }
    print('ORDINE GB VOCE 11: Lune piene confrontate $controllati, '
        'diverse ${sbagliati.length}');
    expect(controllati, greaterThan(5),
        reason: 'la prova gira quasi a vuoto');
    expect(sbagliati, isEmpty, reason: sbagliati.join('\n'));
  });

  test(
      'ogni Luna nuova che il Calendario trova e\' il giorno del picco '
      'esatto dato da IlMotoreLunare', () {
    final sbagliati = <String>[];
    var controllati = 0;
    for (var giorno = 0; giorno < 120; giorno += 11) {
      final adesso = DateTime(2026, 1, 1 + giorno);
      final nuova = ProssimiEventi.da(adesso: adesso, orizzonte: 45)
          .where((e) => e.evento == EventiDelCielo.lunaNuova)
          .firstOrNull;
      if (nuova == null) continue;
      controllati++;
      final picchi = IlMotoreLunare.luneNuoveFra(
          nuova.quando.subtract(const Duration(days: 1)),
          nuova.quando.add(const Duration(days: 1)));
      final giornoDelPicco = picchi.isEmpty
          ? null
          : DateTime(picchi.first.year, picchi.first.month, picchi.first.day);
      if (giornoDelPicco != nuova.quando) {
        sbagliati.add('dal ${adesso.day}/${adesso.month}: il Calendario '
            'dice ${nuova.quando}, il picco vero e\' $giornoDelPicco');
      }
    }
    print('ORDINE GB VOCE 11: Lune nuove confrontate $controllati, '
        'diverse ${sbagliati.length}');
    expect(controllati, greaterThan(5),
        reason: 'la prova gira quasi a vuoto');
    expect(sbagliati, isEmpty, reason: sbagliati.join('\n'));
  });

  test('il caso del rapporto GA: la Luna piena e la Luna nuova di fine '
      'ottobre cadono al picco, non all\'apertura della finestra', () {
    // Il rapporto dell'ordine GA, punto 4: "Il Calendario degli eventi
    // mostra 24 ottobre e 7 novembre; il Respiro della Luna e la Collana
    // mostrano 26 ottobre e 9 novembre".
    final elenco =
        ProssimiEventi.da(adesso: DateTime(2026, 10, 20), orizzonte: 30);
    final piena =
        elenco.where((e) => e.evento == EventiDelCielo.lunaPiena).firstOrNull;
    final nuova =
        elenco.where((e) => e.evento == EventiDelCielo.lunaNuova).firstOrNull;
    expect(piena, isNotNull);
    expect(nuova, isNotNull);
    print('ORDINE GB VOCE 11: luna_piena ${piena!.quando}, '
        'luna_nuova ${nuova!.quando}');
    expect(piena.quando, DateTime(2026, 10, 26),
        reason: 'il Calendario deve dire il picco (26 ottobre), non '
            'l\'apertura della finestra (24 ottobre)');
    expect(nuova.quando, DateTime(2026, 11, 9),
        reason: 'il Calendario deve dire il picco (9 novembre), non '
            'l\'apertura della finestra (7 novembre)');
  });
}

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA SINASTRIA GUARDA IL CIELO INTERO. Ordine BO voce 02.
///
/// **Il fatto da abbattere, contato prima di cominciare.** Il responso
/// dipendeva dal solo segno solare, e cinquanta VIP distribuiti su dodici
/// segni davano allo stesso utente **93 coppie di responsi numericamente
/// identici**: 8 Cancro fanno 28 coppie da soli, e cosi' via. La misura che
/// chiude questa voce e' che quel numero scenda sotto cinque.
void main() {
  /// Una persona di prova con ora e luogo, cosi' anche l'Ascendente entra.
  final identita = BirthIdentity.fromParts(
    birthDate: DateTime(1988, 3, 14),
    birthHour: 7,
    birthMinute: 25,
    birthPlace: const BirthPlace(
      city: 'Roma',
      latitude: 41.9004,
      longitude: 12.4957,
      timeZoneId: 'Europe/Rome',
      utcOffsetMinutes: 60,
    ),
  );
  final cielo = CieloDiSinastria.perIdentita(identita, nome: 'Prova');

  /// L'impronta numerica di un responso: e' cio' che l'ordine chiama
  /// "responso numerico", cioe' i quattro numeri che la schermata mostra.
  String impronta(SynastryReport r) =>
      '${r.overall}|${r.love}|${r.mental}|${r.sparks}';

  test('le coppie di VIP con responso numerico identico sono meno di cinque',
      () {
    final responsi = [
      for (final v in VipCatalog.vips)
        impronta(SynastryReport.perCieli(tuo: cielo, vip: v)),
    ];
    var identiche = 0;
    final dove = <String>[];
    for (var i = 0; i < responsi.length; i++) {
      for (var j = i + 1; j < responsi.length; j++) {
        if (responsi[i] == responsi[j]) {
          identiche++;
          dove.add('${VipCatalog.vips[i].name} = ${VipCatalog.vips[j].name} '
              '(${responsi[i]})');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE BO VOCE 02: coppie con responso identico $identiche '
        'su ${responsi.length * (responsi.length - 1) ~/ 2} possibili');
    expect(identiche, lessThan(5),
        reason: 'erano 93 col solo segno solare e adesso sono $identiche: '
            'il cielo intero non sta distinguendo abbastanza.\n'
            '${dove.take(10).join("\n")}');
  });

  test('due VIP dello stesso segno danno responsi diversi', () {
    // Gli otto Cancro erano il cuore del difetto: fra loro facevano ventotto
    // coppie identiche da soli.
    final cancro = VipCatalog.vips
        .where((v) => v.sign.id == 'cancer')
        .toList();
    expect(cancro.length, greaterThanOrEqualTo(5));
    final impronte = {
      for (final v in cancro) impronta(SynastryReport.perCieli(tuo: cielo, vip: v))
    };
    expect(impronte.length, cancro.length,
        reason: 'i ${cancro.length} VIP del Cancro danno solo '
            '${impronte.length} responsi distinti');
  });

  test('il responso nomina un aspetto vero, calcolato e non generico', () {
    var conAspetti = 0;
    for (final v in VipCatalog.vips) {
      final r = SynastryReport.perCieli(tuo: cielo, vip: v);
      if (r.aspetti.isEmpty) continue;
      conAspetti++;
      final primo = r.aspetti.first;
      expect(r.reading, contains(primo.fatto),
          reason: '${v.name}: il responso non nomina il fatto piu\' stretto');
      // E l'aspetto nominato esiste davvero: il suo orbo sta dentro l'orbo
      // ammesso per quel tipo, che e' la definizione di "aspetto vero".
      expect(primo.orbo,
          lessThanOrEqualTo(AspettiDiSinastria.orbo[primo.tipo]!),
          reason: '${v.name}: aspetto oltre il suo orbo');
    }
    expect(conAspetti, greaterThan(40),
        reason: 'solo $conAspetti VIP su 50 hanno un aspetto col cielo di '
            'prova: con cosi\' pochi il responso resterebbe generico');
  });

  test('senza ora del VIP la lettura lo dichiara, e non finge l\'Ascendente',
      () {
    final v = VipCatalog.first;
    final suo = CieloDiSinastria.perVip(v);
    expect(suo.oraNota, isFalse,
        reason: 'il catalogo non dichiara nessuna ora certificata');
    expect(suo.haAscendente, isFalse,
        reason: 'un Ascendente senza ora e\' un numero esatto e falso');
    final r = SynastryReport.perCieli(tuo: cielo, vip: v);
    // **LA DICHIARAZIONE SI E' SPOSTATA, NON E' SPARITA. Ordine CA voce 04.**
    // Occupava tre righe su otto dentro la bolla, cioe' dentro il testo che
    // deve diventare virale: adesso vive nella NOTA, fuori dalla bolla e in
    // corpo minore. Cio' che questa prova difende, cioe' che l'app non finga
    // un Ascendente che nessuna fonte dichiara, non cambia.
    expect(r.nota, contains('ora esatta di nascita'),
        reason: 'la nota non dichiara che l\'ora del VIP non si conosce');
    expect(r.reading.contains('ora esatta di nascita'), isFalse,
        reason: 'la dichiarazione e\' tornata dentro la bolla');
    expect(r.oraDelVipNota, isFalse);
  });

  test('l\'Ascendente della persona c\'e\' solo con ora e luogo', () {
    expect(cielo.haAscendente, isTrue,
        reason: 'con ora e luogo l\'Ascendente si calcola');
    final senzaOra = CieloDiSinastria.perIdentita(BirthIdentity.fromParts(
      birthDate: DateTime(1988, 3, 14),
      birthPlace: const BirthPlace(
        city: 'Roma',
        latitude: 41.9004,
        longitude: 12.4957,
        timeZoneId: 'Europe/Rome',
        utcOffsetMinutes: 60,
      ),
    ));
    expect(senzaOra.haAscendente, isFalse);
    final senzaLuogo = CieloDiSinastria.perIdentita(BirthIdentity.fromParts(
        birthDate: DateTime(1988, 3, 14), birthHour: 7, birthMinute: 25));
    expect(senzaLuogo.haAscendente, isFalse);
  });

  test('lo stesso paio da\' sempre lo stesso esito', () {
    for (final v in VipCatalog.vips.take(10)) {
      final a = SynastryReport.perCieli(tuo: cielo, vip: v);
      final b = SynastryReport.perCieli(tuo: cielo, vip: v);
      expect(impronta(a), impronta(b), reason: v.name);
      expect(a.reading, b.reading, reason: v.name);
      expect(a.aspetti.length, b.aspetti.length, reason: v.name);
    }
  });

  test('i numeri restano dentro le scale che la schermata disegna', () {
    for (final v in VipCatalog.vips) {
      final r = SynastryReport.perCieli(tuo: cielo, vip: v);
      expect(r.overall, inInclusiveRange(0, 99), reason: v.name);
      expect(r.love, inInclusiveRange(0, 100), reason: v.name);
      expect(r.mental, inInclusiveRange(0, 100), reason: v.name);
      expect(r.sparks, inInclusiveRange(0, 100), reason: v.name);
      expect(r.band, isNotEmpty, reason: v.name);
    }
  });

  test('gli aspetti sono ordinati dal piu\' stretto al piu\' largo', () {
    final r = SynastryReport.perCieli(tuo: cielo, vip: VipCatalog.vips[7]);
    for (var i = 1; i < r.aspetti.length; i++) {
      expect(r.aspetti[i].orbo,
          greaterThanOrEqualTo(r.aspetti[i - 1].orbo));
    }
  });

  test('l\'Ascendente calcolato sta dove la tradizione lo mette', () {
    // Una verifica indipendente dal resto: all'alba il Sole e' vicino
    // all'Ascendente, ed e' il controllo che ogni manuale usa per capire se
    // una carta e' orientata bene. Si prende un giorno d'equinozio, dove il
    // Sole sorge alle sei circa, e si guarda che i due punti disti no poco.
    final alba = BirthIdentity.fromParts(
      birthDate: DateTime(2000, 3, 20),
      birthHour: 6,
      birthMinute: 10,
      birthPlace: const BirthPlace(
        city: 'Roma',
        latitude: 41.9004,
        longitude: 12.4957,
        timeZoneId: 'Europe/Rome',
        utcOffsetMinutes: 60,
      ),
    );
    final c = CieloDiSinastria.perIdentita(alba);
    final asc = c.longitudini[PuntoDelCielo.ascendente]!;
    final sole = c.longitudini[PuntoDelCielo.sole]!;
    final scarto = ChartAspect(
        aLongitude: asc, bLongitude: sole, type: AspectType.conjunction).orbe;
    expect(scarto, lessThan(15),
        reason: 'nato all\'alba, l\'Ascendente dista $scarto gradi dal Sole: '
            'la carta non e\' orientata come la tradizione la orienta');
  });
}

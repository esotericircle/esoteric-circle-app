import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'elenco offline dei luoghi di nascita.
///
/// Prima di questo elenco la schermata del luogo era muta: digitando "busto
/// Arsizio" non compariva niente, perche' in catalogo c'erano settanta citta' e
/// il proprio comune non c'era quasi mai. Senza luogo la carta natale veniva
/// chiesta per il punto zero zero, in mezzo al Golfo di Guinea, e Ascendente e
/// case erano di quel punto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => CityCatalog.ensureLoaded(bundle: rootBundle));

  group('Copertura', () {
    test('Ci sono tutti i comuni italiani e le citta\' del mondo', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      final tutti = CityCatalog.cities;
      // Le aree italiane sono sigle di provincia di due lettere maiuscole, le
      // estere sono nomi di nazione: si distinguono da li' senza altri campi.
      final italiane = tutti.where(
          (c) => c.country.length == 2 && c.country == c.country.toUpperCase());
      final estere = tutti.where((c) =>
          !(c.country.length == 2 && c.country == c.country.toUpperCase()));

      expect(italiane.length, greaterThanOrEqualTo(7900),
          reason: 'i comuni italiani sono 7896, piu\' le localita\' che comune '
              'non sono');
      expect(estere.length, greaterThanOrEqualTo(200));
    });

    test('Nessun campo vuoto e nessuna coordinata nulla', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      for (final c in CityCatalog.cities) {
        expect(c.name.trim(), isNotEmpty);
        expect(c.country.trim(), isNotEmpty);
        expect(c.timeZoneId.trim(), isNotEmpty);
        expect(c.timeZoneId.contains('/'), isTrue,
            reason: 'il fuso e\' un identificativo IANA: ${c.timeZoneId}');
        expect(c.latitude, inInclusiveRange(-90, 90));
        expect(c.longitude, inInclusiveRange(-180, 180));
        // Il punto zero zero e' il Golfo di Guinea: nessun luogo dell'elenco
        // puo' caderci, altrimenti il ripiego che si voleva togliere sarebbe
        // rientrato dalla finestra.
        expect(c.latitude == 0 && c.longitude == 0, isFalse,
            reason: '${c.name} cade sul punto zero zero');
      }
    });

    test('Gli offset dei fusi sono quelli veri, non stimati', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      int offsetDi(String nome) =>
          CityCatalog.search(nome).first.utcOffsetMinutes;
      // Roma e Tokyo li indovinerebbe anche una stima dalla longitudine. Lagos
      // no: sta sul meridiano di Greenwich e segue l'ora dell'Europa centrale,
      // quindi e' la prova che gli offset vengono dalla tabella dei fusi.
      expect(offsetDi('Roma'), 60);
      expect(offsetDi('Tokyo'), 540);
      expect(offsetDi('Lagos'), 60);
      expect(offsetDi('New York'), -300);
      // Le mezze ore esistono e non vanno arrotondate.
      expect(offsetDi('Kathmandu'), 345);
    });
  });

  group('Ricerca', () {
    test('Busto compare fra i primi cinque', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      final r = CityCatalog.search('busto').take(5).map((c) => c.name);
      expect(r, contains('Busto Arsizio'));
    });

    test('Senza accenti si trova lo stesso', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      final r = CityCatalog.search('citta di cast').map((c) => c.name);
      expect(r, contains('Città di Castello'));
    });

    test('Gli omonimi si distinguono dall\'area', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      final r = CityCatalog.search('roma', limit: 12).toList();
      expect(r.first.name, 'Roma',
          reason: 'la piu' ' grande viene prima delle simili');
      expect(r.first.country, 'RM');
      final altri = r.where((c) => c.name != 'Roma');
      expect(altri, isNotEmpty, reason: 'gli omonimi ci sono');
      for (final c in altri) {
        expect(c.country.trim(), isNotEmpty,
            reason: '${c.name} deve dire da quale provincia viene');
      }
    });

    test('Le citta\' estere si trovano anche col nome italiano', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      final it = CityCatalog.search('londra');
      expect(it.first.name, 'Londra');
      expect(it.first.country, 'Regno Unito');
      final en = CityCatalog.search('london');
      expect(en.map((c) => c.name), contains('Londra'));
    });

    test('Una lettera sola non cerca niente', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      expect(CityCatalog.search('r'), isEmpty);
      expect(CityCatalog.search(''), isEmpty);
    });
  });

  group('Chiavi di lista uniche per costruzione', () {
    test('Nessun prefisso di due lettere produce due chiavi identiche',
        () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      // Il crash vero: cercando "new" la lista montava due voci Newcastle e
      // Flutter cadeva con Duplicate keys found. La chiave e' ora nome piu'
      // area, e il dato e' deduplicato alla sorgente: qui si prova TUTTO lo
      // spazio dei prefissi di due lettere, come il dito potrebbe digitarli.
      const lettere = 'abcdefghijklmnopqrstuvwxyz';
      final doppi = <String>[];
      for (final a in lettere.split('')) {
        for (final b in lettere.split('')) {
          final chiavi = <String>{};
          for (final c in CityCatalog.search('$a$b', limit: 50)) {
            final k = 'citta_${c.name}_${c.country}';
            if (!chiavi.add(k)) doppi.add('"$a$b" -> $k');
          }
        }
      }
      expect(doppi, isEmpty, reason: 'chiavi duplicate: ${doppi.join(', ')}');
    });

    test('Il dato non contiene doppioni esatti nome piu\' area', () async {
      await CityCatalog.ensureLoaded(bundle: rootBundle);
      final visti = <String>{};
      final doppi = <String>[];
      for (final c in CityCatalog.cities) {
        final k = '${c.name.toLowerCase()}|${c.country}';
        if (!visti.add(k)) doppi.add(k);
      }
      expect(doppi, isEmpty, reason: 'doppioni nel dato: $doppi');
    });
  });

  group('Formato', () {
    test('Una riga malformata non porta giu\' tutto l\'elenco', () {
      const raw = 'v1\n'
          'Europe/Rome=60|Asia/Tokyo=540\n'
          'Roma;;RM;41.9004;12.4957;0\n'
          'riga rotta\n'
          'Tokyo;;Giappone;35.6895;139.6917;1\n'
          'Fuso inesistente;;XX;1.0;2.0;9\n';
      final out = CityCatalog.parse(raw);
      expect(out.length, 2);
      expect(out.first.name, 'Roma');
      expect(out.first.utcOffsetMinutes, 60);
      expect(out.last.timeZoneId, 'Asia/Tokyo');
    });
  });
}

import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **GLI SFONDI DELLE SCHEDE SONO NEL REPOSITORY E OGNI ARTE HA I SUOI TRE.**
/// Ordine EO voce 01, 26 settembre 2026. Il fondatore: *"Allora, iniziamo a
/// fare tutte le schede dell'ultimo elenco, 10 per ogni maestro."*
///
/// **Il cardinale e' dichiarato.** Era 99 all'ordine EO, 102 dall'ordine EP
/// voce 12 coi tre orizzontali di "Consulta". **Dall'ordine ER voce 10 e'
/// 216**, cioe' ogni file della cartella del fondatore: 66 arti e i tre sfondi
/// dei Maestri in tre formati (207), piu' i "Consulta" nei tre formati (9).
/// **Dall'ordine ER voce 20 e' 219**: i tre del Segreto dell'Iride.
/// **Dall'ordine ES voci 05 e 11 e' 246**: i tre emblemi dei periodi
/// dell'Oroscopo (Settimana, Mese, Anno) e i sei delle tradizioni, in tre
/// formati, 27 file, tutti usati: l'app ne usa 240.
/// Il fondatore: *"ogni webp della cartella del PC sostituisce quello di
/// assets/schede con lo stesso nome; quelli che mancano si aggiungono"*. Le
/// schede ne usano 210: i "Consulta" quadrati e verticali stanno nella
/// cartella senza che una scheda li chieda. Una guardia che scorresse la
/// cartella vuota sarebbe verde senza aver guardato niente.
void main() {
  const cardinale = 246;
  const usati = 240;

  test('i 246 WebP stanno in assets/schede/ e il pubspec li registra', () {
    final cartella = Directory(GliSfondiDelleSchede.cartella);
    final webp = cartella
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.webp'))
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    cardinaleMinimo(webp.length, cardinale,
        cosa: 'WebP in assets/schede',
        perche: 'la guardia degli sfondi scorre la cartella.');
    expect(webp.length, cardinale,
        reason: 'in assets/schede/ ci sono ${webp.length} WebP');
    final altri = cartella
        .listSync()
        .whereType<File>()
        .where((f) => !f.path.endsWith('.webp'));
    expect(altri, isEmpty,
        reason: 'PNG o JPG di lavorazione sono entrati nel repository');
    // LAPIDE, ordine ER voce 10: qui si pretendeva che di "Consulta"
    // entrassero solo i tre orizzontali. Era una scelta di Code, tratta dalla
    // correzione del fondatore sulla scheda (orizzontale e non quadrata);
    // l'ordine ER chiede che ogni file della sua cartella entri. La scheda
    // continua a chiedere solo l'orizzontale, e lo dice la prova qui sotto.
    expect(webp.where((f) => f.startsWith('Consulta-')), hasLength(9));
    for (final m in Maestro.values) {
      expect(GliSfondiDelleSchede.consultaDi(m), endsWith('-Oriz-1.webp'),
          reason: 'la scheda "Consulta" non e\' piu\' orizzontale');
    }
    final tutti = GliSfondiDelleSchede.tutti();
    expect(tutti.length, usati);
    for (final f in tutti) {
      expect(File(f).existsSync(), isTrue, reason: 'manca $f');
    }
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('    - assets/schede/'),
        reason: 'la cartella degli sfondi non e\' registrata');
  });

  // LAPIDE, ordine ER voce 10: qui si pretendevano dieci arti con lo sfondo
  // per Maestro, trenta in tutto (ordine EO). Adesso ogni arte del catalogo
  // ha il suo sfondo, tranne le due che vivono solo nel Passaporto.
  test('ogni arte del catalogo ha lo sfondo, tranne le due del Passaporto', () {
    final senza = <String>[];
    for (final m in Maestro.values) {
      for (final s in ArtCatalog.forMaestro(m)) {
        for (final a in s.arts) {
          if (a.soloNelPassaporto) continue;
          if (GliSfondiDelleSchede.perArte(
                  a.id, FormatoDellaScheda.verticale) ==
              null) {
            senza.add(a.id);
          }
        }
      }
    }
    final ids = {for (final a in ArtCatalog.all) a.id};
    final estranei =
        GliSfondiDelleSchede.nomi.keys.where((k) => !ids.contains(k)).toList();
    // ignore: avoid_print
    print('ORDINE ER VOCE 10: arti del catalogo senza sfondo ${senza.length}, '
        'sfondi di arti che il catalogo non ha ${estranei.length}');
    expect(senza, isEmpty, reason: 'arti senza sfondo: $senza');
    expect(estranei, isEmpty);
    expect(GliSfondiDelleSchede.nomi, hasLength(67));
  });

  test('i formati hanno le misure dell\'ordine', () {
    expect(FormatoDellaScheda.verticale.proporzione, 0.8);
    expect(FormatoDellaScheda.quadrata.proporzione, 1);
    expect(FormatoDellaScheda.orizzontale.proporzione, closeTo(16 / 9, 1e-9));
    expect(
        GliSfondiDelleSchede.perArte('rune_draw', FormatoDellaScheda.verticale),
        'assets/schede/Rune-Vert-1.webp');
    expect(
        GliSfondiDelleSchede.delMaestro(
            Maestro.caligo, FormatoDellaScheda.orizzontale),
        'assets/schede/Sfondo-Caligo-Oriz-1.webp');
  });
}

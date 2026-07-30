import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LO SCAFFALE NASCE CON NOVE ARTI, TRE PER MAESTRO.
///
/// **Il difetto veniva prima della regola.** Lo scaffale mostrava tre arti e
/// sembrava scarno, ed erano esattamente horoscope, meditation e rune_draw:
/// cioe' il seme del caso SENZA Maestro. `setMaestro` non era chiamato da
/// nessuno in tutto il progetto, quindi allo scaffale arrivava sempre un
/// Maestro nullo, mentre la home diceva "Entra nel Dominio di Aura". Il Maestro
/// esisteva, allo scaffale non ci arrivava.
///
/// Cambiare il seme senza correggere quello si sarebbe visto uguale, e sarebbe
/// sembrato che il lavoro non avesse funzionato.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Il tetto e\' un dato, e vale nove', () {
    // Il numero sta in un punto solo e il foglio della matita lo legge da li'.
    // Nove e' un cambio di una decisione precedente, non una svista: era sei, e
    // il fondatore l'ha cambiata il 30 luglio 2026.
    expect(ArtiPreferiteController.tetto, 9);
    expect(ArtiPreferiteController.perMaestro, 3);
  });

  test('Il seme ha tre arti per ciascun Maestro', () {
    for (final assegnato in [null, ...Maestro.values]) {
      final seme = ArtiPreferiteController.semePer(assegnato);

      // Il conto NON si deduce dalla lunghezza: nove voci potrebbero essere
      // sette di un Maestro e una a testa per gli altri due, e sarebbe un altro
      // scaffale. Si conta per Maestro.
      for (final m in Maestro.values) {
        final sue = ArtCatalog.activeOf(m).map((a) => a.id).toSet();
        final quante = seme.where(sue.contains).length;
        expect(quante, ArtiPreferiteController.perMaestro,
            reason: 'col Maestro assegnato ${assegnato?.name ?? "nessuno"} lo '
                'scaffale nasce con $quante arti di ${m.name} invece di tre: '
                'non e\' piu\' tre per Maestro');
      }
      expect(seme.length, ArtiPreferiteController.tetto,
          reason: 'il seme ha ${seme.length} arti invece di '
              '${ArtiPreferiteController.tetto}');
      expect(seme.toSet().length, seme.length,
          reason: 'nel seme la stessa arte compare due volte');
    }
  });

  test('Il proprio Maestro apre lo scaffale', () {
    final seme = ArtiPreferiteController.semePer(Maestro.aura);
    final sueDiAura = ArtCatalog.activeOf(Maestro.aura).map((a) => a.id).toSet();
    expect(seme.take(3).every(sueDiAura.contains), isTrue,
        reason: 'lo scaffale non si apre sulle arti del proprio Maestro: cio\' '
            'che e\' tuo deve venire prima del resto del Cerchio');
  });

  test('Col Maestro assegnato lo scaffale non resta sul seme senza Maestro',
      () {
    // La prova del difetto vero: il seme col Maestro e quello senza devono
    // essere diversi, altrimenti non si potrebbe nemmeno accorgersi che il
    // Maestro non arriva.
    final senza = ArtiPreferiteController.semePer(null);
    final conAura = ArtiPreferiteController.semePer(Maestro.aura);
    expect(conAura, isNot(senza),
        reason: 'il seme e\' identico col Maestro e senza: un Maestro che non '
            'arriva sarebbe invisibile');

    final scaffale = ArtiPreferiteController()..setMaestro(Maestro.aura);
    expect(scaffale.ids, conAura,
        reason: 'assegnato il Maestro, lo scaffale resta sul seme di prima');
  });

  test('Il Maestro arriva davvero allo scaffale', () {
    // `setMaestro` esisteva e non lo chiamava NESSUNO: e' il difetto. Adesso il
    // legame sta nel guscio dell'app, dove il Maestro e lo scaffale si
    // incontrano, e questa prova conta le porte invece di visitarne una.
    final porte = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p.endsWith('arti_preferite.dart')) continue;
      if (f.readAsStringSync().contains('setMaestro(')) porte.add(p);
    }
    expect(porte, isNotEmpty,
        reason: 'nessuno dice allo scaffale qual e\' il Maestro: il seme resta '
            'quello del caso senza Maestro, cioe' ' tre arti in croce');
  });

  test('Il foglio della matita legge il tetto da un punto solo', () {
    final foglio =
        File('lib/features/santuario/widgets/tue_arti_view.dart').readAsStringSync();
    expect(foglio, contains('ArtiPreferiteController.tetto'),
        reason: 'il foglio ripete il numero invece di leggerlo: due numeri che '
            'devono restare uguali sono due numeri che prima o poi divergono');
    expect(foglio, isNot(contains('fino a 6')),
        reason: 'il foglio dichiara ancora il vecchio tetto');
  });

  test('Un MaestroController appena nato non ha un Maestro attivo', () {
    // Serve a spiegare il difetto: se il Maestro nasce nullo, e nessuno lo
    // assegna, lo scaffale resta per sempre sul seme senza Maestro.
    expect(MaestroController().activeMaestro, isNull);
  });
}

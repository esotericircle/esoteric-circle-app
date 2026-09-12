import 'dart:io';

import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

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

  test("Il tetto e' un dato, e vale nove", () {
    // Il numero sta in un punto solo e il foglio della matita lo legge da li'.
    expect(ArtiPreferiteController.tetto, 9);
  });

  test("Il seme e' le sette di Mauro, per chiunque", () {
    // **LA GRANDEZZA E' CAMBIATA CON L'ORDINE AK VOCE 01, col perche'.**
    // Prima il seme era due arti per Maestro (e prima ancora tre), contato
    // per Maestro, e due prove pretendevano che il proprio Maestro aprisse
    // lo scaffale e che il seme cambiasse col Maestro assegnato: la voce di
    // Mauro del 17 agosto ha fissato le SETTE sue, uguali per tutti e
    // nell'ordine suo, e quelle pretese sono superate dalla decisione.
    // Sotto il tetto di nove restano due posti per la matita, che era la
    // ragione da salvare.
    for (final assegnato in [null, ...Maestro.values]) {
      final seme = ArtiPreferiteController.semePer(assegnato);
      expect(seme, ArtiPreferiteController.setteDiMauro,
          reason: "col Maestro ${assegnato?.name ?? 'nessuno'} il seme non "
              "e' l'elenco di Mauro");
      expect(seme.length, lessThan(ArtiPreferiteController.tetto),
          reason: 'il seme riempie tutto il tetto e la matita non ha niente '
              'da aggiungere');
      expect(seme.toSet().length, seme.length,
          reason: 'nel seme la stessa arte compare due volte');
    }
  });

  test('Il Maestro arriva davvero allo scaffale', () {
    // `setMaestro` esisteva e non lo chiamava NESSUNO: e' il difetto. Adesso il
    // legame sta nel guscio dell'app, dove il Maestro e lo scaffale si
    // incontrano, e questa prova conta le porte invece di visitarne una.
    final porte = <String>[];
    for (final f in sorgentiDiLib()) {
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p.endsWith('arti_preferite.dart')) continue;
      if (f.readAsStringSync().contains('setMaestro(')) porte.add(p);
    }
    expect(porte, isNotEmpty,
        reason: 'nessuno dice allo scaffale qual e\' il Maestro: il seme resta '
            'quello del caso senza Maestro, cioe'
            ' tre arti in croce');
  });

  test('Il foglio della matita legge il tetto da un punto solo', () {
    final foglio = File('lib/features/santuario/widgets/tue_arti_view.dart')
        .readAsStringSync();
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

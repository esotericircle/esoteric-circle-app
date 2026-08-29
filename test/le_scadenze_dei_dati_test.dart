import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/face/face_classifier.dart';
import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/face/face_history.dart';
import 'package:esoteric_circle/core/identity/scadenze_del_telefono.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE SCADENZE DEI DATI SUL TELEFONO. Ordine CB voce 05.
///
/// **Parole del fondatore:** "decide Code, non l'hai ancora capito? e
/// chiaramente deve motivarlo."
///
/// **Cosa difende questa prova**: che ogni tempo deciso porti la sua ragione
/// scritta, e che le due memorie che crescono si potino davvero. La prova del
/// rosso che l'ordine chiede e' proprio la seconda meta': si scrive una riga
/// vecchia di piu' del tempo deciso e si pretende che, riaprendo, non ci sia
/// piu'.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('la decisione', () {
    test('ogni scadenza del telefono ha un tempo e una ragione', () {
      expect(ScadenzeDelTelefono.tutte, isNotEmpty);
      for (final s in ScadenzeDelTelefono.tutte) {
        expect(s.giorni, greaterThan(0), reason: '${s.nome} non ha un tempo');
        expect(s.perche.length, greaterThan(60),
            reason: '${s.nome} scade senza dire perche\': "${s.perche}"');
      }
      // ignore: avoid_print
      print('ORDINE CB VOCE 05: scadenze del telefono '
          '${ScadenzeDelTelefono.tutte.map((s) => "${s.nome} ${s.giorni}g").join(", ")}');
    });

    test('il listino del server esiste e porta le sue ragioni', () {
      // Il server non e' Dart, quindi si legge il suo listino come testo: la
      // cosa difesa e' la stessa, cioe' che nessun tempo sia senza motivo.
      final server = File('functions/src/scadenze.ts').readAsStringSync();
      final quante = RegExp(r'giorni: \d+').allMatches(server).length;
      // Si contano le ragioni SCRITTE, cioe' quelle che vanno a capo su
      // una stringa: `perche: string;` e' la dichiarazione del campo
      // nell'interfaccia, e contarla direbbe sei ragioni su cinque voci.
      final ragioni =
          RegExp(r'perche:\s*\n').allMatches(server).length;
      // ignore: avoid_print
      print('ORDINE CB VOCE 05: categorie sul server $quante, ragioni '
          'scritte $ragioni');
      expect(quante, greaterThanOrEqualTo(5));
      expect(ragioni, quante,
          reason: 'sul server ci sono $quante scadenze e $ragioni ragioni: '
              'una scadenza senza motivazione non e\' accettata');
    });
  });

  group('le letture del viso si potano', () {
    Future<void> conUnaLetturaVecchiaDi(int giorni, DateTime adesso) async {
      final quando = adesso.subtract(Duration(days: giorni));
      SharedPreferences.setMockInitialValues({
        'viso.storico': <String>[
          jsonEncode(FaceEsito(
                  quando: quando,
                  reading: const FaceReading(letture: [
                    TraitLettura(
                        tratto: FaceTrait.voltoTondo, marcatezza: 0.8),
                  ]))
              .toJson()),
        ],
      });
    }

    testWidgets('una lettura dentro il tempo resta', (tester) async {
      final adesso = DateTime(2026, 8, 29);
      await conUnaLetturaVecchiaDi(
          ScadenzeDelTelefono.viso.giorni - 1, adesso);
      final storico = FaceHistory(clock: () => adesso);
      await storico.carica();
      // ignore: avoid_print
      print('ORDINE CB VOCE 05: viso, a '
          '${ScadenzeDelTelefono.viso.giorni - 1} giorni restano '
          '${storico.esiti.length} letture');
      expect(storico.esiti, hasLength(1));
    });

    testWidgets('una lettura oltre il tempo non c\'e\' piu\', nemmeno sul disco',
        (tester) async {
      final adesso = DateTime(2026, 8, 29);
      await conUnaLetturaVecchiaDi(
          ScadenzeDelTelefono.viso.giorni + 1, adesso);
      final prima = (await SharedPreferences.getInstance())
              .getStringList('viso.storico')
              ?.length ??
          0;
      final storico = FaceHistory(clock: () => adesso);
      await storico.carica();
      final dopo = (await SharedPreferences.getInstance())
              .getStringList('viso.storico')
              ?.length ??
          0;
      // ignore: avoid_print
      print('ORDINE CB VOCE 05: viso, a '
          '${ScadenzeDelTelefono.viso.giorni + 1} giorni: sul disco prima '
          '$prima, dopo $dopo, in memoria ${storico.esiti.length}');
      expect(storico.esiti, isEmpty,
          reason: 'una lettura del viso piu\' vecchia del tempo deciso e\' '
              'ancora in memoria');
      expect(dopo, 0,
          reason: 'la riga scaduta e\' sparita dalla scena ma e\' rimasta sul '
              'disco: la scadenza non vale davvero');
    });
  });

  group('lo storico dell\'Archetipo si pota', () {
    Future<void> conUnTestVecchioDi(int giorni, DateTime adesso) async {
      final quando = adesso.subtract(Duration(days: giorni));
      SharedPreferences.setMockInitialValues({
        'archetipo.storico': <String>[
          jsonEncode(ArchetypeEsito(
            quando: quando,
            percentuali: const {Archetype.saggio: 60, Archetype.eroe: 40},
            dominante: Archetype.saggio,
            secondo: Archetype.eroe,
          ).toJson()),
        ],
      });
    }

    testWidgets('un test dentro il tempo resta', (tester) async {
      final adesso = DateTime(2026, 8, 29);
      await conUnTestVecchioDi(
          ScadenzeDelTelefono.archetipo.giorni - 1, adesso);
      final storico = ArchetypeHistory(clock: () => adesso);
      await storico.carica();
      expect(storico.esiti, hasLength(1));
    });

    testWidgets('un test oltre il tempo non c\'e\' piu\'', (tester) async {
      final adesso = DateTime(2026, 8, 29);
      await conUnTestVecchioDi(
          ScadenzeDelTelefono.archetipo.giorni + 1, adesso);
      final storico = ArchetypeHistory(clock: () => adesso);
      await storico.carica();
      final dopo = (await SharedPreferences.getInstance())
              .getStringList('archetipo.storico')
              ?.length ??
          0;
      // ignore: avoid_print
      print('ORDINE CB VOCE 05: archetipo, a '
          '${ScadenzeDelTelefono.archetipo.giorni + 1} giorni: in memoria '
          '${storico.esiti.length}, sul disco $dopo');
      expect(storico.esiti, isEmpty);
      expect(dopo, 0);
    });
  });

  test('il lavoro notturno del server esiste ed e\' esportato', () {
    final indice = File('functions/src/index.ts').readAsStringSync();
    final pulizia = File('functions/src/pulizia.ts').readAsStringSync();
    expect(indice.contains('pulisciLeScadenze'), isTrue,
        reason: 'il lavoro notturno non e\' esportato, quindi per Firebase '
            'non esiste');
    expect(pulizia.contains('onSchedule'), isTrue);
    // **E NON E' TORNATA L'ATTESA CHE IL FONDATORE HA ABOLITO.** L'ordine BE
    // voce 07 ha tolto i trenta giorni prima della cancellazione: queste
    // scadenze parlano di dati che nessuno ha chiesto di cancellare.
    expect(indice.contains('export {chiediLOblio'), isFalse);
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'dart:ui' as ui;

/// I NOVE DIFETTI EREDITATI, ordine P voci da 22 a 30.
///
/// Sono voci vecchie del Registro dei Difetti, mai richiuse. **Quale sia gia'
/// caduta con gli ordini recenti non si scrive a memoria: si riverifica una per
/// una**, ed e' quello che fanno queste prove. Dove il difetto era gia' chiuso,
/// la prova resta come presidio contro il ritorno.
void main() {
  String sorgente(String percorso) => File(percorso).readAsStringSync();

  group('P.22 il velo sui corpi sotto l\'orizzonte', () {
    test('il corpo sotto il suolo si vela, e la velatura non lo cancella', () {
      final s = sorgente('lib/features/santuario/sky_overview_screen.dart');
      expect(s, contains('sottoIlSuolo'),
          reason: 'il corpo sotto l\'orizzonte non ha piu\' un segno visivo, e '
              'la scheda continuerebbe a dire una cosa che la scena smentisce');
      expect(s, contains('velaturaSottoLOrizzonte'));
      expect(s, contains('_LineaDellOrizzonte'),
          reason: 'senza la linea del suolo la velatura sembra un difetto di '
              'resa invece di un\'informazione');
      // La velatura passa da _SkyBody, quindi vale per TUTTI E DUE i cieli:
      // una sola porta, come chiede la voce.
      expect(s.split('sottoIlSuolo').length - 1, greaterThanOrEqualTo(4),
          reason: 'il flag non arriva a tutti i costruttori dei corpi');
    });

    test('la soglia dell\'orizzonte e\' una sola in tutta l\'app', () {
      // Il difetto gia' pagato una volta su questa schermata: due soglie
      // diverse, meno cinque qui e meno due nel motore, e chi stava in mezzo
      // spariva senza che nessun messaggio uscisse.
      final s = sorgente('lib/features/santuario/sky_overview_screen.dart');
      expect(s, contains('nomiVisibili'),
          reason: 'il conto di chi sta sopra l\'orizzonte e\' stato rifatto '
              'qui invece di chiederlo al motore');
    });
  });

  group('P.28 il gesto di condividere in un punto solo', () {
    test('nessun file dell\'app chiama la condivisione per conto suo', () {
      // SI ENUMERANO I CHIAMANTI invece di visitarne uno. Erano TREDICI punti
      // che facevano la stessa cosa, cioe' tredici occasioni di farla in modo
      // diverso.
      final colpevoli = <String>[];
      for (final voce in Directory('lib').listSync(recursive: true)) {
        if (voce is! File || !voce.path.endsWith('.dart')) continue;
        final percorso = voce.path.replaceAll('\\', '/');
        if (percorso.endsWith('core/condivisione/porta_della_condivisione.dart')) {
          continue;
        }
        final testo = voce.readAsStringSync();
        if (testo.contains('SharePlus.instance') ||
            testo.contains("package:share_plus/share_plus.dart")) {
          colpevoli.add(percorso);
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'questi file condividono per conto loro invece di passare '
              'dalla porta unica:\n${colpevoli.join("\n")}');
    });

    test('la porta esiste e tiene l\'errore invece di lasciarlo salire', () {
      final s = sorgente('lib/core/condivisione/porta_della_condivisione.dart');
      for (final modo in const ['testo(', 'daFile(', 'immagine(']) {
        expect(s, contains(modo), reason: 'la porta non offre $modo');
      }
      // Tre `catch` e tre `return false`: chi condivide sta finendo un rito.
      expect(RegExp(r'catch \(_\)').allMatches(s).length, 3);
    });
  });

  group('P.29 la rinomina di sunset_time in solar_time', () {
    test('il file dichiara il vero, e nessuno cerca piu\' il nome vecchio', () {
      expect(File('lib/core/astro/solar_time.dart').existsSync(), isTrue);
      // Il nome vecchio si compone invece di scriverlo: questa prova cerca il
      // nome vecchio in tutto il progetto, e scriverlo per intero qui la
      // farebbe cadere su se stessa.
      final nomeVecchio = 'sunset' '_time.dart';
      expect(File('lib/core/astro/$nomeVecchio').existsSync(), isFalse,
          reason: 'il file vecchio e\' tornato: il nome dichiarava il falso, '
              'perche\' dentro c\'e\' anche il sorgere');
      final rimasti = <String>[];
      for (final cartella in ['lib', 'test', 'tool']) {
        for (final voce in Directory(cartella).listSync(recursive: true)) {
          if (voce is! File || !voce.path.endsWith('.dart')) continue;
          if (voce.readAsStringSync().contains(nomeVecchio)) {
            rimasti.add(voce.path);
          }
        }
      }
      expect(rimasti, isEmpty,
          reason: 'questi file importano ancora il nome vecchio:\n'
              '${rimasti.join("\n")}');
    });

    test('il file contiene davvero anche il sorgere', () {
      // E' la ragione della rinomina: se un giorno il sorgere uscisse di qui,
      // il nome tornerebbe a dichiarare il falso al contrario.
      final s = sorgente('lib/core/astro/solar_time.dart');
      expect(s.toLowerCase(), contains('sorge'));
    });
  });

  group('P.30 Uruz scontornata', () {
    testWidgets('Uruz sta nella famiglia delle altre ventitre', (tester) async {
      // **LA MISURA, non la memoria.** L'ordine la dava al 94,3 per cento di
      // pixel opachi con un rettangolo nero attorno. Si conta, e si confronta
      // con le altre: un asset scontornato bene non e' quello che rispetta un
      // numero scelto, e' quello che sta dove stanno i suoi fratelli.
      //
      // Si decodifica col motore di Flutter e non con una libreria in piu': il
      // WebP e' esattamente cio' che l'app mostra, e aggiungere una dipendenza
      // per contarne i pixel sarebbe un secondo decodificatore.
      final pietre = Directory('assets/img/rune_bone')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.webp'))
          .toList();
      expect(pietre, hasLength(24));
      final quote = <String, double>{};
      await tester.runAsync(() async {
        for (final pietra in pietre) {
          final codec =
              await ui.instantiateImageCodec(pietra.readAsBytesSync());
          final fotogramma = await codec.getNextFrame();
          final immagine = fotogramma.image;
          final dati = await immagine.toByteData();
          var opachi = 0;
          for (var i = 3; i < dati!.lengthInBytes; i += 4) {
            if (dati.getUint8(i) > 250) opachi++;
          }
          quote[pietra.uri.pathSegments.last] =
              opachi / (immagine.width * immagine.height);
          immagine.dispose();
        }
      });
      final uruz =
          quote.entries.firstWhere((e) => e.key.contains('uruz')).value;
      final altre = quote.entries
          .where((e) => !e.key.contains('uruz'))
          .map((e) => e.value)
          .toList()
        ..sort();
      // Il tetto e' quello delle altre, non un numero deciso qui: se Uruz
      // tornasse col rettangolo nero sarebbe sopra tutte e ventitre.
      expect(uruz, lessThanOrEqualTo(altre.last),
          reason: 'Uruz ha ${(uruz * 100).toStringAsFixed(1)} per cento di '
              'pixel opachi, piu\' della piu\' piena delle altre '
              '(${(altre.last * 100).toStringAsFixed(1)}): il rettangolo nero '
              'attorno alla pietra e\' tornato');
    });
  });
}

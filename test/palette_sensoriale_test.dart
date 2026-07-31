import 'dart:io';

import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il livello sensoriale parte da un punto solo, e obbedisce a un comando solo.
///
/// **L'aptica viene prima del suono.** La maggior parte delle persone tiene il
/// telefono in silenzio, quindi un'app che affida la propria identita' al suono
/// e' muta per la maggioranza di chi la usa. La vibrazione arriva sempre.
///
/// Prima c'erano diciassette chiamate dirette a `HapticFeedback` sparse in sette
/// file, ognuna con la propria idea di quanto forte vibrare: la stessa azione
/// vibrava in modo diverso a seconda di dove la si faceva, e nessuna guardava
/// una preferenza dell'utente, che del resto non esisteva.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Le vibrazioni chieste alla piattaforma durante una prova.
  List<String> spiaAptica() {
    final chiamate = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        chiamate.add('${call.arguments}');
      }
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    return chiamate;
  }

  Widget conImpostazioni(SettingsController s, Widget child) => MaterialApp(
        home: ChangeNotifierProvider<SettingsController>.value(
            value: s, child: child),
      );

  group('I quattro schemi, e nessuno di piu\'', () {
    test('Sono esattamente quattro', () {
      expect(SchemaAptico.values.length, 4,
          reason: 'un vocabolario di gesti si impara solo se e\' piccolo: con '
              'piu\' di quattro schemi nessuno riconosce piu\' niente');
    });

    testWidgets('La rivelazione e\' due colpi, gli altri uno', (tester) async {
      final chiamate = spiaAptica();

      await PaletteSensoriale.eseguiSchema(SchemaAptico.tocco);
      expect(chiamate.length, 1, reason: 'il tocco non e\' un colpo solo');

      chiamate.clear();
      await tester.runAsync(
          () => PaletteSensoriale.eseguiSchema(SchemaAptico.soglia));
      expect(chiamate.length, 1, reason: 'la soglia non e\' un colpo solo');

      chiamate.clear();
      await tester.runAsync(
          () => PaletteSensoriale.eseguiSchema(SchemaAptico.rivelazione));
      expect(chiamate.length, 2,
          reason: 'la rivelazione deve essere DUE colpi crescenti, ne sono '
              'arrivati ${chiamate.length}');
    });

    testWidgets('Il rifiuto e\' il tocco due volte, senza schema suo',
        (tester) async {
      final chiamate = spiaAptica();
      final s = SettingsController(suonoEVibrazione: true);
      late BuildContext ctx;
      await tester.pumpWidget(conImpostazioni(s, Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));

      await tester.runAsync(() => PaletteSensoriale.rifiuto(ctx));

      expect(chiamate.length, 2,
          reason: 'il rifiuto non e\' due tocchi: ne sono arrivati '
              '${chiamate.length}');
      // Due volte lo stesso colpo, non un colpo dedicato.
      expect(chiamate.first, chiamate.last,
          reason: 'il rifiuto usa due colpi diversi, quindi ha uno schema suo: '
              'il rifiuto non merita teatro');
    });
  });

  group('L\'interruttore unico governa tutto', () {
    testWidgets('Acceso, la vibrazione parte', (tester) async {
      final chiamate = spiaAptica();
      final s = SettingsController(suonoEVibrazione: true);
      late BuildContext ctx;
      await tester.pumpWidget(conImpostazioni(s, Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));

      await tester.runAsync(
          () => PaletteSensoriale.vibra(ctx, SchemaAptico.conferma));
      expect(chiamate, isNotEmpty, reason: 'col comando acceso non vibra');
    });

    testWidgets('Spento, non vibra niente', (tester) async {
      final chiamate = spiaAptica();
      final s = SettingsController(suonoEVibrazione: false);
      late BuildContext ctx;
      await tester.pumpWidget(conImpostazioni(s, Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));

      // Tre funzioni diverse, come chiede l'ordine.
      await tester.runAsync(() async {
        await PaletteSensoriale.vibra(ctx, SchemaAptico.tocco);
        await PaletteSensoriale.vibra(ctx, SchemaAptico.rivelazione);
        await PaletteSensoriale.rifiuto(ctx);
      });

      expect(chiamate, isEmpty,
          reason: 'col comando spento arrivano ancora ${chiamate.length} '
              'vibrazioni: l\'interruttore non governa tutto');
    });

    testWidgets('Senza controller non si vibra', (tester) async {
      // Se non si sa cosa l'utente ha scelto, il silenzio e' il ripiego giusto.
      final chiamate = spiaAptica();
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));

      await tester.runAsync(
          () => PaletteSensoriale.vibra(ctx, SchemaAptico.soglia));
      expect(chiamate, isEmpty);
    });
  });

  test('Nessuna chiamata diretta all\'aptica fuori dalla palette', () {
    // La rete che tiene insieme tutto: se una schermata torna a vibrare per
    // conto proprio, quella vibrazione non rispetterebbe l'interruttore e non
    // apparterrebbe a nessuno dei quattro schemi.
    final colpevoli = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll('\\', '/');
      if (p.endsWith('core/sensi/palette_sensoriale.dart')) continue;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].trimLeft().startsWith('//')) continue;
        if (righe[i].contains('HapticFeedback.')) {
          colpevoli.add('$p:${i + 1}');
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'queste righe vibrano fuori dalla palette, quindi ignorano '
              + colpevoli.join(', '));
  });

  group('I suoni del catalogo, e nessuno fuori', () {
    test('Sono esattamente cinque', () {
      // SEI dal primo agosto 2026: si e' aggiunta la voce del principio,
      // sulla schermata nera dell'intro. Il numero non e' sacro, il catalogo
      // si': un suono in piu' entra qui e viene contato, invece di nascere
      // fuori dove nessuno lo vede. La regola ha fatto il suo mestiere, e ha
      // costretto la voce a passare da qui.
      expect(SuonoDelCerchio.values.length, 6,
          reason: 'il silenzio e cio che rende un suono importante: le app che '
              'stancano suonano a ogni tocco');
    });

    test('Ogni suono dichiara file e durata attesa', () {
      for (final s in SuonoDelCerchio.values) {
        expect(s.file.endsWith('.mp3'), isTrue,
            reason: '${s.name} non dichiara un file mp3');
        expect(s.percorso.startsWith('audio/'), isTrue);
        expect(s.durataAttesa.inMilliseconds, greaterThan(0));
        expect(s.durataAttesa.inSeconds, lessThanOrEqualTo(2),
            reason: '${s.name} dura piu di due secondi: nessuno dei cinque '
                'momenti regge un suono lungo');
      }
    });

    test('I tre Maestri non hanno tre suoni diversi', () {
      // Una firma che cambia a seconda di chi parla non e piu una firma.
      final nomi = SuonoDelCerchio.values.map((s) => s.name.toLowerCase());
      for (final m in const ['medora', 'aura', 'caligo']) {
        expect(nomi.any((n) => n.contains(m)), isFalse,
            reason: 'esiste un suono dedicato a $m: sarebbe rumore, non '
                'identita');
      }
    });

    test('Il catalogo e un DATO, e nessuno suona fuori da esso', () {
      // Se una schermata riproducesse un file audio per conto proprio, quel
      // suono non rispetterebbe l'interruttore e non sarebbe nel catalogo.
      final colpevoli = <String>[];
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final p = f.path.replaceAll(Platform.pathSeparator, '/');
        if (p.contains('core/sensi/')) continue;
        final righe = f.readAsLinesSync();
        for (var i = 0; i < righe.length; i++) {
          final r = righe[i];
          if (r.trimLeft().startsWith('//')) continue;
          if (r.contains('AssetSource(') || r.contains('.mp3')) {
            colpevoli.add('$p riga ${i + 1}');
          }
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'questi punti riproducono suoni fuori dal catalogo: '
              + colpevoli.join(', '));
    });

    test('La firma suona una volta sola per sessione', () {
      // Prova strutturale, e lo dichiaro: la regola vive nel codice e non si
      // puo' misurare a schermo senza il plugin audio, che in prova non c'e'.
      // Il ripiego silenzioso invece e' misurato dal motore stesso.
      final codice = File('lib/core/sensi/palette_sensoriale.dart')
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join(' ');
      expect(codice.contains('SuonoDelCerchio.firma'), isTrue,
          reason: 'la firma non ha nessuna regola dedicata');
      expect(codice.contains('_giaEmessi'), isTrue,
          reason: 'niente ricorda che la firma sia gia stata emessa, quindi '
              'suonerebbe a ogni ritorno in home');
    });
  });
}

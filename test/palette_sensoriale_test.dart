import 'dart:io';

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
            'l\'interruttore unico: ${colpevoli.join(", ")}');
  });
}

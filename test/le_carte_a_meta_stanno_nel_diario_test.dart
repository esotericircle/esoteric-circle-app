import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_diario_dei_viaggi_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE CARTE A META' STANNO NEL DIARIO, UNA ACCANTO ALL'ALTRA.** Ordine FZ
/// voce FZ.04: *"Chi segue ombre diverse ha piu' carte scoperte a meta',
/// ciascuna col suo numero di pezzi: si vedono tutte nel Diario dei viaggi,
/// una accanto all'altra"*.
///
/// **Il fatto**: nel Diario non c'erano. La prima simulazione da persona
/// dell'ordine (19 ottobre 2026) l'aveva annotato, *"Non trovata una vista
/// aggregata delle carte scoperte per animale"*, e la voce era stata chiusa
/// lo stesso. Padre: ordine FZ voce FZ.04.
///
/// **Cosa misura**: con tre ombre seguite un numero diverso di volte, il
/// Diario mostra tre carte, una per animale, in una fila, ognuna con la sua
/// carta vera e il suo numero di pezzi in parole; un animale mai seguito non
/// ha carta.
class _DiarioDiTreOmbre extends DiarioDeiViaggi {
  _DiarioDiTreOmbre() : super(archivio: false);

  @override
  List<String> get scelteInOrdine =>
      const ['Lince', 'Cavallo', 'Cavallo', 'Cervo', 'Cavallo', 'Cervo'];
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'TRE OMBRE SEGUITE, TRE CARTE A META\' NEL DIARIO, ognuna col suo '
      'numero di pezzi, una accanto all\'altra', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: IlDiarioDeiViaggiScreen(diario: _DiarioDiTreOmbre()),
    ));
    await tester.pump();
    expect(find.byKey(const Key('diario_carte_a_meta')), findsOneWidget,
        reason: 'nel Diario non c\'e\' la fila delle carte a meta\'');
    const attese = {
      'Cavallo': 'tre pezzi su quattro',
      'Cervo': 'due pezzi su quattro',
      'Lince': 'un pezzo su quattro',
    };
    final sinistre = <String, double>{};
    for (final e in attese.entries) {
      final carta = find.byKey(Key('diario_carta_${e.key}'));
      expect(carta, findsOneWidget, reason: 'manca la carta di ${e.key}');
      final immagine = tester
          .widget<Image>(find.byKey(Key('diario_carta_immagine_${e.key}')));
      expect((immagine.image as AssetImage).assetName,
          contains('${e.key.toLowerCase()}_carta_da_grattare_v1'),
          reason: 'la carta di ${e.key} nel Diario non e\' la sua carta vera');
      expect(
          tester
              .widget<Text>(find.byKey(Key('diario_carta_pezzi_${e.key}')))
              .data,
          e.value,
          reason: 'la carta di ${e.key} non dice quanti pezzi ha, in parole');
      sinistre[e.key] = tester.getTopLeft(carta).dx;
    }
    // **UNA ACCANTO ALL'ALTRA**: sulla stessa riga, dalla piu' scoperta.
    final cime = {
      for (final k in attese.keys)
        k: tester.getTopLeft(find.byKey(Key('diario_carta_$k'))).dy,
    };
    expect(cime.values.toSet().length, 1,
        reason: 'le carte non stanno sulla stessa riga: $cime');
    expect(sinistre['Cavallo']! < sinistre['Cervo']!, isTrue);
    expect(sinistre['Cervo']! < sinistre['Lince']!, isTrue);
    // **IL CARDINALE**: un animale mai seguito non ha carta.
    expect(find.byKey(const Key('diario_carta_Lupo')), findsNothing,
        reason: 'il Lupo non e\' mai stato seguito e ha una carta');
  });
}

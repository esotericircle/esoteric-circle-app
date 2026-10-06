import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/ricordi/azioni_del_responso.dart';

import 'il_diario_finto.dart';

/// **OGNI LETTURA ENTRA NEL DIARIO DA SE'. Ordine FE voce 22.6.**
///
/// Il fondatore: *"Ogni consulto, ogni responso e ogni lettura prodotta
/// dall'app entra nel Diario da sé, senza che l'utente prema niente."* Il
/// censimento del 6 ottobre 2026 ha trovato due buchi: sei letture senza la
/// porta del responso, che non entravano mai, e tre arti con la porta in
/// fondo a un elenco pigro, che entravano solo se la persona scorreva fino
/// in fondo. Qui: il censimento delle nove, ognuna col suo punto di
/// annotazione; e la prova viva dell'elenco pigro, dove il responso entra
/// senza scorrere e la porta in fondo non ne fa una seconda voce.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  /// Le nove arti curate, col file dove il responso si mostra e l'arte con
  /// cui entra nel Diario.
  const curate = {
    'stesa': 'lib/features/tarot/stesa_tre_carte_screen.dart',
    'sinastria': 'lib/features/synastry/sinastria_vip_screen.dart',
    'sigillo':
        'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart',
    'viaggio':
        'lib/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart',
    'angeli': 'lib/features/angels/angels_screen.dart',
    'consiglio': 'lib/features/maestri/ask/ask_maestri_screen.dart',
    'oroscopo_': 'lib/features/horoscope/oroscopo_screen.dart',
    'confronto': 'lib/features/cerchio/confronto_del_cielo_screen.dart',
    'gemello': 'lib/features/synastry/schermata_del_gemello.dart',
  };

  /// Le tre con la porta in fondo a un elenco pigro.
  const pigre = {'stesa', 'sinastria', 'sigillo'};

  test('FE.22.6: le nove letture curate hanno il loro punto di annotazione',
      () {
    final mancanti = <String>[];
    for (final e in curate.entries) {
      final sorgente = File(e.value)
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      final arte = sorgente.contains("arte: '${e.key}") ||
          sorgente.contains("arte: 'oroscopo_\${");
      final annota = sorgente.contains('IlResponsoNelDiario(') ||
          sorgente.contains('annotaNelDiario(');
      if (!arte || !annota) {
        mancanti.add('${e.key} (${e.value}): arte $arte, annotazione $annota');
      }
      if (pigre.contains(e.key)) {
        final diario = sorgente.indexOf('IlResponsoNelDiario(');
        final porta = sorgente.indexOf('AzioniDelResponso(');
        final stessoIstante =
            RegExp(r'AzioniDelResponso\([^;]*quando: quando', dotAll: true)
                .hasMatch(sorgente);
        if (diario < 0 || porta < 0 || !stessoIstante) {
          mancanti.add('${e.key}: elenco pigro senza IlResponsoNelDiario o '
              'senza lo stesso istante della porta');
        }
      }
    }
    // ignore: avoid_print
    print('FE.22.6 MISURA: letture curate ${curate.length}, senza il loro '
        'punto di annotazione ${mancanti.length}');
    expect(mancanti, isEmpty, reason: mancanti.join(' | '));
  });

  testWidgets(
      'FE.22.6: in un elenco pigro il responso entra senza scorrere, e la '
      'porta in fondo non fa una seconda voce', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final porta = PortaFintaDelDiario();
    final registro =
        RegistroDeiRicordi(orologio: () => DateTime(2026, 10, 6), porta: porta);
    await registro.carica();
    final quando = DateTime(2026, 10, 6, 15, 20);
    const responso = ResponsoDaCustodire(
      arte: 'stesa',
      titolo: 'La tua stesa a tre carte',
      testo: 'Il Matto, la Torre e la Stella: lascia andare per ricominciare.',
      dati: {'carte': 'Il Matto,La Torre,La Stella'},
    );
    await tester.pumpWidget(ChangeNotifierProvider<RegistroDeiRicordi>.value(
      value: registro,
      child: MaterialApp(
        home: Scaffold(
          body: ListView(
            key: const Key('elenco_pigro'),
            children: [
              IlResponsoNelDiario(
                  maestro: Maestro.medora, responso: responso, quando: quando),
              for (var i = 0; i < 30; i++)
                SizedBox(height: 200, child: Text('riga $i')),
              AzioniDelResponso(
                palette: MaestroPalette.medora,
                maestro: Maestro.medora,
                responso: responso,
                quando: quando,
                aperturaDellaChat: 'La mia stesa: cosa vuol dire?',
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(AzioniDelResponso), findsNothing,
        reason: 'la porta e\' gia\' costruita: la prova non misura l\'elenco '
            'pigro');
    final senzaScorrere = registro.tutte.length;
    await tester.scrollUntilVisible(find.byType(AzioniDelResponso), 2000,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('FE.22.6 MISURA: voci nel Diario senza scorrere $senzaScorrere, '
        'dopo aver raggiunto la porta ${registro.tutte.length}, annotazioni '
        'al server ${porta.chiamate.where((c) => c.containsKey('annota')).length}');
    expect(senzaScorrere, 1,
        reason: 'il responso non e\' entrato nel Diario senza scorrere');
    expect(registro.tutte.length, 1,
        reason: 'la porta in fondo ha fatto una seconda voce dello stesso '
            'responso');
  });
}

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/viaggio/la_promessa_del_viaggio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **LA SOGLIA E' UNA SCENA PIENA, E LA PROMESSA CAMBIA NEL TEMPO.**
/// Ordine DE voci 01 e 02, 11 settembre 2026.
///
/// **CHE COSA SORVEGLIA CHE LA GUARDIA DI PRIMA NON SORVEGLIAVA.** La guardia
/// dell'ordine DC pretende che la scena copra **almeno un terzo** della
/// finestra: con quella soglia, un riquadro alto il quaranta per cento in cima
/// a una colonna passerebbe, ed e' esattamente cio' che il fondatore ha
/// bocciato. Qui il numero e' **cento per cento**, contato sui punti dipinti
/// nella finestra vera, come vuole la Regola I.
///
/// **E LA REGOLA H, che qui vale due volte.** La promessa che si legge prima
/// della quarta discesa deve **non** essere quella che si legge dopo, e le tre
/// righe che si leggono prima della prima devono **non** esserci alla seconda.
/// Una guardia che dimostra solo la presenza di una frase e' verde anche
/// quando quella frase c'e' sempre, e una promessa che c'e' sempre non e' una
/// promessa che cambia.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  void telefono(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> apri(WidgetTester tester, {int discese = 0}) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MaestroController(),
        child: MaterialApp(
          home: MaestroScope(
            child: ViaggioDelloSciamanoScreen(
              // **UNA CHIAVE DIVERSA PER OGNI NUMERO DI DISCESE.** Senza,
              // Flutter riusa lo stesso State fra un pumpWidget e l altro, e
              // il diario resta quello del primo giro: la prova leggerebbe
              // sempre la stessa promessa e sarebbe verde per sbaglio.
              key: ValueKey(discese),
              userSign: Zodiac.gemini,
              now: DateTime(2026, 9, 11, 12),
              diario: DiarioDelloSciamanoDiProva(discese),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('DE.01, REGOLA I: LA SCENA COPRE IL CENTO PER CENTO DELLA '
      'FINESTRA UTILE', (tester) async {
    telefono(tester);
    await apri(tester);
    final scena = tester.getRect(find.byKey(const Key('viaggio_bosco')));
    final finestra = tester.getRect(find.byType(Scaffold));
    final quotaAlta = scena.height / finestra.height;
    final quotaLarga = scena.width / finestra.width;
    // ignore: avoid_print
    print('ORDINE DE VOCE 01: la scena misura '
        '${scena.width.toStringAsFixed(0)} per '
        '${scena.height.toStringAsFixed(0)} dentro una finestra di '
        '${finestra.width.toStringAsFixed(0)} per '
        '${finestra.height.toStringAsFixed(0)}, cioe il '
        '${(quotaLarga * 100).toStringAsFixed(1)} per cento in larghezza e il '
        '${(quotaAlta * 100).toStringAsFixed(1)} per cento in altezza');
    expect(quotaLarga, greaterThanOrEqualTo(0.999),
        reason: 'la scena non arriva ai due bordi laterali: e ancora dentro '
            'un riquadro');
    expect(quotaAlta, greaterThanOrEqualTo(0.999),
        reason: 'la scena non arriva in cima e in fondo: la soglia e ancora '
            'una card in testa a una colonna che scorre');
    // **E PARTE DAL PUNTO ZERO**, cioe sotto la barra e non sotto una
    // striscia di pagina.
    expect(scena.top, lessThanOrEqualTo(0.5),
        reason: 'sopra la scena resta una striscia alta ${scena.top} punti');
  });

  testWidgets('DE.01: IL TESTO STA SOPRA LA SCENA, NON SOTTO', (tester) async {
    telefono(tester);
    await apri(tester);
    final scena = tester.getRect(find.byKey(const Key('viaggio_bosco')));
    final promessa = tester.getRect(find.byKey(const Key('viaggio_promessa')));
    // ignore: avoid_print
    print('ORDINE DE VOCE 01: la scena va da ${scena.top.toStringAsFixed(0)} a '
        '${scena.bottom.toStringAsFixed(0)}, la promessa sta a '
        '${promessa.top.toStringAsFixed(0)}');
    expect(promessa.top, greaterThan(scena.top),
        reason: 'la promessa comincia sopra la scena');
    expect(promessa.bottom, lessThan(scena.bottom),
        reason: 'la promessa esce dal fondo della scena: il testo non ci sta '
            'sopra, ci sta dopo');
  });

  testWidgets('DE.02, REGOLA H: LE TRE COSE DA SAPERE CI SONO ALLA PRIMA '
      'DISCESA E NON ALLA SECONDA', (tester) async {
    telefono(tester);
    await apri(tester);
    var quante = 0;
    for (var i = 0; i < LaPromessaDelViaggio.treCoseDaSapere.length; i++) {
      if (find.byKey(Key('viaggio_promessa_$i')).evaluate().isNotEmpty) {
        quante++;
      }
    }
    // ignore: avoid_print
    print('ORDINE DE VOCE 02: prima della prima discesa le righe della '
        'promessa a schermo sono $quante su '
        '${LaPromessaDelViaggio.treCoseDaSapere.length}');
    expect(quante, LaPromessaDelViaggio.treCoseDaSapere.length,
        reason: 'chi apre la soglia la prima volta non legge le tre cose che '
            'deve sapere: non sa che in quattro discese conoscera il nome, '
            'ne che quell animale resta, ne che si potra consultare');

    // **E ALLA SECONDA NON CI SONO PIU.**
    await apri(tester, discese: 1);
    var ancora = 0;
    for (var i = 0; i < LaPromessaDelViaggio.treCoseDaSapere.length; i++) {
      if (find.byKey(Key('viaggio_promessa_$i')).evaluate().isNotEmpty) {
        ancora++;
      }
    }
    // ignore: avoid_print
    print('ORDINE DE VOCE 02: alla seconda discesa le righe della promessa '
        'sono $ancora');
    expect(ancora, 0,
        reason: 'la promessa si ripete a chi l ha gia accettata: da li in poi '
            'si legge come una reclame');
  });

  testWidgets('DE.02, REGOLA H: LA PROMESSA PRIMA DELLA QUARTA DISCESA NON E '
      'QUELLA DI DOPO', (tester) async {
    telefono(tester);
    String promessaCon(int discese) => (tester
            .widget<Text>(find.byKey(const Key('viaggio_promessa'))))
        .data!;

    await apri(tester, discese: 2);
    final prima = promessaCon(2);
    await apri(tester, discese: 4);
    final dopo = promessaCon(4);
    // ignore: avoid_print
    print('ORDINE DE VOCE 02: a due discese la soglia promette "$prima"; a '
        'quattro promette "$dopo"');
    expect(prima, isNot(dopo),
        reason: 'la promessa non cambia mai: chi ha gia il nome del suo '
            'animale legge ancora che lo scoprira');
    expect(prima.toLowerCase(), contains('animale'),
        reason: 'prima della quarta discesa la promessa non nomina la cosa '
            'che si ottiene: "$prima"');
    expect(dopo.toLowerCase(), contains('risposta'),
        reason: 'dopo la quarta discesa la promessa non parla di risposte: '
            '"$dopo"');
  });

  test('DE.02: IL TITOLO DELL ARTE E SU TRE RIGHE, E LE RIGHE SONO QUELLE '
      'DICHIARATE', () {
    final viaggio = ArtCatalog.all.firstWhere((a) => a.id == 'guide_animal');
    // ignore: avoid_print
    print('ORDINE DE VOCE 02: la card del Viaggio scrive il titolo su '
        '${viaggio.righeDelTitolo?.length} righe: '
        '${viaggio.righeDelTitolo}');
    expect(viaggio.righeDelTitolo, LaPromessaDelViaggio.righeDelTitolo,
        reason: 'la card e il file della promessa scrivono due titoli diversi');
    expect(viaggio.righeDelTitolo, ['VIAGGIO', 'dello', 'SCIAMANO']);

    // **REGOLA H: nessun altra arte ha le righe.** Un titolo a piu righe e
    // una eccezione motivata, non il nuovo modo di scrivere i titoli: se un
    // giorno ne comparissero altre due senza che nessuno lo decida, questa
    // prova cade coi loro nomi in mano.
    final altre = [
      for (final a in ArtCatalog.all)
        if (a.id != 'guide_animal' && a.righeDelTitolo != null) a.id,
    ];
    // ignore: avoid_print
    print('ORDINE DE VOCE 02: arti nel catalogo ${ArtCatalog.all.length}, '
        'altre con il titolo a righe ${altre.length}');
    expect(ArtCatalog.all.length, greaterThanOrEqualTo(20),
        reason: 'il catalogo delle arti si e svuotato e questa prova cerca '
            'dentro il nulla');
    expect(altre, isEmpty, reason: 'anche queste arti spezzano il titolo '
        'senza che nessun ordine lo abbia chiesto: $altre');
  });

  test('DE.02: LA DESCRIZIONE CAMBIA ALLA QUARTA DISCESA E NON PRIMA', () {
    final righe = <int, String>{
      for (var d = 0; d <= 6; d++) d: LaPromessaDelViaggio.descrizionePer(d),
    };
    // ignore: avoid_print
    print('ORDINE DE VOCE 02: descrizione per discese fatte: $righe');
    for (var d = 0; d < 4; d++) {
      expect(righe[d], righe[0],
          reason: 'la descrizione cambia gia a $d discese');
    }
    for (var d = 4; d <= 6; d++) {
      expect(righe[d], isNot(righe[0]),
          reason: 'a $d discese la descrizione e ancora quella di prima');
      expect(righe[d], righe[4],
          reason: 'dopo la quarta la descrizione continua a cambiare');
    }
  });
}

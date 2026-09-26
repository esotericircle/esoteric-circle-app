import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/viaggio/i_quattro_viaggi.dart';
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

  testWidgets('DI.07, REGOLA H: LE TRE INFORMAZIONI DEL PERCORSO CI SONO '
      'FINO AL RICONOSCIMENTO, AL LORO POSTO, E DOPO NO', (tester) async {
    // **I TESTI SONO QUELLI DELL'ORDINE, scritti qui per esteso** e non letti
    // dalle costanti: una costante sbagliata non deve poter far passare se
    // stessa.
    const dellOrdine = {
      'viaggio_dove_ti_trovi': "Il Mondo di Sotto è il luogo dove gli "
          "sciamani scendono per incontrare l'animale che li accompagna. Ci "
          "si arriva per un'apertura nella terra.",
      'viaggio_cosa_stai_facendo': "Scendi con una domanda. L'animale ti "
          "mostra una scena. La scena è la risposta.",
      'viaggio_cosa_otterrai':
          'Si mostra quattro volte prima di farsi riconoscere. Poi resta '
              'con te.',
    };
    telefono(tester);
    for (var d = 0; d <= 4; d++) {
      await apri(tester, discese: d);
      final aSchermo = <String>[
        for (final k in dellOrdine.keys)
          if (find.byKey(Key(k)).evaluate().isNotEmpty) k,
      ];
      // ignore: avoid_print
      print('ORDINE DI VOCE 07: a $d discese le righe del percorso a schermo '
          'sono ${aSchermo.length} su 3');
      if (d < 4) {
        expect(aSchermo.length, 3,
            reason: 'a $d discese mancano righe del percorso: per tre viaggi '
                'su quattro l app non diceva che si scende con una domanda');
        for (final e in dellOrdine.entries) {
          expect(tester.widget<Text>(find.byKey(Key(e.key))).data, e.value,
              reason: 'la riga ${e.key} non e quella dell ordine');
        }
        // **AL LORO POSTO**: sotto il titolo, sopra il pulsante, subito
        // sotto.
        final titolo = tester.getRect(find.byKey(const Key('viaggio_promessa')));
        final dove = tester.getRect(find.byKey(const Key('viaggio_dove_ti_trovi')));
        final scendi = tester.getRect(find.byKey(const Key('viaggio_scendi')));
        final facendo =
            tester.getRect(find.byKey(const Key('viaggio_cosa_stai_facendo')));
        final otterrai =
            tester.getRect(find.byKey(const Key('viaggio_cosa_otterrai')));
        expect(dove.top, greaterThanOrEqualTo(titolo.bottom),
            reason: 'dove ti trovi non sta sotto il titolo');
        expect(facendo.bottom, lessThanOrEqualTo(scendi.top),
            reason: 'cosa stai facendo non sta sopra il pulsante');
        expect(otterrai.top, greaterThanOrEqualTo(scendi.bottom),
            reason: 'cosa otterrai non sta subito sotto il pulsante');
        expect(otterrai.top - scendi.bottom, lessThan(40),
            reason: 'cosa otterrai sta ${otterrai.top - scendi.bottom} punti '
                'sotto il pulsante: non e subito sotto');
      } else {
        expect(aSchermo, isEmpty,
            reason: 'riconosciuto l animale, le righe del percorso restano '
                'accese a vuoto: e cio che fa sembrare la funzione un gioco '
                'senza fine');
      }
    }
  });

  testWidgets('DI.08: LE QUATTRO IMPRONTE STANNO IN ALTO E NON SCORRONO VIA, '
      'E LA RIGA E IN PAROLE', (tester) async {
    telefono(tester);
    await apri(tester, discese: 2);
    final impronte = find.byKey(const Key('viaggio_i_quattro_segni'));
    final riga = find.byKey(const Key('viaggio_a_che_punto'));
    expect(impronte, findsOneWidget);
    final barra = tester.getRect(find.byType(AppBar));
    final prima = tester.getRect(impronte);
    // ignore: avoid_print
    print('ORDINE DI VOCE 08: la barra finisce a '
        '${barra.bottom.toStringAsFixed(0)}, le impronte cominciano a '
        '${prima.top.toStringAsFixed(0)}; la riga dice '
        '"${tester.widget<Text>(riga).data}"');
    expect(prima.top, greaterThanOrEqualTo(barra.bottom),
        reason: 'le impronte finiscono sotto la barra');
    expect(prima.top - barra.bottom, lessThan(24),
        reason: 'le impronte stanno ${prima.top - barra.bottom} punti sotto '
            'la barra: non sono in alto');
    // **SEMPRE VISIBILI**: si scorre la soglia fino in fondo, e le impronte
    // restano dove sono.
    await tester.drag(
        find.byKey(const Key('viaggio_soglia_scorre')), const Offset(0, -600));
    await tester.pump();
    expect(tester.getRect(impronte), prima,
        reason: 'scorrendo la soglia le impronte se ne vanno: non sono '
            'sempre visibili');
    expect(tester.widget<Text>(riga).data,
        'Si è mostrato due volte, ne mancano due.',
        reason: 'la riga del cammino non e quella dell ordine');
    // **OGNI IMPRONTA STA DENTRO LA SUA SCATOLA.** Difetto visto nella
    // fotografia della soglia, 12 settembre 2026: la prima usciva di sotto e
    // l ultima di sopra, e lo Stack le tagliava a meta.
    final scatola =
        tester.getRect(find.byKey(const Key('viaggio_le_quattro_impronte')));
    for (var i = 0; i < 4; i++) {
      final r = tester.getRect(find.byKey(Key('viaggio_impronta_vuota_$i')));
      expect(
          r.top >= scatola.top - 0.5 &&
              r.bottom <= scatola.bottom + 0.5 &&
              r.left >= scatola.left - 0.5 &&
              r.right <= scatola.right + 0.5,
          isTrue,
          reason: 'l impronta $i esce dalla sua scatola ($r fuori da '
              '$scatola): lo Stack la taglia');
    }
    // **E DOPO IL RICONOSCIMENTO NON CI SONO PIU.**
    await apri(tester, discese: 4);
    expect(impronte, findsNothing,
        reason: 'riconosciuto l animale, le impronte restano accese a vuoto');
  });

  test('DI.08: NESSUNA RIGA DEL CAMMINO USA UNA CIFRA', () {
    final dette = <String>[
      for (var d = 0; d <= 10; d++) ...[
        IQuattroViaggi.aChePunto(d),
        IQuattroViaggi.quanteVolteSiEMostrato(d == 0 ? 1 : d),
      ],
    ];
    final conCifre = dette.where((r) => r.contains(RegExp(r'\d'))).toList();
    // ignore: avoid_print
    print('ORDINE DI VOCE 08: righe del cammino guardate ${dette.length}, '
        'con una cifra ${conCifre.length}');
    expect(conCifre, isEmpty,
        reason: 'l ordine vuole la riga "in parole e mai in numeri": '
            '$conCifre');
    expect(IQuattroViaggi.aChePunto(1),
        'Si è mostrato una volta, ne mancano tre.');
    expect(IQuattroViaggi.aChePunto(3), 'Si è mostrato tre volte, ne manca una.');
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
    // **DOPO IL RICONOSCIMENTO L'INTESTAZIONE E' UN'ALTRA**, ordine DI voce
    // 11: l'animale chiamato per nome e la riga *"<Nome> resta con te. Scendi
    // quando hai una domanda."*. La promessa di dopo si legge li'.
    expect(find.byKey(const Key('viaggio_promessa')), findsNothing,
        reason: 'dopo il riconoscimento la soglia promette ancora di scoprire');
    final dopo = tester
        .widget<Text>(find.byKey(const Key('viaggio_resta_con_te')))
        .data!;
    // ignore: avoid_print
    print('ORDINE DE VOCE 02: a due discese la soglia promette "$prima"; a '
        'quattro promette "$dopo"');
    expect(prima, isNot(dopo),
        reason: 'la promessa non cambia mai: chi ha gia il nome del suo '
            'animale legge ancora che lo scoprira');
    expect(prima.toLowerCase(), contains('animale'),
        reason: 'prima della quarta discesa la promessa non nomina la cosa '
            'che si ottiene: "$prima"');
    expect(dopo.toLowerCase(), contains('domanda'),
        reason: 'dopo la quarta discesa la soglia non parla di domande: '
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

  /// **IL TESTO DELLA SOGLIA NON SCORRE SOTTO LA BARRA.** Ordine DG, collaudo
  /// a video della 2249, 12 settembre 2026.
  ///
  /// **Il difetto visto sul 767f596c.** La lista che scorre occupava tutto lo
  /// schermo, barra compresa, e partiva piu' in basso solo per un margine:
  /// appena si scorreva, il testo saliva sotto la barra trasparente e ci si
  /// sovrapponeva. Si leggeva *"Dodici ti aspettano"* sopra *"Il Viaggio dello
  /// Sciamano"*. La cattura sta in
  /// `docs/catture/dg/2249_04_soglia_testo_sotto_la_barra.png`.
  ///
  /// **LA GRANDEZZA MISURATA E' LA GEOMETRIA VERA**, dopo aver scorso: il
  /// bordo alto della finestra della lista contro il bordo basso della barra.
  /// Una lista che scorre taglia da se' cio' che esce dalla sua finestra,
  /// quindi basta che la finestra cominci sotto la barra.
  ///
  /// **VISTA ROSSA** riportando la lista a cominciare dal bordo dello schermo:
  /// la finestra cominciava a zero punti e la barra finiva a 56.
  testWidgets('DG: la lista della soglia comincia sotto la barra, e scorrendo '
      'non ci passa sotto', (tester) async {
    telefono(tester);
    await apri(tester);
    final lista = find.byKey(const Key('viaggio_soglia_scorre'));
    expect(lista, findsOneWidget,
        reason: 'la lista della soglia non ha piu la sua chiave, e questa '
            'prova non sa piu cosa misurare');
    await tester.drag(lista, const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 300));
    final finestra = tester.getRect(lista);
    final barra = tester.getRect(find.byType(AppBar));
    // ignore: avoid_print
    print('ORDINE DG: la finestra della lista comincia a '
        '${finestra.top.toStringAsFixed(0)} punti, la barra finisce a '
        '${barra.bottom.toStringAsFixed(0)}');
    expect(finestra.top, greaterThanOrEqualTo(barra.bottom - 0.5),
        reason: 'LA LISTA DELLA SOGLIA COMINCIA DIETRO LA BARRA: la sua '
            'finestra parte a ${finestra.top.toStringAsFixed(0)} punti e la '
            'barra finisce a ${barra.bottom.toStringAsFixed(0)}. Scorrendo, '
            'il testo sale sotto la barra trasparente e ci si sovrappone, '
            'come si e visto sul 767f596c con la 2249.');
  });
}

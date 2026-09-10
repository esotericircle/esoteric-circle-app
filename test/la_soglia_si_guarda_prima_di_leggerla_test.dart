import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_girandola_degli_animali.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA SOGLIA SI GUARDA PRIMA DI LEGGERLA.**
/// Ordine DC voce 21, 10 settembre 2026.
///
/// **DA DOVE NASCE, e sono parole del fondatore davanti alla fotografia della
/// prova a video**: *"l'utente e' gia' scappato prima ancora di leggere. Ti
/// sembra un'esperienza immersiva per un utente medio? Solo testo da leggere,
/// nessuna vena artistica, nessuna immagine o riquadro che metta in evidenza
/// o guidi l'utente. Niente di attraente a primo impatto, niente che faccia
/// capire di cosa si tratta a primo impatto. Le domande buttate li'."*
///
/// **Aveva ragione su tre leggi di casa insieme**, e nessuna guardia le
/// sorvegliava su questa schermata: l'anatomia del responso a quattro strati
/// vuole il livello visivo **prima** del testo; la regola dell'ordine AS vuole
/// meno testo e piu' diretto; e nessun elenco di cose toccabili puo' avere
/// l'aspetto di un paragrafo.
///
/// **PERCHE' NESSUNA PROVA POTEVA VEDERLO.** Le guardie del Viaggio
/// misuravano che i testi ci fossero, che le sei domande esistessero, che il
/// pulsante rispondesse. **Erano tutte vere.** Una schermata puo' avere ogni
/// pezzo al suo posto ed essere un muro di parole, e nessuna asserzione
/// sull'esistenza dei pezzi lo dira' mai.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// **LA FINESTRA VERA**, che e' quella su cui questo progetto misura.
  void telefono(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> apri(WidgetTester tester, {int discese = 0}) async {
    final diario = DiarioDelloSciamanoDiProva(discese);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => MaestroController(),
        child: MaterialApp(
          home: MaestroScope(
            child: ViaggioDelloSciamanoScreen(
              userSign: Zodiac.gemini,
              now: DateTime(2026, 9, 10, 12),
              diario: diario,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('IL COLPO D OCCHIO STA SOPRA OGNI PAROLA DA LEGGERE',
      (tester) async {
    telefono(tester);
    await apri(tester);

    final scena = find.byKey(const Key('viaggio_bosco'));
    expect(scena, findsOneWidget,
        reason: 'la soglia non ha nessuna scena: chi apre trova un documento');

    final altoScena = tester.getTopLeft(scena).dy;
    final altoTesto =
        tester.getTopLeft(find.byKey(const Key('viaggio_a_che_punto'))).dy;
    // ignore: avoid_print
    print('ORDINE DC VOCE 21: la scena parte a $altoScena, il primo testo da '
        'leggere a $altoTesto');
    expect(altoScena, lessThan(altoTesto),
        reason: 'il primo strato della soglia e un paragrafo e non una '
            'immagine: e esattamente il difetto che il fondatore ha visto');
  });

  testWidgets('LA SCENA OCCUPA ALMENO UN TERZO DELLA FINESTRA',
      (tester) async {
    telefono(tester);
    await apri(tester);
    final misura = tester.getSize(find.byKey(const Key('viaggio_bosco')));
    final quota = misura.height / 844;
    // ignore: avoid_print
    print('ORDINE DC VOCE 21: la scena della soglia e alta '
        '${misura.height.toStringAsFixed(0)} su 844, cioe il '
        '${(quota * 100).toStringAsFixed(1)} per cento della finestra');
    expect(quota, greaterThanOrEqualTo(0.33),
        reason: 'la scena e alta il ${(quota * 100).toStringAsFixed(1)} per '
            'cento della finestra: una figurina in cima a una colonna di '
            'testo non e un colpo d occhio');
  });

  testWidgets('LE TRE VIE SONO TRE, E SI VEDE CHE SONO TRE', (tester) async {
    telefono(tester);
    await apri(tester);
    final vie = find.byKey(const Key('viaggio_le_tre_vie'));
    expect(vie, findsOneWidget,
        reason: 'le tre vie della voce DC.05 non sono dichiarate: chi guarda '
            'vede un campo, sei righe e una settima riga, tutte uguali');
    // **UNA VIA ALLA VOLTA.** Aperta la scelta, il campo libero non c e: due
    // strade aperte insieme sono due strade che si contraddicono.
    expect(find.byKey(const Key('viaggio_domanda_scelta')), findsOneWidget);
    expect(find.byKey(const Key('viaggio_domanda')), findsNothing,
        reason: 'il campo libero e aperto insieme all elenco delle domande');
  });

  testWidgets('NESSUN NOME DI ANIMALE COMPARE SULLA SOGLIA', (tester) async {
    // **REGOLA DELLA VOCE DC.02**: il nome si conquista in quattro discese, e
    // la girandola dei dodici mostra **che sono dodici**, non quale sara il
    // tuo. Un nome scritto qui bruciera la rivelazione meglio di qualunque
    // onboarding.
    telefono(tester);
    await apri(tester, discese: 2);
    final nomi = <String>[];
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      final testo = t.data ?? '';
      for (final a in AnimalCatalog.animals) {
        if (testo.toLowerCase().contains(a.name.toLowerCase())) {
          nomi.add('${a.name} in "$testo"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 02: animali cercati sulla soglia '
        '${AnimalCatalog.animals.length}, nominati ${nomi.length}');
    expect(AnimalCatalog.animals.length, greaterThanOrEqualTo(12),
        reason: 'il catalogo si e svuotato e questa prova cerca fra niente');
    expect(nomi, isEmpty, reason: 'la soglia dice gia un nome: $nomi');
  });

  testWidgets('LA GIRANDOLA PORTA TUTTI I TOTEM DEL CATALOGO',
      (tester) async {
    telefono(tester);
    await apri(tester);
    expect(GirandolaDegliAnimali.quantiSonoDavvero(),
        AnimalCatalog.animals.length,
        reason: 'la girandola e il catalogo non contano lo stesso numero');
    expect(find.byType(GirandolaDegliAnimali), findsOneWidget,
        reason: 'i dodici totem gia fatti non si vedono da nessuna parte '
            'prima di aver conosciuto il proprio animale');
  });

  testWidgets('IL PULSANTE CHE PORTA GIU E ALTO ALMENO CINQUANTADUE',
      (tester) async {
    telefono(tester);
    await apri(tester);
    final scendi = find.byKey(const Key('viaggio_scendi'));
    expect(scendi, findsOneWidget);
    final misura = tester.getSize(scendi);
    // ignore: avoid_print
    print('ORDINE DC VOCE 21: il pulsante Scendi misura '
        '${misura.width.toStringAsFixed(0)} per '
        '${misura.height.toStringAsFixed(0)}');
    expect(misura.height, greaterThanOrEqualTo(52),
        reason: 'il pulsante che porta giu e alto ${misura.height}: un tratto '
            'in fondo a una colonna lunga');
  });
}

/// Un diario finto con un numero di discese dichiarato, che non tocca il
/// disco: le prove non aspettano nessun archivio.
class DiarioDelloSciamanoDiProva extends DiarioDeiViaggi {
  DiarioDelloSciamanoDiProva(this.quante);

  final int quante;

  @override
  Future<void> carica() async {}

  @override
  int get quanteDiscese => quante;

  @override
  List<String> get scelteInOrdine => const [];

  @override
  bool siPuoScendereOggi({required bool giaRiconosciuto}) => true;

  @override
  int? get giorniDallUltima => quante == 0 ? null : 1;
}


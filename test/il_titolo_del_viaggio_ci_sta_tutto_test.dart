// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/components/titolo_che_non_si_rompe.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL TITOLO DEL VIAGGIO CI STA TUTTO, ANCHE COL LIBRO NELLA BARRA.**
/// Ordine DQ voce 14, 16 settembre 2026.
///
/// **Il difetto, visto sul 767f596c nella prova a video.** Appena il Diario
/// ha qualcosa dentro, nella barra compare il libro, ordine DQ voce 02: le
/// azioni diventano tre e al titolo resta meno larghezza. La barra si
/// leggeva **"Il Viaggio dello"**, e *"Sciamano"* non c'era piu'.
///
/// **Perche' nessuna guardia l'ha preso.** `il_titolo_non_si_rompe`
/// sorveglia i Sentieri, non questa barra; e `TitoloCheNonSiRompe`, quando
/// la parola piu' lunga entra ma il titolo intero vuole piu' righe di quelle
/// concesse, **restituisce lo stesso una misura**: il testo non si spezza a
/// meta' di una parola, ma l'ultima riga viene tagliata via. Il titolo non
/// si rompeva: spariva.
///
/// **Qui si misura la resa vera**: lo stile con cui il titolo e' dipinto, la
/// larghezza della scatola che ha davvero nella barra, e le righe che gli
/// sono concesse. Se in quelle righe non ci sta, la prova cade.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> apri(WidgetTester tester, DiarioDeiViaggi diario) async {
    // **LA MISURA DEL 767f596c**, dove il difetto si e' visto: 1080 per 2400
    // pixel a densita' 480, cioe' **360 punti di larghezza**, non i 390 del
    // banco. Su 390 il titolo ci stava, e una guardia montata li' sarebbe
    // stata verde davanti al difetto fotografato.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
      ],
      // **CON LA SOGLIA DELL'ARTE**, come la apre l'app: e' lei a mettere il
      // cuore nella barra, `ArteCorrente`. Senza, le azioni sono due invece
      // di tre e al titolo resta larghezza che sul telefono non ha.
      child: MaterialApp(
        home: MaestroScope(
          child: SogliaArte(
            id: 'guide_animal',
            maestro: Maestro.caligo,
            child: ViaggioDelloSciamanoScreen(
              userSign: Zodiac.cancer,
              now: DateTime(2026, 9, 16, 12),
              diario: diario,
              demo: false,
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('il titolo della barra si legge INTERO col libro del Diario',
      (tester) async {
    // **IL DIARIO CON UNA DISCESA DENTRO**, che e' la condizione in cui il
    // libro compare: con l'archivio vuoto le azioni sono due e il difetto
    // non si vede. Una guardia che aprisse il Viaggio da zero sarebbe verde
    // senza aver guardato il caso vero.
    final diario = DiarioDeiViaggi();
    await diario.carica();
    await diario.segna(UnViaggio(
      quando: DateTime(2026, 9, 15, 12),
      domanda: 'Non riesco a decidere se cambiare lavoro',
      temaDellaDomanda: 'blocco',
      pezzi: const ['radura', 'ramo_secco', 'si_ferma', 'alba'],
      animaleSeguito: 'Lupo',
      nitidezza: 1,
      titolo: 'La direzione non e la soluzione',
      risposta: 'Una risposta.',
      gesto: 'Un gesto.',
      strato: 1,
    ));
    await apri(tester, diario);

    expect(find.byKey(const Key('viaggio_il_diario')), findsOneWidget,
        reason: 'col Diario pieno il libro deve stare nella barra: senza di '
            'lui questa prova non guarda il caso che ha rotto il titolo');

    const titolo = 'Il Viaggio dello Sciamano';
    final reso = tester.widget<Text>(find.text(titolo));

    // **LA LARGHEZZA SI CALCOLA, non si misura al banco.** Al banco il cuore
    // della barra resta vuoto finche' non ha reclamato l'arte, e al titolo
    // avanza larghezza che sul telefono non ha: la scatola qui risulta di
    // settanta punti piu' larga di quella fotografata. Quindi si parte dalla
    // barra e si tolgono la freccia e le **tre** azioni che ci sono quando il
    // Diario ha qualcosa dentro: il libro, le fonti e il cuore. Il conto e'
    // largo: sul 767f596c ne restavano ancora meno.
    const freccia = 56.0, azione = 48.0, azioni = 3;
    final larghezza =
        tester.getSize(find.byType(AppBar)).width - freccia - azione * azioni;
    final righe = reso.maxLines ?? 2;
    final misura = TitoloCheNonSiRompe.misuraChePermetteDiLeggere(
      testo: titolo,
      stile: reso.style!
          .copyWith(fontSize: TypographyTokens.titoloScheda().fontSize),
      larghezza: larghezza,
      righe: righe,
    );
    ({bool taglia, double alto}) come(double quanta) {
      final p = TextPainter(
        text: TextSpan(
            text: titolo, style: reso.style!.copyWith(fontSize: misura)),
        textDirection: TextDirection.ltr,
        maxLines: righe,
        textAlign: TextAlign.center,
      )..layout(maxWidth: quanta);
      return (taglia: p.didExceedMaxLines, alto: p.height);
    }

    final qui = come(larghezza);
    // **E A CENTOVENTI PUNTI**, che e' la larghezza sotto la quale il difetto
    // si e' visto: la barra di un telefono stretto, o una quarta azione
    // domani. In due righe il titolo li' si taglia a qualunque misura.
    final stretta = come(120);
    final barra = tester.getSize(find.byType(AppBar)).height;
    print('ORDINE DQ VOCE 14, IL TITOLO DELLA BARRA: con tre azioni restano '
        '${larghezza.toStringAsFixed(0)} punti, il titolo scende a '
        '${misura.toStringAsFixed(1)} su $righe righe e vuole '
        '${qui.alto.toStringAsFixed(0)} punti di altezza in una barra alta '
        '${barra.toStringAsFixed(0)}; a 120 punti '
        '${stretta.taglia ? "SI TAGLIA" : "ci sta"}');
    expect(qui.taglia, isFalse,
        reason: 'il titolo non ci sta nelle $righe righe che ha, con le tre '
            'azioni nella barra: l\'ultima riga viene tagliata e la barra si '
            'legge monca, come sul 767f596c');
    expect(stretta.taglia, isFalse,
        reason: 'a centoventi punti di larghezza il titolo si taglia: e la '
            'misura in cui il difetto della prova a video si e visto');
    // **E LA BARRA E' ALTA ABBASTANZA PER LE RIGHE CHE CONCEDE**: tre righe
    // in una barra da cinquantasei punti sono un titolo tagliato di sotto
    // invece che di lato.
    expect(barra, greaterThanOrEqualTo(stretta.alto),
        reason: 'la barra e alta ${barra.toStringAsFixed(0)} punti e il '
            'titolo su $righe righe ne vuole ${stretta.alto.toStringAsFixed(0)}');
  });
}

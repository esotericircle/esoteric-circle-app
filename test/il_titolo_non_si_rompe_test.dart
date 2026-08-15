import 'dart:io';

import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/components/titolo_che_non_si_rompe.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'istante_dichiarato.dart';

/// IL TITOLO DELLA BARRA NON SI ROMPE. Correzione nata dalla voce S.05.
///
/// **Due difetti diversi, uno dietro l'altro.** Prima il titolo si troncava coi
/// puntini, "Costellazione pers...", ed e' costato una voce nell'ordine P. Poi,
/// quando la riga del saldo e' cresciuta con la parola Eos, si e' spezzato dentro
/// una parola: "Costellazio / ne persona...". Un titolo su due righe e' una cosa,
/// un titolo rotto e' un'altra, e il secondo si legge come una schermata non
/// finita.
///
/// **LA LARGHEZZA NON SI INDOVINA: SI MONTA LA BARRA VERA.** La prima stesura di
/// questa prova scriveva 176 punti come spazio del titolo, un numero preso a
/// occhio, e passava anche col difetto in piedi: a quella larghezza inventata la
/// parola piu' lunga entrava, mentre nella barra vera non entrava. Una prova che
/// passa per la ragione sbagliata si butta. Adesso la barra si monta con le sue
/// azioni, il saldo e il cuore, e la larghezza del titolo si MISURA dalla resa.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  });

  /// LO SCHERMO PIU' STRETTO FRA QUELLI SUPPORTATI: 360 punti logici, la stessa
  /// larghezza del corredo delle anteprime.
  const Size schermoPiuStretto = Size(360, 797);

  String piuLungoDeiTitoli() => Sentiero.values
      .map((s) => s.titolo)
      .reduce((a, b) => b.length > a.length ? b : a);

  /// MONTA LA SCHERMATA VERA, non una barra ricostruita a mano.
  ///
  /// **La prima stesura montava `BarraArte` da se' e non le dava il cuore delle
  /// arti preferite**, che nella schermata vera arriva dalla soglia dell'arte e si
  /// prende un pezzo dello spazio a destra: il titolo aveva percio' piu' larghezza
  /// del vero e non scendeva mai, cioe' la prova non misurava il difetto. Si monta
  /// la schermata dalla sua ROTTA, che e' il modo in cui l'app la monta.
  Future<Sentiero> montaIlSentieroPiuLungo(WidgetTester tester) async {
    final quale = Sentiero.values
        .reduce((a, b) => b.titolo.length > a.titolo.length ? b : a);
    tester.view.physicalSize = schermoPiuStretto;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(
            create: (_) => ArtiPreferiteController(maestroAssegnato: quale.maestro)),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MediaQuery(
        data: const MediaQueryData(size: schermoPiuStretto),
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: Builder(builder: (context) {
            return Navigator(
              onGenerateRoute: (_) => SentieroScreen.route(quale),
            );
          }),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return quale;
  }

  testWidgets('nella barra VERA il titolo piu\' lungo non spezza nessuna parola',
      (tester) async {
    final quale = await montaIlSentieroPiuLungo(tester);
    final testo = quale.titolo;
    final reso = tester.widget<Text>(find.text(testo));
    final misura = reso.style!.fontSize!;
    // LA LARGHEZZA VERA, misurata sulla resa e non scritta a mano.
    final larghezza = tester.getSize(find.text(testo)).width;

    // LA PAROLA PIU' LUNGA ENTRA: e' la condizione che impedisce lo spezzo,
    // perche' un motore di testo rompe una parola solo quando da sola non sta in
    // una riga.
    // **SI GUARDA LA SCATOLA, non solo le righe.** La prima stesura misurava
    // soltanto se il testo superava le due righe, e un titolo su UNA riga non le
    // supera mai: intanto dipingeva fuori dalla sua scatola, sopra le azioni.
    // Adesso si confronta l'altezza resa con quella che il testo occuperebbe
    // andando a capo dentro la larghezza che ha.
    final scatola = tester.getSize(find.text(testo));
    final andandoACapo = TextPainter(
      text: TextSpan(text: testo, style: reso.style),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: scatola.width);
    expect(scatola.height, greaterThanOrEqualTo(andandoACapo.height - 0.5),
        reason: 'il titolo occupa ${scatola.height} punti in altezza ma andando '
            'a capo ne vorrebbe ${andandoACapo.height}: non e\' andato a capo, '
            'quindi sta dipingendo fuori dalla sua scatola e passa sopra le '
            'azioni della barra');
    expect(andandoACapo.width, lessThanOrEqualTo(scatola.width + 0.5),
        reason: 'il testo reso e\' piu\' largo della sua scatola: sborda');
    final parolaPiuLunga = testo
        .split(RegExp(r'\s+'))
        .reduce((a, b) => b.length > a.length ? b : a);
    final pittore = TextPainter(
      text: TextSpan(
          text: parolaPiuLunga, style: reso.style),
      textDirection: TextDirection.ltr,
    )..layout();
    expect(pittore.width, lessThanOrEqualTo(larghezza + 0.5),
        reason: '«$parolaPiuLunga» a $misura punti misura '
            '${pittore.width.toStringAsFixed(1)} e il titolo ha '
            '${larghezza.toStringAsFixed(1)} punti nella schermata vera: la '
            'parola viene spezzata a meta\' e il titolo si legge rotto');
  });

  testWidgets('e si legge INTERO, senza puntini e senza sbordare',
      (tester) async {
    final quale = await montaIlSentieroPiuLungo(tester);
    final testo = quale.titolo;
    final reso = tester.widget<Text>(find.text(testo));
    expect(reso.data, testo, reason: 'il testo a schermo non e\' quello del dato');
    expect(reso.overflow, TextOverflow.visible,
        reason: 'il titolo e\' tornato a poter mettere i puntini: un\'ellissi '
            'nasconde il difetto invece di mostrarlo');

    final larghezza = tester.getSize(find.text(testo)).width;
    final pittore = TextPainter(
      text: TextSpan(text: testo, style: reso.style),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: larghezza);
    expect(pittore.didExceedMaxLines, isFalse,
        reason: '«$testo» non sta in due righe da '
            '${larghezza.toStringAsFixed(1)} punti: qualcosa verrebbe tagliato');

    expect(reso.style!.fontSize,
        greaterThanOrEqualTo(TitoloCheNonSiRompe.minimo));
    expect(TitoloCheNonSiRompe.minimo, greaterThan(TypographyTokens.pavimento),
        reason: 'il minimo del titolo e\' scivolato sotto il pavimento');
  });

  test('TUTTE le barre delle arti passano da questo titolo', () {
    // **UNA PORTA SOLA.** Tre schermate avvolgevano il titolo in un `FittedBox`,
    // che lo rimpicciolisce senza fondo per tenerlo su UNA riga: puo' scendere
    // sotto il pavimento tipografico dell'app e non va a capo mai. Un'altra
    // passava un `Text` nudo, che eredita il `softWrap: false` dell'AppBar e
    // dipinge fuori dalla propria scatola. Sono tre modi diversi di rompere lo
    // stesso titolo, e la prova li enumera invece di visitarne uno.
    final colpevoli = <String>[];
    for (final voce in Directory('lib/features').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final righe = voce.readAsStringSync().split('\n');
      for (var i = 0; i < righe.length; i++) {
        if (!righe[i].contains('titolo: ')) continue;
        if (righe[i].contains('TitoloCheNonSiRompe')) continue;
        // Le righe che passano un titolo COME TESTO a un widget che non e' la
        // barra (le sezioni di una scheda, per esempio) non c'entrano.
        if (righe[i].contains("titolo: '")) continue;
        if (righe[i].contains('titolo: Text(') ||
            righe[i].contains('titolo: FittedBox(')) {
          colpevoli.add('${voce.path} riga ${i + 1}');
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'queste barre montano il titolo per conto loro, e ognuna lo '
            'rompe a modo suo: $colpevoli');
  });

  test('quando il minimo non basta si scende al pavimento, non si spezza', () {
    // **IL CASO VERO, e lo ha trovato l'anteprima delle rune.** Con tre azioni a
    // destra (le fonti, il borsellino e il cuore) al titolo restano circa novanta
    // punti: a quattordici la parola "Estrazione" ne chiede novantotto, e il motore
    // di testo faceva l'unica cosa che sa fare, la spezzava. Si leggeva
    // "ESTRAZION / E RUNE".
    //
    // La regola di Mauro ha un ORDINE, e qui i due articoli si scontrano: prima
    // viene "mai dentro una parola", poi "entro un minimo dichiarato". Vince il
    // primo, quindi la misura scende fino al pavimento dell'app.
    final stile = TypographyTokens.titoloScheda();
    final misura = TitoloCheNonSiRompe.misuraChePermetteDiLeggere(
        testo: 'Estrazione Rune', stile: stile, larghezza: 92.7);
    expect(misura, lessThan(TitoloCheNonSiRompe.minimo),
        reason: 'in novantadue punti il titolo resta al minimo preferito, e a '
            'quella misura la parola non entra: si spezza');
    expect(misura, greaterThanOrEqualTo(TitoloCheNonSiRompe.pavimentoAssoluto),
        reason: 'la misura e\' scesa sotto il pavimento tipografico dell\'app');

    // E A QUELLA MISURA LA PAROLA ENTRA DAVVERO, col margine dichiarato: il
    // difetto era che entrava per meno di due punti e si spezzava comunque.
    final pittore = TextPainter(
      text: TextSpan(
          text: 'Estrazione', style: stile.copyWith(fontSize: misura)),
      textDirection: TextDirection.ltr,
    )..layout();
    expect(pittore.width,
        lessThanOrEqualTo(92.7 - TitoloCheNonSiRompe.margineDellaScatola),
        reason: 'la parola piu\' lunga entra per meno del margine dichiarato: '
            'sull\'anteprima si spezza comunque');
  });

  test('la misura scende solo quanto serve', () {
    // **Il rimedio non diventa una tassa fissa.** Con lo spazio che basta il
    // titolo resta al ruolo tipografico: se rimpicciolisse comunque, avremmo
    // pagato tutte le schermate per il caso peggiore di una. Qui la larghezza si
    // puo\' scegliere, perche\' la domanda non e\' "quanto spazio ha nella barra"
    // ma "la funzione scende solo quando serve".
    final stile = TypographyTokens.titoloScheda();
    final larga = TitoloCheNonSiRompe.misuraChePermetteDiLeggere(
        testo: piuLungoDeiTitoli(), stile: stile, larghezza: 360);
    expect(larga, stile.fontSize,
        reason: 'con lo spazio che basta il titolo si rimpicciolisce comunque');
    final stretta = TitoloCheNonSiRompe.misuraChePermetteDiLeggere(
        testo: piuLungoDeiTitoli(), stile: stile, larghezza: 120);
    expect(stretta, lessThan(larga),
        reason: 'in centoventi punti il titolo piu\' lungo NON scende: allora la '
            'funzione non adatta niente');
  });
}

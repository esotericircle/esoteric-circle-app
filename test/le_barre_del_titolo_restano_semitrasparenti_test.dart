// ignore_for_file: avoid_print
import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/account/privacy_policy_screen.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/shell/barra_dell_identita.dart';
import 'package:esoteric_circle/features/synastry/sinastria_evolutiva_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LE BARRE DEL TITOLO RESTANO SEMITRASPARENTI, TUTTE E PER SEMPRE.**
/// Ordine FY voce 20, 16 ottobre 2026.
///
/// Il fondatore, sulla build 2312: *"Quando scorro in alto, la barra del
/// titolo compare solida di botto e non piu' trasparente"*; e poi *"Tutte le
/// barre del titolo di ogni funzionalita' devono restare sempre
/// semitrasparenti, tutte e per sempre"*.
///
/// **Due livelli, perche' ognuno vede cio' che l'altro non vede.**
///
/// 1. **Il sorgente.** Ogni `AppBar(` e `SliverAppBar(` di `lib`, scoperta
///    dalla porta comune dei sorgenti: il fondo non supera mai il velo comune
///    `AppTheme.veloDellaBarra` (un colore senza velo, come `palette.deepest`,
///    vale pieno), e l'elevazione, quella scorsa compresa, e' zero, e la tinta
///    della superficie trasparente. Un fondo che la prova non sa leggere non
///    passa: una barra che non si sa dimostrare semitrasparente non e'
///    semitrasparente. Le eccezioni sono dichiarate qui sotto con la loro
///    ragione, e un'eccezione che non serve piu' fa cadere la prova.
/// 2. **Il colore vero a video.** Si montano schermate vere con un elenco
///    lungo, si scorre, e si legge il `Material` sotto la barra: alfa non
///    sopra il velo comune ed elevazione zero, a riposo e scorsa. Qui si vede
///    il tema, che il sorgente delle barre non nomina: una barra senza fondo
///    dichiarato prende quello del tema, e in Material 3, scorsa, quello di
///    `surfaceContainer`, che e' pieno.
///
/// E una misura del titolo: al velo comune, sul colore piu' chiaro che puo'
/// scorrere sotto, l'oro chiaro e il testo primario hanno almeno 3 di
/// contrasto, il minimo dei titoli grandi. Il titolo si legge per il velo,
/// mai per il pieno.
void main() {
  // ---------------------------------------------------------------------
  // 1. IL SORGENTE
  // ---------------------------------------------------------------------

  /// **LE BARRE CHE QUESTA PROVA SA DI NON POTER ANCORA PRETENDERE.** Stanno
  /// nelle cartelle dove, nello stesso ordine FY, altri applicano questa
  /// stessa regola alle loro schermate (Respiro della Luna, Angeli,
  /// Sinastrie). **Quando la loro correzione entra, la riga va tolta**: una
  /// eccezione che non trova piu' una barra piena fa cadere la prova, perche'
  /// un'eccezione scaduta e' un buco lasciato aperto per il prossimo.
  const eccezioni = <String, String>{};

  test('nessuna barra del titolo di lib e\' piena, ne\' si fa piena scorsa',
      () {
    final barre = barreDiLib();
    // **65 barre contate il 16 ottobre 2026**, meno un margine dichiarato di
    // 15: regge una ripulitura, non tace se il riconoscimento si rompe.
    cardinaleMinimo(barre.length, 50,
        cosa: 'barre del titolo (AppBar e SliverAppBar) in lib',
        perche: 'Se il riconoscimento delle barre si rompe, questa prova '
            'diventa verde senza aver guardato una barra sola.');

    final difetti = <String>[];
    final fileConDifetti = <String>{};
    var piene = 0;
    for (final b in barre) {
      final suoi = difettiDellaBarra(b);
      if (suoi.isEmpty) continue;
      piene++;
      fileConDifetti.add(b.percorso);
      if (eccezioni.containsKey(b.percorso)) continue;
      for (final d in suoi) {
        difetti.add('${b.percorso}:${b.riga}: $d');
      }
    }
    final scadute = [
      for (final e in eccezioni.keys)
        if (!fileConDifetti.contains(e))
          '$e: eccezione scaduta, nessuna barra piena piu\' nel file. Togli '
              'la riga dalle eccezioni.',
    ];
    print('ORDINE FY VOCE 20: barre del titolo guardate ${barre.length}, '
        'piene o non dimostrabili $piene, di cui nelle eccezioni '
        '${fileConDifetti.where(eccezioni.containsKey).length} file; '
        'velo comune ${AppTheme.veloDellaBarra}');
    expect(difetti, isEmpty,
        reason: 'Barre del titolo che diventano piene (il fondatore le vuole '
            'semitrasparenti in ogni stato, ordine FY voce 20):\n'
            '${difetti.join('\n')}');
    expect(scadute, isEmpty, reason: scadute.join('\n'));
  });

  test('il tema spegne il passaggio al pieno di Material 3', () {
    final tema = AppTheme.dark().appBarTheme;
    expect(tema.scrolledUnderElevation, 0,
        reason: 'senza, ogni barra scorsa sale a 3 con ombra e tinta');
    expect(tema.elevation, 0);
    expect(tema.surfaceTintColor, Colors.transparent);
    expect(tema.backgroundColor, isNotNull,
        reason: 'senza un fondo nel tema la barra scorsa prende '
            'surfaceContainer, che e\' pieno');
    expect(tema.backgroundColor!.a, lessThanOrEqualTo(AppTheme.veloDellaBarra));
  });

  test('al velo comune il titolo si legge su cio\' che scorre sotto', () {
    final palette = [
      MaestroPalette.medora,
      MaestroPalette.aura,
      MaestroPalette.caligo,
      MaestroPalette.neutral,
    ];
    final titoli = <String, Color>{
      'oro chiaro': ColorTokens.goldLight,
      'testo primario': ColorTokens.textPrimary,
    };
    final sotto = <String, Color>{
      'bianco': const Color(0xFFFFFFFF),
      'oro piu\' chiaro': ColorTokens.goldBright,
    };
    var peggiore = double.infinity;
    var coppie = 0;
    final sotto3 = <String>[];
    for (final p in palette) {
      for (final s in sotto.entries) {
        final fondo = Color.alphaBlend(
            p.deepest.withValues(alpha: AppTheme.veloDellaBarra), s.value);
        for (final t in titoli.entries) {
          coppie++;
          final c = _contrasto(t.value, fondo);
          peggiore = math.min(peggiore, c);
          if (c < 3) {
            sotto3.add('${t.key} su ${s.key}: ${c.toStringAsFixed(2)}');
          }
        }
      }
    }
    cardinaleMinimo(coppie, 16, cosa: 'coppie di colori misurate');
    print('ORDINE FY VOCE 20: contrasto peggiore del titolo al velo '
        '${AppTheme.veloDellaBarra}: ${peggiore.toStringAsFixed(2)} su '
        '$coppie coppie');
    expect(sotto3, isEmpty, reason: sotto3.join('\n'));
  });

  // ---------------------------------------------------------------------
  // 2. IL COLORE VERO A VIDEO
  // ---------------------------------------------------------------------

  testWidgets('la barra di fabbrica, col solo tema dell\'app, scorsa',
      (tester) async {
    await _schermo(tester);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text('Una barra senza niente')),
        body: ListView(
          key: const Key('elenco'),
          children: [
            for (var i = 0; i < 80; i++)
              ListTile(title: Text('riga $i', style: _bianco)),
          ],
        ),
      ),
    ));
    await _misura(tester, 'barra di fabbrica', find.byKey(const Key('elenco')));
  });

  testWidgets('la pagina legale, scorsa', (tester) async {
    await _schermo(tester);
    await tester.pumpWidget(_conIProvider(const PrivacyPolicyScreen()));
    await tester.pump(const Duration(milliseconds: 300));
    await _misura(
        tester, 'pagina legale', find.byKey(const Key('privacy_policy_lista')));
  });

  testWidgets('l\'oroscopo, scorso', (tester) async {
    await _schermo(tester);
    await tester.pumpWidget(_conIProvider(OroscopoScreen(
        userSign: Zodiac.gemini, now: DateTime(2026, 10, 1, 10, 0))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await _misura(tester, 'oroscopo', find.byKey(const Key('oroscopo_list')),
        barra: find.byKey(const Key('oroscopo_barra')));
  });
}

const _bianco = TextStyle(color: Color(0xFFFFFFFF));

Future<void> _schermo(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _conIProvider(Widget schermata) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: schermata,
      ),
    );

/// Legge il `Material` della barra a riposo e dopo aver scorso l'elenco di
/// 600 punti: alfa del fondo non sopra il velo comune, elevazione zero.
Future<void> _misura(WidgetTester tester, String nome, Finder elenco,
    {Finder? barra}) async {
  final laBarra = barra ?? find.byType(AppBar);
  expect(laBarra, findsOneWidget, reason: '$nome: la barra non c\'e\'');
  Material materiale() => tester.widget<Material>(
      find.descendant(of: laBarra, matching: find.byType(Material)).first);
  double alfa(Material m) =>
      m.type == MaterialType.transparency ? 0 : (m.color?.a ?? 0);

  final aRiposo = materiale();
  await tester.drag(elenco, const Offset(0, -600));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  final scorsa = materiale();
  final posizione = tester.state<ScrollableState>(
      find.descendant(of: elenco, matching: find.byType(Scrollable)).first);
  final spostato = posizione.position.pixels;
  print('ORDINE FY VOCE 20, $nome: alfa a riposo '
      '${alfa(aRiposo).toStringAsFixed(2)} elevazione ${aRiposo.elevation}; '
      'scorsa di ${spostato.toStringAsFixed(0)} punti alfa '
      '${alfa(scorsa).toStringAsFixed(2)} elevazione ${scorsa.elevation}');
  expect(spostato, greaterThan(0),
      reason: '$nome: l\'elenco non e\' scorso, lo stato scorso non e\' '
          'stato guardato');
  for (final (stato, m) in [('a riposo', aRiposo), ('scorsa', scorsa)]) {
    expect(alfa(m), lessThan(1), reason: '$nome, $stato: la barra e\' piena');
    expect(alfa(m), lessThanOrEqualTo(AppTheme.veloDellaBarra),
        reason: '$nome, $stato: la barra supera il velo comune, si legge '
            'piena (ordine FY voce 20)');
    expect(m.elevation, 0,
        reason: '$nome, $stato: la barra prende ombra e tinta della '
            'superficie');
  }
}

double _canale(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
double _luce(Color c) =>
    0.2126 * _canale(c.r) + 0.7152 * _canale(c.g) + 0.0722 * _canale(c.b);
double _contrasto(Color a, Color b) {
  final l1 = _luce(a), l2 = _luce(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

// -------------------------------------------------------------------------
// IL LETTORE DELLE BARRE NEL SORGENTE
// -------------------------------------------------------------------------

typedef Barra = ({
  String percorso,
  int riga,
  Map<String, String> argomenti,
  String sorgente,
});

final _apertura = RegExp(r'(?<![A-Za-z0-9_])(?:Sliver)?AppBar\(');

/// Ogni `AppBar(` e `SliverAppBar(` dei sorgenti di `lib`, senza i commenti,
/// coi suoi argomenti col nome letti al primo livello.
List<Barra> barreDiLib() {
  final barre = <Barra>[];
  for (final f in sorgentiDiLib()) {
    final percorso = f.path.replaceAll('\\', '/');
    final sorgente = senzaCommenti(f.readAsStringSync());
    for (final m in _apertura.allMatches(sorgente)) {
      final fine = _chiusura(sorgente, m.end);
      if (fine < 0) continue;
      barre.add((
        percorso: percorso.substring(percorso.indexOf('lib/')),
        riga: '\n'.allMatches(sorgente.substring(0, m.start)).length + 1,
        argomenti: _argomenti(sorgente.substring(m.end, fine)),
        sorgente: sorgente,
      ));
    }
  }
  return barre;
}

/// L'indice della parentesi che chiude quella aperta prima di [da].
int _chiusura(String s, int da) {
  var profondita = 1;
  var apice = '';
  for (var i = da; i < s.length; i++) {
    final c = s[i];
    if (apice.isNotEmpty) {
      if (c == r'\') {
        i++;
      } else if (c == apice) {
        apice = '';
      }
      continue;
    }
    if (c == "'" || c == '"') {
      apice = c;
    } else if ('([{'.contains(c)) {
      profondita++;
    } else if (')]}'.contains(c)) {
      profondita--;
      if (profondita == 0) return i;
    }
  }
  return -1;
}

/// Gli argomenti col nome, al primo livello, separati dalle virgole fuori da
/// parentesi e stringhe.
Map<String, String> _argomenti(String corpo) {
  final pezzi = <String>[];
  var profondita = 0;
  var apice = '';
  var inizio = 0;
  for (var i = 0; i < corpo.length; i++) {
    final c = corpo[i];
    if (apice.isNotEmpty) {
      if (c == r'\') {
        i++;
      } else if (c == apice) {
        apice = '';
      }
      continue;
    }
    if (c == "'" || c == '"') {
      apice = c;
    } else if ('([{'.contains(c)) {
      profondita++;
    } else if (')]}'.contains(c)) {
      profondita--;
    } else if (c == ',' && profondita == 0) {
      pezzi.add(corpo.substring(inizio, i));
      inizio = i + 1;
    }
  }
  pezzi.add(corpo.substring(inizio));
  final argomenti = <String, String>{};
  for (final p in pezzi) {
    final m = RegExp(r'^\s*(\w+)\s*:\s*([\s\S]*)$').firstMatch(p);
    if (m != null) argomenti[m.group(1)!] = m.group(2)!.trim();
  }
  return argomenti;
}

/// Le costanti di velo che il lettore sa risolvere: quelle che le barre
/// nominano davvero, coi loro valori presi dal codice e non riscritti qui.
final _costanti = <String, double>{
  'AppTheme.veloDellaBarra': AppTheme.veloDellaBarra,
  'BarraDellIdentita.velo': BarraDellIdentita.velo,
  'SinastriaEvolutivaScreen.veloDellaBarra':
      SinastriaEvolutivaScreen.veloDellaBarra,
  'OracoloDegliAngeliScreen.veloDellaBarra':
      OracoloDegliAngeliScreen.veloDellaBarra,
};

/// L'alfa piu' alto che il fondo [espressione] puo' prendere, in qualunque
/// stato; null se non si sa leggere.
double? alfaMassimo(String espressione, String sorgente) {
  final e = espressione.trim();
  if (e == 'Colors.transparent') return 0;
  // Una funzione del file che torna il colore, come `fondo(palette)`.
  final chiamata = RegExp(r'^(\w+)\(\s*[\w.]*\s*\)$').firstMatch(e);
  if (chiamata != null) {
    final corpo = RegExp('Color\\s+${chiamata.group(1)}\\([^)]*\\)\\s*=>'
            r'\s*([^;]+);')
        .firstMatch(sorgente);
    if (corpo == null) return null;
    return alfaMassimo(corpo.group(1)!, sorgente);
  }
  final valori = <double>[];
  for (final m in RegExp(r'Color\(0x([0-9A-Fa-f]{8})\)').allMatches(e)) {
    valori.add(int.parse(m.group(1)!.substring(0, 2), radix: 16) / 255);
  }
  for (final m in RegExp(r'(?:alpha:|withOpacity\()\s*').allMatches(e)) {
    final resto = e.substring(m.end);
    final fine = _fineArgomento(resto);
    final argomento = resto.substring(0, fine);
    final numeri = [
      for (final n
          in RegExp(r'(?<![\w.])\d+(?:\.\d+)?(?![\w.])').allMatches(argomento))
        double.parse(n.group(0)!),
      for (final c in RegExp(r'[A-Z]\w*\.\w+').allMatches(argomento))
        if (_costanti.containsKey(c.group(0)))
          _costanti[c.group(0)]!
        else
          double.nan,
    ];
    if (numeri.isEmpty || numeri.any((n) => n.isNaN)) return null;
    valori.add(numeri.reduce(math.max));
  }
  // Un colore senza velo, come `palette.deepest`, e' pieno.
  if (valori.isEmpty) return 1;
  return valori.reduce(math.max);
}

int _fineArgomento(String s) {
  var profondita = 0;
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if ('([{'.contains(c)) {
      profondita++;
    } else if (')]}'.contains(c)) {
      if (profondita == 0) return i;
      profondita--;
    } else if (c == ',' && profondita == 0) {
      return i;
    }
  }
  return s.length;
}

/// I difetti di una barra: fondo oltre il velo comune o non dimostrabile,
/// elevazione (anche scorsa) diversa da zero, tinta della superficie.
List<String> difettiDellaBarra(Barra b) {
  final difetti = <String>[];
  final fondo = b.argomenti['backgroundColor'];
  if (fondo != null) {
    final a = alfaMassimo(fondo, b.sorgente);
    if (a == null) {
      difetti.add('fondo che la prova non sa dimostrare semitrasparente: '
          '"$fondo"');
    } else if (a > AppTheme.veloDellaBarra) {
      difetti.add('fondo con alfa ${a.toStringAsFixed(2)}, oltre il velo '
          'comune ${AppTheme.veloDellaBarra}: "$fondo"');
    }
  }
  for (final nome in ['elevation', 'scrolledUnderElevation']) {
    final v = b.argomenti[nome];
    if (v != null && double.tryParse(v) != 0) {
      difetti.add('$nome: $v, la barra prende ombra e tinta');
    }
  }
  final tinta = b.argomenti['surfaceTintColor'];
  if (tinta != null && tinta != 'Colors.transparent') {
    difetti.add('surfaceTintColor: $tinta');
  }
  return difetti;
}

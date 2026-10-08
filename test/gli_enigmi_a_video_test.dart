// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/gli_enigmi_del_cerchio.dart';
import 'package:esoteric_circle/core/cerchio/i_tempi_dei_giochi.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/il_ritratto.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/enigmi/gli_enigmi_screen.dart';
import 'package:esoteric_circle/features/cerchio/enigmi/il_ritratto_screen.dart';
import 'package:esoteric_circle/features/cerchio/enigmi/l_indovinello_screen.dart';
import 'package:esoteric_circle/features/cerchio/enigmi/la_prova_screen.dart';
import 'package:esoteric_circle/features/cerchio/profilo_nel_cerchio_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'gli_enigmi_finti.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **GLI ENIGMI DEL CERCHIO A VIDEO.** Ordine FF, 8 ottobre 2026: le prove
/// delle schermate (voci FF.02.6 a e c, FF.04.6 e, FF.06.5 c, FF.07.3 a) e
/// le nove anteprime a 360x797 punti logici della consegna, scritte in
/// `docs/preview/FF/` con `AGGIORNA_ANTEPRIME=1`.
///
/// **IL TEMPO CHE RESTA SI CONFRONTA COL CALCOLO**, non con una cifra
/// scritta a mano: il 25 ottobre 2026 si torna all'ora solare, e sul
/// calcolatore del fondatore da martedi' 20 alle 9 a lunedi' 26 restano 5
/// giorni e 16 ore, sul cancello di GitHub (in UTC) 5 e 15.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();

  /// I sensori del movimento non esistono nelle prove: lo sfondo li chiede,
  /// e qui rispondono a vuoto (lo stesso delle anteprime del Cerchio).
  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  final aggiorna = Platform.environment['AGGIORNA_ANTEPRIME'] == '1';
  final adesso = DateTime(2026, 10, 22, 18);

  void misura(WidgetTester tester) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
  }

  Future<void> passa(WidgetTester tester, [int volte = 8]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Scorre la pagina finche' [cosa] non si vede: le liste costruiscono solo
  /// cio' che sta vicino allo schermo.
  Future<void> finoA(WidgetTester tester, Finder cosa) async {
    await tester.scrollUntilVisible(cosa, 150,
        scrollable: find.byType(Scrollable).first);
    await passa(tester, 2);
  }

  String resta(DateTime fine, [DateTime? da]) =>
      ilTempoCheResta(ITempiDeiGiochi.resta(fine, da ?? adesso));

  Future<void> scatta(WidgetTester tester, String nome) async {
    if (!aggiorna) return;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FF');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/$nome.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('ORDINE FF ANTEPRIMA: ${dir.path}/$nome.png '
          '${img.width ~/ 3}x${img.height ~/ 3} punti');
      img.dispose();
    });
  }

  Future<void> scattaIn(
      WidgetTester tester, String cartella, String nome) async {
    if (!aggiorna) return;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory(cartella);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/$nome.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print('ORDINE FF ANTEPRIMA: ${dir.path}/$nome.png');
      img.dispose();
    });
  }

  Future<PortaFintaDelCerchioSociale> monta(WidgetTester tester, Widget s,
      {PortaFintaDelCerchioSociale? porta}) async {
    silenzia();
    misura(tester);
    final finta = porta ?? PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
    });
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          builder: (c, figlio) => MediaQuery(
            data: MediaQuery.of(c).copyWith(disableAnimations: true),
            child: MaestroScope(neutro: true, child: figlio!),
          ),
          // Una chiave nuova a ogni montatura: la stessa schermata montata
          // due volte nella stessa prova ripartirebbe dallo stato di prima.
          home: KeyedSubtree(key: UniqueKey(), child: s),
        ),
      ),
    ));
    await passa(tester);
    // Le icone dei volti si caricano prima della cattura: senza, la prima
    // anteprima mostra le iniziali e la seconda le figure.
    await tester.runAsync(() async {
      final ctx = radice.currentContext!;
      for (final f in FamigliaDelleIcone.values) {
        for (final i in IconaDelProfilo.di(f)) {
          await precacheImage(AssetImage(i.asset), ctx);
        }
      }
    });
    await passa(tester, 3);
    return finta;
  }

  GliEnigmiScreen laPagina({bool provaFatta = false}) => GliEnigmiScreen(
      vista: VistaDegliEnigmi.da(
          GliEnigmiFinti.vista(provaFatta: provaFatta, adesso: adesso)),
      adesso: adesso);

  final otto = IlRitratto.proposteDallaCarta(
      sole: Zodiac.taurus,
      luna: Zodiac.cancer,
      ascendente: Zodiac.libra,
      giornoDiNascita: 12);

  testWidgets('FF.02 c) il Ritratto non si chiude con meno di venti',
      (t) async {
    await monta(t, IlRitrattoScreen(tratti: [...otto], proposte: otto));
    expect(
        find.text('Otto le abbiamo segnate dalla tua carta natale: puoi '
            'cambiarle tutte.'),
        findsOneWidget);
    await scatta(t, '01_ritratto_otto_piene');
    FilledButton pulsante() => t.widget<FilledButton>(find.descendant(
        of: find.byKey(const Key('ritratto_chiudi')),
        matching: find.byType(FilledButton)));
    expect(pulsante().onPressed, isNull);
    // Si scelgono le altre dodici, l'una dopo l'altra.
    var scelte = 8;
    for (final tr in IlRitratto.tutti) {
      if (scelte == 20) break;
      if (otto.contains(tr.numero)) continue;
      final k = find.byKey(Key('tratto_${tr.numero}'));
      await finoA(t, k);
      await t.tap(k);
      await t.pump();
      scelte++;
      expect(pulsante().onPressed, scelte == 20 ? isNotNull : isNull,
          reason: 'con $scelte caratteristiche');
    }
    expect(find.textContaining('Hai scelto le tue venti'), findsOneWidget);
  });

  testWidgets('FF.02 il Ritratto completo, visto da chi lo possiede',
      (t) async {
    final venti = [...otto];
    for (final tr in IlRitratto.tutti) {
      if (venti.length == 20) break;
      if (!venti.contains(tr.numero)) venti.add(tr.numero);
    }
    await monta(t, IlRitrattoScreen(tratti: venti, proposte: otto));
    expect(find.textContaining('Hai scelto le tue venti'), findsOneWidget);
    await scatta(t, '02_ritratto_completo');
  });

  testWidgets(
      'FF.02 a) senza Ritratto nessun gioco si apre e compare l\'invito',
      (t) async {
    await monta(
        t,
        GliEnigmiScreen(
            vista: VistaDegliEnigmi.da(
                GliEnigmiFinti.vista(ritrattoCompilato: false, adesso: adesso)),
            adesso: adesso));
    expect(find.byKey(const Key('enigmi_compila_ritratto')), findsOneWidget);
    for (final k in ['enigmi_gioca', 'enigmi_fai_la_prova']) {
      await finoA(t, find.byKey(Key(k)));
      final p = t.widget<FilledButton>(find.descendant(
          of: find.byKey(Key(k)), matching: find.byType(FilledButton)));
      expect(p.onPressed, isNull, reason: '$k si apre senza Ritratto');
    }
    // E la porta dell'indovinello, senza Ritratto, rimanda al Ritratto.
    await monta(t, const LIndovinelloScreen());
    await passa(t);
    expect(find.textContaining('Prima di giocare compila il tuo Ritratto'),
        findsOneWidget);
    expect(find.byKey(const Key('indovinello_al_ritratto')), findsOneWidget);
  });

  testWidgets('FF.04 l\'indovinello coi quattro volti, poi con due indizi',
      (t) async {
    await monta(
        t,
        LIndovinelloScreen(
            partita: PartitaDellEnigma.da(GliEnigmiFinti.partita())));
    expect(find.text('Chi di loro dice: «Perdo le chiavi ogni settimana»?'),
        findsOneWidget);
    for (final f in GliEnigmiFinti.facce) {
      expect(find.byKey(Key('indovinello_volto_${f['uid']}')), findsOneWidget);
    }
    expect(find.textContaining('il primo è gratis'), findsOneWidget);
    await scatta(t, '03_indovinello_quattro_volti');

    await monta(
        t,
        LIndovinelloScreen(
            partita: PartitaDellEnigma.da(
                GliEnigmiFinti.partita(indizi: GliEnigmiFinti.dueIndizi))));
    expect(
        find.text('1. Il suo Sole sta in un segno di aria.'), findsOneWidget);
    expect(
        find.text('2. «Rispondo ai messaggi dopo due giorni e poi mi scuso»'),
        findsOneWidget);
    expect(find.text('Se indovini adesso prendi un punto.'), findsOneWidget);
    expect(find.textContaining('5 Eos'), findsOneWidget);
    await scatta(t, '04_indovinello_dopo_due_indizi');
  });

  testWidgets(
      'FF.04 e) il quarto indovinello oltre il limite si rifiuta con garbo',
      (t) async {
    await monta(t, const LIndovinelloScreen(), porta: _PortaAlLimite());
    await passa(t);
    expect(
        find.text('Hai giocato gli indovinelli di oggi. Domani ne arrivano '
            'altri.'),
        findsOneWidget);
  });

  testWidgets(
      'FF.04.3 il ritorno a chi e\' stato indovinato: il numero, mai il nome',
      (t) async {
    await monta(t, laPagina());
    final mago = find.text('2 persone hanno capito che sei il Mago.');
    await finoA(t, mago);
    expect(mago, findsOneWidget);
    expect(
        find.text('Una persona ha capito che dici «Perdo le chiavi ogni '
            'settimana».'),
        findsOneWidget);
    expect(find.text('Segni scoperti: Leone.'), findsOneWidget);
    await scatta(t, '05_il_ritorno_a_chi_e_indovinato');
  });

  testWidgets('FF.07 a) ogni gioco aperto mostra il tempo che resta',
      (t) async {
    await monta(t, laPagina());
    // La Prova finisce lunedi' 26 a mezzanotte, la sfida fra diciassette
    // ore, il Pellegrinaggio col giorno della luna piena del 26.
    final prova = 'Finisce fra ${resta(DateTime(2026, 10, 26))}.';
    await finoA(t, find.text(prova));
    expect(find.text(prova), findsOneWidget);
    final sfida = 'La tua sfida con Selene: restano '
        '${resta(adesso.add(const Duration(hours: 17)))}.';
    await finoA(t, find.text(sfida));
    expect(find.text(sfida), findsOneWidget);
    await scatta(t, '09_sfida_aperta_col_tempo');
    final pelle = 'Verso la luna piena del 26 ottobre: 10 passi di 20. '
        'Finisce fra ${resta(DateTime(2026, 10, 27))}.';
    await finoA(t, find.text(pelle));
    expect(find.text(pelle), findsOneWidget);
    print('ORDINE FF VOCE 07: "$prova" "$sfida" "$pelle"');
    await finoA(t, find.byKey(const Key('enigmi_barra_pellegrinaggio')));
    await scatta(t, '08_pellegrinaggio_a_meta');
  });

  testWidgets(
      'FF.06 c) la barra del Pellegrinaggio mostra il passo di ciascuno',
      (t) async {
    await monta(t, laPagina());
    final barra = find.byKey(const Key('enigmi_barra_pellegrinaggio'));
    await finoA(t, barra);
    final pezzi = t
        .widgetList<Expanded>(
            find.descendant(of: barra, matching: find.byType(Expanded)))
        .map((e) => e.flex)
        .toList();
    print('ORDINE FF VOCE 06: la barra del Pellegrinaggio, pezzi $pezzi');
    // Lunaria 4, Stella 3, Orione 2, Selene 1, poi i dieci che mancano.
    expect(pezzi, [4, 3, 2, 1, 10]);
  });

  testWidgets('FF.05 la Prova della settimana e la scommessa', (t) async {
    final martedi = DateTime(2026, 10, 20, 9);
    await monta(t, LaProvaScreen(adesso: martedi));
    expect(find.byKey(const Key('prova_tema')), findsOneWidget);
    expect(find.text('Finisce fra ${resta(DateTime(2026, 10, 26), martedi)}.'),
        findsOneWidget);
    expect(find.text('Domanda 1 di 10'.toUpperCase()), findsOneWidget);
    await scatta(t, '06_la_prova_della_settimana');

    await monta(t, laPagina(provaFatta: true));
    final scommetti = find.byKey(const Key('enigmi_scommetti_u-selene'));
    await finoA(t, scommetti);
    await t.tap(scommetti);
    await passa(t);
    expect(find.text('Quanto farà Selene?'), findsOneWidget);
    await scatta(t, '07_la_scommessa_su_un_amico');
  });

  testWidgets('FF.02.5 il Ritratto si cambia dal profilo, quando si vuole',
      (t) async {
    final porta = PortaFintaDelCerchioSociale();
    await monta(t, const ProfiloNelCerchioScreen(), porta: porta);
    await t.runAsync(() async => Future<void>.delayed(Duration.zero));
    await passa(t);
    final apri = find.byKey(const Key('profilo_ritratto'));
    await finoA(t, apri);
    await t.tap(apri);
    await passa(t, 12);
    expect(find.byType(IlRitrattoScreen), findsOneWidget);
  });

  testWidgets(
      'FF.02 senza la porta pubblicata il Ritratto non mostra un codice',
      (t) async {
    // Visto sul Realme l'8 ottobre 2026 col pacchetto locale: la porta
    // ilMioRitratto non ancora pubblicata rispondeva "NOT_FOUND", e il
    // Ritratto lo scriveva sotto il testo.
    await monta(t, const IlRitrattoScreen(), porta: _PortaNonPubblicata());
    await t.runAsync(() async => Future<void>.delayed(Duration.zero));
    await passa(t);
    expect(find.text('NOT_FOUND'), findsNothing);
    expect(
        find.textContaining('Il Cerchio non risponde adesso'), findsOneWidget);
  });

  // FF aggiunta 1 voce A11, le catture del genere: lo stesso tratto marcato
  // (il 29, "Sono [quello|quella|la persona] che fa ridere") a una donna, a
  // un uomo, e uscito come indizio su un'altra persona, nel neutro. Sul
  // Realme il genere si dichiara solo nell'onboarding, e rifarlo
  // cancellerebbe i dati del telefono di collaudo: le due forme dichiarate
  // si mostrano qui, a 360x797, in docs/collaudo/FF/genere/.
  for (final (forma, nome, attesa) in [
    (
      CourtesyForm.feminine,
      '04_il_tratto_a_una_donna',
      'Sono quella che fa ridere quando la situazione è tesa.'
    ),
    (
      CourtesyForm.masculine,
      '05_il_tratto_a_un_uomo',
      'Sono quello che fa ridere quando la situazione è tesa.'
    ),
  ]) {
    testWidgets('FF.A11 $nome', (t) async {
      LaMarcaDelGenere.formaCorrente = forma;
      addTearDown(() => LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown);
      await monta(t,
          const IlRitrattoScreen(tratti: [29, 21, 30, 37, 75], proposte: []));
      expect(find.text(attesa), findsOneWidget);
      await scattaIn(t, 'docs/collaudo/FF/genere', nome);
    });
  }

  testWidgets('FF.A11 06 lo stesso tratto come indizio, nel neutro', (t) async {
    LaMarcaDelGenere.formaCorrente = CourtesyForm.masculine;
    addTearDown(() => LaMarcaDelGenere.formaCorrente = CourtesyForm.unknown);
    await monta(
        t,
        LIndovinelloScreen(
            partita: PartitaDellEnigma.da(GliEnigmiFinti.partita(indizi: const [
          {'fonte': 'ritratto', 'valore': '29'},
        ]))));
    expect(
        find.text('1. «Sono la persona che fa ridere quando la situazione è '
            'tesa»'),
        findsOneWidget);
    await scattaIn(t, 'docs/collaudo/FF/genere', '06_il_tratto_come_indizio');
  });
}

/// La porta al limite: il quarto indovinello del giorno del Viandante.
class _PortaAlLimite extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'unIndovinello') {
      return const EsitoSociale(
          dati: {'ok': false, 'perche': 'limite', 'limite': 3});
    }
    return super.sociale(porta, corpo);
  }
}

/// La porta del Ritratto non ancora pubblicata: risponde col codice grezzo.
class _PortaNonPubblicata extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'ilMioRitratto') {
      return const EsitoSociale(
          dati: {}, errore: 'not-found', riga: 'NOT_FOUND');
    }
    return super.sociale(porta, corpo);
  }
}

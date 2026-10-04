// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:esoteric_circle/features/amici/gli_amici_online.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/invita_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/la_tendina_del_cerchio.dart';
import 'package:esoteric_circle/features/cerchio/scheda_dell_amico_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **GLI AMICI ONLINE NELLA RUBRICA. Ordine FC voce 09, 4 ottobre 2026.**
///
/// **LAPIDE.** La prima forma della voce era una riga in cima alla rubrica
/// che portava al Cerchio, e questa prova pretendeva che la rubrica non
/// chiamasse mai la tendina. Il fondatore, la stessa sera: *"anziche' aprire
/// una nuova schermata per gli amici online, sarebbe meglio inserire 2
/// pulsanti: a sinistra offline e a destra online con a fianco il numero di
/// amici online e un cerchietto verde. Di default e' selezionato il pulsante
/// offline [...] se clicca su online compaiono gli amici online."* Il numero
/// e l'elenco vogliono la tendina: adesso la prova pretende **al piu' una
/// chiamata per apertura**, e nessuna quando la tendina e' fresca o quando
/// nel Cerchio non c'e' nessuno. Il costo, coi numeri, sta in
/// `lib/features/amici/gli_amici_online.dart`.
void main() {
  Future<(PortaFintaDelCerchioSociale, IlCerchioSociale)> unCerchio(
      WidgetTester tester,
      {required bool conAmici,
      bool conLaTendina = false,
      PortaFintaDelCerchioSociale? porta}) async {
    final finta = porta ?? PortaFintaDelCerchioSociale(amici: conAmici);
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
      await sociale.caricaIlCerchio();
      if (conLaTendina) await sociale.caricaLaTendina();
    });
    return (finta, sociale);
  }

  Future<void> monta(WidgetTester tester, PortaFintaDelCerchioSociale finta,
      IlCerchioSociale sociale,
      {DateTime? adesso}) async {
    SharedPreferences.setMockInitialValues({});
    // Ogni montaggio da capo: il Navigator di prima non resta.
    await tester.pumpWidget(const SizedBox());
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final amici = AmiciOffline();
    await tester.runAsync(amici.carica);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier3)),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (c, figlio) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: MaestroScope(neutro: true, child: figlio!),
        ),
        home: AmiciScreen(amici: amici, adesso: adesso),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  int tendine(PortaFintaDelCerchioSociale f) =>
      f.chieste.where((c) => c.$1 == 'laTendinaDelCerchio').length;

  String? numero(WidgetTester tester) {
    final f = find.byKey(const Key('amici_online_quanti'));
    return f.evaluate().isEmpty ? null : tester.widget<Text>(f).data;
  }

  Future<void> tocca(WidgetTester tester, Key chiave) async {
    await tester.ensureVisible(find.byKey(chiave));
    await tester.tap(find.byKey(chiave));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets(
      'FC.09: due pulsanti, Offline di default; il numero accanto a Online '
      'con al piu\' una chiamata per apertura', (tester) async {
    final misure = <String, String>{};

    // 1. La tendina appena arrivata: si riusa, nessuna chiamata.
    var (finta, sociale) =
        await unCerchio(tester, conAmici: true, conLaTendina: true);
    var prima = finta.chieste.length;
    await monta(tester, finta, sociale);
    misure['tendina fresca'] = 'chiamate ${finta.chieste.length - prima}, '
        'numero ${numero(tester)}';
    expect(finta.chieste.length - prima, 0);
    expect(numero(tester), '1');

    // Di default Offline: gli amici scritti dalla persona, non l'elenco online.
    expect(find.byKey(const Key('amici_offline')), findsOneWidget);
    expect(find.byKey(const Key('amici_online')), findsOneWidget);
    expect(find.byKey(const Key('amici_aggiungi')), findsOneWidget);
    expect(find.byKey(const Key('amici_elenco_online')), findsNothing);
    expect(find.text('Stella Lieve'), findsNothing,
        reason: 'di default la rubrica non mostra gli amici online');

    // 2. Nessuna tendina in questa sessione: una chiamata, e il numero.
    (finta, sociale) = await unCerchio(tester, conAmici: true);
    var t0 = tendine(finta);
    prima = finta.chieste.length;
    await monta(tester, finta, sociale);
    misure['senza tendina'] = 'chiamate ${finta.chieste.length - prima}, '
        'numero ${numero(tester)}';
    expect(tendine(finta) - t0, 1);
    expect(finta.chieste.length - prima, 1,
        reason: 'all\'apertura la sola chiamata e\' la tendina');
    expect(numero(tester), '1');

    // 2b. Riaperta subito dopo: la tendina e' fresca, nessuna chiamata. E'
    // cio' che tiene la rubrica lontana dal tetto di trenta l'ora.
    t0 = tendine(finta);
    await monta(tester, finta, sociale);
    misure['riaperta subito'] = 'chiamate ${tendine(finta) - t0}';
    expect(tendine(finta) - t0, 0);
    expect(numero(tester), '1');

    // 3. La tendina vecchia di due minuti: si richiede, una volta.
    (finta, sociale) =
        await unCerchio(tester, conAmici: true, conLaTendina: true);
    t0 = tendine(finta);
    await monta(tester, finta, sociale,
        adesso: sociale.tendinaArrivata!.add(const Duration(minutes: 2)));
    misure['tendina vecchia'] = 'chiamate ${tendine(finta) - t0}, '
        'numero ${numero(tester)}';
    expect(tendine(finta) - t0, 1);
    expect(numero(tester), '1');

    // 4. Nessun amico nel Cerchio: zero, ed e' vero; nessuna chiamata.
    (finta, sociale) = await unCerchio(tester, conAmici: false);
    prima = finta.chieste.length;
    await monta(tester, finta, sociale);
    misure['nessun amico nel Cerchio'] =
        'chiamate ${finta.chieste.length - prima}, numero ${numero(tester)}';
    expect(finta.chieste.length - prima, 0);
    expect(numero(tester), '0');

    // 5. Il Cerchio non risponde: nessun numero inventato.
    (finta, sociale) =
        await unCerchio(tester, conAmici: true, porta: _PortaSenzaTendina());
    await monta(tester, finta, sociale);
    misure['il Cerchio non risponde'] = 'numero ${numero(tester)}';
    expect(numero(tester), isNull,
        reason: 'senza la tendina accanto a Online non va un numero');

    print('ORDINE FC VOCE 09: la rubrica all\'apertura: $misure');
  });

  testWidgets('FC.09: Online mostra gli amici online, Offline li nasconde',
      (tester) async {
    final (finta, sociale) =
        await unCerchio(tester, conAmici: true, conLaTendina: true);
    await monta(tester, finta, sociale);
    await tocca(tester, const Key('amici_online'));
    expect(find.byKey(const Key('amici_elenco_online')), findsOneWidget);
    expect(find.text('Stella Lieve'), findsOneWidget);
    // Il sottotitolo del fondatore, carattere per carattere.
    expect(
        tester
            .widget<Text>(find.byKey(const Key('amici_online_sottotitolo')))
            .data,
        'Chi del tuo Cerchio è qui con te, adesso.');
    // **L'ICONA DEL MEMBRO ARRIVA ALLA RIGA**: l'immagine nel tondo di
    // Stella e' la sua icona del Cerchio ('animale:6' nella tendina), non un
    // tondo vuoto. Il cerchio nero della prima anteprima era la cattura
    // scattata prima che l'immagine fosse caricata, non la riga.
    final immagine = tester.widget<Image>(find.descendant(
        of: find.byKey(const Key('persona_u-stella')),
        matching: find.byKey(const Key('icona_tonda_immagine'))));
    final percorso = (immagine.image as AssetImage).assetName;
    expect(percorso, IconaDelProfilo.da('animale:6').asset);
    print('ORDINE FC VOCE 09: l\'icona di Stella nella riga Online: $percorso');
    // Nessuna ora dell'ultimo dato: questo e' di adesso.
    expect(find.byKey(const Key('amici_online_ultimo_dato')), findsNothing);
    expect(find.byKey(const Key('amici_aggiungi')), findsNothing,
        reason: 'su Online gli amici scritti dalla persona non si vedono');
    await tocca(tester, const Key('amici_offline'));
    expect(find.byKey(const Key('amici_elenco_online')), findsNothing);
    expect(find.text('Stella Lieve'), findsNothing);
    expect(find.byKey(const Key('amici_aggiungi')), findsOneWidget);

    // Il tocco su un amico online apre la sua scheda, come dalla tendina.
    await tocca(tester, const Key('amici_online'));
    await tocca(tester, const Key('persona_u-stella'));
    expect(find.byType(SchedaDellAmicoScreen), findsOneWidget);
    print('ORDINE FC VOCE 09: Online mostra Stella Lieve, Offline la '
        'nasconde, il tocco apre la sua scheda');
  });

  testWidgets('FC.09: le strade dall\'elenco Online', (tester) async {
    var (finta, sociale) =
        await unCerchio(tester, conAmici: true, conLaTendina: true);
    await monta(tester, finta, sociale);
    await tocca(tester, const Key('amici_online'));
    await tocca(tester, const Key('amici_online_al_cerchio'));
    expect(find.byType(IlTuoCerchioScreen), findsOneWidget);

    (finta, sociale) = await unCerchio(tester, conAmici: false);
    await monta(tester, finta, sociale);
    await tocca(tester, const Key('amici_online'));
    expect(find.byKey(const Key('amici_online_nessuno_nel_cerchio')),
        findsOneWidget);
    // Il testo del Cerchio vuoto resta quello di prima.
    expect(find.text('Il tuo Cerchio è ancora da chiamare.'), findsOneWidget);
    await tocca(tester, const Key('amici_online_invita'));
    expect(find.byType(InvitaNelCerchioScreen), findsOneWidget);

    // Il Cerchio non risponde: la riga del perche', e Riprova richiama.
    (finta, sociale) =
        await unCerchio(tester, conAmici: true, porta: _PortaSenzaTendina());
    await monta(tester, finta, sociale);
    await tocca(tester, const Key('amici_online'));
    expect(find.byKey(const Key('amici_online_silenzio')), findsOneWidget);
    // Il testo del fondatore, carattere per carattere, quando non c'e' un
    // ultimo dato noto.
    expect(
        tester
            .widget<Text>(find.byKey(const Key('amici_online_silenzio')))
            .data,
        'Il Cerchio non risponde in questo momento. Riprova fra poco.');
    final t0 = tendine(finta);
    await tocca(tester, const Key('amici_online_riprova'));
    expect(tendine(finta) - t0, 1);
    print('ORDINE FC VOCE 09: Il tuo Cerchio, l\'invito e Riprova portano '
        'dove dicono');
  });

  testWidgets(
      'FC.09: il tetto condiviso fra tendina e rubrica restituisce l\'ultimo '
      'dato noto con la sua ora, e non l\'errore', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = _PortaColTetto(concesse: 1);
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
      await sociale.caricaIlCerchio();
    });
    final amici = AmiciOffline();
    await tester.runAsync(amici.carica);
    DateTime? adessoDellaRubrica;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier3)),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (c, figlio) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: MaestroScope(neutro: true, child: figlio!),
        ),
        home: Builder(
            builder: (c) => Scaffold(
                    body: Column(children: [
                  TextButton(
                      onPressed: () => apriLaTendinaDelCerchio(c),
                      child: const Text('tendina')),
                  TextButton(
                      onPressed: () => Navigator.of(c).push(MaterialPageRoute(
                          builder: (_) => AmiciScreen(
                              amici: amici, adesso: adessoDellaRubrica))),
                      child: const Text('rubrica')),
                ]))),
      ),
    ));
    Future<void> passa() async {
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    void chiudi(Finder dentro) {
      Navigator.of(tester.element(dentro)).pop();
    }

    final guasti = [
      IlCerchioSociale.rigaDellaTendinaCheNonArriva,
      _PortaColTetto.rigaDelTetto,
    ];
    int guastiAVideo() => guasti
        .map((g) => find.textContaining(g).evaluate().length)
        .fold(0, (a, b) => a + b);

    // 1. La tendina si apre e arriva: e' la sola chiamata concessa.
    await tester.tap(find.text('tendina'));
    await passa();
    expect(find.text('Stella Lieve'), findsOneWidget);
    final presa = sociale.tendinaArrivata!;
    final ora = IlCerchioSociale.rigaDellUltimoDato(presa);
    chiudi(find.byKey(const Key('la_tendina_del_cerchio')));
    await passa();

    // 2. Due minuti dopo la rubrica: la tendina e' vecchia, la chiede, e il
    // tetto e' raggiunto. Mostra l'ultimo dato noto con la sua ora.
    adessoDellaRubrica = presa.add(const Duration(minutes: 2));
    await tester.tap(find.text('rubrica'));
    await passa();
    expect(numero(tester), '1',
        reason: 'col tetto raggiunto il numero e\' quello dell\'ultimo dato');
    await tocca(tester, const Key('amici_online'));
    expect(find.text('Stella Lieve'), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('amici_online_ultimo_dato')))
            .data,
        ora);
    final guastiNellaRubrica = guastiAVideo();
    expect(guastiNellaRubrica, 0, reason: 'la rubrica mostra un guasto');
    chiudi(find.byKey(const Key('amici_lista')));
    await passa();

    // 3. Di nuovo la tendina: anche lei trova il tetto, e mostra l'ultimo
    // dato noto con la sua ora.
    await tester.tap(find.text('tendina'));
    await passa();
    expect(find.text('Stella Lieve'), findsOneWidget);
    expect(
        tester.widget<Text>(find.byKey(const Key('tendina_ultimo_dato'))).data,
        ora);
    final guastiNellaTendina = guastiAVideo();
    expect(guastiNellaTendina, 0, reason: 'la tendina mostra un guasto');
    chiudi(find.byKey(const Key('la_tendina_del_cerchio')));
    await passa();

    // 4. Il tetto e' uno: le due schermate bussano alla stessa porta, e sul
    // server quella porta ha un tetto solo.
    final allaPorta = tendine(finta);
    expect(allaPorta, 3);
    final tetti = File('functions/src/sociale.ts').readAsStringSync();
    final tettoDellaTendina =
        RegExp(r'laTendinaDelCerchio:\s*\{quante:\s*(\d+)')
            .allMatches(tetti)
            .map((m) => m.group(1))
            .toList();
    expect(tettoDellaTendina, ['30']);
    final chiamanti = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is File &&
          f.path.endsWith('.dart') &&
          f.readAsStringSync().contains("'laTendinaDelCerchio'")) {
        chiamanti.add(f.path.replaceAll(r'\', '/'));
      }
    }
    expect(chiamanti, ['lib/core/cerchio/il_cerchio_sociale.dart']);

    // 5. L'app riaperta dentro l'ora del tetto: un Cerchio sociale nuovo,
    // la tendina in memoria non c'e' piu', e la rubrica rilegge l'ultima dal
    // telefono, con la sua ora.
    final dopo = _PortaColTetto(concesse: 0);
    final riaperto = IlCerchioSociale(porta: dopo);
    await tester.runAsync(() async {
      await riaperto.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
      await riaperto.caricaIlCerchio();
    });
    expect(riaperto.tendina, isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: riaperto),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier3)),
        Provider<AppServices>.value(value: AppServices.offline(null, dopo)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (c, figlio) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: MaestroScope(neutro: true, child: figlio!),
        ),
        home: AmiciScreen(amici: amici),
      ),
    ));
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await passa();
    await tocca(tester, const Key('amici_online'));
    expect(find.text('Stella Lieve'), findsOneWidget);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('amici_online_ultimo_dato')))
            .data,
        ora);
    final guastiDopoLaRiapertura = guastiAVideo();
    expect(guastiDopoLaRiapertura, 0);

    print('ORDINE FC VOCE 09: il tetto condiviso: chiamate alla porta della '
        'tendina $allaPorta (tendina, rubrica, tendina), tetto sul server '
        '$tettoDellaTendina, chiamanti nel telefono $chiamanti; guasti a '
        'video col tetto raggiunto: rubrica $guastiNellaRubrica, tendina '
        '$guastiNellaTendina, rubrica dopo la riapertura '
        '$guastiDopoLaRiapertura; ultimo dato mostrato con "$ora"');
  });

  test('FC.09: la freschezza e\' un minuto, scritta in un posto solo', () {
    expect(GliAmiciOnline.freschezzaDellaTendina, const Duration(minutes: 1));
  });
}

/// Una porta che risponde a tutto tranne alla tendina: il Cerchio che non
/// risponde, come senza rete.
class _PortaSenzaTendina extends PortaFintaDelCerchioSociale {
  _PortaSenzaTendina() : super(amici: true);

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'laTendinaDelCerchio') {
      chieste.add((porta, corpo));
      throw StateError('la tendina non risponde');
    }
    return super.sociale(porta, corpo);
  }
}

/// Una porta col tetto della tendina: concede [concesse] chiamate, poi
/// risponde come il server col tetto raggiunto (`resource-exhausted`, con la
/// riga di `rigaDelTetto` in `functions/src/sociale.ts`).
class _PortaColTetto extends PortaFintaDelCerchioSociale {
  _PortaColTetto({required this.concesse}) : super(amici: true);

  final int concesse;
  int _date = 0;

  static const String rigaDelTetto =
      'Hai bussato molte volte: riprova fra un minuto.';

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'laTendinaDelCerchio' && _date >= concesse) {
      chieste.add((porta, corpo));
      return const EsitoSociale(
          dati: {}, errore: 'resource-exhausted', riga: rigaDelTetto);
    }
    if (porta == 'laTendinaDelCerchio') _date++;
    return super.sociale(porta, corpo);
  }
}

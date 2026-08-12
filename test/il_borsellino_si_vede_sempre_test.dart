import 'dart:io';

import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/registro_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/components/borsellino.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL BORSELLINO E' SEMPRE VISIBILE. Ordine S voce 06.
///
/// **Il difetto.** Il saldo esisteva in UNA schermata, il sentiero dei Sigilli,
/// ed era disegnato dentro di essa: da ogni altra parte gli Eos non c'erano. Un
/// numero che appare e scompare non si impara, e chi non lo vede non sa nemmeno
/// di averne.
///
/// **PERCHE' QUESTA PROVA ENUMERA.** Visitare una schermata e trovarci il
/// borsellino non dice niente sulle altre ventotto: la domanda della voce e'
/// "in tutte quelle in cui ha senso", quindi la prova percorre le schermate con
/// una barra e pretende che ognuna stia in UNA delle due liste, quella che il
/// borsellino ce l'ha e quella delle esenzioni DICHIARATE. Una schermata nuova
/// non puo' passare in silenzio: cade col suo nome.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// LE SCHERMATE DELLA PRATICA: qui si guadagnano o si spendono Eos, quindi il
  /// borsellino ci sta.
  const conBorsellino = <String>[
    // Passano dalla barra unica delle arti, che monta il segno da se'.
    'lib/features/maestri/rotta_arte.dart',
    'lib/features/sigilli/sentiero_screen.dart',
    'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
    'lib/features/maestri/aura/face/face_constellation_screen.dart',
    'lib/features/maestri/caligo/animal/guide_animal_screen.dart',
    'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
    // Hanno una AppBar propria, e il segno e' lo stesso widget.
    'lib/features/angels/angels_screen.dart',
    'lib/features/horoscope/oroscopo_screen.dart',
    'lib/features/maestri/ask/ask_maestri_screen.dart',
    'lib/features/maestri/aura/meditation/meditation_screen.dart',
    'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart',
    'lib/features/maestri/domain_screen.dart',
    'lib/features/rituals/dawn_rite_screen.dart',
    'lib/features/rituals/dream_rite_screen.dart',
    'lib/features/rituals/sunset_rune_screen.dart',
    'lib/features/santuario/sky_overview_screen.dart',
    'lib/features/synastry/sinastria_gallery_screen.dart',
    'lib/features/synastry/sinastria_vip_screen.dart',
    'lib/features/tarot/stesa_tre_carte_screen.dart',
  ];

  /// LE ESENZIONI, e ognuna porta la sua ragione scritta. Un'esenzione senza
  /// ragione e' un buco, non una decisione.
  const senzaBorsellino = <String, String>{
    // L'intestazione della chat e' VOLUTAMENTE vuota, e sta scritto nel
    // sorgente: nessun simbolo, tutto centrato in colonna attorno al volto del
    // Maestro. Il residuo delle domande, che li' e' il numero che conta, si
    // legge dentro la conversazione.
    'lib/features/maestri/chat/maestro_chat_screen.dart':
        'intestazione immersiva tenuta vuota per scelta',
    // Superfici immersive: la barra o non c'e' o si nasconde, e le anteprime
    // dell'ordine P lo verificano.
    'lib/features/maestri/art_intro_screen.dart': 'intro a schermo pieno',
    'lib/features/rituals/breath_destiny_screen.dart': 'rito immersivo',
    'lib/features/rituals/ritual_view.dart': 'guscio dei riti, non una schermata',
    // Non e' la pratica: qui non si guadagna e non si spende niente, e nel
    // prezzario un saldo accanto ai piani confonderebbe l'offerta.
    'lib/features/account/account_screen.dart': 'account',
    'lib/features/account/profile_screen.dart': 'account',
    'lib/features/account/dati_di_nascita_screen.dart': 'dati di nascita',
    'lib/features/settings/settings_screen.dart': 'impostazioni',
    'lib/features/pricing/pricing_screen.dart': 'prezzario',
    'lib/features/identity/circle_seal_screen.dart': 'identita, non pratica',
  };

  String sorgente(String p) => File(p).readAsStringSync();

  test('ogni schermata della pratica monta il segno del borsellino', () {
    final senza = <String>[];
    for (final percorso in conBorsellino) {
      final s = sorgente(percorso);
      // Tre modi, e sono lo stesso: l'angolo comune della barra, la barra
      // delle arti che monta l'angolo, o il segno da solo.
      if (!s.contains('SegnoDelBorsellino') &&
          !s.contains('AngoloDellaBarra') &&
          !s.contains('BarraArte(')) {
        senza.add(percorso);
      }
    }
    expect(senza, isEmpty,
        reason: 'queste schermate non mostrano il saldo, e li\' gli Eos non '
            'esistono:\n${senza.join("\n")}');
  });

  test('nessuna schermata con una barra resta fuori dalle due liste', () {
    // **IL PRESIDIO CONTRO LA SCHERMATA NUOVA.** E' l'unico modo in cui
    // un'enumerazione resta vera invece di invecchiare in silenzio: chi aggiunge
    // una barra domani deve decidere, e la decisione si scrive.
    final fuori = <String>[];
    for (final voce in Directory('lib/features').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll('\\', '/');
      final s = voce.readAsStringSync();
      final haUnaBarra = s.contains('AppBar(') || s.contains('BarraArte(');
      if (!haUnaBarra) continue;
      if (conBorsellino.contains(percorso)) continue;
      if (senzaBorsellino.containsKey(percorso)) continue;
      fuori.add(percorso);
    }
    expect(fuori, isEmpty,
        reason: 'queste schermate hanno una barra e non stanno in nessuna delle '
            'due liste: decidi se il borsellino ci va, e scrivilo qui, '
            'altrimenti il saldo torna a comparire a macchia di leopardo:\n'
            '${fuori.join("\n")}');
  });

  test('il registro racconta e NON conta: il saldo resta quello del server',
      () async {
    SharedPreferences.setMockInitialValues({});
    final registro = RegistroDegliEos();
    await registro.segna(quanti: 10, perche: 'Primo passo');
    await registro.segna(quanti: 25, perche: 'Il primo Sigillo grande');
    // Il piu' recente sta in cima: e' l'ordine in cui si legge "gli ultimi".
    expect(registro.ultimi.first.perche, 'Il primo Sigillo grande');
    // **NESSUN SALDO QUI.** Sommare i movimenti darebbe un secondo numero
    // accanto a quello del server, e al primo movimento perso i due
    // discorderebbero: la persona vedrebbe due saldi diversi nella stessa
    // schermata.
    expect(
        sorgente('lib/core/entitlement/registro_degli_eos.dart')
            .contains('fold') ,
        isFalse,
        reason: 'il registro ha cominciato a sommare i movimenti: e\' il '
            'secondo saldo, e vince sempre quello del server');
  });

  test('il registro non cresce senza fine, e sopravvive a un riavvio',
      () async {
    SharedPreferences.setMockInitialValues({});
    final primo = RegistroDegliEos();
    for (var i = 0; i < RegistroDegliEos.quantiSeNeTengono + 4; i++) {
      await primo.segna(quanti: 5, perche: 'Gesto $i');
    }
    expect(primo.ultimi.length, RegistroDegliEos.quantiSeNeTengono);

    // LO STESSO DISCO, UN OGGETTO NUOVO: e' cosi' che si riapre l'app.
    final secondo = RegistroDegliEos();
    await secondo.carica();
    expect(secondo.ultimi.length, RegistroDegliEos.quantiSeNeTengono,
        reason: 'il registro non e\' stato riletto: al riavvio il portafoglio '
            'direbbe che non e\' mai arrivato niente');
    expect(secondo.ultimi.first.perche, primo.ultimi.first.perche);
  });

  /// Monta il sentiero VERO, che e' il modo in cui l'app lo monta.
  Future<RegistroDegliEos> montaUnaSchermata(WidgetTester tester,
      {int saldo = 0}) async {
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino();
    await diario.carica();
    final registro = RegistroDegliEos();
    await registro.segna(quanti: 10, perche: 'Il primo passo del cammino');
    final borsa = QuestionAllowance();
    await borsa.applicaSaldo(saldo);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ChangeNotifierProvider<RegistroDegliEos>.value(value: registro),
        ChangeNotifierProvider(
            create: (_) => ArtiPreferiteController(
                maestroAssegnato: Sentiero.costellazione.maestro)),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: Navigator(
          onGenerateRoute: (_) =>
              SentieroScreen.route(Sentiero.costellazione),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return registro;
  }

  testWidgets('il segno si vede, e al tocco apre il portafoglio con le tre cose',
      (tester) async {
    final registro = await montaUnaSchermata(tester, saldo: 7);
    expect(find.byKey(const Key('borsellino')), findsOneWidget,
        reason: 'il segno del borsellino non c\'e\' nella barra');

    await tester.tap(find.byKey(const Key('borsellino')));
    // NIENTE pumpAndSettle: il fondo cosmico non si assesta mai e l'attesa
    // scadrebbe sempre. Si avanza a passi dichiarati oltre l'apertura del
    // foglio.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }

    expect(find.byKey(const Key('portafoglio')), findsOneWidget,
        reason: 'toccando il borsellino non si apre niente: e\' un vicolo cieco');
    // 1. IL SALDO, e viene dal server e non dal registro: nel registro ci sono
    //    dieci Eos, il server ne dice sette, e a schermo deve leggersi sette.
    final saldo = tester.widget<Text>(find.byKey(const Key('portafoglio_saldo')));
    expect(saldo.data, '7 Eos',
        reason: 'il portafoglio mostra ${saldo.data}: se non e\' il numero del '
            'server, c\'e\' un secondo saldo e i due discorderanno');
    // 2. LA PROSSIMA RICARICA.
    expect(find.byKey(const Key('portafoglio_ricarica')), findsOneWidget);
    // 3. DA DOVE SONO ARRIVATI GLI ULTIMI EOS, con la ragione in parole.
    expect(find.text(registro.ultimi.first.perche), findsOneWidget,
        reason: 'il portafoglio non dice da dove sono arrivati gli Eos: un '
            'numero che sale senza una ragione accanto non si distingue da un '
            'numero che sale per caso');
  });

  test('la riga della ricarica non promette una cifra che non esiste', () {
    // **QUI SI DECIDE DI NON INVENTARE NIENTE.** La matrice promette un livello
    // e non un numero (No, Medio, Alto, Massimo): il portafoglio dice che il
    // piano porta un bonus, non quanto. Una cifra inventata nel borsellino e'
    // peggio di una cifra assente.
    final viandante = PortafoglioDelCerchio.quandoTornano(
        QuestionAllowance(freeDailyLimit: 3), Tier.free);
    expect(viandante, contains('domande ai Maestri'));
    expect(viandante.toLowerCase(), contains('guadagni'),
        reason: 'al Viandante non si dice da dove arrivano gli Eos, e il suo '
            'piano non ne porta nessuno ogni mese');
    final illuminato = PortafoglioDelCerchio.quandoTornano(
        QuestionAllowance(), Tier.tier3);
    expect(illuminato, isNot(contains('Medio')),
        reason: 'il portafoglio ha cominciato a mostrare il livello grezzo '
            'della matrice, che alla persona non dice niente');
  });
}

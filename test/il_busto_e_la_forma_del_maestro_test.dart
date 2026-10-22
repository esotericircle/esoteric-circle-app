import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_empty_state.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/maestri/widgets/busto_del_maestro.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/features/santuario/widgets/maestro_bust.dart'
    as santuario;
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sorgenti_di_lib.dart';

/// IL BUSTO E' LA FORMA DEL MAESTRO IN ALTO, ordine I voce 1.
///
/// Dove un Maestro compare in alto si mostra il BUSTO, il ritaglio dalla vita
/// in su che sfuma in basso, dalla porta unica `BustoDelMaestro`. Le
/// eccezioni sono la home "Il Cerchio", dove i tre restano interi dietro la
/// carta, e dall'ordine FW (15 ottobre 2026) il dominio e la chat vuota di
/// ogni Maestro, dove la scena in video mostra gia' la figura intera a tutto
/// schermo e il busto sparisce per non raddoppiarla (nella chat, corretto lo
/// stesso giorno: il fondatore, vista l'anteprima, "il video deve essere a
/// tutto schermo", non piu' un riquadro sopra il saluto): la guardia cade se
/// una schermata non elencata mostra la figura intera, e cade anche se una
/// delle eccezioni smette di farlo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la scelta dell\'immagine vive in un punto solo, enumerato', () {
    // L'ENUMERAZIONE sul sorgente: ogni file che tocca l'avatar del Maestro
    // (il campo `avatarAsset` o la cartella degli avatar) deve stare
    // nell'elenco dichiarato. Un file nuovo che se lo prende da se' e' una
    // seconda porta, e la prova cade nominandolo.
    const ammessi = {
      // LA PORTA. E' lei a scegliere l'immagine e a ritagliarla.
      'lib/features/maestri/widgets/busto_del_maestro.dart',
      // L'ECCEZIONE: la home Il Cerchio, i tre interi dietro la carta.
      'lib/features/santuario/widgets/maestro_bust.dart',
      // IL TONDO DEL VOLTO: il cerchietto di header, lente e bolla della
      // chat. Non e' la figura in alto, e' un altro elemento, con la sua
      // inquadratura misurata e le sue prove.
      'lib/features/maestri/widgets/maestro_bust.dart',
      // LA CARTA DELLA SCELTA nel Risveglio: il Maestro non presiede una
      // schermata, e' un candidato da scegliere, intero nella sua carta.
      'lib/features/onboarding/widgets/maestro_card.dart',
      // IL SIGILLO SULLA CARD DEL MESE, ordine FV voce FV.11, 15 ottobre
      // 2026: "in basso il sigillo di Medora, il logo e il collegamento
      // diretto". Non e' il busto che presiede una schermata, e' una firma
      // piccola accanto al suo nome, nella stessa riga del logo: un
      // elemento diverso, con la sua misura.
      'lib/features/lunario/la_card_del_mese.dart',
      // La definizione del percorso, accanto al Maestro stesso.
      'lib/core/maestro/maestro.dart',
    };
    // **I COMMENTI NON CONTANO, ordine EG voce 05.** La prova leggeva il file
    // intero e ha accusato la schermata LIVE per **una riga di commento** che
    // raccontava di non prendersi l'immagine da se'. Una prova che accusa il
    // codice per aver spiegato cosa NON fa insegna a cancellare le
    // spiegazioni, ed e' il contrario di quello che serve a questo progetto:
    // e' la seconda volta che capita, dopo `uid` nell'ordine EI.
    String soloCodice(String testo) {
      final b = StringBuffer();
      for (final r in testo.split('\n')) {
        final t = r.trim();
        if (t.startsWith('//') || t.startsWith('*') || t.startsWith('/*')) {
          continue;
        }
        b.writeln(r);
      }
      return b.toString();
    }

    final colpe = <String>[];
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      final s = soloCodice(f.readAsStringSync());
      if (!s.contains('avatarAsset') && !s.contains('avatars_webp')) continue;
      if (!ammessi.contains(percorso)) colpe.add(percorso);
    }
    expect(colpe, isEmpty,
        reason: 'questi file scelgono da se\' l\'immagine del Maestro invece '
            'di passare dalla porta unica BustoDelMaestro:\n${colpe.join('\n')}');
  });

  Future<void> pompa(WidgetTester tester, Widget schermata) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => GreetingController()),
        ChangeNotifierProvider(
          create: (ctx) =>
              FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                ..initialize(),
        ),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: schermata,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  // **LAPIDE: "nei tre domini c'era il busto canonico, mai la figura
  // intera".** Ordine FW voce FW.03, 15 ottobre 2026: il dominio mostra ora
  // la sua scena in video, che gia' porta la figura intera del Maestro
  // (R8: nessun ritaglio disegnato al suo posto). Tenere anche il busto
  // sotto la scena duplicava la figura, una grande dietro e una piccola
  // sopra: scoperto guardando l'anteprima vera (`docs/preview/FW/`) prima di
  // chiudere la voce, mai dalla sola lettura del codice. Il dominio diventa
  // un'eccezione voluta quanto la home.
  testWidgets('nei tre domini c\'e\' la scena intera, mai il busto ritagliato',
      (tester) async {
    for (final m in Maestro.values) {
      await pompa(tester, DomainScreen(maestro: m));
      expect(find.byKey(const Key('dominio_fotogramma')), findsOneWidget,
          reason: '${m.displayName}: il dominio non mostra la sua scena.');
      expect(find.byType(BustoDelMaestro), findsNothing,
          reason: '${m.displayName}: nel dominio e\' tornato il busto '
              'ritagliato sopra la scena, che duplica la figura.');
      expect(find.byType(santuario.MaestroBust), findsNothing,
          reason: '${m.displayName}: nel dominio compare la carta della '
              'figura intera, che e\' della sola home.');
    }
  });

  // **LAPIDE: "la chat vuota mostra il busto".** Ordine FW voce FW.04, 15
  // ottobre 2026, corretta lo stesso giorno: la figura della chat vuota e'
  // salita a sfondo di tutta la schermata (montata da `MaestroChatScreen`,
  // non piu' da `ChatEmptyState`), perche' il fondatore ha trovato
  // "inaccettabile il riquadro in mezzo alla schermata con il maestro".
  // `ChatEmptyState`, isolata come qui, non mostra piu' nessuna figura: solo
  // il saluto.
  testWidgets('la chat vuota, isolata, non mostra nessun busto',
      (tester) async {
    await pompa(
        tester,
        const Scaffold(
            body: ChatEmptyState(
                maestro: Maestro.caligo, greeting: 'Benvenuto nel cerchio.')));
    expect(find.byType(BustoDelMaestro), findsNothing,
        reason: 'ChatEmptyState mostra di nuovo un busto suo: la figura '
            'deve restare lo sfondo intero montato da MaestroChatScreen.');
  });

  // **LAPIDE: "la Stesa mostra il busto di Medora dalla porta unica".**
  // Ordine FL voce 01, 12 ottobre 2026, il fondatore: "SFONDO NUOVO con
  // sovrapposta Medora tagliata alla vita come se fosse dietro il tavolo".
  // La Stesa diventa un'eccezione voluta, come la home: Medora e' il busto
  // disegnato per il tavolo (medora_busto_v1.webp, con le carte sospese),
  // non il ritaglio della porta unica. La prova cade se torna il ritaglio o
  // se Medora sparisce dal tavolo.
  testWidgets(
      'la Stesa resta l\'eccezione: Medora dietro il tavolo, non il '
      'busto della porta unica', (tester) async {
    await pompa(tester, const StesaTreCarteScreen(seed: 7));
    await tester.pump(const Duration(seconds: 3));
    // Dall'ordine GC voce GC.03 Medora, sulla posa dell'invito, e' il
    // fotogramma d'arrivo del filmato, non piu' la posa scontornata: dietro
    // il tavolo c'e' l'una o l'altro.
    expect(
        find.byKey(const Key('tavolo_medora')).evaluate().length +
            find
                .byKey(const Key('tavolo_fotogramma_di_arrivo'))
                .evaluate()
                .length,
        1,
        reason: 'Nella Stesa Medora non sta piu\' dietro il tavolo.');
    expect(find.byType(BustoDelMaestro), findsNothing,
        reason: 'Nella Stesa e\' tornato il busto ritagliato della porta '
            'unica al posto di Medora dietro il tavolo.');
  });

  testWidgets('la home Il Cerchio resta l\'eccezione: i tre interi',
      (tester) async {
    await pompa(
        tester, SantuarioScreen(clock: () => DateTime(2026, 8, 11, 21)));
    await tester.pump(const Duration(milliseconds: 800));
    // I tre Maestri interi dietro la carta: la guardia cade anche se la home
    // smette di mostrarli interi, perche' l'eccezione e' voluta quanto la
    // regola.
    expect(find.byType(santuario.MaestroBust), findsNWidgets(3),
        reason: 'La home Il Cerchio non mostra piu\' i tre Maestri interi '
            'dietro la carta.');
    expect(find.byType(BustoDelMaestro), findsNothing,
        reason: 'Nella home e\' comparso il busto ritagliato: li\' i tre '
            'restano interi.');
  });
}

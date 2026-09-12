import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL CONFRONTO COSTA UNA DOMANDA SOLA, CON UN TETTO SUO.
///
/// **Il numero vero, misurato dentro la schermata prima di toccare codice.**
/// L'ordine partiva da "tre risposte vere valgono tre domande". Non e' cosi':
/// `_fetchLens` conta solo la voce di partenza, `countsAgainstAllowance: m ==
/// widget.starter`, e aprendo il Consiglio dalla chat la lente di partenza
/// arriva GIA' PRONTA dalla conversazione, quindi non viene nemmeno richiesta.
/// Un confronto consuma **ZERO** domande in piu' di quella gia' pagata nella
/// chat. Aprendo la schermata a freddo, cosa che nell'app non succede da
/// nessuna porta, ne consuma UNA.
///
/// **Percio' il tetto separato serve lo stesso.** Se il gesto non costa
/// niente, senza un tetto suo sarebbe gratuito e ripetibile all'infinito,
/// mentre ogni tocco sono due chiamate al modello.
void main() {
  group('Il tetto vive nel listino, e non in un secondo posto', () {
    test('Viandante lucchetto, Iniziato 3, Adepto 5, Illuminato 20', () {
      // **VENTI, E NON PIU\' "SENZA LIMITE".** Ordine CE voce 08: il
      // fondatore ha chiesto che l\'illimitato sparisca da ogni cella, e il
      // numero qui segue il dato del listino, non lo anticipa.
      expect(
          PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, Tier.free),
          0);
      expect(
          PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, Tier.tier1),
          3);
      expect(
          PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, Tier.tier2),
          5);
      expect(
          PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, Tier.tier3),
          20);
    });

    test('`canCompare` CHIEDE al listino invece di decidere da solo', () {
      // Diceva `tier != Tier.free`, cioe' era un secondo posto dove si
      // stabiliva chi puo' cosa. Adesso legge la riga, come la memoria dei
      // Maestri e la profondita' dell'oroscopo.
      final c = QuestionAllowance();
      expect(c.canCompare(Tier.free), isFalse);
      for (final t in [Tier.tier1, Tier.tier2, Tier.tier3]) {
        expect(c.canCompare(t), isTrue);
      }
      // E la decisione NON e' piu' scritta a mano da nessuna parte. Si
      // guardano le righe vive, non i commenti che raccontano com'era.
      final righe = File('lib/core/entitlement/question_allowance.dart')
          .readAsLinesSync();
      final scrittaAMano = [
        for (var i = 0; i < righe.length; i++)
          if (!righe[i].trimLeft().startsWith('//') &&
              !righe[i].trimLeft().startsWith('///') &&
              righe[i].contains('tier != Tier.free'))
            'riga ${i + 1}: ${righe[i].trim()}'
      ];
      expect(scrittaAMano, isEmpty,
          reason: 'il confronto decide di nuovo da solo chi puo\' cosa:'
              '${scrittaAMano.join()}');
      expect(righe.join(), contains('PlanCatalog.rigaConfronti'));
    });

    test('UN SOLO confine del giorno, e i tre contatori lo guardano', () {
      // Un secondo confine accanto a questo divergerebbe alla prima ora
      // legale: `ConfineDelGiorno` e' uno.
      var oggi = DateTime(2026, 8, 2, 23, 0);
      final c = QuestionAllowance(clock: () => oggi);
      c.record(Tier.tier1);
      c.registraApprofondimento(Tier.tier1);
      c.registraConfronto(Tier.tier1);
      expect(c.confrontiRimasti(Tier.tier1), 2);
      expect(c.approfondimentiRimasti(Tier.tier1), 2);
      oggi = DateTime(2026, 8, 3, 1, 0);
      expect(c.confrontiRimasti(Tier.tier1), 3,
          reason: 'i confronti non ribaltano a mezzanotte come gli altri due');
      expect(c.approfondimentiRimasti(Tier.tier1), 3);
      expect(c.usedToday(), 0);
    });
  });

  group('Il conto, e il residuo che si vede prima', () {
    test('Tre tocchi bruciano i tre, il quarto non passa', () {
      final c = QuestionAllowance();
      for (var i = 0; i < 3; i++) {
        expect(c.puoiConfrontare(Tier.tier1), isTrue);
        c.registraConfronto(Tier.tier1);
      }
      expect(c.confrontiRimasti(Tier.tier1), 0);
      expect(c.puoiConfrontare(Tier.tier1), isFalse,
          reason: 'un confronto oltre il tetto del giorno');
    });

    test('Un confronto NON consuma una domanda del giorno', () {
      final c = QuestionAllowance();
      final domande = c.remaining(Tier.tier1);
      c.registraConfronto(Tier.tier1);
      expect(c.remaining(Tier.tier1), domande,
          reason: 'il confronto ha il suo tetto: contarlo anche sulle domande '
              'sarebbe pagarlo due volte');
    });

    test('Il residuo CONCORDA col numero, scendendo da tre a zero', () {
      // **QUESTA PROVA DICEVA IL CONTRARIO, e proteggeva l'errore.** Pretendeva
      // "Oggi te ne resta 3 su 3" e chiamava quella mancanza di accordo una
      // scelta: era sgrammaticata, e l'anteprima della build 2148 la mostrava
      // a video con quelle parole esatte.
      final c = QuestionAllowance();
      expect(c.residuoDeiConfronti(Tier.tier1), 'Oggi te ne restano 3 su 3');
      c.registraConfronto(Tier.tier1);
      expect(c.residuoDeiConfronti(Tier.tier1), 'Oggi te ne restano 2 su 3');
      c.registraConfronto(Tier.tier1);
      expect(c.residuoDeiConfronti(Tier.tier1), 'Oggi te ne resta 1 su 3',
          reason: 'a uno solo ci vuole il singolare');
      c.registraConfronto(Tier.tier1);
      expect(c.residuoDeiConfronti(Tier.tier1), 'Oggi non te ne resta nessuno',
          reason: 'a zero non e\' un residuo, e\' la fine: dirlo con un numero '
              'davanti a "su tre" e\' un conto, non una frase');
    });

    test('Al Viandante non si dice un residuo: e\' un lucchetto', () {
      final c = QuestionAllowance();
      expect(c.residuoDeiConfronti(Tier.free), isNull,
          reason: 'a chi non ce l\'ha nel piano si mostra un numero invece '
              'della porta');
      // **E ALL'ILLUMINATO ADESSO SI DICE, ordine CE voce 08.** Prima non
      // aveva nessun tetto e non c'era niente da contare; adesso ne ha venti,
      // e il residuo si vede come a tutti gli altri.
      expect(c.residuoDeiConfronti(Tier.tier3), 'Oggi te ne restano 20 su 20',
          reason: 'chi ha un tetto deve vederlo, anche quando e\' alto');
    });
  });

  test('Il tetto e il conto esistono nella schermata, non solo nel dato', () {
    final s = File('lib/features/maestri/chat/maestro_chat_screen.dart')
        .readAsStringSync();
    expect(s, contains('puoiConfrontare'),
        reason: 'la chat non guarda il tetto del giorno prima di aprire');
    expect(s, contains('registraConfronto'),
        reason: 'nessuno conta il confronto quando avviene');
  });

  testWidgets('IL RESIDUO SI VEDE, sotto il pulsante e prima del tocco',
      (tester) async {
    // **UNA PROVA DEL ROSSO RESTATA VERDE l'ha chiesta a video.** La prima
    // stesura cercava la chiave nel SORGENTE: spegnendo il ramo con un `if
    // (false)` la chiave restava scritta, quindi la prova passava mentre a
    // schermo non c'era piu' niente. Un ramo spento resta scritto.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          maestro: Maestro.medora,
          child: Scaffold(
            body: SingleChildScrollView(
              child: ChatBubble(
                message: const ChatMessage(
                  role: ChatRole.maestro,
                  text: 'La lettura di Medora, per esteso.',
                ),
                maestro: Maestro.medora,
                durataMassimaDiScrittura: const Duration(seconds: 10),
                altreVoci: const [Maestro.caligo, Maestro.aura],
                onChiediAgliAltri: () {},
                residuoDeiConfronti:
                    QuestionAllowance().residuoDeiConfronti(Tier.tier1),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    final residuo = find.byKey(const Key('chat_residuo_confronti'));
    expect(residuo, findsOneWidget,
        reason: 'chi tocca non sa cosa spende prima di spenderlo');
    expect(find.text('Oggi te ne restano 3 su 3'), findsOneWidget);
    // E sta SOTTO il pulsante, non sopra: prima si legge cosa si fa, poi
    // quanto costa.
    final pulsante = find.byKey(const Key('chat_altre_voci'));
    expect(pulsante, findsOneWidget);
    expect(tester.getTopLeft(residuo).dy,
        greaterThan(tester.getTopLeft(pulsante).dy),
        reason: 'il residuo e\' disegnato sopra il pulsante');
  });
}

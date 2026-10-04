// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_gesto_nelle_prove.dart';

/// **GLI AMICI OFFLINE E L'OROSCOPO PER GLI AMICI. Ordine ES voce 12, 29
/// settembre 2026.**
///
/// Il fondatore: "l'utente premium potrà inserire data e ora di nascita
/// dell'amico, scegliere la tipologia di oroscopo, scoprire il segno
/// corrispondete e creare l'oroscopo e con la condivisione inviarlo
/// all'amico"; "l'utente free non può fare orsocopo per amici, lo vede e se
/// fa click, viene invitato a sottoscrivere abbonamento"; "3 per l'Iniziato,
/// 10 per l'Adepto, nessun limite per l'Illuminato [...] 100 Eos per un posto
/// in più", "ok , approvato".
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  Amico amico(int i, {String? ora}) => Amico(
        id: 'a$i',
        nome: 'Amico $i',
        nascita: DateTime(1980 + i, 1 + i % 12, 1 + i),
        ora: ora,
      );

  test('i posti per piano sono quelli del fondatore, e 100 Eos ne aggiungono',
      () async {
    final a = AmiciOffline();
    await a.carica();
    expect(a.posti(Tier.free), 0);
    expect(a.posti(Tier.tier1), 3);
    expect(a.posti(Tier.tier2), 10);
    // LAPIDE, ordine EZ voce 06: qui stava isNull, l'Illuminato senza
    // limite. Adesso ha cinquanta posti, sotto i 150 legami del Cerchio.
    expect(a.posti(Tier.tier3), 50);
    expect(ListinoDegliEos.amicoInPiu.costo, 100);
    // L'Iniziato ne tiene tre, il quarto no.
    for (var i = 0; i < 3; i++) {
      expect(await a.aggiungi(amico(i), Tier.tier1), isTrue);
    }
    expect(await a.aggiungi(amico(3), Tier.tier1), isFalse,
        reason: 'l\'Iniziato tiene un quarto amico');
    expect(await a.aggiungi(amico(3), Tier.free), isFalse);
    // Un posto comprato fa entrare il quarto, e resta dopo il riavvio.
    await a.unPostoInPiu();
    // Il posto comprato non apre gli amici al Viandante: il suo "No" resta
    // un no anche con gli Eos spesi.
    expect(a.posti(Tier.free), 0);
    expect(await a.aggiungi(amico(3), Tier.free), isFalse,
        reason: 'il posto comprato apre gli amici al Viandante');
    expect(await a.aggiungi(amico(3), Tier.tier1), isTrue);
    final riletti = AmiciOffline();
    await riletti.carica();
    expect(riletti.tutti.length, 4);
    expect(riletti.postiComprati, 1);
    expect(riletti.posti(Tier.tier1), 4);
    await riletti.togli('a0');
    expect(riletti.tutti.length, 3);
  });

  Widget monta(Widget figlio, Tier tier) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
        ],
        // Come nella rotta vera: la schermata e' vestita da Medora.
        child: MaterialApp(
            home: MaestroScope(maestro: Maestro.medora, child: figlio)),
      );

  /// **L'OROSCOPO DI UN AMICO E' L'OROSCOPO, ordine FC voce 02**: si monta
  /// con quello che l'Oroscopo vuole intorno, come nell'app.
  Widget montaLOroscopo(Amico a, Tier tier) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(create: (_) => AmiciOffline()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(maestro: Maestro.medora, child: child!),
          ),
          home: OroscopoScreen(
              userSign: Zodiac.fromDate(a.nascita),
              amico: a,
              now: DateTime(2026, 10, 5, 9)),
        ),
      );

  testWidgets('il Viandante vede la voce e il tocco lo invita al piano',
      (tester) async {
    await tester.pumpWidget(monta(const AmiciScreen(), Tier.free));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('amici_invito_al_piano')), findsOneWidget);
    expect(find.byKey(const Key('amici_aggiungi')), findsNothing);
    await tester.tap(find.byKey(const Key('amici_invito_al_piano')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('L\'oroscopo per gli amici si apre'),
        findsOneWidget);
  });

  testWidgets('dall\'Iniziato si aggiungono amici fino al tetto',
      (tester) async {
    final a = AmiciOffline();
    await tester.runAsync(() async {
      await a.carica();
      for (var i = 0; i < 3; i++) {
        await a.aggiungi(amico(i), Tier.tier1);
      }
    });
    await tester.pumpWidget(monta(AmiciScreen(amici: a), Tier.tier1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Amici 3 su 3.'), findsOneWidget);
    expect(find.byKey(const Key('amici_aggiungi')), findsNothing,
        reason: 'al tetto il pulsante resta');
    expect(find.byKey(const Key('porta_della_spesa')), findsOneWidget,
        reason: 'al tetto non c\'e\' la via del posto in piu\'');
  });

  testWidgets('l\'oroscopo dell\'amico nelle tre tradizioni, al neutro',
      (tester) async {
    LaMarcaDelGenere.formaCorrente = CourtesyForm.masculine;
    final senza = <String>[];
    final chiedeLOra = <String>[];
    for (final (i, ora) in [(1, '08:30'), (5, null), (2, null)]) {
      // LAPIDE, ordine FC voce 02: qui si montava la schermata dell'amico
      // (`LOroscopoDellAmicoScreen`); adesso e' l'Oroscopo col soggetto
      // impostato sull'amico, e le schede nascono dal gesto (FC.03).
      await tester.pumpWidget(montaLOroscopo(amico(i, ora: ora), Tier.tier1));
      // Il profilo appena creato scrive la sua forma nella statica: la forma
      // di chi usa l'app si mette dopo, e la schermata deve lasciarla com'e'.
      LaMarcaDelGenere.formaCorrente = CourtesyForm.masculine;
      await tester.pump(const Duration(milliseconds: 300));
      for (final t in const ['occidentale', 'cinese', 'vedica']) {
        final chip = find.byKey(Key('oroscopo_tradition_$t'));
        await tester.ensureVisible(chip);
        await tester.tap(chip);
        await tester.pump(const Duration(milliseconds: 300));
        await interrogaSeCe(tester);
        final schede = find.byKey(const Key('oroscopo_card_generale'));
        if (schede.evaluate().isNotEmpty) continue;
        // **LA VEDICA SENZA ORA, quando la Luna cambia segno quel giorno.**
        // La Luna resta in un segno due giorni e mezzo: nata in un giorno
        // in cui passa da un segno all'altro, senza l'ora non si sa quale
        // dei due. La schermata allora chiede l'ora invece di scegliere a
        // caso, ed e' la risposta giusta, non una lettura mancata.
        final ambigua = t == 'vedica' &&
            ora == null &&
            LaLetturaVedica.lunaDiNascita(NascitaDeiSegni(
                    locale: amico(i).momento, oraNota: false)) ==
                null;
        if (ambigua &&
            find
                .byKey(const Key('oroscopo_invito_nascita'))
                .evaluate()
                .isNotEmpty) {
          chiedeLOra.add('amico $i');
        } else {
          senza.add('amico $i, $t');
        }
      }
    }
    print('ORDINE ES VOCE 12: letture dell\'amico mancanti ${senza.length} su '
        '9: $senza; la Vedica chiede l\'ora (Luna che cambia segno quel '
        'giorno) per $chiedeLOra');
    expect(senza, isEmpty);
    // **QUANTO SPESSO BASTA LA DATA SOLA**, misurato su un anno intero e non
    // sui tre amici qui sopra, che sono troppo pochi per dire qualcosa. La
    // Luna cambia segno ogni due giorni e mezzo circa, quindi in un giorno
    // su due e mezzo passa da un segno all'altro: la data sola deve bastare
    // piu' o meno sei giorni su dieci. Se bastasse sempre, la schermata
    // sceglierebbe a caso; se non bastasse mai, chiederebbe l'ora a tutti.
    var bastaLaData = 0;
    for (var g = 0; g < 365; g++) {
      final d = DateTime(1990, 1, 1 + g, 12);
      if (LaLetturaVedica.lunaDiNascita(
              NascitaDeiSegni(locale: d, oraNota: false)) !=
          null) {
        bastaLaData++;
      }
    }
    print('ORDINE ES VOCE 12: nel 1990 la data sola basta alla Vedica in '
        '$bastaLaData giorni su 365');
    expect(bastaLaData, inInclusiveRange(150, 280),
        reason: 'la Vedica senza ora legge in $bastaLaData giorni su 365: '
            'la regola del segno certo non e\' quella della Luna');
    expect(LaMarcaDelGenere.formaCorrente, CourtesyForm.masculine,
        reason: 'la schermata dell\'amico ha lasciato la forma al neutro');
  });
}

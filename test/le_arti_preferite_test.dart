import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LO SCAFFALE E' "LE ARTI PREFERITE". Ordine AK voce 01, voce di Mauro del
/// 17 agosto 2026.
///
/// Tre pretese, misurate sullo scaffale montato SENZA salvataggi su disco
/// (cioe' sul seme): il titolo dice "Le arti preferite"; le bolle sono le
/// SETTE di Mauro nell'ordine esatto suo (horoscope, tarot_spread_three,
/// synastry_vip, rune_draw, guide_animal, meditation, face_constellation);
/// la bolla della stesa porta l'etichetta breve "Tarocchi", che e' un dato
/// del controller e MAI un rinomino del catalogo.
///
/// **DALL'ORDINE BK VOCE 01 le etichette brevi sono DUE**: la stesa e
/// l'Oroscopo. Prima l'Oroscopo non ne aveva, e questa prova pretendeva che
/// non ne avesse: adesso pretende il contrario, perche' la decisione del
/// fondatore l'ha cambiata.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // **LAPIDE: fino all'ordine EN il seme erano le sette di Mauro** (ordine AK
  // voce 01: Oroscopo, Tarocchi, Sinastria VIP, Rune, Viaggio dello
  // Sciamano, Meditazione, Mappa del Viso). **Dall'ordine EO voce 09 sono le
  // sei della riga "Le arti preferite"**, nell'ordine del fondatore.
  const setteDiMauro = [
    'horoscope',
    'tarot_spread_three',
    'rune_draw',
    'synastry_vip',
    'meditation',
    'face_constellation',
  ];

  test('il seme e\' le sei dell\'ordine EO, nell\'ordine del fondatore', () {
    for (final maestro in [null, ...Maestro.values]) {
      final seme = ArtiPreferiteController.semePer(maestro);
      // ignore: avoid_print
      print('ORDINE AK VOCE 01: seme per ${maestro?.id ?? "nessuno"}: $seme');
      expect(seme, setteDiMauro,
          reason: 'il seme per ${maestro?.id ?? "chi non ha Maestro"} non e\' '
              'l\'elenco di Mauro nell\'ordine suo');
    }
  });

  // **LAPIDE: dall'ordine AK voce 01 all'ordine EN qui c'erano due prove
  // delle etichette brevi**, "Tarocchi" e "Oroscopo", e lo scaffale montato le
  // doveva mostrare al posto dei titoli del catalogo. **Dall'ordine EO voce
  // 02** la scheda porta `ArtEntry.title` su al massimo due righe e mai
  // rimpicciolito: le etichette esistevano solo perche' la bolla di prima
  // rimpiccioliva i nomi lunghi, e sono uscite dal codice con lei.
  testWidgets(
      'la riga montata: titolo, sei schede in ordine, titoli del '
      'catalogo', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ArtiPreferiteController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const Material(
          child: SingleChildScrollView(
            child: LeRigheDellaCasaView(sensore: false),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(find.text('Le arti preferite'), findsOneWidget,
        reason: 'il titolo della riga deve dire "Le arti preferite"');
    expect(find.text('Le tue arti'), findsNothing,
        reason: 'il titolo vecchio non deve piu\' comparire');
    // La riga scorre in orizzontale e costruisce solo cio' che si vede: si
    // scorre, e si raccolgono le schede nell'ordine in cui compaiono.
    final riga = find.byKey(const Key('riga_scorre_preferite'));
    final viste = <String>[];
    for (var giro = 0; giro < 8; giro++) {
      for (final e in find
          .descendant(
              of: riga,
              matching: find.byWidgetPredicate((w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>)
                      .value
                      .startsWith('riga_preferite_')))
          .evaluate()) {
        final id = (e.widget.key! as ValueKey<String>)
            .value
            .substring('riga_preferite_'.length);
        if (!viste.contains(id)) viste.add(id);
      }
      await tester.drag(riga, const Offset(-200, 0));
      await tester.pump();
    }
    expect(viste, setteDiMauro,
        reason: 'la riga delle arti preferite non mostra il seme dell\'ordine '
            'EO, nell\'ordine del fondatore');
    await tester.drag(riga, const Offset(3000, 0));
    await tester.pump();
    expect(
        tester
            .widget<Text>(find.descendant(
                of: find.byKey(const Key('riga_preferite_tarot_spread_three')),
                matching:
                    find.byKey(const Key('scheda_titolo_tarot_spread_three'))))
            .data,
        'Stesa di Tarocchi',
        reason: 'ordine EO voce 02: il titolo sotto la scheda e\' '
            'ArtEntry.title');
    expect(find.text('Tarocchi'), findsNothing,
        reason: 'l\'etichetta breve di prima non deve piu\' comparire');
  });
}

// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/astro/il_segno_del_cielo.dart';
import 'package:esoteric_circle/core/astro/il_sole_di_nascita.dart';
import 'package:esoteric_circle/core/astro/la_luna_intera.dart';
import 'package:esoteric_circle/core/astro/il_fuso_della_nascita.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/amici/amici_screen.dart';
import 'package:esoteric_circle/features/amici/l_emblema_dell_amico.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l_oroscopo_di_un_amico_nelle_prove.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **L'EMBLEMA DELL'AMICO SCRITTO. Ordine FC voce 10, 5 ottobre 2026.**
///
/// Il fondatore: *"Emblema del segno zodiacale"*. Ogni amico scritto porta
/// nel tondo l'emblema del suo segno solare, dalla posizione reale del Sole
/// alla sua nascita (la porta `IlSegnoDelCielo`), e lo stesso segno lo
/// dicono la rubrica e il suo oroscopo.
void main() {
  Amico amico(String id, String nome, DateTime nascita,
          {String? ora, String? fuso}) =>
      Amico(id: id, nome: nome, nascita: nascita, ora: ora, fuso: fuso);

  /// Il percorso dell'immagine nel tondo di un emblema montato.
  String percorsoNelTondo(WidgetTester tester, Finder dentro) {
    final img = tester.widget<Image>(find.descendant(
        of: dentro, matching: find.byKey(const Key('icona_tonda_immagine'))));
    return (img.image as AssetImage).assetName;
  }

  testWidgets('a) dodici nascite, una per segno, danno i dodici emblemi',
      (tester) async {
    // Il giorno 5 di ogni mese sta dentro un segno solo, lontano dalle
    // cuspidi: gennaio Capricorno, febbraio Acquario, marzo Pesci...
    const attesi = [
      Zodiac.capricorn,
      Zodiac.aquarius,
      Zodiac.pisces,
      Zodiac.aries,
      Zodiac.taurus,
      Zodiac.gemini,
      Zodiac.cancer,
      Zodiac.leo,
      Zodiac.virgo,
      Zodiac.libra,
      Zodiac.scorpio,
      Zodiac.sagittarius,
    ];
    final amici = [
      for (var m = 1; m <= 12; m++)
        amico('a$m', 'Amico $m', DateTime(1990, m, 5)),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Wrap(children: [
          for (final a in amici) LEmblemaDellAmico(amico: a),
        ]),
      ),
    ));
    final visti = <String>[];
    for (var i = 0; i < 12; i++) {
      final a = amici[i];
      final percorso =
          percorsoNelTondo(tester, find.byKey(Key('emblema_amico_${a.id}')));
      visti.add('${a.nascita.month}: ${a.segno.italianName}');
      expect(a.segno, attesi[i], reason: 'il segno del mese ${i + 1}');
      expect(percorso, ZodiacArt.emblemPath(attesi[i]),
          reason: 'l\'emblema del mese ${i + 1}');
    }
    print('FC.10.8 a: dodici emblemi giusti: ${visti.join(', ')}');
  });

  test('b) le cuspidi: la posizione reale del Sole, non le date fisse', () {
    // Dal file delle cuspidi (docs/collaudo/FC/le_cuspidi_del_segno.txt):
    // il giorno, l'anno, il segno delle date fisse e quello del Sole.
    final cuspidi = [
      (DateTime(1950, 1, 20), Zodiac.aquarius, Zodiac.capricorn),
      (DateTime(2024, 3, 20), Zodiac.pisces, Zodiac.aries),
      (DateTime(1910, 6, 21), Zodiac.cancer, Zodiac.gemini),
      (DateTime(1918, 8, 23), Zodiac.virgo, Zodiac.leo),
      (DateTime(1925, 10, 23), Zodiac.scorpio, Zodiac.libra),
    ];
    final righe = <String>[];
    for (final (giorno, delleDateFisse, delSole) in cuspidi) {
      final a = amico('c', 'Cuspide', giorno);
      // La longitudine del Sole a mezzogiorno di Roma, letta direttamente.
      final l = IlSoleDiNascita.longitudine(LaLunaIntera.giornoGiuliano(
          IlFusoDellaNascita.inUtc(
              DateTime(giorno.year, giorno.month, giorno.day, 12),
              'Europe/Rome')));
      righe.add('${giorno.day}/${giorno.month}/${giorno.year}: Sole a '
          '${l.toStringAsFixed(2)} gradi, ${a.segno.italianName} (le date '
          'fisse dicevano ${delleDateFisse.italianName})');
      expect(a.segno, delSole);
      expect(a.segno, isNot(delleDateFisse));
      expect(Zodiac.values[l ~/ 30], delSole,
          reason: 'il segno e\' il settore di trenta gradi del Sole');
    }
    print('FC.10.8 b: ${righe.join('; ')}');
  });

  Future<void> laRubrica(WidgetTester tester, List<Amico> scritti,
      {PortaFintaDelCerchioSociale? porta,
      IlCerchioSociale? sociale,
      bool icone = true}) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SizedBox());
    if (!icone) {
      // La cache delle immagini sopravvive fra le prove dello stesso file:
      // senza svuotarla l'emblema sarebbe gia' pronto (visto nella FC.09).
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
    }
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final amici = AmiciOffline();
    await tester.runAsync(() async {
      await amici.carica();
      for (final a in scritti) {
        await amici.aggiungi(a, Tier.tier3);
      }
    });
    final finta = porta ?? PortaFintaDelCerchioSociale();
    await tester.pumpWidget(MultiProvider(
      providers: [
        if (sociale != null)
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
        home: AmiciScreen(amici: amici),
      ),
    ));
    if (icone) {
      await tester.runAsync(() async {
        final ctx = tester.element(find.byType(AmiciScreen));
        for (final z in Zodiac.values) {
          await precacheImage(AssetImage(ZodiacArt.emblemPath(z)), ctx);
        }
      });
    }
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  final tre = [
    amico('lucia', 'Lucia', DateTime(1990, 1, 12),
        ora: '08:10', fuso: 'Europe/Rome'),
    amico('marco', 'Marco', DateTime(1985, 7, 15)),
    // Una nascita in cuspide, senza ora: le date fisse dicevano Acquario.
    amico('sara', 'Sara', DateTime(1950, 1, 20)),
  ];

  testWidgets(
      'c) il segno nel tondo e\' quello che dicono la rubrica e l\'oroscopo, '
      'su tre amici', (tester) async {
    await laRubrica(tester, tre);
    final righe = <String>[];
    for (final a in tre) {
      final riga = find.byKey(Key('amico_${a.id}'));
      final percorso = percorsoNelTondo(tester, riga);
      final sottotitolo = tester
          .widgetList<Text>(
              find.descendant(of: riga, matching: find.byType(Text)))
          .map((t) => t.data ?? '')
          .firstWhere((t) => t.contains('nascita del'));
      expect(percorso, ZodiacArt.emblemPath(a.segno));
      expect(sottotitolo, startsWith('${a.segno.italianName}, nascita del'));
      righe.add('${a.nome}: tondo ${a.segno.italianName}, rubrica '
          '"$sottotitolo"');
    }
    // L'oroscopo di ognuno: la frase del segno occidentale.
    for (final a in tre) {
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(lOroscopoDiUnAmico(a));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final frase = tester
          .widget<Text>(find.byKey(const Key('oroscopo_frase_occidentale')))
          .data!;
      expect(frase, contains(a.segno.italianName),
          reason: 'l\'oroscopo di ${a.nome} dice un altro segno: $frase');
      // E il titolo porta lo stesso emblema.
      final titolo = find.byKey(Key('emblema_amico_${a.id}')).first;
      expect(percorsoNelTondo(tester, titolo), ZodiacArt.emblemPath(a.segno));
      righe.add('${a.nome}: oroscopo "$frase"');
    }
    print('FC.10.8 c: ${righe.join('; ')}');
  });

  testWidgets(
      'e, f) nessun tondo vuoto nella rubrica Offline: senza immagine la '
      'lettera, con l\'immagine l\'emblema', (tester) async {
    // Prima che le immagini siano caricate: la lettera del nome.
    await laRubrica(tester, tre, icone: false);
    final lettere = <String>[];
    for (final a in tre) {
      final tondo = find.byKey(Key('emblema_amico_${a.id}'));
      final lettera = find.descendant(
          of: tondo, matching: find.byKey(const Key('icona_tonda_iniziale')));
      expect(lettera, findsOneWidget,
          reason: 'il tondo di ${a.nome} e\' vuoto prima dell\'immagine');
      final t = tester
          .widget<Text>(
              find.descendant(of: lettera, matching: find.byType(Text)))
          .data;
      expect(t, a.nome.substring(0, 1).toUpperCase());
      lettere.add('${a.nome}: "$t"');
    }
    // Con le immagini: l'emblema, e nessuna lettera.
    await laRubrica(tester, tre);
    expect(find.byKey(const Key('icona_tonda_iniziale')), findsNothing);
    // L'amico senza data non esiste sul ramo: il modulo non salva senza la
    // data, e un dato salvato senza data non si legge.
    expect(Amico.fromJson({'id': 'x', 'nome': 'Senza data'}), isNull);
    print(
        'FC.10.8 e, f: prima delle immagini le lettere ${lettere.join(', ')}; '
        'con le immagini lettere 0; amico senza data letto dal telefono: '
        '${Amico.fromJson({'id': 'x', 'nome': 'Senza data'})}');
  });

  testWidgets('g) le letture per apertura della rubrica sono invariate',
      (tester) async {
    // Lo stesso conto della FC.09, con tre amici scritti e i loro emblemi:
    // la tendina appena arrivata si riusa, nessuna chiamata.
    final finta = PortaFintaDelCerchioSociale();
    final sociale = IlCerchioSociale(porta: finta);
    await tester.runAsync(() async {
      await sociale.sincronizza(
          identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
      await sociale.caricaIlCerchio();
      await sociale.caricaLaTendina();
    });
    final prima = finta.chieste.length;
    await laRubrica(tester, tre, porta: finta, sociale: sociale);
    final chiamate = finta.chieste.length - prima;
    expect(chiamate, 0);
    expect(find.byKey(const Key('emblema_amico_lucia')), findsOneWidget);
    print('FC.10.8 g: chiamate al server all\'apertura della rubrica coi tre '
        'emblemi $chiamate (prima della FC.10: 0)');
  });

  test('il metodo e\' nel foglio delle fonti, con le parole del fondatore', () {
    expect(
        IlSegnoDelCielo.metodo,
        'Il segno è calcolato dalla posizione reale del Sole alla data di '
        'nascita. In assenza dell\'ora di nascita si usa mezzogiorno.');
  });
}

import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/possibilita_di_incontro.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';
import 'package:esoteric_circle/features/synastry/user_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Sinastria VIP: responso e quattro barre deterministici per coppia, senza AI,
/// piu' la schermata avvolta nel cosmo, il ritratto del VIP sul polo destro, la
/// foto opzionale dell'utente e la card condivisibile.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  /// **LA FIRMA E' CAMBIATA CON L'ORDINE BO VOCE 02, LE MISURE NO.**
  ///
  /// `SynastryReport.forPair(Zodiac, Vip)` non esiste piu', e non e' stata
  /// sostituita da un guscio che ne imita il comportamento: prendeva il solo
  /// segno solare, ed era esattamente il difetto (93 coppie di VIP con lo
  /// stesso responso). Adesso il responso vuole un CIELO. Queste prove
  /// parlavano di "un utente di quel segno", quindi qui si costruisce una
  /// persona nata a mezzogiorno dentro quel segno, senza luogo: e' la stessa
  /// affermazione di prima, detta con l'oggetto giusto.
  final cieliDiSegno = <Zodiac, CieloDiSinastria>{};
  CieloDiSinastria cieloDi(Zodiac segno) => cieliDiSegno.putIfAbsent(segno, () {
        final (mese, giorno) = segno.from;
        // Tre giorni dentro il segno, cosi' nessun caso limite di confine.
        final data = DateTime(1990, mese, giorno).add(const Duration(days: 3));
        return CieloDiSinastria.perIdentita(
            BirthIdentity.fromParts(birthDate: data));
      });

  SynastryReport responso(Zodiac utente, Vip vip) =>
      SynastryReport.perCieli(tuo: cieloDi(utente), vip: vip);

  group('Responso deterministico', () {
    test('La stessa coppia da sempre lo stesso esito', () {
      final vip = VipCatalog.first;
      final a = responso(Zodiac.leo, vip);
      final b = responso(Zodiac.leo, vip);
      expect(a.overall, b.overall);
      expect(a.reading, b.reading);
      expect(a.love, b.love);
      expect(a.mental, b.mental);
      expect(a.sparks, b.sparks);
      expect(a.meetingPercent, b.meetingPercent);
    });

    test('La fascia nasce dal cerchio, e il cerchio dai suoi tre canali', () {
      // **QUESTA PROVA MISURAVA IL DIFETTO.** Diceva che due persone dello
      // stesso segno sono "Anime gemelle" col cerchio sopra 80, ed era vero
      // solo perche' il calcolo guardava il segno e nient'altro: erano i 93
      // responsi identici, visti dall'altra parte. Il segno condiviso non e'
      // piu' una promessa di intesa, e non deve esserlo: due Gemelli nati a
      // sei mesi di distanza hanno Lune e Veneri lontanissime. Cio' che resta
      // vero, e che qui si misura, e' che la fascia sia SEMPRE quella che il
      // cerchio merita, per ogni coppia del catalogo.
      for (final vip in VipCatalog.vips) {
        final r = responso(Zodiac.gemini, vip);
        final attesa = r.overall >= 85
            ? 'Anime gemelle'
            : r.overall >= 75
                ? 'Grande intesa'
                : r.overall >= 64
                    ? 'Bella sintonia'
                    : r.overall >= 54
                        ? 'Attrazione curiosa'
                        : 'Due poli lontani';
        expect(r.band, attesa,
            reason: '${vip.name}: cerchio ${r.overall} e fascia ${r.band}');
      }
    });

    test('Il cerchio e le tre barre restano nel range leggibile', () {
      for (final user in Zodiac.values) {
        for (final vip in VipCatalog.vips) {
          final r = responso(user, vip);
          expect(r.overall, inInclusiveRange(0, 99));
          expect(r.love, inInclusiveRange(0, 100));
          expect(r.mental, inInclusiveRange(0, 100));
          expect(r.sparks, inInclusiveRange(0, 100));
        }
      }
    });

    test('La possibilita di incontro sta nella scala dichiarata', () {
      // **QUESTA PROVA MISURAVA IL DIFETTO.** Pretendeva che il numero
      // restasse fra 0,2 e 4,0 per cento *per tutti*, ed era esattamente cio'
      // che il fondatore ha contestato: "la possibilita' di incontro e'
      // sempre bassa, mentre se un vip abita nella mia citta' dovrebbe avere
      // maggiori probabilita'". Il tetto e il pavimento adesso li dichiara
      // `PossibilitaDiIncontro`, e cio' che si misura qui e' che il numero ci
      // stia dentro, non che sia sempre piccolo. Che poi sia DIVERSO da VIP a
      // VIP lo misura la prova dedicata alla voce BO.03.
      for (final user in Zodiac.values) {
        for (final vip in VipCatalog.vips) {
          final r = responso(user, vip);
          if (!r.incontro.esiste) {
            expect(r.meetingPercent, 0, reason: vip.name);
            continue;
          }
          expect(
              r.meetingPercent,
              inInclusiveRange(PossibilitaDiIncontro.pavimento,
                  PossibilitaDiIncontro.tetto),
              reason: vip.name);
          expect(r.incontro.perche, isNotEmpty, reason: vip.name);
        }
      }
    });

    test('Le sette barre ci sono tutte, nell ordine di layout', () {
      // **DA QUATTRO A SETTE, ordine BX voce 09.** Il fondatore ha chiesto
      // altre dimensioni di affinita\' oltre a quelle presenti: le tre nuove
      // sono Terra comune (elementi, Tetrabiblos I.17-18), Ritmo (qualita\',
      // I.12) e Vita quotidiana (aspetti di Luna e Ascendente). L'ordine
      // delle prime tre e l'ultimo posto della possibilita\' di incontro non
      // sono cambiati: le nuove stanno in mezzo.
      final r = responso(Zodiac.aries, VipCatalog.first);
      expect(r.bars, hasLength(7));
      expect(r.bars[0].label, contains('amore'));
      expect(r.bars[1].label, contains('mentale'));
      expect(r.bars[2].label, 'Scintille');
      expect(r.bars[3].label, 'Terra comune');
      expect(r.bars[4].label, 'Ritmo');
      expect(r.bars[5].label, 'Vita quotidiana');
      expect(r.bars[6].label, contains('incontro'));
      // Solo l ultima barra porta la micro battuta.
      expect(r.bars[6].quip, isNotEmpty);
      expect(r.bars[0].quip, isEmpty);
    });

    test('Il testo nomina il fatto vero, il VIP e la chiusura', () {
      // Prima qui si pretendeva 'Stesso segno', che era la riga generica
      // nata dal solo segno solare. L'ordine BO voce 02 la sostituisce col
      // FATTO: quale punto di lui tocca quale punto tuo, e con che angolo.
      final vip = VipCatalog.first; // Angelina Jolie
      final r = responso(Zodiac.gemini, vip);
      expect(r.aspetti, isNotEmpty);
      expect(r.reading, contains(r.aspetti.first.fatto));
      expect(r.reading, contains('Angelina Jolie'));
      expect(r.reading.trim().endsWith('.'), isTrue);
    });

    test('Ogni VIP ha un carattere agganciato allo stem', () {
      for (final vip in VipCatalog.vips) {
        final r = responso(Zodiac.aries, vip);
        // Nessun ripiego generico: il nome del VIP compare nel testo.
        expect(r.reading, contains(vip.name),
            reason: 'Carattere mancante per ${vip.name} (${vip.stem})');
      }
    });

    test('Nessuna virgola seguita da e nei testi composti', () {
      final vietato = RegExp(r',\s+ed?\b');
      for (final user in Zodiac.values) {
        for (final vip in VipCatalog.vips) {
          final r = responso(user, vip);
          expect(vietato.hasMatch(r.reading), isFalse,
              reason: 'Virgola con e in: ${r.reading}');
        }
      }
    });

    test('La percentuale minima usa la virgola decimale', () {
      final r = responso(Zodiac.aries, VipCatalog.first);
      expect(r.meetingLabel, contains(','));
      expect(r.meetingLabel.endsWith('%'), isTrue);
    });
  });

  group('Catalogo VIP', () {
    test('Almeno un VIP e sempre precaricato', () {
      expect(VipCatalog.vips, isNotEmpty);
      expect(VipCatalog.first, VipCatalog.vips.first);
    });

    test('I cinquanta VIP portano tutti il loro stem', () {
      expect(VipCatalog.vips, hasLength(50));
      for (final vip in VipCatalog.vips) {
        expect(vip.hasImage, isTrue, reason: 'Stem mancante per ${vip.name}');
      }
    });

    test('Il modello VIP risolve il ritratto bundlato dallo stem', () {
      // Il dossier dell'ordine BO voce 01: la data, lo stato in vita,
      // l'esposizione e le fonti sono obbligatori, e non per burocrazia: un
      // VIP senza stato in vita e' un VIP a cui l'app puo' promettere un
      // incontro impossibile.
      const senza = Vip(
          name: 'X',
          sign: Zodiac.leo,
          annoDiNascita: 1980,
          meseDiNascita: 8,
          giornoDiNascita: 1,
          statoInVita: StatoInVita.inVita,
          esposizione: EsposizionePubblica.media,
          fonti: {});
      expect(senza.hasImage, isFalse);
      expect(senza.thumbPath, isNull);
      expect(senza.fullPath, isNull);
      const con = Vip(
          name: 'Y',
          sign: Zodiac.leo,
          annoDiNascita: 1980,
          meseDiNascita: 8,
          giornoDiNascita: 1,
          statoInVita: StatoInVita.inVita,
          esposizione: EsposizionePubblica.media,
          fonti: {},
          stem: 'vip_angelina-jolie_v1');
      expect(con.hasImage, isTrue);
      expect(con.thumbPath,
          'assets/img_thumb/ritratti-vip/vip_angelina-jolie_v1.webp');
      expect(con.fullPath,
          'assets/img/ritratti-vip/vip_angelina-jolie_v1.webp');
    });

    test('Ogni ritratto agganciato esiste come file, piena e miniatura', () {
      for (final vip in VipCatalog.vips) {
        if (vip.hasImage) {
          expect(File(vip.thumbPath!).existsSync(), isTrue,
              reason: 'Miniatura mancante per ${vip.name}: ${vip.thumbPath}');
          expect(File(vip.fullPath!).existsSync(), isTrue,
              reason: 'Ritratto pieno mancante per ${vip.name}: ${vip.fullPath}');
        }
      }
    });
  });

  group('Foto utente, solo in memoria', () {
    test('Scegliere una foto la porta in memoria, toglierla la azzera',
        () async {
      final controller =
          UserPhotoController(service: _FakePhotoService(Uint8List.fromList([1, 2, 3])));
      expect(controller.hasPhoto, isFalse);
      final ok = await controller.pickFrom(UserPhotoSource.gallery);
      expect(ok, isTrue);
      expect(controller.hasPhoto, isTrue);
      controller.clear();
      expect(controller.hasPhoto, isFalse);
    });

    test('Un errore o un rifiuto resta al segnaposto, senza schianti', () async {
      final controller = UserPhotoController(service: _FakePhotoService(null));
      final ok = await controller.pickFrom(UserPhotoSource.camera);
      expect(ok, isFalse);
      expect(controller.hasPhoto, isFalse);
    });
  });

  Future<void> pumpScreen(WidgetTester tester,
      {Zodiac userSign = Zodiac.gemini,
      UserPhotoController? photo,
      String userName = 'Tu',
      DateTime? userBirth,
      Vip? vip}) async {
    silenceSensors();
    // Superficie alta, cosi' l'intera colonna scorrevole (barre, tasto, picker)
    // e' costruita e trovabile senza scroll manuale.
    tester.view.physicalSize = const Size(440, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: SinastriaVipScreen(
            userSign: userSign,
            photoController: photo,
            userName: userName,
            userBirth: userBirth,
            vip: vip),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('La schermata mostra il cerchio, il polo VIP e i VIP',
      (tester) async {
    await pumpScreen(tester);
    expect(find.byKey(const Key('sinastria_list')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_gauge')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_pole_vip')), findsOneWidget);
    expect(find.byKey(const Key('sinastria_reading')), findsOneWidget);
    // **SI SCORRE PER CERCARLO.** La lista e' pigra e con le tre barre nuove
    // dell'ordine BX voce 09 il tasto Condividi e' sceso sotto il bordo:
    // cercarlo senza scorrere diceva "non c'e'" mentre era al suo posto.
    await tester.scrollUntilVisible(
        find.byKey(const Key('sinastria_share')), 200,
        scrollable: find.descendant(
            of: find.byKey(const Key('sinastria_list')),
            matching: find.byType(Scrollable)));
    expect(find.byKey(const Key('sinastria_share')), findsOneWidget);
    // Il selettore in fondo non c'e' piu': al suo posto il tasto Cambia VIP.
    //
    // **SI SCORRE FINO A LUI, non fino al tasto sopra.** L'elenco e' pigro, e
    // Cambia VIP sta sotto Condividi: dopo l'ordine CC voce 06f l'infografica
    // e' salita sotto la bolla e la coda della pagina si e' ridisposta, quindi
    // fermarsi su Condividi lasciava Cambia VIP appena fuori dal viewport.
    await tester.scrollUntilVisible(
        find.byKey(const Key('sinastria_change_vip')), 200,
        scrollable: find.descendant(
            of: find.byKey(const Key('sinastria_list')),
            matching: find.byType(Scrollable)));
    expect(find.byKey(const Key('sinastria_change_vip')), findsOneWidget);
    expect(find.text('Il tuo VIP'), findsNothing);
  });

  testWidgets('Il responso viene prima delle barre', (tester) async {
    await pumpScreen(tester);
    final readingY = tester
        .getTopLeft(find.byKey(const Key('sinastria_reading')))
        .dy;
    final barsY = tester.getTopLeft(find.text('Scintille')).dy;
    expect(readingY, lessThan(barsY));
  });

  testWidgets('Col nome e la data reali, il cartiglio del polo utente li mostra',
      (tester) async {
    await pumpScreen(tester,
        userName: 'Sofia', userBirth: DateTime(1993, 4, 12));
    final ritratto = tester.widget<VipFramedPortrait>(
      find.descendant(
        of: find.byKey(const Key('sinastria_pole_user')),
        matching: find.byType(VipFramedPortrait),
      ),
    );
    expect(ritratto.name, 'Sofia');
    expect(ritratto.name, isNot('Tu'));
    expect(ritratto.date, italianLongDate(DateTime(1993, 4, 12)));
  });

  testWidgets('Senza nome reale, il cartiglio del polo utente resta Tu',
      (tester) async {
    await pumpScreen(tester);
    final ritratto = tester.widget<VipFramedPortrait>(
      find.descendant(
        of: find.byKey(const Key('sinastria_pole_user')),
        matching: find.byType(VipFramedPortrait),
      ),
    );
    expect(ritratto.name, 'Tu');
  });

  testWidgets('Per chi non c\'è più la scena cambia domanda', (tester) async {
    // **Ordine BO voce 04, IN ALBERO e non solo nel dato.** La barra
    // dell'incontro non deve esistere come widget: una barra a zero e'
    // comunque una promessa mancata messa sotto gli occhi.
    await pumpScreen(tester, vip: VipCatalog.conNome('Giorgio Armani')!);
    expect(find.byKey(const Key('sinastria_eredita')), findsOneWidget,
        reason: 'la scena non dice cosa resta');
    expect(find.text('Possibilità di incontro'), findsNothing,
        reason: 'la barra dell\'incontro è ancora in albero');
    // E chi c'e' ce l'ha ancora.
    await pumpScreen(tester, vip: VipCatalog.conNome('Zendaya')!);
    expect(find.byKey(const Key('sinastria_eredita')), findsNothing);
    expect(find.text('Possibilità di incontro'), findsOneWidget);
  });

  testWidgets('Il responso apre sul VIP passato, non sul primo del catalogo',
      (tester) async {
    final scelto = VipCatalog.vips[2];
    await pumpScreen(tester, vip: scelto);

    // Il polo VIP mostra il VIP scelto, e il cerchio la sua percentuale.
    final ritratto = tester.widget<VipFramedPortrait>(
      find.descendant(
        of: find.byKey(const Key('sinastria_pole_vip')),
        matching: find.byType(VipFramedPortrait),
      ),
    );
    expect(ritratto.name, scelto.name);
    // **L'ATTESA SI CHIEDE ALLA STESSA PORTA DELLA SCHERMATA.** Il responso
    // non nasce piu' dal segno ma dal cielo, quindi ricostruirne uno
    // somigliante qui vorrebbe dire misurare due oggetti diversi: si usa il
    // cielo di ripiego che la scena stessa monta quando il guscio non c'e'.
    final expected = SynastryReport.perCieli(
      tuo: SinastriaVipScreenState.cieloDiRipiego(
          BirthIdentity.example.birthMoment, Zodiac.gemini, 'Tu'),
      vip: scelto,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('sinastria_gauge')),
        matching: find.text('${expected.overall}%'),
      ),
      findsOneWidget,
    );
  });
}

/// Sorgente foto finta per i test: niente camera ne galleria, byte prefissati.
class _FakePhotoService implements UserPhotoService {
  _FakePhotoService(this._bytes);
  final Uint8List? _bytes;

  @override
  Future<Uint8List?> pick(UserPhotoSource source) async => _bytes;
}

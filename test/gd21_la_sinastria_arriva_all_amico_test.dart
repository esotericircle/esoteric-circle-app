// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/cielo_evolutivo.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/il_corpus_della_sinastria_evolutiva.g.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/la_lettura_evolutiva.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/legame_e_eta.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/la_sinastria_ricevuta_screen.dart';
import 'package:esoteric_circle/features/synastry/sinastria_evolutiva_screen.dart';
import 'package:esoteric_circle/features/tarot/attesa_di_medora.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LA LETTURA ARRIVA ANCHE ALL'AMICO DEL CERCHIO.** Ordine GD voce GD.21,
/// 23 ottobre 2026 (proposta dell'Architetto approvata dal fondatore con "2
/// si"): quando la persona della sinastria e' un amico del Cerchio, il
/// responso arriva anche a lei, con l'avviso che il vostro cielo e' stato
/// letto. Vincolo: niente dati di nascita a chi non li ha dati, nessun invio
/// a chi non e' nel Cerchio.
///
/// **IL GIRO FRA DUE IDENTITA' DI COLLAUDO FINTE**: "u-io" (Lunaria, chi
/// legge) e "u-stella" (Stella Lieve, la sua amica del Cerchio). Il server e'
/// una memoria in questa prova, con la stessa regola della porta vera
/// (`laSinastriaSiConsegna` in `functions/src/sinastria_evolutiva.ts`,
/// provata a parte da `sinastria_evolutiva.test.ts`): consegna solo fra
/// amici. Il telefono di chi legge manda, quello dell'amica riceve dalla sua
/// porta `ilMioCerchio` e mostra il responso: lo stesso, parola per parola.
class _IlServer {
  /// Gli amici di ciascuno, come il server li sa.
  final Map<String, Set<String>> amici = {
    'u-io': {'u-stella'},
    'u-stella': {'u-io'},
  };

  /// La raccolta `sinastrie` di ciascuno.
  final Map<String, List<Map<String, Object?>>> sinastrie = {};

  /// Ogni corpo arrivato alla porta `mandaLaSinastria`.
  final List<Map<String, Object?>> arrivati = [];
}

class _PortaDi extends PortaFintaDelCerchioSociale {
  _PortaDi(this.io, this.server, {super.nome});

  final String io;
  final _IlServer server;

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'mandaLaSinastria') {
      chieste.add((porta, corpo));
      server.arrivati.add(corpo);
      final a = '${corpo['a']}';
      if (!(server.amici[io]?.contains(a) ?? false)) {
        return const EsitoSociale(dati: {
          'ok': false,
          'perche': 'nonAmici',
          'riga': 'La lettura arriva solo agli amici del Cerchio.',
        });
      }
      server.sinastrie.putIfAbsent(a, () => []).add({
        'id': '$io-${corpo['idMovimento']}',
        'da': io,
        'nomeDa': 'Lunaria',
        'quando': DateTime(2026, 10, 23, 18).millisecondsSinceEpoch,
        'responso': corpo['responso'],
      });
      return const EsitoSociale(dati: {'ok': true});
    }
    final esito = await super.sociale(porta, corpo);
    if (porta == 'ilMioCerchio' && esito != null) {
      return EsitoSociale(dati: {
        ...esito.dati,
        'sinastrie': server.sinastrie[io] ?? const [],
      });
    }
    return esito;
  }
}

final _marco = CieloEvolutivo.perNascita(
    momentoUtc: DateTime.utc(1990, 5, 12, 14, 30), nome: 'Lunaria');
final _stella = CieloEvolutivo.perNascita(
    momentoUtc: DateTime.utc(1992, 9, 3, 8, 15), nome: 'Stella Lieve');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LaSuoneria.spentaPerLeProve = false;
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
  });
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  Future<IlCerchioSociale> cerchioDi(
      WidgetTester tester, _PortaDi porta) async {
    final s = IlCerchioSociale(porta: porta);
    await tester.runAsync(() => s.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 14, 30)),
        oggi: DateTime(2026, 10, 23)));
    await tester.runAsync(s.caricaIlCerchio);
    return s;
  }

  Widget app(Widget home, IlCerchioSociale sociale, {Tier tier = Tier.tier2}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(
              create: (_) => SettingsController(suonoEVibrazione: false)),
          ChangeNotifierProvider(
              create: (_) => EntitlementService(initial: tier)),
          ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (c, f) => MaestroScope(child: f!),
          home: home,
        ),
      );

  Future<void> passa(WidgetTester tester, [int volte = 6]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> leggi(WidgetTester tester, IlCerchioSociale sociale,
      {String? uid, String nome = 'Stella Lieve'}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Una schermata nuova a ogni lettura: lo stato non si riusa.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(
        SinastriaEvolutivaScreen(
          nomeTuo: 'Tu',
          cieloTuo: _marco,
          oggi: DateTime(2026, 10, 23),
          chiediLaPersona: (_) async => SceltaDellaSinastria(
              nome: nome,
              cielo: _stella,
              legame: Legame.amicizia,
              uidDelCerchio: uid),
        ),
        sociale));
    await passa(tester, 8);
    await tester.tap(find.byKey(const Key('sinastria_scegli_la_persona')));
    await passa(tester, 4);
    await tester.pump(AttesaDiMedora.durataMinima);
    await passa(tester, 6);
  }

  testWidgets(
      'GD.21: il giro fra due identita\' di collaudo: la lettura di u-io '
      'arriva a u-stella, la stessa, senza nascite, con l\'avviso',
      (tester) async {
    final server = _IlServer();
    final io = await cerchioDi(tester, _PortaDi('u-io', server));
    expect(io.cerchio.amici.map((p) => p.uid), contains('u-stella'));
    await leggi(tester, io, uid: 'u-stella');

    // Il telefono di chi legge ha mandato una volta, alla sua amica.
    expect(server.arrivati, hasLength(1));
    expect(server.arrivati.single['a'], 'u-stella');
    final corpo = jsonEncode(server.arrivati.single['responso']);
    print('GD.21 IL CORPO CONSEGNATO: ${corpo.length} caratteri');
    for (final nascita in const ['1992', '1990', '08:15', '14:30', 'nascita']) {
      expect(corpo.contains(nascita), isFalse,
          reason: 'nel responso consegnato passa un dato di nascita: $nascita');
    }
    final riga = find.byKey(const Key('sinastria_consegnata'));
    await tester.scrollUntilVisible(riga, 400,
        scrollable: find.byType(Scrollable).last, maxScrolls: 120);
    expect(tester.widget<Text>(riga).data,
        'La vostra lettura è arrivata anche a Stella Lieve, nel suo Cerchio.');

    // Lo stesso responso: i capitoli che il piano di chi legge apre, parola
    // per parola, come li compone la lettura.
    final letti = LetturaEvolutiva.componi(
        tuo: _marco,
        suo: _stella,
        nomeSuo: 'Stella Lieve',
        legame: Legame.amicizia,
        corpus: corpusDellaSinastriaEvolutiva);

    // Il telefono dell'amica: la sua porta ilMioCerchio porta la sinastria.
    final stella = await cerchioDi(
        tester, _PortaDi('u-stella', server, nome: 'Stella Lieve'));
    expect(stella.cerchio.sinastrie, hasLength(1),
        reason: 'all\'amica del Cerchio la lettura non e\' arrivata');
    final ricevuta = stella.cerchio.sinastrie.single;
    expect(ricevuta.da, 'u-io');
    await tester
        .pumpWidget(app(LaSinastriaRicevutaScreen(ricevuta: ricevuta), stella));
    await passa(tester, 6);
    expect(find.text('Il vostro cielo è stato letto'), findsOneWidget);
    var confrontati = 0;
    for (final c in letti) {
      final titolo = find.byKey(Key('sinastria_ricevuta_${c.capitolo.name}'));
      await tester.scrollUntilVisible(titolo, 300,
          scrollable: find.byType(Scrollable).first, maxScrolls: 120);
      // Il titolo del responso va a capo fra le parole: si confronta il testo.
      expect(tester.widget<Text>(titolo).data!.replaceAll('\n', ' '), c.titolo,
          reason: 'il titolo arrivato non e\' quello letto');
      for (final p in c.paragrafi) {
        await tester.scrollUntilVisible(find.text(p), 300,
            scrollable: find.byType(Scrollable).first, maxScrolls: 120);
        expect(find.text(p), findsOneWidget,
            reason: 'un paragrafo letto non e\' arrivato uguale');
      }
      confrontati++;
    }
    print('GD.21 CAPITOLI ARRIVATI UGUALI: $confrontati su ${letti.length}');
    expect(confrontati, 5);
  });

  testWidgets(
      'GD.21: a chi non e\' nel Cerchio non arriva niente e il telefono non '
      'chiama nemmeno la porta', (tester) async {
    final server = _IlServer();
    final porta = _PortaDi('u-io', server);
    final io = await cerchioDi(tester, porta);
    // Una persona che il Cerchio non conosce come amica.
    await leggi(tester, io, uid: 'u-sconosciuta', nome: 'Sara');
    expect(porta.chieste.where((c) => c.$1 == 'mandaLaSinastria'), isEmpty,
        reason: 'il telefono ha chiamato la porta per chi non e\' amico');
    expect(server.sinastrie, isEmpty);
    // E una persona offline (senza Cerchio): niente.
    await leggi(tester, io, nome: 'Bianca');
    expect(porta.chieste.where((c) => c.$1 == 'mandaLaSinastria'), isEmpty);
    expect(server.sinastrie, isEmpty,
        reason: 'a chi non e\' nel Cerchio e\' arrivata una lettura');
    print('GD.21 A CHI NON E\' NEL CERCHIO: chiamate '
        '${porta.chieste.where((c) => c.$1 == 'mandaLaSinastria').length}, '
        'consegne ${server.sinastrie.length}');
  });
}

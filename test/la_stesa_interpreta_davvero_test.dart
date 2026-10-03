import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione_dati.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **LA STESA INTERPRETA DAVVERO.** Ordine EQ voce 04, 27 settembre 2026.
///
/// Il fondatore: *"LE RISPOSTE SONO TROPPO CRIPTICHE, SONO QUASI SENZA
/// SENSO"* e *"Ma una interpretazione la fa veramente o sono testi buttati li'
/// tanto per accontentare?"*. Erano testi fissi: il consiglio composto da
/// elenchi di frasi, e sotto ogni carta il significato del suo verso, lo
/// stesso nel passato, nel presente e nel futuro e per qualunque domanda.
///
/// Qui si pretende la strada nuova, pezzo per pezzo:
/// - il corpus delle carte nella loro posizione e' intero, e nessun suo
///   testo e' il significato generale;
/// - senza modello, ogni carta si legge col testo della sua posizione;
/// - al modello arrivano la domanda, l'argomento, la carta chiave e per ogni
///   carta il suo significato tradizionale (il testo della posizione no: lo
///   parafrasava);
/// - la lettura del modello diventa la lettura a schermo, con la risposta per
///   prima; le guardie scartano quella che non regge, si ritenta col motivo,
///   le frasi col genere si riscrivono o, finiti i tentativi, si tolgono;
/// - la schermata la aspetta e la mostra, e senza modello legge di casa.
///
/// Se la lettura **risponde** e se **interpreta** lo misura il collaudo con
/// Gemini vero, `tool/collaudo_eq04.dart`: una prova di casa non puo'
/// giudicare un testo libero.
void main() {
  // --- Il corpus ---

  test('ogni carta ha i suoi tre testi, in tutti e due i versi', () {
    final mancanti = <String>[];
    for (final c in TarotDeck.cards) {
      for (final verso in const ['dritta', 'capovolta']) {
        final testi = carteNellaPosizione['${c.name}|$verso'];
        if (testi == null ||
            testi.length != SpreadPosition.values.length ||
            testi.any((t) => t.trim().isEmpty)) {
          mancanti.add('${c.name}|$verso');
        }
      }
    }
    cardinaleMinimo(carteNellaPosizione.length, 156,
        cosa: 'chiavi del corpus delle carte nella posizione',
        perche: 'settantotto carte per due versi: se il corpus si svuota, '
            'ogni carta torna al testo uguale per tutte le posizioni');
    expect(mancanti, isEmpty, reason: 'carte senza i loro tre testi: $mancanti');
    expect(carteNellaPosizione.length, TarotDeck.cards.length * 2,
        reason: 'il corpus porta chiavi che il mazzo non conosce');
  });

  test('i tre testi di una carta sono diversi fra loro e dal significato',
      () {
    final colpe = <String>[];
    for (final c in TarotDeck.cards) {
      for (final capovolta in const [false, true]) {
        final testi =
            carteNellaPosizione['${c.name}|${capovolta ? 'capovolta' : 'dritta'}']!;
        if (testi.toSet().length != testi.length) {
          colpe.add('${c.name}: due posizioni con lo stesso testo');
        }
        final significato = capovolta ? c.reversed : c.upright;
        if (testi.contains(significato)) {
          colpe.add('${c.name}: una posizione ripete il significato generale');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  // --- La lettura di casa ---

  test('senza modello ogni carta si legge col testo della sua posizione', () {
    final colpe = <String>[];
    var guardate = 0;
    for (var seme = 0; seme < 60; seme++) {
      final stesa = TarotSpread.draw(seed: seme);
      final lettura = TarotReading.of(stesa, TarotTopic.momentoCheVivo);
      for (final p in lettura.posizioni) {
        guardate++;
        if (p.testo != LeCarteNellaPosizione.di(p.drawn)) {
          colpe.add('seme $seme, ${p.drawn.displayName}: non e\' il testo '
              'della sua posizione');
        }
        if (p.testo == p.drawn.meaning) {
          colpe.add('seme $seme, ${p.drawn.displayName}: e\' il significato '
              'uguale per tutte le posizioni');
        }
      }
    }
    cardinaleMinimo(guardate, 180,
        cosa: 'carte lette di casa',
        perche: 'sessanta stese per tre carte');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('la stessa carta dice cose diverse nel passato e nel futuro', () {
    final torre = TarotDeck.cards.firstWhere((c) => c.name == 'La Torre');
    final nelPassato = LeCarteNellaPosizione.di(DrawnCard(
        card: torre, position: SpreadPosition.passato, reversed: false));
    final nelFuturo = LeCarteNellaPosizione.di(DrawnCard(
        card: torre, position: SpreadPosition.futuro, reversed: false));
    expect(nelPassato, isNot(nelFuturo));
    expect(nelPassato, isNot(torre.upright));
  });

  // --- Cio' che arriva al modello ---

  test('la richiesta porta la domanda, l\'argomento e ogni carta', () {
    final stesa = TarotSpread.draw(seed: 11);
    const domanda = 'Devo accettare l\'offerta di lavoro a Milano?';
    final r = LaLetturaDellaStesa.richiesta(stesa,
        domanda: domanda, argomento: TarotTopic.lavoroTrovare.label);
    expect(r, contains(domanda));
    expect(r, contains(TarotTopic.lavoroTrovare.label));
    expect(r,
        contains('Carta chiave: '
            '${TarotReading.chiaveDi(stesa).drawn.displayName}'),
        reason: 'la chiave del modello e\' quella della schermata');
    for (final d in stesa.cards) {
      expect(r, contains(d.displayName));
      expect(r, contains(d.meaning),
          reason: 'il modello parte dal significato tradizionale');
      // Il testo della posizione non ci va: il modello lo parafrasava invece
      // di leggere la carta sulla domanda (sonde 13 e 14).
      expect(r, isNot(contains(LeCarteNellaPosizione.di(d))));
    }
  });

  test('l\'istruzione chiede la risposta per prima e le carte nella posizione',
      () {
    final i = LaLetturaDellaStesa.istruzione(CourtesyForm.neutral);
    expect(i, contains('La prima risponde alla domanda in modo diretto'));
    expect(i, contains('leggila nella sua posizione'));
    expect(i, contains('partendo dalla carta chiave che ti indico'));
    expect(i, contains('sempre rispetto alla domanda della persona'));
    expect(i, contains('Nessuna previsione data per certa'));
  });

  // --- La lettura del modello ---

  LetturaDelModello buona(TarotSpread s) => LetturaDelModello(
        risposta: 'Le carte indicano che puoi accettare, a patto di chiarire '
            'prima le condizioni. ${s.presente.card.name} nel presente dice '
            'che la decisione e\' matura.',
        passato: '${s.passato.card.name} nel passato racconta da dove parti: '
            'un lavoro che ti stava stretto.',
        presente: '${s.presente.card.name} nel presente dice che adesso hai '
            'gli strumenti per scegliere.',
        futuro: '${s.futuro.card.name} nel futuro indica un ambiente dove il '
            'tuo mestiere puo\' crescere.',
        legame: 'Dal passato al futuro le carte vanno da una chiusura a un '
            'inizio.',
        consiglio: 'Questa settimana chiedi per iscritto orari e compenso.',
      );

  test('la lettura del modello diventa la lettura a schermo', () {
    final stesa = TarotSpread.draw(seed: 3);
    final l = buona(stesa);
    final r = TarotReading.of(stesa, TarotTopic.lavoroTrovare,
        domandaScritta: 'Devo accettare l\'offerta di lavoro a Milano?',
        dalModello: l);
    expect(r.consiglio, startsWith(l.risposta),
        reason: 'la risposta e\' la prima cosa che si legge');
    expect(r.consiglio, contains(l.legame));
    expect(r.consiglio, contains(l.consiglio));
    expect(r.posizioni.map((p) => p.testo).toList(),
        [l.passato, l.presente, l.futuro]);
    // Chi ha scritto la sua domanda non la ritrova in coda.
    expect(r.consiglio.split('\n\n').last, l.consiglio);
  });

  test('la domanda di chiusura resta a chi non ha scritto la sua', () {
    final stesa = TarotSpread.draw(seed: 4);
    final r = TarotReading.of(stesa, TarotTopic.momentoCheVivo,
        dalModello: buona(stesa));
    expect(r.consiglio.split('\n\n').last, r.domanda);
  });

  test('il cielo di oggi resta accanto alle carte', () {
    final stesa = TarotSpread.draw(seed: 5);
    const cielo = 'La Luna oggi passa sul tuo Sole.';
    final r = TarotReading.of(stesa, TarotTopic.momentoCheVivo,
        fattoDelCielo: cielo, dalModello: buona(stesa));
    expect(r.consiglio, contains(VoceDellaStesa.rigaDelCielo(cielo)));
  });

  test('le guardie scartano la lettura che non regge', () {
    final stesa = TarotSpread.draw(seed: 6);
    final l = buona(stesa);
    expect(LaLetturaDellaStesa.scarto(l, stesa), isNull,
        reason: 'una lettura buona deve passare, o la prova sotto non '
            'distingue niente');
    LetturaDelModello con({String? risposta, String? passato}) =>
        LetturaDelModello(
          risposta: risposta ?? l.risposta,
          passato: passato ?? l.passato,
          presente: l.presente,
          futuro: l.futuro,
          legame: l.legame,
          consiglio: l.consiglio,
        );
    expect(
        LaLetturaDellaStesa.scarto(
            con(passato: 'Qui c\'era una carta.'), stesa),
        isNotNull,
        reason: 'una carta letta senza nominarla');
    expect(
        LaLetturaDellaStesa.scarto(
            con(risposta: 'Fra 3 mesi arriva la risposta.'), stesa),
        isNotNull,
        reason: 'una cifra');
    expect(LaLetturaDellaStesa.scarto(con(risposta: 'x' * 400), stesa),
        isNotNull,
        reason: 'una risposta oltre il tetto');
    expect(
        LaLetturaDellaStesa.scarto(
            con(passato: '${stesa.passato.card.name} dice che ti tiene '
                'legata a un vecchio posto.'),
            stesa,
            forma: CourtesyForm.neutral),
        isNotNull,
        reason: 'un genere dato a chi legge, con la forma neutra');
  });

  test('"solo" che vuol dire "soltanto" non da\' un genere a chi legge', () {
    // Dalla sonda 5 del collaudo: una lettura buona scartata tre volte per
    // "essere solo esteriore". Il criterio si restringe sull'avverbio e
    // continua a prendere l'aggettivo.
    for (final avverbio in const [
      'La gioia che provi potrebbe essere solo esteriore.',
      'Ti lascia solo una domanda.',
    ]) {
      expect(formeContrarieAllaForma(avverbio, CourtesyForm.neutral), isEmpty,
          reason: avverbio);
    }
    for (final aggettivo in const [
      'Rischi di restare solo con i tuoi pensieri.',
      'Non vuoi essere solo.',
    ]) {
      expect(formeContrarieAllaForma(aggettivo, CourtesyForm.neutral),
          isNotEmpty,
          reason: aggettivo);
    }
  });

  test('ogni radice del confine sta nelle parole dette al modello', () {
    // La guardia a valle scarta la frase rivolta alla persona che contiene una
    // di queste radici: se il modello non le conosce, la lettura cade per
    // niente. Una radice nuova nel confine fa cadere questa prova finche'
    // non arriva anche al modello.
    for (final radice in ConfineDelResponso.temiDelicati) {
      expect(LaLetturaDellaStesa.paroleDelConfine, contains(radice),
          reason: 'il modello non sa che "$radice" fa cadere la lettura');
    }
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.neutral),
        contains(LaLetturaDellaStesa.paroleDelConfine));
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.neutral),
        contains(ConfineDelResponso.perIlModello));
  });

  test('la riga senza genere arriva solo a chi non ha scelto una forma', () {
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.neutral),
        contains(LaLetturaDellaStesa.senzaGenere));
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.unknown),
        contains(LaLetturaDellaStesa.senzaGenere));
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.feminine),
        isNot(contains(LaLetturaDellaStesa.senzaGenere)));
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.masculine),
        isNot(contains(LaLetturaDellaStesa.senzaGenere)));
  });

  test('una lettura scartata si chiede di nuovo, col motivo', () async {
    final stesa = TarotSpread.draw(seed: 9);
    final l = buona(stesa);
    final richieste = <String>[];
    // Un difetto che non e' il genere: per il genere c'e' la riscrittura,
    // provata qui sotto.
    final conCifra = {
      ...l.toJson(),
      'risposta': 'Fra 3 mesi le carte indicano un cambio. '
          '${stesa.presente.card.name} lo dice.',
    };
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        richieste.add(r);
        return jsonEncode(richieste.length == 1 ? conCifra : l.toJson());
      },
    );
    expect(letta, isNotNull, reason: '${LaLetturaDellaStesa.ultimiScarti}');
    expect(richieste.length, 2);
    expect(LaLetturaDellaStesa.ultimiTentativi, 2);
    expect(richieste.first, isNot(contains('non si può mostrare')));
    expect(richieste.last, contains('non si può mostrare'));
    expect(richieste.last, contains('una cifra'),
        reason: 'il motivo arriva al modello');
  });

  test('finiti i tentativi, la frase col genere si toglie e la lettura resta',
      () async {
    final stesa = TarotSpread.draw(seed: 12);
    final l = buona(stesa);
    final conGenere = {
      ...l.toJson(),
      'passato': '${l.passato} Ti ha lasciato stanco.',
    };
    var chiamate = 0;
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        // Le riscritture non contano: qui tornano senza il campo delle
        // frasi, e la lettura va avanti coi tentativi.
        if (i != LaLetturaDellaStesa.istruzioneDellaRiscrittura) chiamate++;
        return jsonEncode(conGenere);
      },
    );
    expect(chiamate, LaLetturaDellaStesa.tentativi,
        reason: 'la cura viene dopo i tentativi, non al loro posto');
    expect(letta, isNotNull, reason: '${LaLetturaDellaStesa.ultimiScarti}');
    expect(LaLetturaDellaStesa.ultimaCurata, isTrue);
    expect(letta!.passato, l.passato,
        reason: 'si toglie la sola frase col genere');
    expect(letta.risposta, l.risposta);
  });

  test('le frasi col genere si riscrivono, e la carta resta nominata',
      () async {
    final stesa = TarotSpread.draw(seed: 14);
    final l = buona(stesa);
    final carta = stesa.presente.card.name;
    final riscritture = <String>[];
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        if (i == LaLetturaDellaStesa.istruzioneDellaRiscrittura) {
          riscritture.add(r);
          return jsonEncode(
              {'frasi': '$carta nel presente indica che senti un peso.'});
        }
        return jsonEncode({
          ...l.toJson(),
          'presente': '$carta nel presente indica che ti senti sopraffatto.',
        });
      },
    );
    expect(letta, isNotNull, reason: '${LaLetturaDellaStesa.ultimiScarti}');
    expect(LaLetturaDellaStesa.ultimaRiscritta, isTrue);
    expect(LaLetturaDellaStesa.ultimiTentativi, 1,
        reason: 'la riscrittura viene prima di rigenerare');
    expect(riscritture.single, contains('ti senti sopraffatto'),
        reason: 'si manda al correttore la sola frase col genere');
    expect(letta!.presente, '$carta nel presente indica che senti un peso.');
    expect(formeContrarieAllaForma(letta.presente, CourtesyForm.neutral),
        isEmpty);
  });

  test('il genere nella risposta non si cura: parla la lettura di casa',
      () async {
    final stesa = TarotSpread.draw(seed: 13);
    final l = buona(stesa);
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => jsonEncode({
        ...l.toJson(),
        'risposta': 'Sei pronto a cambiare. ${stesa.presente.card.name} lo '
            'dice.',
      }),
    );
    expect(letta, isNull,
        reason: 'la risposta alla domanda non si taglia per curarla');
    expect(LaLetturaDellaStesa.ultimaCurata, isFalse);
  });

  test('dopo tre letture scartate parla la lettura di casa', () async {
    final stesa = TarotSpread.draw(seed: 10);
    var chiamate = 0;
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        chiamate++;
        return jsonEncode({'risposta': 'Solo questa.'});
      },
    );
    expect(letta, isNull);
    expect(chiamate, LaLetturaDellaStesa.tentativi);
  });

  test('il trattino lungo e la virgola con la e si correggono, non si buttano',
      () async {
    final stesa = TarotSpread.draw(seed: 7);
    final l = buona(stesa);
    final grezza = {
      ...l.toJson(),
      'legame': 'Le carte vanno da una chiusura — a un inizio, e lo '
          'fanno piano.',
    };
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => jsonEncode(grezza),
    );
    expect(letta, isNotNull, reason: '${LaLetturaDellaStesa.ultimoScarto}');
    expect(letta!.legame, isNot(contains('—')));
    expect(letta.legame, isNot(contains(', e ')));
  });

  test('una chiamata che non torna lascia parlare la lettura di casa',
      () async {
    final stesa = TarotSpread.draw(seed: 8);
    final rotta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => throw const SocketException('niente rete'),
    );
    expect(rotta, isNull);
    final lenta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) => Completer<String?>().future,
      entro: const Duration(milliseconds: 20),
    );
    expect(lenta, isNull);
    final mezza = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => jsonEncode({'risposta': 'Solo questa.'}),
    );
    expect(mezza, isNull, reason: 'una lettura a meta\' non si mostra');
  });

  // --- La schermata ---

  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key('stesa_fan_$indice'));
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
  }

  Future<void> premi(WidgetTester tester) async {
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0; i < 40; i++) {
      if (pulsante.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(pulsante).onPressed != null) {
        await tester.tap(pulsante, warnIfMissed: false);
        return;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    fail('il pulsante che apre il responso non si e\' mai acceso');
  }

  /// Monta la stesa, pesca tre carte e preme "Leggi le Carte". [chiamata]
  /// riceve la stesa vera, letta dalla schermata dopo il pescaggio.
  Future<TarotSpread> leggiLeCarte(WidgetTester tester,
      Future<String?> Function(TarotSpread stesa, String richiesta)
          chiamata) async {
    silenzia();
    // Alta abbastanza da costruire tutto il responso: la lista e' pigra, e
    // una bolla fuori dalla finestra non c'e' proprio.
    tester.view.physicalSize = const Size(402, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late TarotSpread stesa;
    await tester.pumpWidget(attorno(StesaTreCarteScreen(
      seed: 2,
      skipIntro: true,
      topic: TarotTopic.bivio,
      chiamata: (i, r, c) => chiamata(stesa, r),
    )));
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
    }
    stesa = tester
        .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
        .stesaCorrente;
    await premi(tester);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    return stesa;
  }

  /// Gli spazi si contano come uno: la lettura va a capo in paragrafi suoi
  /// (`spezzaInParagrafi`), e un a capo non e' una parola diversa.
  String piano(String t) => t.replaceAll(RegExp(r'\s+'), ' ').trim();

  String testoDi(WidgetTester tester, String chiave) => piano([
        for (final r in tester.widgetList<RichText>(find.descendant(
            of: find.byKey(Key(chiave)), matching: find.byType(RichText))))
          r.text.toPlainText(),
      ].join(' '));

  testWidgets('la schermata aspetta la lettura del modello e la mostra',
      (tester) async {
    var richieste = 0;
    LetturaDelModello? mandata;
    final stesa = await leggiLeCarte(tester, (s, richiesta) async {
      richieste++;
      mandata = buona(s);
      return jsonEncode(mandata!.toJson());
    });
    expect(richieste, 1, reason: 'una chiamata sola per stesa');
    expect(find.byKey(const Key('stesa_consiglio')), findsOneWidget);
    final consiglio = testoDi(tester, 'stesa_consiglio');
    expect(consiglio, contains(piano(mandata!.risposta)),
        reason: 'il consiglio a schermo non comincia dalla risposta del '
            'modello');
    for (final d in stesa.cards) {
      expect(testoDi(tester, 'stesa_letta_${d.position.name}'),
          contains(piano(mandata!.della(d.position))),
          reason: '${d.position.label}: non e\' il testo del modello');
    }
  });

  testWidgets('senza modello la schermata legge le carte nella posizione',
      (tester) async {
    final stesa = await leggiLeCarte(
        tester, (s, r) async => throw const SocketException('niente rete'));
    expect(find.byKey(const Key('stesa_consiglio')), findsOneWidget);
    for (final d in stesa.cards) {
      expect(testoDi(tester, 'stesa_letta_${d.position.name}'),
          contains(piano(LeCarteNellaPosizione.di(d))),
          reason: '${d.position.label}: senza modello si legge il testo della '
              'sua posizione');
    }
  });
}

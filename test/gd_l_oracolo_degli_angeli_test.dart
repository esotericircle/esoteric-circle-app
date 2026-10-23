// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/oracolo_angeli/le_domande_dell_oracolo.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/components/riquadro_arancione.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/la_mappa_dei_cori.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/i_comandi_dipinti.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'il_giro_dell_oracolo.dart';
import 'sorgenti_di_lib.dart';

/// **ORDINE GD, PARTE C: L'ORACOLO DEGLI ANGELI.** 23 ottobre 2026.
///
/// Le prove delle voci da GD.06 a GD.12. Il modello e' finto (R2), oppure
/// non torna, che e' il caso che sul telefono del fondatore mostrava il
/// messaggio della rete e toglieva la Lunga. Il filmato non si apre: la
/// scena e' ferma da subito.
class _Ferma implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _fallito = false;
  @override
  bool get pronto => false;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    _fallito = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

final _nascita = BirthIdentity(
    birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true);

Future<void> _monta(WidgetTester tester,
    {Tier tier = Tier.tier1, bool colModello = true}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const SizedBox());
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(
              suonoEVibrazione: false, effettiSonori: false)),
      ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (c, figlio) => MaestroScope(child: figlio!),
      home: OracoloDegliAngeliScreen(
        fabbricaDellaScena: _Ferma.new,
        caso: Random(7),
        adesso: () => DateTime(2026, 10, 15, 10, 5),
        identita: _nascita,
        chiamata: (i, r, c) async {
          if (!colModello) throw StateError('GD: la rete non c\'e\'');
          return jsonFintoDellOracolo(c);
        },
      ),
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

bool _acceso(WidgetTester tester, String chiave) =>
    tester.widget<PulsanteDipinto>(find.byKey(Key(chiave))).onTap != null;

/// Il testo di un sorgente con le stringhe adiacenti unite ('...' '...'),
/// cosi' una frase spezzata su due righe si trova intera.
/// Le righe di commento non contano: la lapide che racconta il pulsante
/// tolto non e' il pulsante.
String _unito(String s) => s
    .split('\n')
    .where((r) => !r.trimLeft().startsWith('//'))
    .join('\n')
    .replaceAll(RegExp(r"'\s*\n\s*'"), '');

void main() {
  setUp(silenziaISensoriDelCosmo);

  group('GD.06 via il pulsante rotondo di invio della domanda', () {
    test('il pulsante rotondo non esiste piu\' in lib', () {
      final trovati = <String>[];
      var guardati = 0;
      for (final f in sorgentiDiLib()) {
        final s = _unito(f.readAsStringSync());
        guardati++;
        for (final segno in const [
          "Key('oracolo_affida')",
          "Key('oracolo_simbolo_dell_invio')",
          'simboloDellInvio',
          "'Affida la domanda'",
          'col pulsante rotondo',
        ]) {
          if (s.contains(segno)) trovati.add('${f.path}: $segno');
        }
      }
      cardinaleMinimo(guardati, quantiFileHaLib, cosa: 'file di lib');
      expect(trovati, isEmpty, reason: trovati.join('\n'));
    });

    testWidgets(
        'domanda non data, domanda data col mazzo acceso, carte scelte col '
        'pulsante giallo acceso', (tester) async {
      await _monta(tester);
      final stati = <String, Object>{};
      String guida() => tester
          .widget<Text>(find.byKey(const Key('oracolo_guida_della_scelta')))
          .data!;
      stati['1 senza domanda: guida'] = guida();
      stati['1 senza domanda: avvia acceso'] =
          _acceso(tester, 'oracolo_avvia_la_lettura');
      final campo = find.byKey(const Key('oracolo_campo_domanda'));
      await Scrollable.ensureVisible(tester.element(campo), alignment: 0.5);
      await tester.pump();
      await tester.enterText(campo, 'Devo cambiare casa?');
      await tester.pump();
      stati['2 domanda scritta: guida'] = guida();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await scegliLeTreCarte(tester);
      stati['3 carte scelte: guida'] = guida();
      stati['3 carte scelte: avvia acceso'] =
          _acceso(tester, 'oracolo_avvia_la_lettura');
      print('GD.06: $stati');
      expect(stati['1 senza domanda: guida'],
          'Il mazzo si apre quando scrivi o scegli la tua domanda.');
      expect(stati['1 senza domanda: avvia acceso'], isFalse);
      expect(stati['2 domanda scritta: guida'], startsWith('Scegli la prima'),
          reason: 'scritta la domanda il mazzo non si accende da solo');
      expect(stati['3 carte scelte: avvia acceso'], isTrue);
    });

    testWidgets('anche la domanda scelta fra le proposte accende il mazzo',
        (tester) async {
      await _monta(tester);
      final tema = find.byKey(const Key('oracolo_tema_amore'));
      await Scrollable.ensureVisible(tester.element(tema.first),
          alignment: 0.3);
      await tester.pump();
      await tester.tap(tema.first);
      await tester.pump();
      await tester.tap(find.byKey(const Key('oracolo_proposta_0')));
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const Key('oracolo_proposte')), findsNothing);
      expect(
          tester
              .widget<Text>(find.byKey(const Key('oracolo_guida_della_scelta')))
              .data,
          startsWith('Scegli la prima'));
    });
  });

  test('GD.09 il messaggio di assenza di rete non esiste in lib', () {
    final trovati = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      final s = _unito(f.readAsStringSync());
      guardati++;
      for (final segno in const [
        'arriva quando la rete',
        'Medora oggi risponde dai doni',
        "Key('oracolo_solo_corpus')",
      ]) {
        if (s.contains(segno)) trovati.add('${f.path}: $segno');
      }
    }
    cardinaleMinimo(guardati, quantiFileHaLib, cosa: 'file di lib');
    expect(trovati, isEmpty, reason: trovati.join('\n'));
  });

  group('GD.07, GD.08, GD.09 e GD.12 dopo la lettura', () {
    testWidgets(
        'le carte in piedi, il fondo, il messaggio della rete, la '
        'terna e la mappa dei cori', (tester) async {
      await _monta(tester, colModello: false);
      await consultaLOracolo(tester, 'Devo cambiare casa?');
      // Le carte finiscono di alzarsi dopo il responso.
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      // GD.07: la fila delle tre carte in piedi contro la larghezza.
      final r = [
        for (final p in [0, 1, 2])
          tester.getRect(find.byKey(Key('oracolo_in_piedi_$p'))),
      ];
      final larghezza = tester.view.physicalSize.width;
      final fila = r.last.right - r.first.left;
      print('GD.07: carte larghe ${r.map((x) => x.width.toStringAsFixed(1))} '
          'punti, alte ${r.first.height.toStringAsFixed(1)}, la fila '
          '${fila.toStringAsFixed(1)} su ${larghezza.toStringAsFixed(0)} '
          '(${(fila / larghezza * 100).toStringAsFixed(1)} per cento)');
      expect(fila / larghezza, greaterThanOrEqualTo(0.9),
          reason: 'la fila delle carte in piedi non occupa quasi tutta la '
              'larghezza');
      for (final x in r) {
        expect(x.height, greaterThan(x.width),
            reason: 'la carta in piedi non sta in verticale');
      }
      // GD.09: il messaggio della rete non c'e', anche col responso dai doni.
      expect(find.byKey(const Key('oracolo_solo_corpus')), findsNothing);
      expect(find.textContaining('quando la rete'), findsNothing);
      // GD.08: sotto "Affida una nuova domanda" nessuna bolla.
      expect(find.byKey(const Key('oracolo_angelo_dell_ora')), findsNothing);
      final nuova =
          tester.getRect(find.byKey(const Key('oracolo_nuova_domanda')));
      final sotto = find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('oracolo_') &&
          w is! Text);
      final dopo = [
        for (final e in sotto.evaluate())
          if (tester.getRect(find.byWidget(e.widget).first).top > nuova.bottom)
            (e.widget.key! as ValueKey<String>).value,
      ];
      expect(dopo, isEmpty,
          reason: 'sotto "Affida una nuova domanda" c\'e\' ancora: $dopo');
      // GD.12: la terna una volta sola nel responso.
      final responso = find.byKey(const Key('oracolo_responso'));
      for (final parola in const ['FARE', 'SENTIRE', 'CAPIRE']) {
        final n = find
            .descendant(
                of: responso,
                matching: find.byWidgetPredicate(
                    (w) => w is Text && (w.data ?? '').toUpperCase() == parola))
            .evaluate()
            .length;
        expect(n, 1, reason: '$parola compare $n volte in cima al responso');
      }
      expect(find.byKey(const Key('oracolo_gradino_0')), findsNothing,
          reason: 'la scala colorata e\' ancora nel responso');
      // GD.12: il dato della mappa viene dagli angeli della lettura.
      final accesi = <int>{};
      final nomi = <String>[];
      for (final ruolo in RuoloDellAngelo.values) {
        final nome = tester
            .widget<Text>(find.byKey(Key('oracolo_nome_${ruolo.name}')))
            .data!;
        nomi.add(nome);
        accesi.add(LaMappaDeiCori.postoDel(
            AngelCatalog.all.firstWhere((a) => a.name == nome).choir));
      }
      final aVideo = {
        for (var p = 0; p < 9; p++)
          if (find
              .byKey(Key('oracolo_coro_della_mappa_${p}_acceso'))
              .evaluate()
              .isNotEmpty)
            p,
      };
      final frase = tester
          .widget<Text>(find.byKey(const Key('oracolo_frase_dei_cori')))
          .data!;
      print('GD.12: angeli $nomi, cori attesi $accesi, accesi a video '
          '$aVideo, frase "$frase"');
      expect(aVideo, accesi,
          reason: 'i cori accesi non sono quelli degli angeli usciti');
      for (final p in accesi) {
        expect(frase, contains(LaMappaDeiCori.nomeDel(AngelCatalog.choirs[p])),
            reason: 'la frase non nomina il coro di una carta');
      }
    });
  });

  group('GD.10 la Lunga dell\'Oracolo, col modello e senza', () {
    for (final colModello in const [true, false]) {
      testWidgets(
          'scelta la Lunga, due paragrafi in piu\' e il riquadro "Il salmo '
          'propiziatorio" ${colModello ? 'col modello' : 'senza modello'}',
          (tester) async {
        await _monta(tester, colModello: colModello);
        await scegliLaLunga(tester);
        await consultaLOracolo(tester, 'Devo cambiare casa?');
        final pezzi = [
          for (final p in const [
            'risposta',
            'cosa_fare',
            'approfondimento',
            'rito'
          ])
            if (find.byKey(Key('oracolo_principale_$p')).evaluate().isNotEmpty)
              p,
        ];
        final titolo = find.descendant(
            of: find.byType(RiquadroArancione),
            matching: find.byKey(const Key('oracolo_principale_titolo_rito')));
        print('GD.10 ${colModello ? 'col modello' : 'senza modello'}: '
            '${pezzi.length} pezzi $pezzi, riquadro '
            '"${titolo.evaluate().isEmpty ? '' : tester.widget<Text>(titolo).data}"');
        expect(pezzi.length, 4, reason: '$pezzi');
        expect(tester.widget<Text>(titolo).data, 'Il salmo propiziatorio');
      });
    }

    test('la Lunga dai doni regge su ogni angelo e ogni tema', () {
      final guasti = <String>[];
      var lunghe = 0;
      final domande = [
        for (final t in TemaDellOracolo.values) ...t.domande.take(3),
      ];
      for (var n = 1; n <= 72; n++) {
        Angel a(int k) => AngelCatalog.byNumber((n + k - 1) % 72 + 1);
        final tre = [
          CartaDellOracolo(
              ruolo: RuoloDellAngelo.custode, angelo: a(0), portatore: a(0)),
          CartaDellOracolo(
              ruolo: RuoloDellAngelo.cuore, angelo: a(7), portatore: a(7)),
          CartaDellOracolo(
              ruolo: RuoloDellAngelo.intelletto,
              angelo: a(23),
              portatore: a(23)),
        ];
        final una = EstrazioneDellOracolo.dallaScelta(n);
        final d = domande[n % domande.length];
        for (final carte in [tre, una]) {
          final r = LaLetturaDellOracolo.delCorpus(
                  domanda: d,
                  carte: carte,
                  corpus: corpusDellOracolo,
                  variante: n,
                  profonda: true)
              .responso;
          lunghe++;
          final dove = '${a(0).name} ${carte.length} carte "$d"';
          if (r.approfondimento == null || r.rito == null) {
            guasti.add('$dove: la Lunga manca');
            continue;
          }
          if (!LaFormaDelResponso.aMisura(r.approfondimento!)) {
            guasti.add('$dove: approfondimento di '
                '${LaFormaDelResponso.parole(r.approfondimento!)} parole');
          }
          if (r.approfondimento == r.risposta ||
              r.approfondimento == r.cosaFare) {
            guasti.add('$dove: l\'approfondimento ripete un paragrafo');
          }
        }
      }
      cardinaleMinimo(lunghe, 144, cosa: 'responsi Lunghi dai doni');
      print('GD.10: responsi Lunghi dai doni $lunghe, guasti ${guasti.length}');
      expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
    });
  });

  group('GD.11 le schede delle singole carte', () {
    testWidgets(
        'la risposta per prima, segni della stessa misura, margini '
        'uguali, nessun vuoto', (tester) async {
      await _monta(tester);
      await consultaLOracolo(tester, 'Devo cambiare casa?');
      final misure = <String, Map<String, String>>{};
      final sinistre = <double>{};
      final segni = <Size>{};
      for (final ruolo in RuoloDellAngelo.values) {
        final r = ruolo.name;
        Rect q(String k) => tester.getRect(find.byKey(Key(k)));
        final bolla = q('oracolo_bolla_$r');
        final carta = q('oracolo_carta_della_bolla_$r');
        final segnoRuolo = q('oracolo_segno_ruolo_$r');
        final segnoCoro = q('oracolo_segno_coro_$r');
        final nome = q('oracolo_nome_$r');
        final testata = q('oracolo_testata_$r');
        final messaggio = q('oracolo_messaggio_$r');
        final chiE = q('oracolo_chi_e_$r');
        segni
          ..add(segnoRuolo.size)
          ..add(segnoCoro.size);
        // I margini, misurati dal bordo della bolla.
        sinistre.add(carta.left - bolla.left);
        expect(segnoRuolo.left, segnoCoro.left,
            reason: '$r: i due segni non stanno sulla stessa colonna');
        expect(nome.left, segnoRuolo.left,
            reason: '$r: il nome non sta allo stesso margine dei segni');
        expect(messaggio.top, lessThan(chiE.top),
            reason: '$r: i dettagli vengono prima della risposta');
        expect(
            find
                .byKey(Key('oracolo_carta_singola_${r}_risposta'))
                .evaluate()
                .isNotEmpty,
            isTrue,
            reason: '$r: il messaggio e\' chiuso all\'apertura');
        expect(testata.height, lessThanOrEqualTo(carta.height),
            reason: '$r: la testata e\' piu\' alta della carta');
        expect(find.byKey(Key('oracolo_carta_singola_${r}_titolo_cosa_fare')),
            findsNothing,
            reason: '$r: la carta singola ha il riquadro');
        misure[r] = {
          'margine carta': (carta.left - bolla.left).toStringAsFixed(1),
          'segno ruolo': '${segnoRuolo.width}x${segnoRuolo.height}',
          'segno coro': '${segnoCoro.width}x${segnoCoro.height}',
          'colonna segni': (segnoRuolo.left - bolla.left).toStringAsFixed(1),
          'vuoto accanto alla carta':
              (carta.height - testata.height).toStringAsFixed(1),
        };
      }
      print('GD.11: $misure');
      expect(segni, hasLength(1),
          reason: 'i segni hanno misure diverse: $segni');
      expect(sinistre, hasLength(1),
          reason: 'le carte non hanno lo stesso margine: $sinistre');
    });
  });
}

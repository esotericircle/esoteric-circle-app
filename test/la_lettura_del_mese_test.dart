/// LA LETTURA IN PROSA DEL MESE, DAL PIANO A 9,90. Ordine CG voce 11.
///
/// Le misure di accettazione dell'ordine: una chiamata al modello per mese e
/// per persona, i token in ingresso misurati e dichiarati, e la lettura che
/// non compare a chi non ha il piano, verificato SUL PIANO VERO e non su una
/// copia locale.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/ricordi/lettura_del_mese.dart';
import 'package:esoteric_circle/core/ricordi/riassunti_del_tempo.dart';
import 'package:esoteric_circle/services/ricordi/penna_vera_del_mese.dart';

/// Una penna che non chiama nessun modello e conta quante volte le si chiede.
class _PennaContata extends PennaDelMese {
  int chiamate = 0;
  String? ultimoIngresso;

  @override
  Future<String?> scrivi({
    required String mese,
    required RiassuntoDelTempo riassunto,
    required List<RiassuntoDelTempo> settimane,
    required String maestro,
  }) async {
    chiamate++;
    ultimoIngresso = PennaVeraDelMese.ingresso(
        mese: mese, riassunto: riassunto, settimane: settimane);
    return 'Ad agosto sei tornato spesso da $maestro.';
  }
}

RiassuntoDelTempo _riassunto({
  int voci = 30,
  Map<String, int> perMaestro = const {'caligo': 20, 'aura': 10},
}) =>
    RiassuntoDelTempo(
      chiave: '2026-08',
      quanteVoci: voci,
      perMaestro: perMaestro,
      perArte: const {'gettata': 12, 'meditazione': 10, 'tramonto': 8},
      quantiTraguardi: 3,
      quantiDoni: 4,
      eosGuadagnati: 120,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('CG.11: al Viandante la lettura NON compare, e l\'invito c\'e\'',
      () async {
    final penna = _PennaContata();
    final lettura = LetturaDelMese(penna: penna);
    await lettura.carica();

    final fuori = await lettura.per(
      mese: '2026-08',
      tier: Tier.free,
      riassunto: _riassunto(),
      settimane: const [],
    );

    expect(fuori, isNull,
        reason: 'chi non paga non vede la lettura. IL ROSSO SI DIMOSTRA '
            'togliendo il controllo del piano, e qui torna un testo');
    expect(penna.chiamate, 0,
        reason: 'e non si chiama nemmeno il modello: un cancello che paga la '
            'chiamata e poi butta la risposta costa senza dare niente');
    expect(LetturaDelMese.invito.trim(), isNotEmpty,
        reason: 'al suo posto compare un invito che dichiara cosa otterrebbe, '
            'non un testo in grigio ne\' un lucchetto sopra la prosa');
  });

  test('CG.11: dall\'Iniziato in su la lettura compare', () async {
    for (final tier in const [Tier.tier1, Tier.tier2, Tier.tier3]) {
      SharedPreferences.setMockInitialValues(const {});
      final penna = _PennaContata();
      final lettura = LetturaDelMese(penna: penna);
      await lettura.carica();
      final fuori = await lettura.per(
        mese: '2026-08',
        tier: tier,
        riassunto: _riassunto(),
        settimane: const [],
      );
      expect(fuori, isNotNull, reason: 'il piano $tier deve vederla');
    }
    expect(LetturaDelMese.pianoMinimo, Tier.tier1,
        reason: 'l\'abbonamento a 9,90 al mese e\' l\'Iniziato, cioe\' il '
            'Tier 1: questa voce supera la riga che metteva l\'AI dal Tier 2');
  });

  test('CG.11: una chiamata al mese e per persona, non una per apertura',
      () async {
    final penna = _PennaContata();
    final lettura = LetturaDelMese(penna: penna);
    await lettura.carica();

    // Dieci aperture della schermata sullo stesso mese.
    for (var i = 0; i < 10; i++) {
      await lettura.per(
        mese: '2026-08',
        tier: Tier.tier1,
        riassunto: _riassunto(),
        settimane: const [],
      );
    }

    expect(penna.chiamate, 1,
        reason: 'dieci aperture hanno chiamato il modello ${penna.chiamate} '
            'volte. IL ROSSO SI DIMOSTRA generando la lettura a ogni apertura '
            'invece che una volta, e il conto diventa dieci');
    expect(lettura.chiamateAlModello, 1);

    // E un mese diverso ne chiede una sua.
    await lettura.per(
      mese: '2026-09',
      tier: Tier.tier1,
      riassunto: _riassunto(),
      settimane: const [],
    );
    expect(penna.chiamate, 2,
        reason: 'un mese nuovo ha la sua lettura, altrimenti settembre '
            'mostrerebbe il racconto di agosto');
  });

  test('CG.11: su un mese vuoto non si scrive, e non si chiama nessuno',
      () async {
    final penna = _PennaContata();
    final lettura = LetturaDelMese(penna: penna);
    await lettura.carica();
    final fuori = await lettura.per(
      mese: '2026-02',
      tier: Tier.tier3,
      riassunto: _riassunto(voci: 0, perMaestro: const {}),
      settimane: const [],
    );
    expect(fuori, isNull,
        reason: 'una lettura su un mese in cui non e\' successo niente '
            'sarebbe prosa su niente');
    expect(penna.chiamate, 0);
  });

  test('CG.11: in pareggio fra Maestri non si scrive', () async {
    final penna = _PennaContata();
    final lettura = LetturaDelMese(penna: penna);
    await lettura.carica();
    final fuori = await lettura.per(
      mese: '2026-08',
      tier: Tier.tier3,
      riassunto: _riassunto(perMaestro: const {'aura': 10, 'caligo': 10}),
      settimane: const [],
    );
    expect(fuori, isNull,
        reason: 'l\'ordine dice che la lettura la scrive il Maestro DOMINANTE '
            'di quel mese: in pareggio quel Maestro non c\'e\', e sceglierne '
            'uno a caso vorrebbe dire far parlare qualcuno al posto di un '
            'altro');
    expect(penna.chiamate, 0);
  });

  test('CG.11: l\'ingresso sono i RIASSUNTI, misurato in caratteri', () async {
    final penna = _PennaContata();
    final lettura = LetturaDelMese(penna: penna);
    await lettura.carica();
    await lettura.per(
      mese: '2026-08',
      tier: Tier.tier1,
      riassunto: _riassunto(voci: 1500),
      settimane: [
        for (var i = 1; i <= 5; i++)
          RiassuntoDelTempo(
            chiave: '2026-08-0$i..2026-08-0$i',
            quanteVoci: 300,
            perMaestro: const {'caligo': 300},
            perArte: const {'gettata': 300},
            quantiTraguardi: 1,
            quantiDoni: 5,
            eosGuadagnati: 20,
          ),
      ],
    );

    final quanti = penna.ultimoIngresso!.length;
    // ignore: avoid_print
    print('ORDINE CG VOCE 11: ingresso della lettura del mese, $quanti '
        'caratteri su un mese da 1.500 momenti, contro un tetto di '
        '${PennaVeraDelMese.massimiCaratteriInIngresso}');

    expect(quanti, lessThan(PennaVeraDelMese.massimiCaratteriInIngresso),
        reason: 'un mese da millecinquecento momenti manda $quanti caratteri: '
            'se sfonda il tetto vuol dire che qualcuno ha infilato i testi '
            'pieni nel prompt, che e\' cio\' che l\'ordine vieta');
    expect(penna.ultimoIngresso, isNot(contains('Uruz')),
        reason: 'nell\'ingresso non deve entrare nessun contenuto di responso');
  });

  test('CG.11: il modello e\' quello economico, e non e\' Anthropic', () {
    final sorgente =
        File('lib/services/ricordi/penna_vera_del_mese.dart').readAsStringSync();
    expect(sorgente.contains('kMaestroBreveModel'), isTrue,
        reason: 'la lettura lavora su un pugno di numeri e non deve ragionare: '
            'e\' il compito piu\' economico del progetto');
    // **SI GUARDA IL CODICE, NON I COMMENTI.** La regola d'oro dello stack si
    // spiega scrivendo "mai le API Anthropic", e una guardia che cercasse
    // quella parola nel file intero cadrebbe proprio sulla riga che dichiara
    // la regola. La grandezza giusta e' il codice: si tolgono i commenti e si
    // cerca li'.
    final soloCodice = sorgente
        .split('\n')
        .where((r) {
          final t = r.trimLeft();
          return !t.startsWith('//') && !t.startsWith('///') &&
              !t.startsWith('*') && !t.startsWith('/*');
        })
        .join('\n');
    for (final vietato in const ['anthropic', 'Anthropic', 'claude']) {
      expect(soloCodice.contains(vietato), isFalse,
          reason: 'il codice nomina "$vietato": il runtime resta Google, '
              'cioe\' Gemini su Vertex, ed e\' la regola d\'oro dello stack');
    }
    expect(soloCodice.contains('FirebaseAI.vertexAI()'), isTrue,
        reason: 'la penna deve passare da Vertex');
  });

  test('CG.11: la riga della matrice dice la lettura dal Tier 1', () {
    final riga = PlanCatalog.matrix
        .firstWhere((r) => r.label.contains('Cosmic Journal'));
    // ignore: avoid_print
    print('ORDINE CG VOCE 11: la riga del Cosmic Journal adesso dice '
        '${riga.values}');
    expect(riga.values.length, 4);
    expect(riga.values[0].toLowerCase(), isNot(contains('lettura')),
        reason: 'il Viandante non ha la lettura del mese');
    for (final i in const [1, 2, 3]) {
      expect(riga.values[i].toLowerCase(), contains('lettura'),
          reason: 'dall\'Iniziato in su la lettura c\'e\': la cella $i dice '
              '"${riga.values[i]}". IL ROSSO SI DIMOSTRA rimettendo la riga '
              'vecchia, che metteva l\'AI dal Tier 2');
    }
  });
}

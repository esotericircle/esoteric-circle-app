import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'dart:io';

import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL PIANO ATTIVO E I SUOI TETTI, PER OGNI ARTE.** Ordine CQ voce 1.01,
/// 3 settembre 2026.
///
/// **Il fatto che ha aperto la voce**, parole del fondatore: *"anche dopo aver
/// fatto l'aggiornamento al piano illuminato, il sistema mi dice ugualmente
/// che ho raggiunto il limite giornaliero. e questo mi e' capitato anche con i
/// tarocchi e altre funzionalita', questo e' molto grave."*
///
/// **La causa, misurata e non dedotta.** Il piano viveva in DUE posti che non
/// si parlavano mai: `EntitlementService` dentro il telefono, che il pulsante
/// "Attiva in Demo" cambiava, e `users/<uid>/stato/abbonamento.piano` su
/// Firestore, che **nessuno scriveva** e che valeva `free` per tutti. Il campo
/// `piano` arrivava dal server dentro `StatoDelCerchio` e nessuno lo leggeva.
///
/// Da li' i due fatti dello screenshot: il pannello delle rune mostrava il
/// tetto del piano LOCALE, trenta, e lo stato del piano del SERVER, esaurito.
/// E una gettata sola portava il conto da ventinove a zero, perche' al no del
/// server il client scriveva `_gettate = 1 << 20`.
///
/// **I tetti in se' non divergevano**: la tavola del client e quella del
/// server dicono gli stessi numeri, e `i_limiti_del_server_sono_quelli_promessi`
/// lo sorveglia gia' riga per riga. A divergere era **quale piano** ciascuna
/// parte credesse attivo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Le arti che hanno un tetto, con la riga del listino che lo promette e il
  /// modo in cui il motore lo applica. **Una riga per arte**: la voce chiede
  /// la verifica per OGNI arte, non a campione.
  final arti = <String, ({String riga, int? Function(QuestionAllowance, Tier) applicato})>{
    'domande': (
      riga: PlanCatalog.rigaDomande,
      applicato: (b, t) => b.dailyLimit(t),
    ),
    'approfondimenti': (
      riga: PlanCatalog.rigaApprofondimenti,
      applicato: (b, t) => b.limiteApprofondimenti(t),
    ),
    'confronti': (
      riga: PlanCatalog.rigaConfronti,
      applicato: (b, t) => b.limiteConfronti(t),
    ),
    'gettate': (
      riga: PlanCatalog.rigaGettate,
      applicato: (b, t) => b.limiteGettate(t),
    ),
    'stese': (
      riga: PlanCatalog.rigaStese,
      applicato: (b, t) => b.limiteStese(t),
    ),
    'sinastrie': (
      riga: PlanCatalog.rigaSinastria,
      applicato: (b, t) => b.limiteSinastrie(t),
    ),
  };

  test('per ogni piano e per ogni arte, il tetto applicato e quello promesso',
      () async {
    SharedPreferences.setMockInitialValues(const {});
    final borsa = QuestionAllowance();
    await borsa.load();
    var confronti = 0;
    final storti = <String>[];
    final tavola = <String>[];
    for (final tier in Tier.values) {
      for (final arte in arti.entries) {
        confronti++;
        final promesso =
            PlanCatalog.limiteGiornaliero(arte.value.riga, tier);
        final applicato = arte.value.applicato(borsa, tier);
        tavola.add('${tier.label} ${arte.key}: promesso $promesso, '
            'applicato $applicato');
        if (promesso != applicato) {
          storti.add('${tier.label}, ${arte.key}: il listino promette '
              '$promesso e il motore applica $applicato');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.01: la tavola dei tetti\n  ${tavola.join("\n  ")}');
    cardinaleMinimo(confronti, 24,
        cosa: 'confronti fra tetto promesso e tetto applicato',
        perche: 'Se l elenco delle arti si svuotasse, questa prova sarebbe '
            'verde senza aver confrontato niente.');
    expect(storti, isEmpty, reason: storti.join('\n'));
  });

  test('LE 29 SU 30 DELLO SCREENSHOT: da dove viene quel trenta', () async {
    // **LA DOMANDA DELL'ORDINE CQ, RILANCIO PUNTO 1.** "Nessuna lettura da'
    // 30": una darebbe 50 (Illuminato) e l'altra 1 (free). Il trenta pero'
    // c'e', e non viene da una terza lettura: **e' il tetto dell'Adepto**, e
    // discende dal piano come tutti gli altri.
    //
    // **Le ore degli screenshot lo dicono.** La schermata delle Rune col "29
    // su 30" e' delle **20:09**; quella dei Piani con "L'Illuminato attivo in
    // Demo" e' delle **20:13**, quattro minuti DOPO. Alle 20:09 il telefono
    // era sull'Adepto, che di gettate ne ha trenta, e una era gia' stata
    // fatta.
    //
    // **E non esiste nessun terzo lettore**: ogni punto che nomina il tetto
    // delle gettate passa da `limiteGettate`, che legge la matrice. Sono tre
    // punti, tutti in `rune_draw_screen.dart`, e li elenca la prova qui
    // sotto.
    SharedPreferences.setMockInitialValues(const {});
    final borsa = QuestionAllowance();
    await borsa.load();
    borsa.registraGettata(Tier.tier2);
    final frase = QuestionAllowance.residuoDiCosa(
      borsa.gettateRimaste(Tier.tier2)!,
      borsa.limiteGettate(Tier.tier2)!,
      uno: 'gettata di rune',
      molti: 'gettate di rune',
      femminile: true,
    );
    // ignore: avoid_print
    print('ORDINE CQ RILANCIO 1: con l Adepto e una gettata fatta, la '
        'schermata dice "$frase"');
    expect(frase, 'Ti restano 29 gettate di rune su 30, oggi',
        reason: 'la frase dello screenshot non si riproduce dall Adepto: '
            'allora il trenta viene da qualche altra parte, e va trovata');
  });

  test('il tetto delle gettate ha un lettore solo, e passa dalla matrice',
      () async {
    // **NESSUNA TERZA LETTURA.** Ordine CQ, rilancio punto 1: si legge il
    // sorgente della schermata delle Rune e si pretende che ogni numero di
    // gettate arrivi da `limiteGettate` o da `gettateRimaste`, mai da una
    // costante scritta li'.
    final sorgente =
        File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
            .readAsStringSync();
    // **LA GRANDEZZA GIUSTA, e la prima era sbagliata.** La prima stesura
    // cercava un numero accanto alla parola "gettate", e l'innesto `final
    // limite = 30;` le passava sotto il naso: la variabile si chiama
    // `limite`, non `gettate`. **Si cambia la grandezza misurata, mai la
    // soglia**: ora si guardano tutte le assegnazioni a un nome che parla di
    // tetto o di residuo, e si pretende che a destra ci sia `borsa.`.
    final assegnazioni = RegExp(
            r'(?:final\s+\w*|var\s+\w*|\w*)(?:[Ll]imite|[Rr]imast\w*)\s*=\s*([^;]+);')
        .allMatches(sorgente);
    final fuoriMatrice = <String>[];
    var guardate = 0;
    for (final a in assegnazioni) {
      guardate++;
      final destra = a.group(1)!;
      if (!destra.contains('borsa.') &&
          !destra.contains('widget.') &&
          !destra.contains('limite') &&
          !destra.contains('Limite') &&
          !destra.contains('Rimaste') &&
          !destra.contains('rimaste')) {
        fuoriMatrice.add(a.group(0)!.trim());
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ RILANCIO 1: assegnazioni di tetto o residuo guardate '
        '$guardate nella schermata delle Rune, fuori dalla matrice '
        '${fuoriMatrice.length} $fuoriMatrice');
    cardinaleMinimo(guardate, 4,
        cosa: 'assegnazioni di tetto o residuo nella schermata delle Rune',
        perche: 'Se la ricerca non trovasse piu niente, questa prova sarebbe '
            'verde senza aver guardato una sola riga.');
    expect(fuoriMatrice, isEmpty,
        reason: 'la schermata delle Rune calcola un tetto o un residuo senza '
            'passare dalla matrice del piano: e la terza lettura che '
            'l ordine cercava. Righe: ${fuoriMatrice.join(" | ")}');
  });

  test('il piano che il server dichiara diventa il piano che l app applica',
      () async {
    // **IL PONTE, ed e' il difetto vero della voce.** Il campo arrivava e
    // nessuno lo leggeva.
    final servizio = EntitlementService();
    expect(servizio.tier, Tier.free, reason: 'il piano non nasce Viandante');
    var provati = 0;
    for (final coppia in const {
      'tier1': Tier.tier1,
      'tier2': Tier.tier2,
      'tier3': Tier.tier3,
      'free': Tier.free,
      'un-piano-che-non-esiste': Tier.free,
    }.entries) {
      provati++;
      servizio.applicaIlPianoDelServer(coppia.key);
      expect(servizio.tier, coppia.value,
          reason: 'il server dice "${coppia.key}" e l app applica '
              '${servizio.tier.label}');
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.01: nomi di piano provati $provati');
    expect(provati, 5);
  });

  test('la sincronia col server porta il piano, non solo i residui', () async {
    SharedPreferences.setMockInitialValues(const {});
    final visti = <String>[];
    final borsa = QuestionAllowance(
      porta: const _PortaCheDiceIlPiano('tier3'),
      quandoIlServerDiceIlPiano: visti.add,
    );
    await borsa.load();
    await borsa.sincronizza();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.01: dalla sincronia il piano arrivato e $visti');
    expect(visti, ['tier3'],
        reason: 'il piano del server non arriva a chi lo tiene: il telefono '
            'resta su un piano e il server ne impone un altro, ed e '
            'esattamente cio che il fondatore ha visto');
  });

  test('al no del server il conto si chiude sul tetto vero, non su un milione',
      () async {
    // **IL SALTO DA VENTINOVE A ZERO.** Con `1 << 20` il residuo tornava zero
    // ma il numero speso era un milione: a schermo diventava "le trenta
    // gettate del giorno sono state fatte" dopo UNA gettata.
    SharedPreferences.setMockInitialValues(const {});
    final borsa = QuestionAllowance(
      porta: const _PortaCheDiceNo('tier2'),
      quandoIlServerDiceIlPiano: (_) {},
    );
    await borsa.load();
    await borsa.sincronizza();
    borsa.registraGettata(Tier.tier2);
    // La coda parte da sola: si aspetta che il no sia arrivato.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final tetto = PlanCatalog.limiteGiornaliero(PlanCatalog.rigaGettate,
        Tier.tier2)!;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.01: dopo il no del server, gettate rimaste '
        '${borsa.gettateRimaste(Tier.tier2)} su un tetto di $tetto, '
        'e il conto speso vale ${borsa.gettateSpese}');
    expect(borsa.gettateRimaste(Tier.tier2), 0,
        reason: 'dopo un no del server restano ancora gettate: il conto '
            'locale non si e allineato');
    expect(borsa.gettateSpese, tetto,
        reason: 'il conto speso vale ${borsa.gettateSpese} invece di $tetto: '
            'e la bandiera da un milione, che a schermo diventa una bugia');
  });
}

/// Una porta che risponde con un piano e nessuna spesa.
class _PortaCheDiceIlPiano extends PortaSpentaDelCerchio {
  const _PortaCheDiceIlPiano(this.piano);

  final String piano;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato({
    CamminoDaCustodire? cammino,
    bool azzeraIlCammino = false,
  }) async =>
      StatoDelCerchio(
        giorno: '2026-9-3',
        piano: piano,
        spesi: const {},
        saldoEos: 0,
      );
}

/// Una porta che dichiara il piano e poi rifiuta ogni consumo.
class _PortaCheDiceNo extends _PortaCheDiceIlPiano {
  const _PortaCheDiceNo(super.piano);

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async =>
      const EsitoDelConsumo(concesso: false, resta: 0);
}

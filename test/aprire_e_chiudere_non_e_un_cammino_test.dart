import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **APRIRE E CHIUDERE LA STESSA FUNZIONALITA' NON E' UN CAMMINO.**
/// Ordine CP voce 09, 3 settembre 2026.
///
/// **Il fatto che ha aperto l'ordine.** Il fondatore ha collaudato la build la
/// notte fra il 2 e il 3 settembre 2026 e ha visto **otto feste in due
/// funzionalita'**. Parole sue: *"oggi in 2 funzionalita' mi sono dovuto
/// vedere 8 feste"*.
///
/// Questa prova rifa' quel collaudo, e stampa il numero che il manifesto
/// riporta: **quante feste vede oggi chi apre e chiude la stessa
/// funzionalita' otto volte di fila.**
///
/// Le tre difese si sommano, e la prova le misura tutte e tre:
/// 1. **Il conto una volta al giorno** (voce 02): lo stesso gesto con gli
///    stessi dettagli non conta due volte nella stessa giornata rituale.
/// 2. **Il posto unico del congedo** (voce 01): un gradino acceso occupa il
///    Cammino finche' la sua festa non e' congedata.
/// 3. **Il costo in giorni** (voce 05): nella revisione F un solo gradino per
///    sentiero si chiude in una sessione, e non e' un gesto ripetuto, e' un
///    pezzo dell'identita'.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ({DiarioDelCammino diario, void Function(DateTime) sposta}) conOrologio(
      DateTime partenza) {
    var adesso = partenza;
    final diario = DiarioDelCammino(orologio: () => adesso);
    return (diario: diario, sposta: (DateTime q) => adesso = q);
  }

  /// Quante feste produce una sequenza di gesti su un diario appena nato.
  /// Ogni gesto passa dalla porta vera, `segna`, e dopo ogni gesto si chiede
  /// al Cammino chi si accende, esattamente come fa la regia.
  Future<int> festeDopo(
    List<({String gesto, Map<String, Object?> dettagli})> gesti, {
    Duration passo = const Duration(seconds: 30),
    bool congedaSubito = true,
    bool onboardingGiaFatto = true,
  }) async {
    SharedPreferences.setMockInitialValues(const {});
    final o = conOrologio(DateTime(2026, 6, 15, 10));
    await o.diario.carica();
    var quando = DateTime(2026, 6, 15, 10);
    var feste = 0;
    // **CHI ABUSA HA GIA' FATTO L'ONBOARDING**, ed e' il caso del fondatore:
    // la carta natale c'e' gia', quindi il gradino di testa della
    // Costellazione e' gia' stato preso. Contarlo qui vorrebbe dire
    // attribuire all'abuso una festa che l'abuso non ha prodotto.
    if (onboardingGiaFatto) {
      while (true) {
        final pronti = await o.diario.quelliCheSiAccendono(
            o.diario.statoDelCammino(
                pezziDellIdentita:
                    RegiaDelCammino.pezziDellIdentitaMaturi(o.diario, true)));
        if (pronti.isEmpty) break;
        for (final t in pronti) {
          await o.diario.accendi(t.id);
          await o.diario.congeda(t.id);
        }
      }
    }
    for (final g in gesti) {
      o.sposta(quando);
      await o.diario.segna(g.gesto, dettagli: g.dettagli);
      // **I PEZZI DELL'IDENTITA' ARRIVANO DALLA REGIA**, e senza di loro
      // questa prova misurava un Cammino murato: dalla voce CP.01 il primo
      // gradino di ogni sentiero e' un pezzo dell'identita', e finche' non si
      // prende non matura nient'altro su quel sentiero.
      final accesi = await o.diario.quelliCheSiAccendono(
          o.diario.statoDelCammino(
              pezziDellIdentita:
                  RegiaDelCammino.pezziDellIdentitaMaturi(o.diario, true)));
      for (final t in accesi) {
        feste++;
        await o.diario.accendi(t.id);
        // Chi guarda una festa e la chiude libera il posto: e' il caso
        // peggiore per questa prova, perche' e' quello che ne fa vedere di
        // piu'. Un utente che non congeda ne vedrebbe una sola.
        if (congedaSubito) await o.diario.congeda(t.id);
      }
      quando = quando.add(passo);
    }
    return feste;
  }

  test('il corpus ha abbastanza gradini perche questa prova voglia dire '
      'qualcosa', () {
    cardinaleMinimo(Sentieri.tuttiITraguardi.length, 100,
        cosa: 'gradini del Cammino',
        perche: 'Su un corpus vuoto ogni sequenza produce zero feste, e '
            'questa prova sarebbe verde per non aver guardato niente.');
  });

  test('LA DOMANDA DEL MANIFESTO: otto aperture della stessa funzionalita',
      () async {
    // **IL COLLAUDO DEL FONDATORE, rifatto.** Otto gettate di rune di fila,
    // stesso modo, nell'arco di quattro minuti.
    final feste = await festeDopo([
      for (var i = 0; i < 8; i++)
        (gesto: 'gettata', dettagli: const {'modo': 'tre_rune'}),
    ]);
    // ignore: avoid_print
    print('ORDINE CP VOCE 09: otto gettate di fila, stesso modo, in quattro '
        'minuti: $feste feste');
    expect(feste, 0,
        reason: 'aprire e chiudere la stessa funzionalita otto volte produce '
            '$feste feste: e la slot machine che il fondatore ha visto');
  });

  test("l'Oroscopo quattro volte in due minuti, cambiando orizzonte",
      () async {
    // **IL CASO PIU' DIFFICILE, ed e' il motivo per cui questa prova esiste
    // separata dalla precedente.** L'Oroscopo manda un dettaglio, il periodo,
    // e il conto di una volta al giorno guarda gesto E dettagli insieme:
    // quattro aperture su quattro orizzonti diversi sono quattro chiavi
    // diverse, quindi il freno della voce 02 **non le trattiene**. A
    // trattenerle resta il corpus, che sull'Oroscopo conta i GIORNI e non le
    // aperture.
    final feste = await festeDopo([
      for (final periodo in const ['giorno', 'settimana', 'mese', 'anno'])
        (gesto: 'oroscopo', dettagli: {'periodo': periodo}),
    ], passo: const Duration(seconds: 40));
    // ignore: avoid_print
    print('ORDINE CP VOCE 09: quattro Oroscopi in due minuti su quattro '
        'orizzonti diversi: $feste feste');
    expect(feste, 0,
        reason: 'quattro aperture dell Oroscopo in due minuti producono '
            '$feste feste');
  });

  test('due funzionalita aperte e chiuse quattro volte ciascuna', () async {
    // Le due funzionalita' del collaudo, alternate.
    final feste = await festeDopo([
      for (var i = 0; i < 4; i++) ...[
        (gesto: 'gettata', dettagli: const {'modo': 'una_runa'}),
        (gesto: 'oroscopo', dettagli: const {'periodo': 'giorno'}),
      ],
    ]);
    // ignore: avoid_print
    print('ORDINE CP VOCE 09: due funzionalita, quattro aperture ciascuna: '
        '$feste feste');
    expect(feste, 0);
  });

  test('una giornata onesta di sette arti diverse non supera le tre feste',
      () async {
    // **IL CONTRARIO DELL'ABUSO**, ed e' la meta' che serve a non trasformare
    // il freno in un muro: chi in un giorno solo prova SETTE arti diverse fa
    // una cosa buona, e deve poter essere premiato. La revisione F gli da'
    // tre feste al massimo, una per Maestro, e sono i tre pezzi
    // dell'identita'.
    final feste = await festeDopo(const [
      (gesto: 'gettata', dettagli: {'modo': 'una_runa'}),
      (gesto: 'oroscopo', dettagli: {'periodo': 'giorno'}),
      (gesto: 'stesa', dettagli: {'semi': 'coppe'}),
      (gesto: 'alba', dettagli: {}),
      (gesto: 'soffio', dettagli: {}),
      (gesto: 'viso', dettagli: {'tratto': 'occhi'}),
      (gesto: 'animale_guida', dettagli: {'animale': 'lupo'}),
    ], onboardingGiaFatto: false);
    // ignore: avoid_print
    print('ORDINE CP VOCE 09: sette arti diverse in un giorno solo: $feste '
        'feste');
    expect(feste, lessThanOrEqualTo(3),
        reason: 'sette arti diverse in un giorno producono $feste feste, e il '
            'massimo dichiarato e tre, una per Maestro');
  });

  test('chi non congeda ne vede UNA sola, per quanti gesti faccia', () async {
    // La difesa della voce 01, misurata da sola: senza congedo il posto resta
    // occupato e nessun altro gradino matura.
    final feste = await festeDopo(const [
      (gesto: 'gettata', dettagli: {'modo': 'una_runa'}),
      (gesto: 'oroscopo', dettagli: {'periodo': 'giorno'}),
      (gesto: 'stesa', dettagli: {'semi': 'coppe'}),
      (gesto: 'alba', dettagli: {}),
      (gesto: 'soffio', dettagli: {}),
      (gesto: 'viso', dettagli: {'tratto': 'occhi'}),
      (gesto: 'animale_guida', dettagli: {'animale': 'lupo'}),
    ], congedaSubito: false, onboardingGiaFatto: false);
    // ignore: avoid_print
    print('ORDINE CP VOCE 09: sette arti senza congedare nessuna festa: '
        '$feste feste');
    expect(feste, lessThanOrEqualTo(1),
        reason: 'senza congedare niente si sono viste $feste feste: il posto '
            'unico del congedo non tiene');
  });

  test('IL GIORNO PEGGIORE DELL ANNO per chi apre l app la prima volta',
      () async {
    // **IL NUMERO PIU' ONESTO CHE QUESTO ORDINE PRODUCE.** Ordine CP voci 08
    // e 10.
    //
    // Dire "tre feste nella prima sessione" e' vero per il COSTO IN GIORNI, e
    // non basta: una finestra del cielo costa quanto la sua attesa tipica, ma
    // il giorno che si apre si compie in una sessione sola. Chi installa
    // l'app in un giorno di Luna nuova e getta le rune vede una festa che il
    // giorno prima non avrebbe visto, ed e' voluto, perche' e' la regola 7 del
    // fondatore: legare i traguardi a eventi che il cielo comanda.
    //
    // **Quello che NON deve succedere e' che quei giorni siano molti o
    // affollati.** Qui si prova ogni giorno dell'anno con un utente nuovo che
    // compie tutte e venti le arti, e si cerca il massimo.
    var peggiore = 0;
    var quandoPeggiore = 0;
    var somma = 0;
    for (var g = 0; g < 365; g++) {
      final quando = DateTime(2026, 1, 1, 12).add(Duration(days: g));
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: () => quando);
      await diario.carica();
      var feste = 0;
      // Le venti arti, e i tre pezzi dell'identita' gia' maturi: e' il caso
      // piu' generoso possibile per la prima sessione.
      for (final gesto in const [
        'carta_natale', 'ascendente', 'oroscopo', 'stesa', 'oracolo',
        'sinastria', 'angelo_custode', 'alba', 'soffio', 'viso', 'archetipo',
        'due_volti', 'meditazione', 'gettata', 'tramonto', 'sogno',
        'runa_girata', 'sigillo', 'animale_guida', 'bosco',
      ]) {
        await diario.segna(gesto);
        final stato = diario.statoDelCammino(
            segno: Zodiac.leo,
            pezziDellIdentita: const {
              'carta_natale', 'viso', 'animale_guida',
            });
        for (final t in await diario.quelliCheSiAccendono(stato)) {
          feste++;
          await diario.accendi(t.id);
          await diario.congeda(t.id);
        }
      }
      somma += feste;
      if (feste > peggiore) {
        peggiore = feste;
        quandoPeggiore = g + 1;
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 08: su 365 giorni, un utente nuovo che compie tutte '
        'le venti arti nella prima sessione vede in media '
        '${(somma / 365).toStringAsFixed(2)} feste; il giorno peggiore e il '
        '$quandoPeggiore con $peggiore feste');
    expect(peggiore, lessThanOrEqualTo(5),
        reason: 'nel giorno peggiore dell anno la prima sessione porta '
            '$peggiore feste: il fondatore ne ha viste otto, e sopra le '
            'cinque si torna li');
  });

  test('il freno non e un muro: due giorni di gettata accendono davvero',
      () async {
    // **UNA GUARDIA CHE PROVA SOLO CHE NIENTE SI ACCENDE E\' VERDE ANCHE SU
    // UN CAMMINO ROTTO.** Qui si prova il contrario: cambiato il giorno, la
    // seconda gettata accende cal_2, che ne chiede due in giorni diversi.
    SharedPreferences.setMockInitialValues(const {});
    final o = conOrologio(DateTime(2026, 6, 15, 10));
    await o.diario.carica();
    // **PRIMA SI PRENDE IL GRADINO DI TESTA**, ordine CP voce 01: sull'Albero
    // e' l'Animale Guida, e finche' non e' acceso la scala non va avanti.
    await o.diario.segna('animale_guida');
    Future<List<Traguardo>> chiSiAccende() =>
        o.diario.quelliCheSiAccendono(o.diario.statoDelCammino(
            pezziDellIdentita:
                RegiaDelCammino.pezziDellIdentitaMaturi(o.diario, true)));
    // **SI SVUOTA FINCHE' NON RESTA NIENTE**, e non basta un giro: il Cammino
    // ne fa maturare **uno alla volta** (voce CP.01), quindi un giro solo
    // lasciava indietro i gradini di testa degli altri due sentieri, e la
    // prima gettata trovava ancora qualcosa di pronto.
    while (true) {
      final pronti = await chiSiAccende();
      if (pronti.isEmpty) break;
      for (final t in pronti) {
        await o.diario.accendi(t.id);
        await o.diario.congeda(t.id);
      }
    }
    await o.diario.segna('gettata', dettagli: const {'modo': 'una_runa'});
    var accesi = await chiSiAccende();
    expect(accesi, isEmpty, reason: 'la prima gettata accende gia qualcosa');
    o.sposta(DateTime(2026, 6, 16, 10));
    await o.diario.segna('gettata', dettagli: const {'modo': 'una_runa'});
    accesi = await chiSiAccende();
    // ignore: avoid_print
    print('ORDINE CP VOCE 09: la gettata del secondo giorno accende '
        '${accesi.map((t) => t.id).toList()}');
    expect(accesi.map((t) => t.id), contains('cal_2'),
        reason: 'due gettate in due giorni diversi non accendono cal_2, che '
            'ne chiede esattamente due: il freno e diventato un muro');
  });
}

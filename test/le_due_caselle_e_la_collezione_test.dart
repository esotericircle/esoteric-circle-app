import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/riconoscimento_del_vip.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE DUE CASELLE, LA COLLEZIONE E LA LEVA CHE DEVE GIRARE. Ordine BO voce 13.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  String impronta(SynastryReport r) =>
      '${r.overall}|${r.love}|${r.mental}|${r.sparks}';

  // --- SIMMETRIA ---

  test('scambiando le due caselle il risultato è identico in ogni numero', () {
    // Cento coppie, prese in giro sul catalogo cosi' da toccarne di ogni
    // segno e di ogni stagione senza nessun sorteggio.
    var quante = 0;
    const vips = VipCatalog.vips;
    for (var i = 0; i < 100; i++) {
      final a = vips[(i * 7) % vips.length];
      final b = vips[(i * 13 + 3) % vips.length];
      if (a.name == b.name) continue;
      final avanti = SynastryReport.fraDueVip(primo: a, vip2: b);
      final indietro = SynastryReport.fraDueVip(primo: b, vip2: a);
      expect(impronta(avanti), impronta(indietro),
          reason: 'scambiando ${a.name} e ${b.name} i numeri cambiano');
      quante++;
    }
    // ignore: avoid_print
    print('ORDINE BO VOCE 13: simmetria verificata su $quante coppie');
    expect(quante, greaterThanOrEqualTo(95));
  });

  test('tutte le 1.225 combinazioni danno un esito valido', () {
    const vips = VipCatalog.vips;
    var quante = 0;
    for (var i = 0; i < vips.length; i++) {
      for (var j = i + 1; j < vips.length; j++) {
        final r = SynastryReport.fraDueVip(primo: vips[i], vip2: vips[j]);
        expect(r.overall, inInclusiveRange(0, 99),
            reason: '${vips[i].name} con ${vips[j].name}');
        expect(r.band, isNotEmpty);
        expect(r.reading, isNotEmpty);
        expect(r.incontro.esiste, isFalse,
            reason: 'fra due VIP la possibilità di incontro non esiste');
        expect(r.incontro.perche, isNotEmpty,
            reason: 'manca la riga sui loro mondi');
        quante++;
      }
    }
    // ignore: avoid_print
    print('ORDINE BO VOCE 13: coperte $quante combinazioni su '
        '${CollezioneDelleCoppie.totalePossibile()}');
    expect(quante, CollezioneDelleCoppie.totalePossibile());
  });

  test('fra due VIP la barra dell\'incontro non c\'è', () {
    final r = SynastryReport.fraDueVip(
        primo: VipCatalog.conNome('Zendaya')!,
        vip2: VipCatalog.conNome('Drake')!);
    // **SEI E NON TRE, ordine BX voce 09**: le dimensioni dell'affinita' sono
    // passate da quattro a sette, quindi fra due VIP, dove la possibilita' di
    // incontro non ha senso, restano le altre sei. Il numero segue il dato;
    // cio' che questa riga sorveglia, che la barra dell'incontro non ci sia,
    // e' la riga sotto e non e' cambiato.
    expect(r.bars, hasLength(6));
    expect(r.bars.any((b) => b.label.contains('incontro')), isFalse);
  });

  test('il linguaggio non nomina mai relazioni reali fra i due', () {
    // Punto 5 dell'ordine: l'app confronta i cieli, non le relazioni.
    const vietate = [
      'fidanzat',
      'matrimoni',
      'sposat',
      'separat',
      'divorzi',
      'coppia reale',
      'ex ',
      'flirt',
      'relazione fra',
      'stanno insieme',
      'storia d\'amore',
    ];
    const vips = VipCatalog.vips;
    for (var i = 0; i < vips.length; i += 3) {
      for (var j = i + 1; j < vips.length; j += 5) {
        final r = SynastryReport.fraDueVip(primo: vips[i], vip2: vips[j]);
        final tutto =
            '${r.reading} ${r.incontro.perche} ${r.band}'.toLowerCase();
        for (final p in vietate) {
          expect(tutto.contains(p), isFalse,
              reason: '${vips[i].name} con ${vips[j].name}: il testo nomina '
                  '"$p", e l\'app confronta i cieli, non le relazioni');
        }
      }
    }
  });

  // --- LA COLLEZIONE ---

  test('la collezione mostra solo il suo, e il totale è calcolato', () {
    final c = CollezioneDelleCoppie();
    expect(c.eVuota, isTrue);
    expect(c.quante, 0);
    final oggi = DateTime(2026, 8, 25);
    c.scopri(primo: '', secondo: 'Zendaya', punteggio: 70, quando: oggi);
    c.scopri(primo: '', secondo: 'Drake', punteggio: 61, quando: oggi);
    c.scopri(primo: 'Zendaya', secondo: 'Drake', punteggio: 55, quando: oggi);
    expect(c.quante, 3);
    // In fila per punteggio, dalla piu' alta.
    expect(c.inFila.map((x) => x.punteggio), [70, 61, 55]);
    // E le altre 1.222 non ci sono.
    expect(c.quante, lessThan(CollezioneDelleCoppie.totalePossibile()));
    expect(c.riepilogo, '3 coppie su 1.225');
  });

  test('il totale si calcola dal catalogo, e non è scritto a mano', () {
    // **La misura che l'ordine chiede**: portando il catalogo da cinquanta a
    // cinquantuno VIP la riga passa da 1.225 a 1.275, senza toccare nessuna
    // stringa. Qui si passa il numero, che e' il modo di dire "se il catalogo
    // crescesse".
    expect(CollezioneDelleCoppie.totalePossibile(50), 1225);
    expect(CollezioneDelleCoppie.totalePossibile(51), 1275);
    expect(CollezioneDelleCoppie.totalePossibile(200), 19900);
    // E quello vero viene dal catalogo, non da una costante.
    expect(CollezioneDelleCoppie.totalePossibile(),
        CollezioneDelleCoppie.totalePossibile(VipCatalog.vips.length));
  });

  test('la chiave della coppia è simmetrica, quindi non si paga due volte', () {
    final c = CollezioneDelleCoppie();
    final oggi = DateTime(2026, 8, 25);
    expect(
        c.scopri(
            primo: 'Zendaya', secondo: 'Drake', punteggio: 55, quando: oggi),
        isTrue);
    // La stessa coppia al contrario NON e' nuova.
    expect(
        c.scopri(
            primo: 'Drake', secondo: 'Zendaya', punteggio: 55, quando: oggi),
        isFalse,
        reason: 'invertendo le caselle la coppia sembra nuova, e il fondatore '
            'la pagherebbe due volte');
    expect(c.contiene('Drake', 'Zendaya'), isTrue);
    expect(c.quante, 1);
  });

  test('la collezione si ricorda fra un avvio e l\'altro', () async {
    final a = CollezioneDelleCoppie();
    a.scopri(
        primo: '',
        secondo: 'Zendaya',
        punteggio: 70,
        quando: DateTime(2026, 8, 25));
    // Un giro di scrittura.
    await Future<void>.delayed(Duration.zero);
    final b = CollezioneDelleCoppie();
    await b.carica();
    expect(b.contiene('', 'Zendaya'), isTrue,
        reason: 'la collezione si perde alla chiusura dell\'app');
  });

  // --- IL CONSUMO ---

  test('da Viandante le prime tre coppie NUOVE passano, la quarta chiede', () {
    final borsa = QuestionAllowance();
    expect(borsa.limiteSinastrie(Tier.free), 3,
        reason: 'la leva virale è chiusa al piano gratuito');
    for (var i = 0; i < 3; i++) {
      expect(borsa.puoiComporreUnaCoppia(Tier.free), isTrue, reason: 'la $i');
      borsa.registraSinastria(Tier.free);
    }
    expect(borsa.puoiComporreUnaCoppia(Tier.free), isFalse,
        reason: 'la quarta coppia nuova del giorno non chiede niente');
  });

  test('riaprire una coppia già scoperta non scala niente', () {
    final borsa = QuestionAllowance();
    final c = CollezioneDelleCoppie();
    final oggi = DateTime(2026, 8, 25);
    // Si esauriscono le tre del giorno.
    for (var i = 0; i < 3; i++) {
      c.scopri(
          primo: '',
          secondo: VipCatalog.vips[i].name,
          punteggio: 60,
          quando: oggi);
      borsa.registraSinastria(Tier.free);
    }
    expect(borsa.sinastrieRimaste(Tier.free), 0);
    // Riaprire la prima: la collezione la conosce gia', quindi non si
    // scopre niente di nuovo e non si consuma.
    final nuova = c.scopri(
        primo: '',
        secondo: VipCatalog.vips.first.name,
        punteggio: 60,
        quando: oggi);
    expect(nuova, isFalse,
        reason: 'riaprire una coppia già scoperta la fa sembrare nuova');
    expect(borsa.sinastrieRimaste(Tier.free), 0,
        reason: 'la riapertura ha scalato qualcosa: parole del fondatore, '
            '"no, non deve consumare"');
  });

  test('le sinastrie e i confronti nel Cerchio sono due contatori diversi', () {
    final borsa = QuestionAllowance();
    // Il Viandante non ha confronti nel Cerchio, e ha tre sinastrie.
    expect(borsa.limiteConfronti(Tier.free), 0);
    expect(borsa.limiteSinastrie(Tier.free), 3);
    borsa.registraSinastria(Tier.free);
    expect(borsa.sinastrieRimaste(Tier.free), 2);
    // E consumare una sinastria non tocca i confronti, che restano a zero
    // perche' il piano non li comprende: la prova qui e' che il contatore
    // delle sinastrie non sia lo stesso oggetto.
    expect(borsa.sinastrieRimaste(Tier.tier1), 4,
        reason: 'il contatore delle sinastrie è condiviso con un altro');
  });

  // --- IL RICONOSCIMENTO ---

  test('il riconoscimento scatta solo con data e luogo coincidenti', () {
    final rihanna = VipCatalog.conNome('Rihanna')!;
    final trovato = RiconoscimentoDelVip.forse(
      nascita: DateTime(rihanna.annoDiNascita, rihanna.meseDiNascita,
          rihanna.giornoDiNascita),
      latitudine: rihanna.luogoDiNascita!.latitudine,
      longitudine: rihanna.luogoDiNascita!.longitudine,
    );
    expect(trovato?.name, 'Rihanna');
    // Stessa data, altro luogo: niente.
    expect(
        RiconoscimentoDelVip.forse(
            nascita: DateTime(rihanna.annoDiNascita, rihanna.meseDiNascita,
                rihanna.giornoDiNascita),
            latitudine: 45.4642,
            longitudine: 9.1920),
        isNull);
    // Stesso luogo, altra data: niente.
    expect(
        RiconoscimentoDelVip.forse(
            nascita: DateTime(1990, 1, 1),
            latitudine: rihanna.luogoDiNascita!.latitudine,
            longitudine: rihanna.luogoDiNascita!.longitudine),
        isNull);
    // Senza luogo: niente, mai.
    expect(
        RiconoscimentoDelVip.forse(
            nascita: DateTime(rihanna.annoDiNascita, rihanna.meseDiNascita,
                rihanna.giornoDiNascita)),
        isNull);
  });

  test('il riconoscimento CHIEDE e non dichiara mai', () {
    final v = VipCatalog.conNome('Rihanna')!;
    final domanda = RiconoscimentoDelVip.domandaPer(v);
    expect(domanda.contains('?'), isTrue, reason: 'la riga non è una domanda');
    expect(domanda.toLowerCase().contains('sei tu'), isTrue);
    // E non dichiara: nessuna frase afferma l'identità.
    expect(domanda.toLowerCase().contains('tu sei ${v.name.toLowerCase()}'),
        isFalse,
        reason: 'la riga dichiara l\'identità invece di chiederla');
  });
}

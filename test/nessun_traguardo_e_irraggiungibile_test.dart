import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **NESSUN TRAGUARDO CHIEDE UNA COSA CHE NON PUO' SUCCEDERE.**
/// Ordine DC voce 17, 10 settembre 2026.
///
/// **DA DOVE NASCE.** Nell'ordine DB voce 06 l'Architetto proponeva *"tre
/// giorni di seguito sullo stesso centro"*, e misurandolo ho trovato che **non
/// si sarebbe acceso mai per nessuno**: il centro segue il giorno della
/// settimana con una mappa biiettiva, quindi tre giorni consecutivi danno per
/// costruzione tre centri diversi. Trecentosessantacinque giorni provati, zero
/// coppie.
///
/// **Il fondatore ha accolto la correzione** e ha chiesto una guardia
/// permanente: *"nessun traguardo puo' avere una condizione che una
/// simulazione di un anno non accende mai"*.
///
/// **COME SI MISURA, e la scelta va dichiarata.** Non si simula un anno di uso
/// vero, che vorrebbe dire inventare quale persona lo vive. Si costruisce
/// invece **la fotografia piu' generosa che un anno possa produrre**: chi ha
/// fatto tutto, ogni giorno, in ogni ora, con ogni varieta'. **Se una
/// condizione resta spenta anche li', non e' difficile: e' impossibile.**
///
/// **REGOLA H.** Non basta trovare zero impossibili: si prova che la
/// simulazione **sa** riconoscerne uno, costruendone uno finto che chiede piu'
/// di quanto un anno contenga. Senza quella meta', una fotografia troppo
/// generosa direbbe che va tutto bene per non aver saputo dire di no.
void main() {
  /// **LA FOTOGRAFIA PIU' GENEROSA DI UN ANNO.**
  ///
  /// Ogni gesto fatto trecentosessantacinque volte, ogni serie lunga un anno,
  /// ogni varieta' al massimo che il corpus permette. I nomi dei gesti si
  /// scoprono dalle condizioni stesse, cosi' un gesto nuovo entra da solo.
  StatoDelCammino unAnnoDiTutto(Iterable<Traguardo> tutti) {
    const giorni = 365;
    final gesti = <String>{};
    for (final t in tutti) {
      gesti.addAll(t.condizione.gestiNominati);
    }
    // **LE CHIAVI NON SI INDOVINANO: si prendono dalle firme.**
    //
    // La prima stesura costruiva chiavi semplici, `gesto` e `gesto.dettaglio`,
    // e ha accusato **centoquattro traguardi su centosessantacinque**. Non
    // erano rotti: le famiglie usano separatori diversi, `rito:arco`,
    // `gesto@ora`, e la chiave intera della firma. **Era la fotografia a non
    // essere generosa, non il catalogo a essere impossibile.**
    //
    // E' lo stesso errore che questa guardia deve prevenire, fatto dalla
    // guardia stessa: accusare chi non c'entra si impara a ignorare.
    //
    // Adesso si raccoglie **ogni pezzo di ogni firma**, la firma intera e
    // ogni loro combinazione coi separatori in uso, e si mettono in tutte le
    // mappe. La fotografia diventa *"tutto cio' che ha un nome, al massimo che
    // un anno permette"*, e il valore resta 365 perche' e' li' che sta il
    // confine fra difficile e impossibile.
    final chiavi = <String>{};
    for (final t in tutti) {
      final firma = t.condizione.firma;
      chiavi.add(firma);
      final pezzi = firma.split(RegExp('[:@]'));
      chiavi.addAll(pezzi);
      // La firma senza il prefisso di famiglia, che e' come molte condizioni
      // compongono la loro chiave interna.
      if (pezzi.length > 1) {
        chiavi.add(pezzi.sublist(1).join(':'));
        chiavi.add(pezzi.sublist(1).join('@'));
      }
      for (final g in t.condizione.gestiNominati) {
        for (final p in pezzi) {
          chiavi.addAll(['$g:$p', '$g@$p', '$g.$p']);
        }
      }
    }
    chiavi.addAll(gesti);
    final aTappo = {for (final c in chiavi) c: giorni};
    return StatoDelCammino(
      gestiCompiuti: aTappo,
      giorniConGesto: aTappo,
      oggiHaFatto: chiavi,
      seriePerRito: aTappo,
      gestiNellOraGiusta: aTappo,
      oraFedelePerGesto: aTappo,
      oggiHaFattoNellOra: chiavi,
      giorniSaltatiPerRito: aTappo,
      giorniDiAssenzaDalSentiero: {
        for (final s in Sentiero.values) s.name: giorni,
      },
      ripetizioniNellaFinestra: aTappo,
      variePerValore: aTappo,
      valoriDistinti: aTappo,
      massimeRipetizioni: aTappo,
      costanzeLarghe: aTappo,
      giornateInsieme: aTappo,
      eventiDelCieloDiOggi: chiavi,
      pezziDellIdentita: chiavi,
      memoria: aTappo,
      gradiniAlleSpalle: {for (final s in Sentiero.values) s.name: 55},
      giorniDiAssenzaPrimaDiOggi: giorni,
      giorniDalPrimoGiorno: giorni,
    );
  }

  test('IN UN ANNO DI TUTTO, OGNI TRAGUARDO SI PUO ACCENDERE', () {
    final tutti = Sentieri.tuttiITraguardi;
    cardinaleMinimo(tutti.length, 150,
        cosa: 'traguardi del catalogo',
        perche: 'Su un catalogo svuotato non ci sono condizioni impossibili '
            'da trovare, e questa guardia sarebbe verde per non aver guardato '
            'nessun traguardo.');
    final stato = unAnnoDiTutto(tutti);
    final spenti = <String>[];
    for (final t in tutti) {
      // I dormienti sono spenti per decisione dichiarata, non per difetto.
      if (t.dormiente) continue;
      if (!t.condizione.raggiunto(stato)) {
        spenti.add('${t.id} "${t.nome}" -> ${t.condizione.firma}');
      }
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 17: traguardi guardati ${tutti.length}, mai '
        'accendibili in un anno di tutto ${spenti.length}');
    final perFamiglia = <String, int>{};
    for (final t in tutti) {
      if (t.dormiente || t.condizione.raggiunto(stato)) continue;
      final tipo = t.condizione.firma.split(':').first;
      perFamiglia.update(tipo, (n) => n + 1, ifAbsent: () => 1);
    }
    // ignore: avoid_print
    print('ORDINE DC VOCE 17: spenti per famiglia $perFamiglia');
    expect(spenti, isEmpty,
        reason: 'questi traguardi non si accendono nemmeno per chi in un anno '
            'ha fatto tutto ogni giorno, quindi nel catalogo stanno come '
            'gradini che nessuno vedra mai accesi:\n  ${spenti.join("\n  ")}');
  });

  test('REGOLA H: LA SIMULAZIONE SA RICONOSCERE UN IMPOSSIBILE', () {
    // **Senza questa meta la prova qui sopra sarebbe verde per generosita.**
    // Si costruisce una condizione che chiede piu' di quanto un anno
    // contenga, e la simulazione deve dirlo.
    final tutti = Sentieri.tuttiITraguardi;
    final stato = unAnnoDiTutto(tutti);
    const impossibile = GestiCompiuti('alba', 4000, inGiorniDiversi: true);
    expect(impossibile.raggiunto(stato), isFalse,
        reason: 'la fotografia di un anno accende anche una condizione da '
            'quattromila giorni: e troppo generosa e non sa dire di no, '
            'quindi la prova qui sopra non prova niente');
    // E una condizione che un anno contiene si accende: la simulazione non e'
    // nemmeno troppo avara.
    const possibile = GestiCompiuti('alba', 100, inGiorniDiversi: true);
    expect(possibile.raggiunto(stato), isTrue,
        reason: 'la fotografia non accende nemmeno cento albe in un anno: e '
            'troppo avara, e accuserebbe traguardi sani');
  });
}

import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/core/sigilli/gesti_delle_arti.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:esoteric_circle/core/sigilli/pezzi_dell_identita.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// UN GESTO, UNA FESTA, UN PAGAMENTO. Ordine U voce 01.
///
/// **Il difetto, con le parole di Mauro:** non ha senso che la creazione della
/// carta natale sia un traguardo per tutti e tre i Maestri, perche' significa
/// vedere tre volte di seguito la stessa animazione e ricevere tre volte gli Eos
/// per lo stesso motivo. Oltre a essere sbagliato, innervosisce.
///
/// **Questa intestazione diceva il falso fino al 15 agosto 2026**, e la coda
/// della voce l'ha fatta riscrivere: sosteneva che la prova nasce rossa e che
/// tre condizioni sono ripetute. Non e' piu' vero, e un commento che descrive un
/// mondo finito e' peggio di nessun commento, perche' si legge come vero.
///
/// **Cosa e' vero adesso.** La prova e' diventata verde in due tempi. Il 15
/// agosto sono stati montati i sei traguardi sostitutivi dell'Allegato D, e le
/// tre condizioni ripetute sono sparite. Poi la coda della voce ha mostrato che
/// **la firma non era l'unita' giusta**: `identita:archetipo` e
/// `gesti:archetipo:1:false` sono due firme diverse che lo STESSO gesto accende
/// insieme, quindi la prova per firma era verde su un difetto vivo, due feste e
/// trenta Eos per un compimento solo del Test Archetipo. La prova per GESTO
/// l'ha trovato, ed e' stata scritta ed eseguita rossa PRIMA che il difetto
/// sparisse; poi `cal_27` e' diventato un traguardo di giornata ed e' tornata
/// verde da sola, senza toccarla.
///
/// **Cosa la fa tornare rossa.** Due traguardi che chiedono la stessa cosa, in
/// qualunque forma: la stessa condizione scritta due volte, oppure due
/// condizioni diverse che un gesto solo soddisfa insieme. La seconda e' quella
/// che si vede meno, ed e' la ragione per cui la prova per gesto esiste accanto
/// a quella per firma invece che al suo posto.

void main() {
  test('nessuna condizione accende piu di un traguardo alla volta', () {
    // La FIRMA di una condizione e' il suo dato, non il suo testo: due
    // traguardi con la stessa firma si accendono insieme, sempre.
    final perFirma = <String, List<String>>{};
    var osservati = 0;
    for (final sentiero in Sentieri.tutti) {
      for (final t in Sentieri.di(sentiero)) {
        osservati++;
        (perFirma[t.condizione.firma] ??= <String>[])
            .add('${sentiero.name}:${t.id}');
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE U VOCE 01: traguardi osservati $osservati');
    expect(osservati, greaterThan(0),
        reason: 'la prova non ha guardato nessun traguardo: gira a vuoto');

    final doppie = <String>[];
    for (final voce in perFirma.entries) {
      if (voce.value.length > 1) {
        doppie.add('${voce.key} -> ${voce.value.join(", ")}');
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 01: condizioni ripetute ${doppie.length}');
    expect(doppie, isEmpty,
        reason: 'queste condizioni sono scritte su piu\' di un traguardo, '
            'quindi UN gesto ne accende piu\' di uno: partono piu\' feste e '
            'piu\' accrediti per lo stesso motivo. Vanno sostituite coi '
            'traguardi dell\'Allegato D, non tolte. ${doppie.join(" | ")}');
  });

  test('MISURA: quante feste e quanti pagamenti produce il gesto peggiore', () {
    // **NON E' UNA SOGLIA, E' UN NUMERO**, e serve a dire quanto e' grave oggi.
    final perFirma = <String, int>{};
    for (final sentiero in Sentieri.tutti) {
      for (final t in Sentieri.di(sentiero)) {
        perFirma[t.condizione.firma] = (perFirma[t.condizione.firma] ?? 0) + 1;
      }
    }
    var peggiore = 0;
    var quale = '';
    var eosDelPeggiore = 0;
    for (final voce in perFirma.entries) {
      if (voce.value > peggiore) {
        peggiore = voce.value;
        quale = voce.key;
      }
    }
    for (final sentiero in Sentieri.tutti) {
      for (final t in Sentieri.di(sentiero)) {
        if (t.condizione.firma == quale) eosDelPeggiore += t.eos;
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 01: la condizione ripetuta di piu\' e\' "$quale", '
        'su $peggiore traguardi, per $eosDelPeggiore Eos in un gesto solo');
    expect(peggiore, greaterThan(0));
  });

  test('UN GESTO accende al massimo UN traguardo', () {
    // **L'UNITA' E' IL GESTO, NON LA FIRMA.** La prova qui sopra raggruppa per
    // firma della condizione, ed e' verde: ma `identita:archetipo` e
    // `gesti:archetipo:1:false` sono due firme DIVERSE che lo stesso gesto
    // accende insieme. Chi vede la festa non vede una firma, compie un gesto.
    //
    // Quindi: per ogni gesto registrato si costruisce uno stato da zero come se
    // quel gesto fosse stato compiuto una volta sola, e si conta quanti dei 165
    // si accendono.
    //
    // **IL LEGAME FRA GESTO E PEZZO DELL'IDENTITA' NON SI RICOPIA QUI.** Vive in
    // `PezziDellIdentita`, e lo legge anche la regia: due elenchi dello stesso
    // dato divergono, e nessuno se ne accorge finche' non e' tardi.
    var gestiOsservati = 0;
    var cieliOsservati = 0;
    final troppi = <String>[];
    for (final sorgente in GestiDelleArti.tutte) {
      final gesto = sorgente.gesto;
      gestiOsservati++;
      final stato = StatoDelCammino(
        gestiCompiuti: {gesto: 1},
        giorniConGesto: {gesto: 1},
        oggiHaFatto: {gesto},
        pezziDellIdentita:
            PezziDellIdentita.eUnPezzo(gesto) ? {gesto} : const {},
      );
      final accesi = Sentieri.tuttiITraguardi
          .where((t) => t.condizione.raggiunto(stato))
          .toList();
      if (accesi.length > 1) {
        troppi.add('$gesto accende ${accesi.length} traguardi: '
            '${accesi.map((t) => t.id).join(", ")}');
      }
      // **E LO STESSO GESTO SOTTO UN CIELO, uno per volta.** La prima stesura
      // guardava solo lo stato nudo, e aveva un punto cieco che una prova di
      // casa ha trovato il giorno stesso: una gettata in un giorno di luna nuova
      // accende `cal_1`, la prima gettata, E `cal_6`, la finestra del cielo.
      // Due feste e due accrediti per un gesto solo, che e' esattamente cio' che
      // questa voce vieta. **Il cielo non e' un caso raro: e' un giorno su
      // tanti, e capita alla prima volta di qualcuno.**
      for (final evento in EventiDelCielo.tutti) {
        final sottoIlCielo = StatoDelCammino(
          gestiCompiuti: {gesto: 1},
          giorniConGesto: {gesto: 1},
          oggiHaFatto: {gesto},
          eventiDelCieloDiOggi: {evento},
          pezziDellIdentita:
              PezziDellIdentita.eUnPezzo(gesto) ? {gesto} : const {},
        );
        cieliOsservati++;
        final sotto = Sentieri.tuttiITraguardi
            .where((t) => t.condizione.raggiunto(sottoIlCielo))
            .toList();
        if (sotto.length > 1) {
          troppi.add('$gesto sotto "$evento" accende ${sotto.length} '
              'traguardi: ${sotto.map((t) => t.id).join(", ")}');
        }
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE U VOCE 01: gesti osservati $gestiOsservati, coppie gesto e '
        'cielo osservate $cieliOsservati');
    expect(gestiOsservati, greaterThan(0),
        reason: 'la prova non ha osservato nessun gesto: gira a vuoto');
    expect(cieliOsservati, greaterThan(0),
        reason: 'la prova non ha guardato nessun cielo: il punto cieco è '
            'tornato');
    expect(troppi, isEmpty,
        reason: 'questi gesti accendono più di un traguardo alla volta, '
            'quindi partono più feste e più accrediti per un gesto solo: '
            '${troppi.join(" | ")}');
  });
}

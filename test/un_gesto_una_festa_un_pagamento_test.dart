import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/core/sigilli/gesti_delle_arti.dart';
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
/// **LA REGOLA, e distingue due cose che si somigliano solo a guardarle male.**
///
/// **Lo stesso FATTO non si festeggia due volte.** Tre traguardi che chiedono la
/// carta natale sono lo stesso fatto scritto tre volte, e un gesto solo li
/// accendeva tutti: quella e' la ripetizione vera, ed e' vietata.
///
/// **Fatti DIVERSI che cadono nello stesso istante sono due feste meritate.** La
/// prima gettata e la gettata a luna nuova non sono la stessa cosa detta in due
/// modi: **una la decidi tu, l'altra te la regala il calendario e non la puoi
/// cercare.** Chi le fa cadere insieme ha fatto una cosa piu' rara di chi le fa
/// cadere separate, e togliergli una delle due feste sarebbe punirlo.
///
/// **UNA SOGLIA SUL NUMERO DI TRAGUARDI ACCESI DA UN GESTO NON PUO' ESISTERE, e
/// non e' un'opinione: e' misurato.** Delle trenta finestre del cielo scritte nei
/// tre sentieri, **sette non chiedono nessun gesto** (med_35 equinozio, med_41
/// luna piena nel tuo segno, med_50 ritorno solare, cal_19 solstizio, cal_35
/// saturno diretto, cal_41 luna nuova nel tuo segno, aur_41 tre transiti
/// insieme): si accendono da sole, senza che nessuno abbia toccato l'app. E
/// dentro `EventiDelCielo.diOggi` la riga che aggiunge luna crescente oppure
/// luna calante non ha condizioni, quindi **uno dei due e' acceso tutti i giorni
/// dell'anno**. Un tetto sul numero lo romperebbe il cielo da solo, in un giorno
/// qualunque, senza che nessuno tocchi il codice.
///
/// **QUINDI QUI DENTRO CI SONO DUE MESTIERI DIVERSI, e non si confondono.**
///
/// **La GUARDIA** enumera i gesti a cielo vuoto e pretende che un gesto ne
/// accenda al massimo uno. E' cio' che una persona puo' ottenere quando vuole, e
/// il cielo ne resta fuori perche' il cielo non si sceglie. Non si ammorbidisce.
///
/// **La MISURA** enumera gesto per cielo, dichiara quante coppie ha guardato e
/// stampa il massimo trovato. **Non pretende nessun numero**, perche' qualunque
/// numero sarebbe falso, e cade solo se non ha guardato niente.
///
/// **Come ci si e' arrivati, in tre tempi, e il primo era sbagliato due volte.**
/// La prima stesura raggruppava per FIRMA della condizione ed era verde su un
/// difetto vivo: `identita:archetipo` e `gesti:archetipo:1:false` sono due firme
/// diverse che lo stesso gesto accende insieme, cioe' due feste e trenta Eos per
/// un compimento solo del Test Archetipo. La seconda stesura ha misurato il
/// GESTO e l'ha trovato, rossa, prima che il difetto sparisse. La terza ha
/// aggiunto il cielo e ha scoperto che la pretesa, cosi' com'era, non era
/// soddisfacibile.
///
/// **Cosa fa cadere la guardia, oggi.** Due traguardi che un gesto solo accende
/// a cielo vuoto: la stessa condizione scritta due volte, oppure due condizioni
/// diverse che quel gesto soddisfa insieme. La seconda e' quella che si vede
/// meno, ed e' la ragione per cui questa prova guarda il gesto e non la firma.

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

  test('LA GUARDIA: un gesto, a cielo vuoto, accende al massimo un traguardo',
      () {
    // **QUESTO E' CIO' CHE UNA PERSONA PUO' OTTENERE QUANDO VUOLE**, ed e'
    // esattamente il difetto che Mauro ha nominato: la carta natale pagata tre
    // volte. Il cielo qui non c'e' di proposito, perche' il cielo non si sceglie.
    //
    // **IL LEGAME FRA GESTO E PEZZO DELL'IDENTITA' NON SI RICOPIA QUI.** Vive in
    // `PezziDellIdentita`, e lo legge anche la regia: due elenchi dello stesso
    // dato divergono, e nessuno se ne accorge finche' non e' tardi.
    var gestiOsservati = 0;
    final troppi = <String>[];
    for (final sorgente in GestiDelleArti.tutte) {
      final gesto = sorgente.gesto;
      gestiOsservati++;
      final accesi = Sentieri.tuttiITraguardi
          .where((t) => t.condizione.raggiunto(_statoDi(gesto)))
          .toList();
      if (accesi.length > 1) {
        troppi.add('$gesto accende ${accesi.length} traguardi: '
            '${accesi.map((t) => t.id).join(", ")}');
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE U VOCE 01: gesti osservati a cielo vuoto $gestiOsservati');
    expect(gestiOsservati, greaterThan(0),
        reason: 'la prova non ha osservato nessun gesto: gira a vuoto');
    expect(troppi, isEmpty,
        reason: 'questi gesti accendono più di un traguardo alla volta, '
            'quindi partono più feste e più accrediti per un gesto solo: '
            '${troppi.join(" | ")}');
  });

  test('MISURA: quanti traguardi accende un gesto sotto un cielo', () {
    // **NON E' UNA GUARDIA E NON HA SOGLIA**, e la ragione e' misurata: qualunque
    // numero sarebbe falso. Sette traguardi si accendono senza nessun gesto, e
    // uno fra luna crescente e luna calante e' acceso tutti i giorni dell'anno.
    // Un tetto sul numero di traguardi accesi da un gesto lo romperebbe il cielo
    // da solo, senza che nessuno tocchi il codice.
    //
    // Cade solo se le osservazioni sono zero.
    var coppie = 0;
    var massimo = 0;
    final alMassimo = <String>[];
    for (final sorgente in GestiDelleArti.tutte) {
      final gesto = sorgente.gesto;
      for (final evento in EventiDelCielo.tutti) {
        coppie++;
        final quanti = Sentieri.tuttiITraguardi
            .where((t) => t.condizione.raggiunto(_statoDi(gesto, cielo: evento)))
            .length;
        if (quanti > massimo) {
          massimo = quanti;
          alMassimo
            ..clear()
            ..add('$gesto sotto "$evento"');
        } else if (quanti == massimo && massimo > 1) {
          alMassimo.add('$gesto sotto "$evento"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 01: coppie gesto e cielo osservate $coppie, massimo '
        'trovato $massimo, raggiunto da ${alMassimo.length} coppie, le prime '
        'otto: ${alMassimo.take(8).join(", ")}');
    expect(coppie, greaterThan(0),
        reason: 'la misura non ha guardato nessuna coppia: gira a vuoto');
  });

  test('MISURA: il limite superiore per gesto, e non e\' un giorno vero', () {
    // **E' UN LIMITE SUPERIORE, non la simulazione di un giorno.** Per ogni gesto
    // si somma: uno per il traguardo che quel gesto accende da solo, piu' le
    // finestre del cielo che chiedono QUEL gesto, piu' le sette che non chiedono
    // nessun gesto e quindi si accendono comunque.
    //
    // **Nessun giorno vero puo' raggiungerlo**, perche' alcuni eventi si
    // escludono a vicenda e la somma li conta tutti insieme: luna crescente
    // contro luna calante, luna nuova contro luna piena, e i quattro quarti fra
    // loro. Il numero serve a dire quanto in alto puo' arrivare la cosa, non
    // quanto arriva.
    const senzaGesto = 7;
    var gestiOsservati = 0;
    var peggiore = 0;
    var qualeGesto = '';
    for (final sorgente in GestiDelleArti.tutte) {
      final gesto = sorgente.gesto;
      gestiOsservati++;
      // **NON SI CONTA DALLA FIRMA, e la prima stesura sbagliava proprio qui.**
      // La firma di una finestra senza gesto finisce con la parola "presenza",
      // che e' anche il nome di un gesto vero: contando dalla firma, il gesto
      // `presenza` si prendeva le sette finestre di nessuno e poi se le vedeva
      // sommare un'altra volta. Si guarda la condizione.
      var finestreDelGesto = 0;
      for (final t in Sentieri.tuttiITraguardi) {
        final c = t.condizione;
        if (c is FinestraDelCielo && c.conGesto == gesto) finestreDelGesto++;
      }
      final limite = 1 + finestreDelGesto + senzaGesto;
      if (limite > peggiore) {
        peggiore = limite;
        qualeGesto = gesto;
      }
    }
    // ignore: avoid_print
    print('ORDINE U VOCE 01: limite superiore per gesto $peggiore, sul gesto '
        '"$qualeGesto", su $gestiOsservati gesti');
    expect(gestiOsservati, greaterThan(0),
        reason: 'la misura non ha guardato nessun gesto: gira a vuoto');
  });
}

/// Lo stato di chi ha compiuto UN gesto una volta sola, e nient'altro.
StatoDelCammino _statoDi(String gesto, {String? cielo}) => StatoDelCammino(
      gestiCompiuti: {gesto: 1},
      giorniConGesto: {gesto: 1},
      oggiHaFatto: {gesto},
      eventiDelCieloDiOggi: cielo == null ? const {} : {cielo},
      pezziDellIdentita:
          PezziDellIdentita.eUnPezzo(gesto) ? {gesto} : const {},
    );

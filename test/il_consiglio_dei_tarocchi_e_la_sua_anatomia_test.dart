// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/tetti_della_stesa.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL CONSIGLIO DEI TAROCCHI E L'ANATOMIA DEL RESPONSO.**
/// Ordine S voce 26, **rifatta dall'ordine DF voce 04**, 11 settembre 2026.
///
/// **QUESTA GUARDIA DIFENDEVA IL DIFETTO, e va detto per primo.**
///
/// Fino a ieri pretendeva tre cose, e tutte e tre erano il difetto che il
/// fondatore ha visto sulla build 2245:
///
/// - che il consiglio contenesse la cucitura *"Le tre carte lo dicono
///   insieme."*, cioe' che le carte arrivassero **dopo** un blocco che non le
///   nominava;
/// - che **nessuna carta fosse nominata prima** di quella cucitura;
/// - che il consiglio **aprisse con `topic.lente` seguita da `group.risposta`**,
///   cioe' con i due testi che hanno tre valori in tutto e che non guardano
///   nessuna carta.
///
/// **Era verde, e la persona leggeva quattro responsi identici.** E' il caso
/// piu' puro della quarta specie di cecita' del registro delle guardie: una
/// prova viva, che misura davvero, e che **misura la cosa sbagliata**. La
/// cucitura c'era per costruzione, quindi la prima asserzione non poteva
/// cadere; la seconda vietava esattamente cio' che l'ordine DF voce 04.1 adesso
/// pretende.
///
/// **ATTRIBUZIONE, regola TRE dell'ordine DF.** La forma difesa qui nasce
/// dall'ordine P voce 09, che aveva portato le carte dentro il consiglio, e
/// dall'ordine S voce 26 con il suo allegato C, che aveva aggiunto la risposta
/// del gruppo **in testa**. Nessuno dei due e' stato sbagliato quando e' stato
/// scritto: sbagliato e' stato non misurare mai che cosa succede **a leggerne
/// quattro di fila**.
///
/// **ADESSO LA LEGGE E' QUESTA**, ed e' la voce DF.04.1: *"la risposta parla
/// alla domanda posta E dice cosa la lettura vede, quindi le carte entrano nel
/// primo paragrafo, non dal terzo in poi"*.
void main() {
  /// Tutti e sedici gli argomenti per un pugno di estrazioni: le prove qui
  /// dentro guardano la **forma**, e la forma non ha bisogno di cento giri.
  /// Le cento le guarda `cento_letture_uguali_test.dart`.
  List<(TarotTopic, TarotSpread, TarotReading)> leLetture(
      {int quanti = 8, String? domanda}) {
    final fuori = <(TarotTopic, TarotSpread, TarotReading)>[];
    for (final t in TarotTopic.values) {
      for (var seme = 0; seme < quanti; seme++) {
        final stesa = TarotSpread.draw(seed: seme);
        fuori.add((t, stesa, TarotReading.of(stesa, t, domandaScritta: domanda)));
      }
    }
    return fuori;
  }

  test('DF.04.1: LE CARTE SONO NOMINATE NEL PRIMO PARAGRAFO, sempre', () {
    // **E' l'esatto contrario di cio' che questa guardia pretendeva ieri.**
    final senza = <String>[];
    var quante = 0;
    for (final (t, stesa, lettura) in leLetture()) {
      quante++;
      final primo = lettura.consiglio.split('\n\n').first;
      final nominata = stesa.cards.any((c) =>
          primo.contains(c.displayName) || primo.contains(c.card.name));
      if (!nominata) {
        senza.add('${t.name} seme $quante: il primo paragrafo non nomina '
            'nessuna delle tre carte');
      }
    }
    print('ORDINE DF VOCE 04.1: su $quante letture, quelle che non nominano '
        'nessuna carta nel primo paragrafo sono ${senza.length}');
    expect(quante, TarotTopic.values.length * 8,
        reason: 'la prova ha guardato meno letture di quante ne prometteva');
    expect(senza, isEmpty,
        reason: 'il primo paragrafo del Consiglio non dipende dalle carte '
            'uscite, ed e il difetto che ha aperto l ordine DF:\n'
            '${senza.take(6).join("\n")}');
  });

  test('DF.04.2: IL FUTURO NON E UNA MINACCIA QUANDO LA CARTA NON LO E', () {
    // **Il fondatore l ha nominato per primo:** la formula *"X non e una
    // sentenza: e dove questo va se non cambi passo"* toccava a **L Appeso**,
    // il dono della sospensione, e a **Il Mondo**, il cerchio che si compie.
    //
    // **La grandezza misurata e la famiglia di parole della minaccia**, dentro
    // le letture in cui il Futuro e una carta di compimento, cioe un Arcano
    // Maggiore dritto.
    const minacce = [
      'se non cambi passo',
      'non e una sentenza',
      'non è una sentenza',
    ];
    final colpe = <String>[];
    var conCompimento = 0;
    for (final (t, stesa, lettura) in leLetture(quanti: 24)) {
      if (NaturaDellaCarta.di(stesa.futuro) != NaturaDellaCarta.compimento) {
        continue;
      }
      conCompimento++;
      for (final m in minacce) {
        if (lettura.consiglio.toLowerCase().contains(m)) {
          colpe.add('${t.name}, futuro ${stesa.futuro.displayName}: "$m"');
        }
      }
    }
    print('ORDINE DF VOCE 04.2: letture col Futuro di compimento esaminate '
        '$conCompimento, minacce trovate ${colpe.length}');
    expect(conCompimento, greaterThan(20),
        reason: 'non ci sono abbastanza letture col Futuro di compimento: '
            'questa prova sta cercando dentro il nulla');
    expect(colpe, isEmpty,
        reason: 'la minaccia e detta su una carta di compimento:\n'
            '${colpe.take(6).join("\n")}');
  });

  test('DF.04.3: IL CONSIGLIO NON CITA I SIGNIFICATI, che stanno gia sotto le '
      'carte', () {
    // **Il difetto misurato dal fondatore:** i significati erano scritti **due
    // volte nella stessa schermata**, nell elenco Passato Presente Futuro e di
    // nuovo dentro il Consiglio, a pochi centimetri di distanza.
    final doppi = <String>[];
    for (final (t, stesa, lettura) in leLetture()) {
      for (final c in stesa.cards) {
        final sintesi = c.summary.replaceAll(RegExp(r'\.$'), '');
        if (sintesi.length < 12) continue;
        if (lettura.consiglio.contains(sintesi)) {
          doppi.add('${t.name}: "${c.card.name}" porta la sua sintesi dentro '
              'il Consiglio, e la stessa sintesi si legge gia sotto la carta');
        }
      }
    }
    print('ORDINE DF VOCE 04.3: significati ripetuti dentro il Consiglio '
        '${doppi.length}');
    expect(doppi, isEmpty, reason: doppi.take(6).join('\n'));
  });

  test('DF.04.7: NESSUN NUMERO IN CIFRA DENTRO IL TESTO LETTERARIO', () {
    // *"con 3 Arcani Maggiori nella stesa"*: il fondatore lo ha nominato.
    final cifre = <String>[];
    for (final (t, _, lettura) in leLetture(quanti: 24)) {
      final trovate = RegExp(r'\d').allMatches(lettura.consiglio);
      if (trovate.isNotEmpty) {
        cifre.add('${t.name}: ${trovate.length} cifre nel Consiglio');
      }
    }
    print('ORDINE DF VOCE 04.7: letture col numero in cifra ${cifre.length}');
    expect(cifre, isEmpty, reason: cifre.take(6).join('\n'));
    // E il traduttore in lettere fa il suo mestiere.
    expect(VoceDellaStesa.inLettere(2), 'due');
    expect(VoceDellaStesa.inLettere(3), 'tre');
  });

  test('DF.04.5: IL TITOLO C E SEMPRE, E NON HA UN PUNTO DENTRO', () {
    // *"Il titolo grande col significato della carta presente compare in una
    // lettura su quattro, e nelle altre tre no. O c e sempre o non c e mai, e
    // senza il punto fermo dentro il titolo."*
    final guasti = <String>[];
    for (final (t, stesa, _) in leLetture(quanti: 24)) {
      final titolo = VoceDellaStesa.titolo(stesa);
      if (titolo.trim().isEmpty) {
        guasti.add('${t.name}: titolo vuoto');
      }
      if (titolo.endsWith('.')) {
        guasti.add('${t.name}: il titolo finisce col punto, "$titolo"');
      }
    }
    print('ORDINE DF VOCE 04.5: titoli guasti ${guasti.length} su '
        '${TarotTopic.values.length * 24}');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
  });

  test('LA DOMANDA: in fondo quando viene dal corpus, e mai due volte', () {
    for (final t in TarotTopic.values) {
      final lettura = TarotReading.of(TarotSpread.draw(seed: 4), t);
      expect(lettura.consiglio.trimRight().endsWith(lettura.domanda), isTrue,
          reason: '${t.name}: la domanda di chiusura non chiude il consiglio');
      expect(lettura.domanda.allMatches(lettura.consiglio).length, 1,
          reason: '${t.name}: la domanda compare piu di una volta');
    }
    // **E QUANDO LA PERSONA LA SCRIVE, la sua domanda si legge UNA volta.**
    // Ordine DF voce 02, misura D: prima compariva due volte nella stessa
    // bolla, riconosciuta in cima e ripetuta in coda, e su cento letture
    // faceva cento paragrafi identici.
    const sua = 'denaro e fortuna';
    for (final t in TarotTopic.values) {
      final lettura =
          TarotReading.of(TarotSpread.draw(seed: 4), t, domandaScritta: sua);
      expect(sua.allMatches(lettura.consiglio).length, 1,
          reason: '${t.name}: la domanda scritta dalla persona compare '
              '${sua.allMatches(lettura.consiglio).length} volte');
    }
  });

  test('la RISPOSTA viene prima dell AZIONE, come dice l anatomia', () {
    // **LA GRANDEZZA MISURATA E CAMBIATA, e la legge no.** Prima si cercavano
    // `group.risposta` e `group.consiglio`, cioe due costanti: quelle costanti
    // non stanno piu nel Consiglio, e cercarle qui vorrebbe dire pretendere il
    // difetto.
    //
    // La legge dell anatomia resta: **prima cosa la lettura vede, poi cosa
    // puoi fare**. Si misura sui paragrafi: il primo nomina le carte e dice
    // cosa vedono, il secondo porta un imperativo.
    const imperativi = [
      'Fai ', 'Scegli ', 'Chiedi ', 'Metti ', 'Cerca ', 'Rendi ', 'Fissa ',
      'Dichiara ', 'Usa ', 'Dai ', 'Mostra ', 'Togli ', 'Segna ', 'Scrivi ',
      'Smetti ', 'Rimanda ', 'Prova ', 'Parla ', 'Prenditi ', 'Cambia ',
      'Elimina ', 'Controlla ', 'Rinuncia ', 'Rifai ',
    ];
    final guasti = <String>[];
    var quante = 0;
    for (final (t, _, lettura) in leLetture(quanti: 12)) {
      quante++;
      final pezzi = lettura.consiglio.split('\n\n');
      if (pezzi.length < 3) {
        guasti.add('${t.name}: il consiglio ha ${pezzi.length} paragrafi');
        continue;
      }
      final azione = pezzi[1];
      if (!imperativi.any(azione.contains)) {
        guasti.add('${t.name}: il secondo paragrafo non porta nessun gesto '
            'da fare: "${azione.substring(0, azione.length.clamp(0, 60))}"');
      }
    }
    print('ORDINE S VOCE 26: letture esaminate $quante, senza gesto nel '
        'secondo paragrafo ${guasti.length}');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
    // Le tre parti dell'anatomia restano quelle.
    expect(ParteDelResponso.nelResponso.length, 3);
  });

  test('il troncamento non decapita: la domanda resta anche al filo del tetto',
      () {
    final monchi = <String>[];
    for (final t in TarotTopic.values) {
      for (var seme = 0; seme < 60; seme++) {
        final lettura = TarotReading.of(TarotSpread.draw(seed: seme), t);
        final pezzi = lettura.consiglio.split('\n\n');
        expect(pezzi.length, inInclusiveRange(3, 4),
            reason: '${t.name} seme $seme: il consiglio non ha lo stacco fra '
                'la prosa e la domanda, oppure la prosa non e in due o tre '
                'paragrafi come la voce BN.06 promette');
        for (final paragrafo in pezzi.take(pezzi.length - 1)) {
          final prosa = paragrafo.trimRight();
          if (!prosa.endsWith('.') &&
              !prosa.endsWith('?') &&
              !prosa.endsWith('!') &&
              !prosa.endsWith('»')) {
            monchi.add('${t.name} seme $seme: un paragrafo finisce con '
                '"...${prosa.substring(prosa.length - 30)}"');
          }
        }
        if (pezzi.last.trim() != lettura.domanda) {
          monchi.add('${t.name} seme $seme: la domanda di chiusura e stata '
              'tagliata');
        }
      }
    }
    expect(monchi, isEmpty,
        reason: 'il troncamento ha decapitato il consiglio:\n'
            '${monchi.take(6).join("\n")}');
  });

  test('il tetto del consiglio tiene il caso peggiore con margine', () {
    var peggiore = 0;
    var quale = '';
    for (final t in TarotTopic.values) {
      for (var seme = 0; seme < 200; seme++) {
        final lettura = TarotReading.of(TarotSpread.draw(seed: seme), t);
        if (lettura.consiglio.length > peggiore) {
          peggiore = lettura.consiglio.length;
          quale = '${t.name} seme $seme';
        }
      }
    }
    print('ORDINE DF: caso peggiore del consiglio $peggiore caratteri '
        '($quale), tetto ${TettiDellaStesa.consiglio}');
    expect(peggiore, lessThan(TettiDellaStesa.consiglio),
        reason: 'il caso peggiore del consiglio e $peggiore ($quale) e il '
            'tetto e ${TettiDellaStesa.consiglio}: il tetto taglia, e un testo '
            'tagliato e un testo non scritto');
    expect(TettiDellaStesa.consiglio - peggiore,
        greaterThan(TettiDellaStesa.consiglio * 0.10),
        reason: 'il margine fra il caso peggiore ($peggiore) e il tetto '
            '(${TettiDellaStesa.consiglio}) e meno del dieci per cento: il '
            'tetto sta al filo');
  });

  test('ogni argomento innesta la SUA lente, non quella di un altro', () {
    // **LA LENTE NON APRE PIU LA BOLLA, e questo e voluto.** Ordine DF voce
    // 02: con la lente sempre in testa, le prime parole di ogni lettura dello
    // stesso argomento erano identiche. Adesso la lente sta **dentro** la
    // prima frase, in una delle otto aperture, e a volte apre e a volte no.
    //
    // Cio' che resta da difendere e' che sia **la sua**: se un argomento
    // prendesse la lente di un altro, il Consiglio parlerebbe della cosa
    // sbagliata.
    final sbagliate = <String>[];
    for (final t in TarotTopic.values) {
      final lettura = TarotReading.of(TarotSpread.draw(seed: 7), t);
      if (!lettura.consiglio.contains(t.lente)) {
        sbagliate.add('${t.name}: il consiglio non porta la sua lente '
            '"${t.lente}"');
        continue;
      }
      for (final altro in TarotTopic.values) {
        if (altro == t || altro.lente == t.lente) continue;
        if (lettura.consiglio.contains(altro.lente)) {
          sbagliate.add('${t.name}: porta anche la lente di ${altro.name}');
        }
      }
    }
    expect(sbagliate, isEmpty, reason: sbagliate.join('\n'));
    expect(TarotTopic.values.map((t) => t.lente).toSet().length,
        TarotTopic.values.length,
        reason: 'due argomenti condividono la stessa lente: le sedici aperture '
            'diverse non sono piu sedici');
  });

  test('LE QUATTRO NATURE COPRONO TUTTE LE SETTANTOTTO CARTE, nei due versi',
      () {
    // **Cardinale minimo dichiarato.** La natura decide che cosa il Consiglio
    // dice del Presente e del Futuro: se una carta non avesse natura, la
    // composizione cadrebbe a runtime davanti alla persona.
    final conto = <NaturaDellaCarta, int>{};
    for (final c in TarotDeck.cards) {
      for (final rovesciata in [false, true]) {
        final n = NaturaDellaCarta.di(DrawnCard(
            card: c,
            position: SpreadPosition.presente,
            reversed: rovesciata));
        conto[n] = (conto[n] ?? 0) + 1;
      }
    }
    print('ORDINE DF VOCE 04.2: le quattro nature sulle '
        '${TarotDeck.cards.length} carte nei due versi: $conto');
    expect(TarotDeck.cards.length, 78,
        reason: 'il mazzo non ha piu settantotto carte');
    expect(conto.length, NaturaDellaCarta.values.length,
        reason: 'una delle quattro nature non tocca mai nessuna carta');
    for (final n in NaturaDellaCarta.values) {
      expect(VoceDellaStesa.cosaDiceIlPresente[n]?.length ?? 0,
          greaterThanOrEqualTo(8),
          reason: 'la natura ${n.name} ha meno di otto forme del presente');
      expect(VoceDellaStesa.gestoPerNatura[n]?.length ?? 0,
          greaterThanOrEqualTo(8),
          reason: 'la natura ${n.name} ha meno di otto gesti');
      expect(VoceDellaStesa.formeDelFuturo[n]?.length ?? 0,
          greaterThanOrEqualTo(8),
          reason: 'la natura ${n.name} ha meno di otto chiusure sul futuro');
    }
  });
}

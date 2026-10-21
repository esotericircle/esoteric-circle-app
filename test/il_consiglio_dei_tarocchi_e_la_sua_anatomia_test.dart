// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta.dart';
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta_scritta.dart';
import 'package:esoteric_circle/core/tarot/la_domanda_letta.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/tetti_della_stesa.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'ga06_campioni_per_i_lettori_ciechi_test.dart' as campioni;

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
///
/// **E DALL'ORDINE GA, voci GA.03, GA.05, GA.06 e GA.07, 20 ottobre 2026,
/// il Consiglio di casa e' il responso principale nella forma nuova**: il
/// titolo, la risposta e il "Cosa fare adesso", ogni paragrafo da 40 a 50
/// parole (decisione del fondatore "Carte dal corpus": il modello scrive solo
/// il responso principale, e quando non torna parla
/// `VoceDellaStesa.responsoDiCasa`). Il terzo paragrafo, col legame, il
/// seguito, i versi e la chiusura, **scompare**; la domanda di chiusura e la
/// riga del cielo escono dai paragrafi; il tetto del Consiglio intero in
/// caratteri diventa il tetto di **un paragrafo**, e niente si tronca piu'.
/// La prima frase **risponde** (GA.06): porta la lente della domanda, la
/// carta che regge la stesa e la sua natura. Le prove qui sotto leggono la
/// voce alla fonte, cosi' restano vere qualunque forma prenda
/// `TarotReading`.
void main() {
  /// Tutti e sedici gli argomenti per un pugno di estrazioni, nelle quattro
  /// stese: le prove qui dentro guardano la **forma**, e la forma non ha
  /// bisogno di cento giri. Le cento le guarda `cento_letture_uguali_test.dart`.
  List<
      (
        TarotTopic,
        TarotSpread,
        ({String titolo, String risposta, String cosaFare})
      )> leLetture({int quanti = 8, String? domanda}) {
    final fuori = <(
      TarotTopic,
      TarotSpread,
      ({String titolo, String risposta, String cosaFare})
    )>[];
    for (final tipo in TarotSpreadType.values) {
      for (final t in TarotTopic.values) {
        for (var seme = 0; seme < quanti; seme++) {
          final stesa = TarotSpread.draw(
              seed: seme * 7 + t.index, posizioni: tipo.posizioni);
          fuori.add((
            t,
            stesa,
            VoceDellaStesa.responsoDiCasa(stesa, t, domandaScritta: domanda)
          ));
        }
      }
    }
    return fuori;
  }

  // LAPIDE: `primaFrase`, la prima frase fino al primo punto: dall'ordine GA
  // voce GA.06 il verdetto si legge con `verdetto`, qui sotto.

  /// Le frasi del verdetto: la prima (dopo l'avviso della domanda doppia), e
  /// la seguente quando la prima non nomina nessuna carta.
  String verdetto(String risposta, TarotSpread s) {
    final f = risposta
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((x) => x.trim().isNotEmpty)
        .toList();
    final i = f.first.startsWith('Le carte rispondono alla prima') && f.length > 1 ? 1 : 0;
    if (!s.cards.any(
            (c) => f[i].toLowerCase().contains(c.card.name.toLowerCase())) &&
        i + 1 < f.length) {
      return '${f[i]} ${f[i + 1]}';
    }
    return f[i];
  }

  test(
      'DF.04.1 e GA.06: LA PRIMA FRASE NOMINA LA CARTA CHIAVE, E SENZA DOMANDA '
      'PORTA LA LENTE', () {
    // **E' l'esatto contrario di cio' che questa guardia pretendeva ieri.**
    // Dall'ordine GA la pretesa sale dal primo paragrafo alla prima frase:
    // *"risposte dirette immediatamente"*. **Dall'ordine GA voce GA.06, 21
    // ottobre 2026**, la carta e' la carta chiave della stesa
    // (`TarotReading.chiaveDi`), non quella della prima posizione: il
    // lettore cieco ne ha trovate 19 su 30 nominate al posto della chiave.
    // E la lente sta nella prima frase solo quando la persona non ha scritto
    // una domanda: con la domanda scritta la prima frase risponde a lei
    // (LAPIDE: "la prima frase porta la lente" sempre, che metteva *"sul
    // ritorno che aspetti"* in testa alla risposta su una causa legale).
    final senza = <String>[];
    var quante = 0;
    for (final domanda in [null, 'Il colloquio di giovedì andrà bene?']) {
      for (final (t, stesa, r) in leLetture(domanda: domanda)) {
        quante++;
        final chiave =
            TarotReading.chiaveDi(stesa, domandaScritta: domanda).drawn;
        final prima = verdetto(r.risposta, stesa);
        if (!prima.toLowerCase().contains(chiave.displayName.toLowerCase())) {
          senza.add('${t.name}: la prima frase non nomina la chiave '
              '${chiave.displayName}: "$prima"');
        }
        if (domanda == null &&
            !prima.toLowerCase().contains(t.lente.toLowerCase())) {
          senza.add('${t.name}: senza domanda la prima frase non porta la '
              'lente: "$prima"');
        }
      }
    }
    print('ORDINE GA VOCE 06: su $quante letture, prime frasi senza la carta '
        'chiave o senza la lente ${senza.length}');
    cardinaleMinimo(quante, TarotSpreadType.values.length * 16 * 8 * 2,
        cosa: 'letture di casa guardate');
    expect(senza, isEmpty, reason: senza.take(6).join('\n'));
  });

  test('DF.04.2: L APPRODO NON E UNA MINACCIA QUANDO LA CARTA NON LO E', () {
    // **Il fondatore l ha nominato per primo:** la formula *"X non e una
    // sentenza: e dove questo va se non cambi passo"* toccava a **L Appeso**,
    // il dono della sospensione, e a **Il Mondo**, il cerchio che si compie.
    //
    // **La grandezza misurata e la famiglia di parole della minaccia**, dentro
    // le letture in cui l'approdo e una carta di compimento, cioe un Arcano
    // Maggiore dritto. Dall'ordine GA il seguito vive nell'approdo del "Cosa
    // fare adesso" (`VoceDellaStesa.formeDellApprodo`).
    const minacce = [
      'se non cambi passo',
      'non e una sentenza',
      'non è una sentenza',
      'minaccia',
      'condanna',
    ];
    // **Dall'ordine GA voce GA.06** l'approdo aperto e' quello col tono
    // favorevole dal suo significato (`LaCartaNellaRisposta`), non piu' il
    // Maggiore dritto della natura di compimento (LAPIDE: `NaturaDellaCarta`).
    final colpe = <String>[];
    var conCompimento = 0;
    for (final (t, stesa, r) in leLetture(quanti: 24)) {
      final approdo = stesa.approdo;
      if (approdo == null ||
          LaCartaNellaRisposta.di(approdo).tono != TonoDellaCarta.favorevole) {
        continue;
      }
      conCompimento++;
      for (final m in minacce) {
        if ('${r.risposta} ${r.cosaFare}'.toLowerCase().contains(m)) {
          colpe.add('${t.name}, approdo ${approdo.displayName}: "$m"');
        }
      }
    }
    print('ORDINE DF VOCE 04.2: letture con l approdo di compimento esaminate '
        '$conCompimento, minacce trovate ${colpe.length}');
    expect(conCompimento, greaterThan(20),
        reason: 'non ci sono abbastanza letture con l approdo di compimento: '
            'questa prova sta cercando dentro il nulla');
    expect(colpe, isEmpty,
        reason: 'la minaccia e detta su una carta di compimento:\n'
            '${colpe.take(6).join("\n")}');
  });

  test(
      'DF.04.3: IL CONSIGLIO NON CITA I SIGNIFICATI, che stanno gia sotto le '
      'carte', () {
    // **Il difetto misurato dal fondatore:** i significati erano scritti **due
    // volte nella stessa schermata**, nell elenco Passato Presente Futuro e di
    // nuovo dentro il Consiglio, a pochi centimetri di distanza.
    final doppi = <String>[];
    for (final (t, stesa, r) in leLetture()) {
      final testo = '${r.risposta} ${r.cosaFare}';
      for (final c in stesa.cards) {
        final sintesi = c.summary.replaceAll(RegExp(r'\.$'), '');
        if (sintesi.length < 12) continue;
        if (testo.contains(sintesi)) {
          doppi.add('${t.name}: "${c.card.name}" porta la sua sintesi dentro '
              'il Consiglio, e la stessa sintesi si legge gia sotto la carta');
        }
      }
    }
    print('ORDINE DF VOCE 04.3: significati ripetuti dentro il Consiglio '
        '${doppi.length}');
    expect(doppi, isEmpty, reason: doppi.take(6).join('\n'));
  });

  /// **TUTTI I TESTI DELLA VOCE**, ordine GA voce GA.06: cio' che ogni
  /// carta-verso porta nella risposta, i gesti e le cose da non fare di ogni
  /// situazione, lente e tema sensibile, le frasi di servizio. LAPIDE: le
  /// tavole di forme a segnaposto (`verdettiDelCuore` e le altre sei).
  List<String> testiDellaVoce() => [
        for (final c in LaCartaNellaRisposta.tavola.values) c.tema,
        for (final testi in testiDelleCarte.values) ...testi.values,
        for (final gesti in gestiDellaDomanda.values) ...gesti.values,
        for (final domanda in [
          'L\'operazione andrà bene?',
          'Vincerò la causa?',
          'Conviene investire in borsa?',
        ])
          for (final t in TarotTopic.values) ...[
            ...LaDomandaLetta.di(domanda).azioni(t),
            ...LaDomandaLetta.di(domanda).nonFare(t),
          ],
        ...VoceDellaStesa.frasiDiServizio,
      ];

  test(
      'DF.04.7 e GA.07: NESSUNA CIFRA, NESSUN FUTURO CERTO, NESSUNA PAROLA '
      'VIETATA, IN NESSUN TESTO', () {
    // *"con 3 Arcani Maggiori nella stesa"*: il fondatore lo ha nominato.
    // Le regole di casa si guardano su tutti i testi della voce e su un
    // migliaio di composizioni vere: un testo che nessun seme pesca resta un
    // testo che un giorno qualcuno legge.
    //
    // **IL FUTURO DATO PER CERTO** si cerca come grandezza della lingua: le
    // desinenze del futuro semplice. Le parole che finiscono cosi' senza
    // essere un futuro stanno nell'elenco delle eccezioni, scritte per nome.
    const nonFuturi = {'però', 'perciò', 'già', 'concrete', 'discrete'};
    // Non `\b`: in Dart non vede le lettere accentate, e "sarà" sfuggirebbe.
    final futuro = RegExp(
        r'(?<![A-Za-zÀ-ÿ])[A-Za-zÀ-ÿ]+(rò|rà|rai|remo|rete|ranno)(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    final guasti = <String>[];
    final testi = [
      ...testiDellaVoce(),
      for (final domanda in [null, ...campioni.domande.map((d) => d.$1)])
        for (final (_, _, r) in leLetture(quanti: 1, domanda: domanda)) ...[
          r.titolo,
          r.risposta,
          r.cosaFare,
        ],
    ];
    for (final t in testi) {
      if (RegExp(r'\d').hasMatch(t)) guasti.add('cifra: "$t"');
      if (RegExp(r'\bvoce\b', caseSensitive: false).hasMatch(t)) {
        guasti.add('la parola vietata "voce": "$t"');
      }
      if (RegExp(r',\s+(e|ed)\s').hasMatch(t)) {
        guasti.add('virgola prima di e: "$t"');
      }
      if (t.contains('\u2014') || t.contains('\u2013')) {
        guasti.add('trattino lungo: "$t"');
      }
      if (t.contains('[') || t.contains('|') || t.contains(']')) {
        guasti.add('marca del genere non risolta: "$t"');
      }
      for (final m in futuro.allMatches(t)) {
        final parola = m.group(0)!.toLowerCase();
        if (!nonFuturi.contains(parola)) {
          guasti.add('futuro "$parola": "$t"');
        }
      }
    }
    print('ORDINE GA VOCE 06: testi guardati ${testi.length}, guasti '
        '${guasti.length}');
    cardinaleMinimo(testi.length, 156 * 3 + 1000,
        cosa: 'testi della voce e composizioni guardate');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('DF.04.5: IL TITOLO C E SEMPRE, E NON HA UN PUNTO DENTRO', () {
    // *"Il titolo grande col significato della carta presente compare in una
    // lettura su quattro, e nelle altre tre no. O c e sempre o non c e mai, e
    // senza il punto fermo dentro il titolo."*
    // **LAPIDE: "VoceDellaStesa.titolo(stesa)", la sintesi della carta del
    // Presente.** Ordine FK aggiunta voci A1 e A2: il titolo e' la risposta,
    // `TarotReading.titolo`. La legge della voce DF.04.5 resta la stessa, e
    // dall'ordine GA il titolo ha da tre a otto parole.
    final guasti = <String>[];
    var quante = 0;
    for (final (t, _, r) in leLetture(quanti: 6)) {
      quante++;
      final titolo = r.titolo;
      if (titolo.trim().isEmpty) {
        guasti.add('${t.name}: titolo vuoto');
      }
      if (titolo.endsWith('.')) {
        guasti.add('${t.name}: il titolo finisce col punto, "$titolo"');
      }
      final n = LaFormaDelResponso.parole(titolo);
      if (n < 3 || n > 8) {
        guasti.add('${t.name}: il titolo ha $n parole, "$titolo"');
      }
    }
    print('ORDINE DF VOCE 04.5: titoli guasti ${guasti.length} su $quante');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
  });

  test('LA DOMANDA NON STA NEI PARAGRAFI, ne quella del corpus ne la sua', () {
    // **LAPIDE: "la domanda in fondo quando viene dal corpus, e mai due
    // volte".** Ordine GA: la domanda di chiusura resta un dato
    // (`TarotReading.domanda`, il dono del mattino dopo) e non e' un
    // paragrafo della forma; la domanda scritta sta a video sotto il titolo,
    // e dentro il paragrafo la misura dipenderebbe da quanto scrive la
    // persona. Si pretende che i due paragrafi non portino ne' l'una ne'
    // l'altra. Dall'ordine GA voce GA.06 la domanda scritta cambia la
    // risposta: ne sceglie la forma e i gesti.
    const sua = 'Devo lasciare il mio lavoro per aprire una libreria?';
    final chiusure = TarotReading.domande.map(LaMarcaDelGenere.risolvi);
    final guasti = <String>[];
    var quante = 0;
    for (final t in TarotTopic.values) {
      for (var seme = 0; seme < 8; seme++) {
        quante++;
        final s = TarotSpread.draw(seed: seme);
        final senza = VoceDellaStesa.responsoDiCasa(s, t);
        final con = VoceDellaStesa.responsoDiCasa(s, t, domandaScritta: sua);
        final testo = '${con.risposta} ${con.cosaFare}';
        if (testo.contains(sua)) guasti.add('${t.name}: la domanda scritta');
        for (final c in chiusure) {
          if (testo.contains(c)) guasti.add('${t.name}: la chiusura "$c"');
        }
        // **LAPIDE: "la domanda scritta non cambia i paragrafi".** Ordine
        // GA voce GA.06: la risposta risponde alla domanda, quindi la
        // domanda scritta la cambia; si pretende il contrario.
        if (con.risposta == senza.risposta && con.cosaFare == senza.cosaFare) {
          guasti.add('${t.name}: la domanda scritta non cambia niente');
        }
      }
    }
    cardinaleMinimo(quante, 16 * 8, cosa: 'letture guardate');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
  });

  test('la RISPOSTA viene prima dell AZIONE, come dice l anatomia', () {
    // **LA GRANDEZZA MISURATA E CAMBIATA, e la legge no.** La legge
    // dell'anatomia: **prima cosa la lettura vede, poi cosa puoi fare**. Il
    // primo paragrafo non apre con un gesto; il secondo porta un gesto
    // concreto (scritto per la domanda, `gestiDellaDomanda`, o il gesto
    // scritto della carta, `VoceDellaStesa.gestoDellaCarta`; sui temi
    // sensibili `LaDomandaLetta.azioni`) e dice che cosa **non** fare.
    // LAPIDE: l'elenco dei ventiquattro imperativi delle forme di
    // `gestoPerNatura`.
    final guasti = <String>[];
    var quante = 0;
    for (final domanda in [null, ...campioni.domande.map((d) => d.$1)]) {
      for (final (t, stesa, r) in leLetture(quanti: 2, domanda: domanda)) {
        quante++;
        final gesti = [
          for (final c in stesa.cards) VoceDellaStesa.gestoDellaCarta(c),
          for (final g in gestiDellaDomanda.values) ...g.values,
          ...LaDomandaLetta.di(domanda).azioni(t),
        ];
        if (!gesti.any((g) => r.cosaFare.contains(g))) {
          guasti.add('${t.name}, "$domanda": il secondo paragrafo non porta '
              'nessun gesto: "${r.cosaFare}"');
        }
        if (!RegExp(r'(^|[.:] |E )[Nn]on ').hasMatch(r.cosaFare)) {
          guasti.add('${t.name}: il secondo paragrafo non dice che cosa non '
              'fare: "${r.cosaFare}"');
        }
        if (gesti
            .any((g) => r.risposta.toLowerCase().startsWith(g.toLowerCase()))) {
          guasti.add('${t.name}: la risposta apre con un gesto');
        }
      }
    }
    print(
        'ORDINE S VOCE 26: letture esaminate $quante, guasti ${guasti.length}');
    cardinaleMinimo(quante, 36 * 4 * 16 * 2, cosa: 'letture esaminate');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
    // Le tre parti dell'anatomia restano quelle.
    expect(ParteDelResponso.nelResponso.length, 3);
  });

  test('NIENTE SI TRONCA: due paragrafi interi, ognuno chiuso dal suo punto',
      () {
    // **LAPIDE: "il troncamento non decapita: la domanda resta anche al filo
    // del tetto".** Il Consiglio si tagliava al tetto con
    // `TettiDellaStesa.dentro`, e la prova pretendeva che il taglio non
    // mangiasse la domanda. Ordine GA voce GA.07, *"I TESTI RISCRITTI, MAI
    // TRONCATI"*: si pretende che i paragrafi siano due, interi, nella
    // misura, e che nessuno finisca a meta' frase.
    final monchi = <String>[];
    var quante = 0;
    for (final (t, stesa, r) in leLetture(quanti: 15)) {
      quante++;
      for (final p in [r.risposta, r.cosaFare]) {
        final prosa = p.trimRight();
        if (!prosa.endsWith('.') &&
            !prosa.endsWith('?') &&
            !prosa.endsWith('!')) {
          monchi.add('${t.name} ${stesa.cards.length} carte: un paragrafo '
              'finisce con "...${prosa.substring(prosa.length - 30)}"');
        }
        if (!LaFormaDelResponso.aMisura(p)) {
          monchi.add('${t.name}: ${LaFormaDelResponso.parole(p)} parole');
        }
      }
      expect(VoceDellaStesa.paragrafi(stesa, t), [r.risposta, r.cosaFare]);
    }
    cardinaleMinimo(quante, TarotSpreadType.values.length * 16 * 15,
        cosa: 'letture guardate');
    expect(monchi, isEmpty,
        reason: 'un paragrafo e stato tagliato o e fuori misura:\n'
            '${monchi.take(6).join("\n")}');
  });

  test('il tetto di un paragrafo tiene il caso peggiore con margine', () {
    // **Dall'ordine GA voce GA.06 il caso peggiore si misura enumerando**:
    // ogni carta-verso come carta chiave, in ogni stesa, con ogni domanda del
    // campione e senza domanda. LAPIDE: la somma delle fessure piu' lunghe,
    // che valeva per le forme a segnaposto.
    final caso = Random(3801);
    var peggiore = 0;
    var quale = '';
    var quante = 0;
    for (final c in TarotDeck.cards) {
      for (final rovesciata in [false, true]) {
        for (final tipo in TarotSpreadType.values) {
          for (final domanda in [
            null,
            ...campioni.domande.map((d) => d.$1),
          ]) {
            final altre = TarotDeck.cards.where((x) => x != c).toList()
              ..shuffle(caso);
            var a = 0;
            final carte = [
              for (var i = 0; i < tipo.posizioni.length; i++)
                DrawnCard(
                    card: i == 0 ? c : altre[a++],
                    position: tipo.posizioni[i],
                    reversed: i == 0 ? rovesciata : caso.nextBool()),
            ];
            final r = VoceDellaStesa.responsoDiCasa(
                TarotSpread(carte), TarotTopic.values[caso.nextInt(16)],
                domandaScritta: domanda, chiave: carte.first);
            quante++;
            for (final p in [r.risposta, r.cosaFare]) {
              if (p.length > peggiore) {
                peggiore = p.length;
                quale = p;
              }
            }
          }
        }
      }
    }
    print('ORDINE GA VOCE 06: su $quante composizioni il paragrafo piu lungo '
        'ha $peggiore caratteri ("$quale"). Tetto '
        '${TettiDellaStesa.consiglio}.');
    cardinaleMinimo(quante, 156 * 4 * 36, cosa: 'composizioni misurate');
    expect(TettiDellaStesa.consiglio - peggiore,
        greaterThan(TettiDellaStesa.consiglio * 0.10),
        reason: 'il margine fra il caso peggiore ($peggiore) e il tetto '
            '(${TettiDellaStesa.consiglio}) e meno del dieci per cento: il '
            'tetto sta al filo');
  });

  test('ogni argomento innesta la SUA lente, non quella di un altro', () {
    // **LA LENTE NON APRE PIU LA BOLLA SEMPRE, e questo e voluto.** Ordine DF
    // voce 02: con la lente sempre in testa, le prime parole di ogni lettura
    // dello stesso argomento erano identiche. Adesso la lente sta **dentro**
    // la prima frase, a volte in testa e a volte in mezzo, in minuscolo.
    //
    // Cio' che resta da difendere e' che sia **la sua**: se un argomento
    // prendesse la lente di un altro, il Consiglio parlerebbe della cosa
    // sbagliata.
    final sbagliate = <String>[];
    for (final t in TarotTopic.values) {
      for (var seme = 0; seme < 6; seme++) {
        final r =
            VoceDellaStesa.responsoDiCasa(TarotSpread.draw(seed: seme), t);
        final testo = '${r.risposta} ${r.cosaFare}'.toLowerCase();
        if (!testo.contains(t.lente.toLowerCase())) {
          sbagliate.add('${t.name}: il consiglio non porta la sua lente '
              '"${t.lente}"');
          continue;
        }
        for (final altro in TarotTopic.values) {
          if (altro == t || altro.lente == t.lente) continue;
          if (testo.contains(altro.lente.toLowerCase())) {
            sbagliate.add('${t.name}: porta anche la lente di ${altro.name}');
          }
        }
      }
    }
    expect(sbagliate, isEmpty, reason: sbagliate.join('\n'));
    expect(TarotTopic.values.map((t) => t.lente).toSet().length,
        TarotTopic.values.length,
        reason: 'due argomenti condividono la stessa lente: le sedici aperture '
            'diverse non sono piu sedici');
  });

  test('I TRE TONI COPRONO TUTTE LE SETTANTOTTO CARTE, nei due versi', () {
    // **Cardinale minimo dichiarato.** Ordine GA voce GA.06: il tono decide
    // il verdetto, e una carta senza la sua voce nella tavola farebbe cadere
    // la composizione a runtime davanti alla persona. LAPIDE: le quattro
    // nature di `NaturaDellaCarta`, che venivano dall'arcano e dal verso.
    final conto = <TonoDellaCarta, int>{};
    for (final c in TarotDeck.cards) {
      for (final rovesciata in [false, true]) {
        final d = DrawnCard(
            card: c, position: SpreadPosition.presente, reversed: rovesciata);
        final k = LaCartaNellaRisposta.tavola[LaCartaNellaRisposta.chiaveDi(d)];
        expect(k, isNotNull, reason: '${d.displayName} non ha la sua voce');
        conto[k!.tono] = (conto[k.tono] ?? 0) + 1;
      }
    }
    print('ORDINE GA VOCE 06: i tre toni sulle ${TarotDeck.cards.length} '
        'carte nei due versi: $conto');
    expect(TarotDeck.cards.length, 78,
        reason: 'il mazzo non ha piu settantotto carte');
    expect(LaCartaNellaRisposta.tavola.length, 156);
    expect(conto.length, TonoDellaCarta.values.length,
        reason: 'uno dei tre toni non tocca mai nessuna carta');
  });
}

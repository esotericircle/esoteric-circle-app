// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/tetti_della_stesa.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

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

  /// La prima frase di un paragrafo: fino al primo punto fermo.
  String primaFrase(String p) {
    final i = p.indexOf(RegExp(r'[.!?](\s|$)'));
    return i < 0 ? p : p.substring(0, i + 1);
  }

  test(
      'DF.04.1 e GA.06: LA PRIMA FRASE NOMINA LA CARTA CHE REGGE E PORTA LA '
      'SUA LENTE', () {
    // **E' l'esatto contrario di cio' che questa guardia pretendeva ieri.**
    // Dall'ordine GA la pretesa sale dal primo paragrafo alla prima frase:
    // *"risposte dirette immediatamente"*.
    final senza = <String>[];
    var quante = 0;
    for (final (t, stesa, r) in leLetture()) {
      quante++;
      final prima = primaFrase(r.risposta);
      if (!prima.contains(stesa.cuore.displayName)) {
        senza.add('${t.name}: la prima frase non nomina '
            '${stesa.cuore.displayName}: "$prima"');
      }
      if (!prima.toLowerCase().contains(t.lente.toLowerCase())) {
        senza.add('${t.name}: la prima frase non porta la lente: "$prima"');
      }
    }
    print('ORDINE GA VOCE 06: su $quante letture, prime frasi senza la carta '
        'o senza la lente ${senza.length}');
    cardinaleMinimo(quante, TarotSpreadType.values.length * 16 * 8,
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
    final colpe = <String>[];
    for (final f
        in VoceDellaStesa.formeDellApprodo[NaturaDellaCarta.compimento]!) {
      for (final m in minacce) {
        if (f.toLowerCase().contains(m)) colpe.add('forma: "$f" porta "$m"');
      }
    }
    var conCompimento = 0;
    for (final (t, stesa, r) in leLetture(quanti: 24)) {
      final approdo = stesa.approdo;
      if (approdo == null ||
          NaturaDellaCarta.di(approdo) != NaturaDellaCarta.compimento) {
        continue;
      }
      conCompimento++;
      for (final m in minacce) {
        if (r.cosaFare.toLowerCase().contains(m)) {
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

  /// Tutte le forme della voce, una tavola dopo l'altra.
  Map<String, List<String>> tavole() => {
        'verdetto': [
          for (final l in VoceDellaStesa.verdettiDelCuore.values) ...l
        ],
        'cosa dice': [
          for (final l in VoceDellaStesa.cosaDiceIlPresente.values) ...l
        ],
        'cosa vuol dire': [
          for (final l in VoceDellaStesa.cosaVuolDire.values) ...l
        ],
        'aggancio': VoceDellaStesa.aggancioDellAzione,
        'gesto': [for (final l in VoceDellaStesa.gestoPerNatura.values) ...l],
        'approdo': [
          for (final l in VoceDellaStesa.formeDellApprodo.values) ...l
        ],
        'perche': VoceDellaStesa.percheFarlo,
        'titolo': [
          for (final l in VoceDellaStesa.titoliDelPresente.values) ...l
        ],
      };

  test(
      'DF.04.7 e GA.07: NESSUNA CIFRA, NESSUN FUTURO CERTO, NESSUNA PAROLA '
      'VIETATA, IN NESSUNA FORMA', () {
    // *"con 3 Arcani Maggiori nella stesa"*: il fondatore lo ha nominato.
    // Dall'ordine GA le regole di casa si guardano sulle forme, tutte, e non
    // su un campione di letture: una forma che nessun seme pesca resta una
    // forma che un giorno qualcuno legge.
    //
    // **IL FUTURO DATO PER CERTO** si cerca come grandezza della lingua: le
    // desinenze del futuro semplice. Le parole che finiscono cosi' senza
    // essere un futuro stanno nell'elenco delle eccezioni, scritte per nome.
    const nonFuturi = {'però', 'perciò', 'già'};
    // Non `\b`: in Dart non vede le lettere accentate, e "sarà" sfuggirebbe.
    final futuro = RegExp(
        r'(?<![A-Za-zÀ-ÿ])[A-Za-zÀ-ÿ]+(rò|rà|rai|remo|rete|ranno)(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    final guasti = <String>[];
    var guardate = 0;
    final prima = LaMarcaDelGenere.formaCorrente;
    try {
      for (final e in tavole().entries) {
        for (final forma in e.value) {
          for (final f in CourtesyForm.values) {
            LaMarcaDelGenere.formaCorrente = f;
            guardate++;
            final t = VoceDellaStesa.riempi(forma,
                lente: 'Lente', presente: 'Nome', futuro: 'Approdo');
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
            if (e.key != 'titolo' && !VoceDellaStesa.valeOvunque(forma)) {
              guasti.add('non vale per ogni stesa: "$forma"');
            }
          }
        }
      }
    } finally {
      LaMarcaDelGenere.formaCorrente = prima;
    }
    print('ORDINE GA VOCE 07: forme guardate con ogni forma di cortesia '
        '$guardate, guasti ${guasti.length}');
    cardinaleMinimo(guardate, 212 * 4,
        cosa: 'forme guardate con ogni forma di cortesia');
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
    // l'altra, e che la domanda scritta non cambi la misura.
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
        if (con.risposta != senza.risposta || con.cosaFare != senza.cosaFare) {
          guasti.add('${t.name}: la domanda scritta cambia i paragrafi');
        }
      }
    }
    cardinaleMinimo(quante, 16 * 8, cosa: 'letture guardate');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
  });

  test('la RISPOSTA viene prima dell AZIONE, come dice l anatomia', () {
    // **LA GRANDEZZA MISURATA E CAMBIATA, e la legge no.** Prima si cercavano
    // `group.risposta` e `group.consiglio`, cioe due costanti: quelle costanti
    // non stanno piu nel Consiglio, e cercarle qui vorrebbe dire pretendere il
    // difetto.
    //
    // La legge dell anatomia resta: **prima cosa la lettura vede, poi cosa
    // puoi fare**. Si misura sui paragrafi: il primo nomina le carte e dice
    // cosa vedono, il secondo porta un imperativo. Dall'ordine GA, voce
    // GA.06, il secondo dice anche che cosa **non** fare.
    const imperativi = [
      'Fai ',
      'Scegli ',
      'Chiedi ',
      'Metti ',
      'Cerca ',
      'Rendi ',
      'Fissa ',
      'Dichiara ',
      'Usa ',
      'Dai ',
      'Mostra ',
      'Togli ',
      'Segna ',
      'Scrivi ',
      'Smetti ',
      'Rimanda ',
      'Prova ',
      'Parla ',
      'Prenditi ',
      'Cambia ',
      'Elimina ',
      'Controlla ',
      'Rinuncia ',
      'Rifai ',
    ];
    final guasti = <String>[];
    var quante = 0;
    for (final (t, _, r) in leLetture(quanti: 12)) {
      quante++;
      final azione = r.cosaFare;
      if (!imperativi.any(azione.contains)) {
        guasti.add('${t.name}: il secondo paragrafo non porta nessun gesto '
            'da fare: "${azione.substring(0, azione.length.clamp(0, 60))}"');
      }
      if (!RegExp(r'(^|[.:] |E )[Nn]on ').hasMatch(azione)) {
        guasti.add('${t.name}: il secondo paragrafo non dice che cosa non '
            'fare: "$azione"');
      }
      if (imperativi.any(r.risposta.startsWith)) {
        guasti.add('${t.name}: la risposta apre con un gesto');
      }
    }
    print('ORDINE S VOCE 26: letture esaminate $quante, senza gesto nel '
        'secondo paragrafo ${guasti.length}');
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
    // **Il caso peggiore si calcola, non si campiona.** Ogni fessura si
    // riempie con la lente e il nome di carta piu' lunghi in caratteri, con
    // ogni marca del genere; il paragrafo piu' lungo possibile e' la somma
    // delle fessure piu' lunghe e degli spazi fra loro.
    final lente = TarotTopic.values
        .map((t) => t.lente)
        .reduce((a, b) => a.length >= b.length ? a : b);
    final nome = [
      for (final c in TarotDeck.cards)
        for (final r in [false, true])
          DrawnCard(card: c, position: SpreadPosition.presente, reversed: r)
              .displayName
    ].reduce((a, b) => a.length >= b.length ? a : b);
    int lunga(List<String> tavola) {
      var max = 0;
      final prima = LaMarcaDelGenere.formaCorrente;
      try {
        for (final f in tavola) {
          for (final c in CourtesyForm.values) {
            LaMarcaDelGenere.formaCorrente = c;
            final n = VoceDellaStesa.riempi(f,
                    lente: lente, presente: nome, futuro: nome)
                .length;
            if (n > max) max = n;
          }
        }
      } finally {
        LaMarcaDelGenere.formaCorrente = prima;
      }
      return max;
    }

    final t = tavole();
    final risposta = lunga(t['verdetto']!) +
        lunga(t['cosa dice']!) +
        lunga(t['cosa vuol dire']!) +
        2;
    final cosaFare = lunga(t['aggancio']!) +
        lunga(t['gesto']!) +
        [lunga(t['approdo']!), lunga(t['perche']!)]
            .reduce((a, b) => a > b ? a : b) +
        2;
    final peggiore = risposta > cosaFare ? risposta : cosaFare;
    // E il campione vero, che non puo' superare il calcolo.
    var campione = 0;
    for (final (_, _, r) in leLetture(quanti: 10)) {
      for (final p in [r.risposta, r.cosaFare]) {
        if (p.length > campione) campione = p.length;
      }
    }
    print('ORDINE GA VOCE 07: il paragrafo piu lungo possibile ha $peggiore '
        'caratteri (risposta $risposta, cosa fare $cosaFare; lente "$lente", '
        'carta "$nome"); il piu lungo del campione $campione. Tetto '
        '${TettiDellaStesa.consiglio}.');
    expect(campione, lessThanOrEqualTo(peggiore),
        reason: 'il campione supera il caso peggiore calcolato: il calcolo non '
            'e piu la somma delle fessure');
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

  test('LE QUATTRO NATURE COPRONO TUTTE LE SETTANTOTTO CARTE, nei due versi',
      () {
    // **Cardinale minimo dichiarato.** La natura decide che cosa il Consiglio
    // dice della carta che regge e dell'approdo: se una carta non avesse
    // natura, la composizione cadrebbe a runtime davanti alla persona.
    final conto = <NaturaDellaCarta, int>{};
    for (final c in TarotDeck.cards) {
      for (final rovesciata in [false, true]) {
        final n = NaturaDellaCarta.di(DrawnCard(
            card: c, position: SpreadPosition.presente, reversed: rovesciata));
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
      for (final (nome, tavola) in [
        ('verdetti', VoceDellaStesa.verdettiDelCuore),
        ('forme di cosa dice', VoceDellaStesa.cosaDiceIlPresente),
        ('forme di cosa vuol dire', VoceDellaStesa.cosaVuolDire),
        ('gesti', VoceDellaStesa.gestoPerNatura),
        ('approdi', VoceDellaStesa.formeDellApprodo),
        ('titoli', VoceDellaStesa.titoliDelPresente),
      ]) {
        expect(tavola[n]?.length ?? 0, greaterThanOrEqualTo(8),
            reason: 'la natura ${n.name} ha meno di otto $nome');
      }
      expect(VoceDellaStesa.titoliDelPresente[n]!.length,
          VoceDellaStesa.cosaDiceIlPresente[n]!.length,
          reason: '${n.name}: i titoli non sono uno per forma di cosa dice');
    }
  });
}

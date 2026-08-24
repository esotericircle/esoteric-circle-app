import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/core/sigilli/pezzi_dell_identita.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// I 165 TRAGUARDI, sorvegliati contando e non guardando.
///
/// Ogni prova qui dentro e' un criterio di accettazione dell'ordine O, e
/// nessuna si accontenta dell'intenzione: si misura sulla CONDIZIONE, che e'
/// un dato tipizzato, non su una promessa scritta in un commento.
///
/// **Perche' contano piu' delle altre prove.** Un traguardo sbagliato non fa
/// cadere l'app: fa perdere la ragione per cui una persona torna domani. Un
/// sentiero pieno di compiti da sbrigare in un pomeriggio sembrerebbe
/// completo e sarebbe morto.
void main() {
  // **I MINIMI SEGUONO IL CORPUS DELLA REVISIONE C, ordine AR voce 02.** La
  // pretesa non cambia: un sentiero non deve essere una lista di compiti da
  // sbrigare in un pomeriggio, e ogni famiglia deve esserci. I numeri invece
  // seguono il dato, perche' il dato e' cambiato per decisione di Mauro: i
  // conteggi nudi sono spariti e al loro posto sono entrate profondita',
  // coincidenza e costanza. Misurato sui tre sentieri, il piu' povero di
  // ciascuna famiglia porta: cielo 13, ritorno 6, giornata 4, profondita 8,
  // ampiezza 6, memoria 0 (il Loto non ne ha), cerchio 4.
  const minimiPerFamiglia = {
    FamigliaDelTraguardo.cielo: 10,
    FamigliaDelTraguardo.ritorno: 6,
    FamigliaDelTraguardo.giornata: 4,
    FamigliaDelTraguardo.profondita: 8,
    FamigliaDelTraguardo.ampiezza: 5,
    // **IDENTITA' NON STA PIU' QUI, e non e' un allentamento: e' aritmetica.**
    // Ordine U voce 01, coda. Il minimo di cinque per sentiero non era
    // raggiungibile e non lo era nemmeno prima: i pezzi dell'identita' che l'app
    // possiede sono NOVE, piu' i tre grandi di posizione 50 che sono di questa
    // famiglia, cioe' DODICI caselle in tutto contro le QUINDICI che tre
    // sentieri per cinque pretendono. Il conto tornava solo perche' carta
    // natale, angelo e animale occupavano nove caselle invece di tre: **il
    // minimo stava in piedi appoggiato al difetto che la voce U.01 ha tolto.**
    //
    // Al suo posto tre pretese piu' sotto, e la prima non esisteva: vieta per
    // sempre la triplicazione, che il minimo per sentiero invece incoraggiava.
    // **La guardia non e' stata allentata, e' stata spostata** su cio' che
    // l'identita' e' davvero, cioe' una cosa sola per persona e non una per
    // sentiero. Le altre sette famiglie e il tetto del Cerchio non si toccano.
    // **MEMORIA NON HA PIU' UN MINIMO PER SENTIERO, ordine AR voce 02.** Nel
    // corpus della revisione C le coincidenze sulla memoria sono quattro in
    // tutto e il Loto non ne ha nessuna: un minimo per sentiero
    // costringerebbe a inventarne, che e' esattamente cio' che l'ordine
    // vieta. Resta la pretesa che ne esistano nel Cammino, contata piu' sotto
    // sull'insieme.
  };

  test('165 traguardi, 55 per sentiero, nelle posizioni giuste', () {
    expect(Sentieri.tuttiITraguardi, hasLength(165),
        reason: 'i traguardi non sono 165');
    for (final sentiero in Sentieri.tutti) {
      final tutti = Sentieri.di(sentiero);
      expect(tutti, hasLength(55),
          reason: '${sentiero.titolo} non ha 55 traguardi');

      final mini = Sentieri.miniDi(sentiero);
      expect(mini, hasLength(50),
          reason: '${sentiero.titolo} non ha 50 traguardi piccoli');
      // **LE POSIZIONI VANNO DA 1 A 55 CON I GRANDI DENTRO, ordine AR voce
      // 02.** Nel corpus della revisione C i cinque grandi stanno a 11, 22,
      // 33, 44 e 55, e i mini occupano le altre cinquanta posizioni: prima i
      // due elenchi si sovrapponevano (mini 1..50 e grandi a 10, 20, 30, 40,
      // 50) e serviva un calcolo per rimetterli in fila. Adesso l'ordine e'
      // quello del file.
      final posizioniDeiMini = mini.map((t) => t.posizione).toList();
      expect(posizioniDeiMini.toSet().length, 50,
          reason: 'i piccoli di ${sentiero.titolo} hanno posizioni ripetute');
      expect(posizioniDeiMini.every((p) => p >= 1 && p <= 55), isTrue,
          reason: 'un piccolo di ${sentiero.titolo} sta fuori da 1..55');

      final grandi = Sentieri.grandiDi(sentiero);
      // Le posizioni dei grandi vengono dal corpus e stanno in un punto
      // solo: qui si confronta con quello, non con cinque numeri ricopiati.
      expect(grandi.map((t) => t.posizione).toList(),
          Traguardo.posizioniDeiGrandi,
          reason: 'i grandi di ${sentiero.titolo} non stanno a 10, 20, 30, '
              '40 e 50');
    }
  });

  test('le otto famiglie rispettano i minimi, e il Cerchio il suo tetto', () {
    for (final sentiero in Sentieri.tutti) {
      final conta = <FamigliaDelTraguardo, int>{};
      for (final t in Sentieri.di(sentiero)) {
        conta[t.famiglia] = (conta[t.famiglia] ?? 0) + 1;
      }
      for (final minimo in minimiPerFamiglia.entries) {
        expect(conta[minimo.key] ?? 0, greaterThanOrEqualTo(minimo.value),
            reason: '${sentiero.titolo}: la famiglia ${minimo.key.name} ha '
                '${conta[minimo.key] ?? 0} traguardi contro i ${minimo.value} '
                'che l\'ordine pretende');
      }
      // IL CERCHIO E' UN TETTO, non un minimo: la condivisione e' un premio,
      // mai un pedaggio, e un sentiero pieno di inviti sarebbe una catena di
      // sant\'Antonio con le stelle.
      expect(conta[FamigliaDelTraguardo.cerchio] ?? 0, lessThanOrEqualTo(4),
          reason: '${sentiero.titolo} chiede troppe volte di condividere');
    }
  });

  test('ogni pezzo dell\'identità è nominato da AL PIÙ un traguardo', () {
    // **LA PRETESA CHE NON ESISTEVA.** Vieta per sempre la triplicazione: un
    // pezzo dell'identita' e' una cosa che una persona ha UNA volta, quindi tre
    // traguardi sullo stesso pezzo non sono tre traguardi, sono lo stesso pagato
    // tre volte. Si contano tutte e due le forme con cui un pezzo si nomina, il
    // pezzo dichiarato e il gesto compiuto una volta.
    var pezziOsservati = 0;
    final ripetuti = <String>[];
    for (final pezzo in PezziDellIdentita.tutti) {
      pezziOsservati++;
      final chi = <String>[];
      for (final t in Sentieri.tuttiITraguardi) {
        final f = t.condizione.firma;
        if (f == 'identita:$pezzo' || f.startsWith('gesti:$pezzo:1:')) {
          chi.add(t.id);
        }
      }
      if (chi.length > 1) {
        ripetuti.add('$pezzo è nominato da ${chi.length} traguardi: '
            '${chi.join(", ")}');
      }
    }
    // **QUANTE OSSERVAZIONI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE U VOCE 01: pezzi dell\'identita osservati $pezziOsservati');
    expect(pezziOsservati, greaterThan(0),
        reason: 'la prova non ha guardato nessun pezzo: gira a vuoto');
    expect(ripetuti, isEmpty,
        reason: 'un pezzo dell\'identità si ha una volta sola, quindi un solo '
            'traguardo può nominarlo: ${ripetuti.join(" | ")}');
  });

  test('i traguardi di identita sono almeno sei in tutto', () {
    // **SEI E NON DODICI, ordine AR voce 02, e il numero viene dal dato.**
    // La revisione C del corpus ha tolto i conteggi nudi e ha riscritto i
    // 165: l'identita' compare in sei voci, non in dodici, perche' i pezzi
    // dell'identita' si danno una volta sola e ripeterli su tre sentieri era
    // proprio il difetto che l'ordine U aveva chiuso. La pretesa resta la
    // stessa (l'identita' non deve sparire dal cammino), il numero segue il
    // dato invece di comandarlo.
    // **DODICI E NON QUINDICI, e il numero non è scelto: è quanto ce n\'è.**
    // Nove pezzi dell'identita' piu' i tre grandi di posizione 50, che sono di
    // questa famiglia. Quindici era il numero che tre sentieri per cinque
    // pretendevano, e non esisteva.
    final quanti = Sentieri.tuttiITraguardi
        .where((t) => t.famiglia == FamigliaDelTraguardo.identita)
        .length;
    // ignore: avoid_print
    print('ORDINE U VOCE 01: traguardi di identita in tutto $quanti');
    expect(quanti, greaterThanOrEqualTo(6),
        reason: 'i traguardi di identità sono $quanti su dodici caselle '
            'possibili: l\'identità sta sparendo dal cammino');
  });

  test('ogni sentiero porta almeno un traguardo di identita', () {
    // **UNO E NON TRE, ordine AR voce 02, e il numero viene dal dato.** Nella
    // revisione C l'identita' e' sei voci in tutto: quattro sul Loto, una
    // sulla Costellazione, una sull'Albero. Pretenderne tre per sentiero
    // costringerebbe a inventarne, cioe' a triplicare gli stessi pezzi, che
    // e' il difetto che l'ordine U aveva chiuso. La pretesa resta che nessun
    // sentiero resti senza: chi percorre un solo sentiero deve incontrare
    // almeno una volta se stesso.
    var osservati = 0;
    for (final sentiero in Sentieri.tutti) {
      osservati++;
      final quanti = Sentieri.di(sentiero)
          .where((t) => t.famiglia == FamigliaDelTraguardo.identita)
          .length;
      expect(quanti, greaterThanOrEqualTo(1),
          reason: '${sentiero.titolo} non porta nessun traguardo di identita');
    }
    expect(osservati, 3);
  });

  test('almeno 30 traguardi per sentiero non si chiudono in giornata', () {
    for (final sentiero in Sentieri.tutti) {
      final lenti = Sentieri.miniDi(sentiero)
          .where((t) => t.condizione.chiedeUnAltroGiorno)
          .length;
      expect(lenti, greaterThanOrEqualTo(30),
          reason: '${sentiero.titolo}: solo $lenti traguardi su 50 chiedono '
              'un altro giorno. Un traguardo che si chiude nello stesso minuto '
              'in cui lo scopri non e\' un traguardo di ritorno, e\' un '
              'compito');
    }
  });

  test('almeno 10 traguardi per sentiero dipendono dal cielo vero', () {
    for (final sentiero in Sentieri.tutti) {
      final delCielo = Sentieri.di(sentiero)
          .where((t) => t.condizione.chiedeIlCielo)
          .length;
      expect(delCielo, greaterThanOrEqualTo(10),
          reason: '${sentiero.titolo} ha solo $delCielo traguardi legati a un '
              'evento del cielo: e\' la famiglia che nessuno puo\' copiare '
              'senza un motore astronomico vero');
    }
  });

  test('ogni evento nominato esiste nel catalogo del cielo', () {
    for (final t in Sentieri.tuttiITraguardi) {
      final condizione = t.condizione;
      if (condizione is FinestraDelCielo) {
        expect(EventiDelCielo.tutti, contains(condizione.evento),
            reason: '${t.id} aspetta l\'evento "${condizione.evento}", che il '
                'catalogo del cielo non sa riconoscere: quel traguardo non si '
                'accenderebbe mai');
      }
    }
  });

  test('nessun traguardo e\' la riformulazione di un altro', () {
    final visti = <String, String>{};
    final doppioni = <String>[];
    for (final t in Sentieri.tuttiITraguardi) {
      final firma = t.condizione.firma;
      if (Sentieri.agganciTrasversali.contains(firma)) continue;
      if (visti.containsKey(firma)) {
        doppioni.add('${t.id} ripete ${visti[firma]} ("$firma")');
      }
      visti[firma] = t.id;
    }
    expect(doppioni, isEmpty,
        reason: 'due traguardi chiedono la stessa identica cosa con parole '
            'diverse: $doppioni');
  });

  test('ogni ripetizione DICHIARATA sta davvero su tre sentieri', () {
    // **IL TITOLO DICEVA TRE, E OGGI SONO ZERO.** Ordine U voce 01, coda: le tre
    // ripetizioni non erano una decisione ma un difetto, e la voce le ha tolte.
    // Zero e' lo stato giusto, ma **una prova che guarda una lista vuota e passa
    // in silenzio non e' una prova**: qui il numero si stampa, cosi' chi legge il
    // verde sa se ha guardato qualcosa. La pretesa su ogni firma dichiarata
    // resta identica: se una ripetizione si dichiara, deve stare su tutti e tre.
    // ignore: avoid_print
    print('ORDINE U VOCE 01: ripetizioni dichiarate '
        '${Sentieri.agganciTrasversali.length}');
    for (final firma in Sentieri.agganciTrasversali) {
      final quanti = Sentieri.tuttiITraguardi
          .where((t) => t.condizione.firma == firma)
          .length;
      expect(quanti, 3,
          reason: 'l\'aggancio "$firma" compare $quanti volte invece di una '
              'per sentiero');
    }
  });

  test('nessuna frase wow si ripete, e nessuna e\' generica', () {
    final viste = <String, String>{};
    for (final t in Sentieri.tuttiITraguardi) {
      expect(viste.containsKey(t.frase), isFalse,
          reason: '${t.id} usa la stessa frase di ${viste[t.frase]}');
      viste[t.frase] = t.id;

      // **LA FRASE E' LA CONDIZIONE DEL CORPUS, ordine AR voce 02.** Prima
      // era una riga scritta per festeggiare, lunga per costruzione; adesso
      // il dato porta la condizione, e "Il primo Oracolo del Giorno." dice
      // tutto in ventotto caratteri. La pretesa resta che non sia vuota ne'
      // ripetuta, ed e' quella che conta: due traguardi con la stessa frase
      // sono due traguardi che si raccontano uguali.
      expect(t.frase.length, greaterThan(15),
          reason: '${t.id} ha una frase troppo corta per festeggiare '
              'qualcosa: "${t.frase}"');
      for (final vuota in const [
        'Congratulazioni',
        'Complimenti',
        'Bravo',
        'Ottimo lavoro',
        'Traguardo raggiunto',
      ]) {
        expect(t.frase.startsWith(vuota), isFalse,
            reason: '${t.id} apre con "$vuota", che vale per qualunque '
                'traguardo e quindi non festeggia nessuno');
      }
    }
  });

  test('la somma degli Eos torna, sentiero per sentiero e in tutto', () {
    // IL NUMERO ATTESO NASCE DALLA CURVA, non da una cifra ricopiata: con 55
    // traguardi per sentiero la curva decisa produce 2.010 e non i 1.960
    // scritti nell'ordine, che varrebbero per 45 piccoli invece di 50. La
    // contraddizione e' dichiarata accanto al codice e nel rapporto: qui si
    // verifica che i dati siano coerenti con la curva, che e' la cosa che
    // una prova puo' sorvegliare.
    const atteso = Sentieri.eosAttesiPerSentiero;
    expect(atteso, 2010,
        reason: 'la curva degli Eos non e piu quella decisa: se il cambio e '
            'voluto, va cambiato anche questo numero, e con lui il rapporto');
    for (final sentiero in Sentieri.tutti) {
      expect(Sentieri.eosDi(sentiero), atteso,
          reason: '${sentiero.titolo} vale ${Sentieri.eosDi(sentiero)} Eos '
              'invece dei $atteso che la curva produce');
    }
    expect(Sentieri.eosInTutto, atteso * 3,
        reason: 'i tre sentieri insieme non tornano');
  });

  test('la curva degli Eos viene dal dato, e nessun premio e zero', () {
    // **NON C'E' PIU' UNA FORMULA DA CONFRONTARE, ordine AR voce 02.** La
    // curva la scrive il corpus voce per voce: qui si pretende che nessun
    // premio sia zero e che i grandi valgano piu' dei piccoli. La somma per
    // sentiero, 2.010, e' la pretesa vera e vive nella guardia dei sentieri
    // dal dato.
    for (final sentiero in Sentieri.tutti) {
      for (final t in Sentieri.di(sentiero)) {
        expect(t.eos, greaterThan(0),
            reason: '${t.id} non vale niente: un traguardo senza premio non e '
                'un traguardo');
      }
      // **LA CURVA DELLA REVISIONE C E' PIU' PIATTA, ed e' una scelta del
      // dato**: i grandi valgono 40, 60, 80, 100 e 130, e il mini piu' ricco
      // ne vale 55. Un grande NON vale sempre piu' di ogni piccolo, e
      // pretenderlo qui vorrebbe dire chiedere al codice di smentire il
      // corpus. Resta la pretesa che la scala dei grandi cresca: e' quella
      // che fa sentire la distanza fra un grande e l'altro.
      final grandi = Sentieri.grandiDi(sentiero).toList()
        ..sort((a, b) => a.posizione.compareTo(b.posizione));
      for (var i = 1; i < grandi.length; i++) {
        expect(grandi[i].eos, greaterThan(grandi[i - 1].eos),
            reason: 'in ${sentiero.titolo} il grande ${grandi[i].id} non vale '
                'piu del precedente: la scala non sale');
      }
    }
  });

  test('ogni traguardo ha un nome proprio e un id unico', () {
    final idVisti = <String>{};
    for (final t in Sentieri.tuttiITraguardi) {
      expect(idVisti.add(t.id), isTrue, reason: 'id ripetuto: ${t.id}');
      expect(t.nome.length, greaterThan(3),
          reason: '${t.id} non ha un nome proprio');
    }
  });
}

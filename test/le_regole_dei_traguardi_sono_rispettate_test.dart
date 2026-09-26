import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/prossimi_eventi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/sigilli/eventi_del_cielo.dart';
import 'package:esoteric_circle/core/sigilli/gesti_delle_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LE UNDICI REGOLE DEL FONDATORE, VERIFICATE SU OGNI SINGOLO GRADINO.**
/// Ordine CP voci 04 e 05, 3 settembre 2026.
///
/// Le regole sono del fondatore, del 17 agosto 2026, piu' la decisione del 3
/// settembre. Le misure sono di chi scrive, e stanno per esteso in
/// `docs/regole_dei_traguardi.md`: qui c'e' il codice che le controlla.
///
/// **Perche' esiste.** Il fondatore ha collaudato la build la notte fra il 2 e
/// il 3 settembre 2026 e ha visto **otto feste in due funzionalita'**. Parole
/// sue: *"anche se funzionasse hai scelto dei traguardi che si possono fare
/// tutti in una singola sessione"*. Il corpus della revisione E aveva
/// **quarantacinque** gradini raggiungibili in una sessione sola, per
/// seicentodieci Eos. Nessuna guardia lo misurava, perche' nessuna guardava
/// il **costo in giorni**: la grandezza che questa prova ha introdotto.
///
/// **Non e' una verifica a campione.** Ogni pretesa gira su tutti e 165 e
/// stampa quanti gradini ha guardato: una prova che passa perche' non ha
/// guardato niente e' peggio di una prova che manca.
void main() {
  final tutti = Sentieri.tuttiITraguardi;

  /// I gesti che una schermata manda DAVVERO, letti dai sorgenti e non da un
  /// elenco a mano. Un elenco a mano invecchia, i sorgenti no.
  Set<String> gestiConSchermata() {
    final schema = RegExp(r"dopoUnGesto\(\s*\w+,\s*'([a-z_]+)'");
    final trovati = <String>{};
    for (final file in sorgentiDiLib()) {
      for (final m in schema.allMatches(file.readAsStringSync())) {
        trovati.add(m.group(1)!);
      }
    }
    cardinaleMinimo(trovati.length, 15,
        cosa: 'gesti che una schermata manda davvero',
        perche: 'Se lo schema smettesse di riconoscere le chiamate, questa '
            'prova direbbe che NESSUN gesto ha una schermata e sarebbe verde '
            'per la ragione sbagliata.');
    return trovati;
  }

  test('REGOLA 11, il Cammino e\' chiuso e finibile: 165, 55, 2.010, 6.030',
      () {
    expect(tutti, hasLength(165));
    for (final sentiero in Sentieri.tutti) {
      expect(Sentieri.di(sentiero), hasLength(55),
          reason: '${sentiero.titolo} non ha 55 gradini');
      expect(Sentieri.eosDi(sentiero), 2010);
    }
    expect(Sentieri.eosInTutto, 6030);
  });

  test('REGOLA 4, il costo in giorni non diminuisce mai lungo un sentiero',
      () {
    // **LA MISURA CENTRALE.** "Facili all'inizio, sempre piu' difficili e
    // rari verso la fine" diventa: il minimo numero di giorni rituali
    // distinti in cui un gradino si puo' chiudere non cala mai andando
    // avanti. Chi cammina non incontra mai un gradino piu' facile del
    // precedente.
    var guardati = 0;
    for (final sentiero in Sentieri.tutti) {
      final gradini = Sentieri.di(sentiero)
        ..sort((a, b) => a.posizione.compareTo(b.posizione));
      for (var i = 1; i < gradini.length; i++) {
        guardati++;
        final prima = gradini[i - 1].condizione.costoInGiorni;
        final dopo = gradini[i].condizione.costoInGiorni;
        expect(dopo, greaterThanOrEqualTo(prima),
            reason: '${gradini[i].id} costa $dopo giorni dopo un gradino che '
                'ne costava $prima: la scala scende, e chi cammina trova un '
                'gradino piu\' facile di quello che ha appena superato');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: coppie di gradini consecutivi guardate '
        '$guardati');
    expect(guardati, 162);
  });

  test('REGOLA 4, ogni fascia sta dentro la sua banda di giorni', () {
    // Le bande: da 1 a 8, da 9 a 30, da 31 a 90, da 91 a 190, da 191 a 365.
    // La prima arriva a otto e non a sette perche' il gradino grande della
    // prima fascia e' una finestra del cielo, e il primo quarto di Luna si
    // aspetta al peggio otto giorni: la banda segue il cielo.
    const bande = {
      'Primi giorni': [1, 8],
      'Prima settimana': [9, 30],
      'Primo mese': [31, 90],
      'La stagione': [91, 190],
      'L\'anno': [191, 365],
    };
    var guardati = 0;
    for (final t in tutti) {
      final banda = bande[t.fascia];
      expect(banda, isNotNull,
          reason: '${t.id} sta in una fascia che nessuna banda copre: '
              '"${t.fascia}"');
      final costo = t.condizione.costoInGiorni;
      guardati++;
      expect(costo, inInclusiveRange(banda![0], banda[1]),
          reason: '${t.id} costa $costo giorni e sta nella fascia '
              '"${t.fascia}", che va da ${banda[0]} a ${banda[1]}');
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: gradini dentro la loro banda $guardati');
    expect(guardati, 165);
  });

  test('REGOLE 1 e 5, un solo gradino per sentiero si chiude in una sessione',
      () {
    // **IL NUMERO CHE IL FONDATORE PUO\' CONTARE.** Un gradino che costa un
    // giorno solo e' un gradino raggiungibile nella prima sessione. Uno per
    // sentiero vuol dire **tre feste nella prima sessione**, una per Maestro,
    // e non una di piu'. Nella revisione E erano quarantacinque.
    final unaSessione = <String>[];
    for (final t in tutti) {
      if (t.condizione.costoInGiorni <= 1) unaSessione.add(t.id);
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: gradini da una sessione sola '
        '${unaSessione.length} $unaSessione, per '
        '${tutti.where((t) => t.condizione.costoInGiorni <= 1).fold<int>(0, (a, t) => a + t.eos)} Eos');
    expect(unaSessione, hasLength(3),
        reason: 'i gradini raggiungibili in una sessione sola sono '
            '${unaSessione.length}: $unaSessione. Il fondatore ne ha visti '
            'otto di fila sul telefono, ed e\' da li\' che nasce questo '
            'ordine');
    for (final sentiero in Sentieri.tutti) {
      final quanti = Sentieri.di(sentiero)
          .where((t) => t.condizione.costoInGiorni <= 1)
          .length;
      expect(quanti, 1,
          reason: '${sentiero.titolo} ha $quanti gradini da una sessione');
      expect(
          Sentieri.di(sentiero)
              .firstWhere((t) => t.condizione.costoInGiorni <= 1)
              .posizione,
          1,
          reason: '${sentiero.titolo}: il gradino da un giorno non e\' il '
              'primo, quindi la scala scenderebbe subito dopo');
    }
  });

  test('REGOLA 2, due gradini di pari costo non nominano lo stesso gesto', () {
    // **LA REGOLA DEL FONDATORE, alla lettera**: *"i traguardi si
    // riprogettano e si scelgono di nuovo facendo in modo che non possano
    // capitare contemporaneamente"*. Due gradini che costano gli stessi
    // giorni e nominano lo stesso gesto maturano sullo stesso evento: la
    // macchina ne mostrerebbe comunque uno solo, ma **il corpus avrebbe
    // disegnato la collisione**, e la macchina non e' il posto dove si
    // rimedia a un disegno.
    var coppie = 0;
    final scontri = <String>[];
    for (final sentiero in Sentieri.tutti) {
      final gradini = Sentieri.di(sentiero);
      for (var i = 0; i < gradini.length; i++) {
        for (var j = i + 1; j < gradini.length; j++) {
          if (gradini[i].condizione.costoInGiorni !=
              gradini[j].condizione.costoInGiorni) {
            continue;
          }
          coppie++;
          final comuni = gradini[i]
              .condizione
              .gestiNominati
              .intersection(gradini[j].condizione.gestiNominati);
          if (comuni.isNotEmpty) {
            scontri.add('${gradini[i].id} e ${gradini[j].id} costano '
                '${gradini[i].condizione.costoInGiorni} giorni e nominano '
                'entrambi ${comuni.join(", ")}');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: coppie di pari costo confrontate $coppie');
    expect(coppie, greaterThan(10),
        reason: 'nessuna coppia di pari costo confrontata: la prova gira a '
            'vuoto');
    expect(scontri, isEmpty, reason: scontri.join('\n'));
  });

  test('REGOLA 3, dalla seconda fascia in poi la meta\' non e\' un conteggio',
      () {
    // *"Piuttosto il traguardo diventa piu' articolato e difficile, come Hai
    // effettuato la tua prima gettata durante la Luna nuova."* La difficolta'
    // non deve crescere solo di numero: da un certo punto in poi il gradino
    // deve chiedere un fatto del cielo, un'ora vera, una costanza dentro un
    // arco o piu' arti nello stesso giorno.
    var fasceGuardate = 0;
    for (final sentiero in Sentieri.tutti) {
      final perFascia = <String, List<Traguardo>>{};
      for (final t in Sentieri.di(sentiero)) {
        perFascia.putIfAbsent(t.fascia, () => []).add(t);
      }
      for (final voce in perFascia.entries) {
        if (voce.key == 'Primi giorni') continue;
        fasceGuardate++;
        final articolati = voce.value
            .where((t) => t.condizione is! GestiCompiuti)
            .length;
        expect(articolati * 2, greaterThanOrEqualTo(voce.value.length),
            reason: '${sentiero.titolo}, fascia "${voce.key}": solo '
                '$articolati gradini su ${voce.value.length} chiedono piu\' '
                'di un conteggio');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: fasce oltre la prima guardate $fasceGuardate');
    expect(fasceGuardate, 12);
  });

  test('REGOLA 7, tre finestre del cielo per fascia e il grande e\' sempre una',
      () {
    // *"Si possono legare i traguardi a eventi astrologici rari come le
    // eclissi."* Il cielo non si affretta, ed e' il tipo di traguardo che
    // nessun'altra app puo' dare.
    var fasceGuardate = 0;
    var grandiGuardati = 0;
    for (final sentiero in Sentieri.tutti) {
      final perFascia = <String, List<Traguardo>>{};
      for (final t in Sentieri.di(sentiero)) {
        perFascia.putIfAbsent(t.fascia, () => []).add(t);
      }
      for (final voce in perFascia.entries) {
        final delCielo =
            voce.value.where((t) => t.condizione is FinestraDelCielo).length;
        if (voce.key != 'Primi giorni') {
          fasceGuardate++;
          expect(delCielo, greaterThanOrEqualTo(3),
              reason: '${sentiero.titolo}, fascia "${voce.key}": solo '
                  '$delCielo gradini legati a una finestra del cielo');
        }
        final grande = voce.value.firstWhere((t) => t.eGrande);
        grandiGuardati++;
        expect(grande.condizione, isA<FinestraDelCielo>(),
            reason: '${grande.id} chiude la fascia "${voce.key}" e non e\' '
                'una finestra del cielo: il gradino piu\' importante di una '
                'fascia deve dipendere dal cielo vero, non dalla volonta\'');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: fasce col cielo guardate $fasceGuardate, '
        'gradini grandi guardati $grandiGuardati');
    expect(fasceGuardate, 12);
    expect(grandiGuardati, 15);
  });

  test('REGOLA 6, ogni arte del sentiero si incontra nelle prime tre fasce',
      () {
    // *"La ricerca dell'obiettivo deve portare alla scoperta di nuove
    // funzionalita'."* Un'arte nominata solo al giorno trecento e' un'arte
    // che chi cammina non scoprira' mai attraverso il Cammino.
    const primeTre = {'Primi giorni', 'Prima settimana', 'Primo mese'};
    var artiGuardate = 0;
    for (final sentiero in Sentieri.tutti) {
      final tutteLeArti = <String>{};
      final presto = <String>{};
      for (final t in Sentieri.di(sentiero)) {
        tutteLeArti.addAll(t.condizione.gestiNominati);
        if (primeTre.contains(t.fascia)) {
          presto.addAll(t.condizione.gestiNominati);
        }
      }
      artiGuardate += tutteLeArti.length;
      final tardive = tutteLeArti.difference(presto).toList()..sort();
      expect(tardive, isEmpty,
          reason: '${sentiero.titolo}: queste arti compaiono solo dopo il '
              'terzo mese, quindi il Cammino non le fa scoprire: $tardive');
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: arti guardate sui tre sentieri $artiGuardate');
    expect(artiGuardate, greaterThan(15));
  });

  test('REGOLA 6, ogni gradino dichiara la porta che apre', () {
    var guardati = 0;
    for (final t in tutti) {
      guardati++;
      expect(t.cosaApre.trim().length, greaterThan(20),
          reason: '${t.id} non dice cosa apre: "${t.cosaApre}". Un traguardo '
              'che non apre niente non entra nell\'elenco');
    }
    expect(guardati, 165);
  });

  test('REGOLA 10, nessun gradino nomina un gesto che nessuna schermata manda',
      () {
    // *"Si calibra sull'MVP, una volta sola."* Un gradino che chiede un gesto
    // senza schermata non e' difficile: e' irraggiungibile, e prima si
    // chiamava dormiente. **Nella revisione F i dormienti sono zero.**
    final conSchermata = gestiConSchermata();
    final orfani = <String>[];
    var guardati = 0;
    for (final t in tutti) {
      for (final gesto in t.condizione.gestiNominati) {
        guardati++;
        if (!conSchermata.contains(gesto)) orfani.add('${t.id} chiede $gesto');
      }
      expect(t.dormiente, isFalse,
          reason: '${t.id} e\' dichiarato dormiente: la revisione F non ne '
              'ammette');
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: gesti nominati e verificati $guardati, '
        'schermate che ne mandano ${conSchermata.length}');
    expect(guardati, greaterThan(165));
    expect(orfani, isEmpty, reason: orfani.join('\n'));
  });

  test('REGOLA 10, nessun gesto inventato: il registro delle arti li conosce',
      () {
    var guardati = 0;
    final fuori = <String>[];
    for (final t in tutti) {
      for (final gesto in t.condizione.gestiNominati) {
        guardati++;
        if (GestiDelleArti.di(gesto) == null) fuori.add('${t.id}: $gesto');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: gesti confrontati col registro $guardati');
    expect(guardati, greaterThan(165));
    expect(fuori, isEmpty, reason: fuori.join('\n'));
  });

  test('REGOLA 7, nessun evento del cielo inventato', () {
    var guardati = 0;
    for (final t in tutti) {
      final c = t.condizione;
      if (c is! FinestraDelCielo) continue;
      guardati++;
      expect(EventiDelCielo.tutti, contains(c.evento),
          reason: '${t.id} nomina l\'evento "${c.evento}", che il catalogo '
              'del cielo non conosce');
      expect(attesaTipicaDelCieloConosce(c.evento), isTrue,
          reason: '${t.id} nomina "${c.evento}", per cui non e\' dichiarata '
              'nessuna attesa tipica: il suo costo in giorni sarebbe '
              'indefinito');
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: finestre del cielo guardate $guardati');
    expect(guardati, 48);
  });

  test('REGOLA 9, ogni evento nominato ha una data prevedibile in anticipo',
      () {
    // *"I promemoria partono almeno una settimana prima."* Un promemoria si
    // puo' mandare solo se l'evento ha una data futura calcolabile: qui si
    // verifica che il motore locale sappia dirla per ogni evento che i 165
    // nominano, dentro l'orizzonte di quattrocento giorni.
    //
    // **Non prova che il promemoria parta**: prova che possa partire. Chi
    // manda l'avviso e' un lavoro suo, e oggi non c'e'.
    final nominati = <String>{
      for (final t in tutti)
        if (t.condizione case final FinestraDelCielo c) c.evento,
    };
    cardinaleMinimo(nominati.length, 20,
        cosa: 'eventi del cielo nominati dai 165',
        perche: 'Se il corpus smettesse di nominare eventi, questa prova '
            'girerebbe su zero e sarebbe verde senza aver guardato niente.');
    // **CON UNA CARTA NATALE VERA**, perche' cinque degli eventi che i 165
    // nominano sono PERSONALI: i transiti sul Sole, sulla Luna e
    // sull'Ascendente, il ritorno solare e i tre transiti insieme. Senza
    // carta il motore non li calcola, e ha ragione a non calcolarli: senza
    // sapere chi sei non esistono. La prova senza carta li dava per
    // imprevedibili, ed e' stata la prima cosa che questa riga ha detto.
    const carta = NatalChart(
      sunSign: Zodiac.leo,
      hasTime: true,
      ascendantLongitude: 42.0,
      planets: [
        PlanetPosition(
            id: 'sun',
            name: 'Sole',
            glyph: '☉',
            longitude: 130.0,
            sign: Zodiac.leo),
        PlanetPosition(
            id: 'moon',
            name: 'Luna',
            glyph: '☽',
            longitude: 15.0,
            sign: Zodiac.aries),
        PlanetPosition(
            id: 'venus',
            name: 'Venere',
            glyph: '♀',
            longitude: 155.0,
            sign: Zodiac.virgo),
        PlanetPosition(
            id: 'mars',
            name: 'Marte',
            glyph: '♂',
            longitude: 210.0,
            sign: Zodiac.scorpio),
      ],
    );
    final elenco = ProssimiEventi.da(
      adesso: DateTime(2026, 9, 3),
      segno: Zodiac.leo,
      carta: carta,
    );
    final conData = elenco.map((e) => e.evento).toSet();
    final senzaData = nominati.difference(conData).toList()..sort();
    // ignore: avoid_print
    print('ORDINE CP VOCE 04: eventi nominati ${nominati.length}, con una '
        'data entro l\'orizzonte ${nominati.length - senzaData.length}');
    expect(senzaData, isEmpty,
        reason: 'questi eventi non hanno una data futura calcolabile entro '
            'quattrocento giorni, quindi nessun promemoria potra\' mai '
            'partire per loro: $senzaData');
  });

  test('FORMA, nessuna frase elide davanti a una consonante', () {
    // **DUE DIFETTI VERI, TROVATI LEGGENDO.** Il 3 settembre 2026 le frasi
    // generate dicevano "dell’tramonto", perche' una preposizione era
    // incollata senza tavola, e "L’arcano del giorno", perche' capitalize()
    // alza la prima lettera e abbassa tutto il resto. **Nessuna prova che
    // conta i gradini poteva vederli.**
    //
    // Il generatore adesso si rifiuta di scriverli, e questa riga li ferma
    // anche se un giorno qualcuno tocca i file generati a mano.
    // **E LA ACCA MUTA, che in italiano si elide come una vocale**: "il
    // cielo che l’ha attraversato" e' scritto giusto, e senza questa
    // lettera la guardia lo accusava.
    const vocali = 'aeiouàèéìòùhAEIOUH';
    var guardate = 0;
    final storte = <String>[];
    for (final t in tutti) {
      for (final testo in [t.frase, t.nome, t.cosaApre]) {
        guardate++;
        for (final pezzo in testo.split('’').skip(1)) {
          if (pezzo.isEmpty || vocali.contains(pezzo[0])) continue;
          storte.add('${t.id}: "$testo"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 05: testi guardati per elisione $guardate');
    expect(guardate, 495);
    expect(storte, isEmpty, reason: storte.join('\n'));
  });

  test('FORMA, ogni conteggio conta i GIORNI, mai le aperture', () {
    // **LA PORTA DA CUI RIENTRA LA SLOT MACHINE.** `GestiCompiuti` senza
    // `inGiorniDiversi` conta le volte da sempre, non i giorni: un gradino
    // scritto cosi' si chiuderebbe aprendo e chiudendo la stessa schermata,
    // che e' esattamente cio' che il fondatore ha visto.
    //
    // Il freno della voce CP.02 non basta a coprirlo, e va detto: quel freno
    // guarda il gesto INSIEME ai suoi dettagli, quindi quattro aperture
    // dell'Oroscopo su quattro orizzonti diversi sono quattro chiavi diverse
    // e passano. A trattenerle e' questa riga, che vieta al corpus di
    // contarle.
    var guardati = 0;
    final aperture = <String>[];
    for (final t in tutti) {
      final c = t.condizione;
      if (c is! GestiCompiuti) continue;
      guardati++;
      if (!c.inGiorniDiversi) {
        aperture.add('${t.id} conta ${c.quanti} volte il gesto ${c.gesto} '
            'senza chiedere giorni diversi');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 09: conteggi di gesti guardati $guardati');
    expect(guardati, greaterThan(50));
    expect(aperture, isEmpty, reason: aperture.join('\n'));
  });

  test('FORMA, gli id sono unici e valgono prefisso e posizione', () {
    final visti = <String>{};
    var guardati = 0;
    for (final sentiero in Sentieri.tutti) {
      final prefisso = switch (sentiero) {
        Sentiero.costellazione => 'med',
        Sentiero.loto => 'aur',
        Sentiero.albero => 'cal',
      };
      for (final t in Sentieri.di(sentiero)) {
        guardati++;
        expect(visti.add(t.id), isTrue, reason: 'id ripetuto: ${t.id}');
        expect(t.id, '${prefisso}_${t.posizione}');
      }
    }
    expect(guardati, 165);
  });

  test('FORMA, nessuna condizione si ripete identica in tutto il corpus', () {
    final firme = <String, String>{};
    var guardati = 0;
    for (final t in tutti) {
      guardati++;
      final gia = firme[t.condizione.firma];
      expect(gia, isNull,
          reason: '${t.id} ha la stessa condizione di $gia: sono lo stesso '
              'traguardo detto due volte');
      firme[t.condizione.firma] = t.id;
    }
    expect(guardati, 165);
  });

  test('FORMA, il grande di ogni fascia sta in undici, ventidue e via', () {
    var guardati = 0;
    for (final t in tutti) {
      guardati++;
      expect(t.eGrande, Traguardo.posizioniDeiGrandi.contains(t.posizione),
          reason: '${t.id} sta in posizione ${t.posizione} ed e\' '
              '${t.eGrande ? "" : "non "}grande');
    }
    expect(guardati, 165);
  });
}

/// L'attesa tipica esiste per quell'evento. Vive in `attesa_del_cielo.dart`,
/// generato dal corpus insieme ai sentieri.
bool attesaTipicaDelCieloConosce(String evento) =>
    const FinestraDelCielo('x').runtimeType == FinestraDelCielo &&
    _attesaEsiste(evento);

bool _attesaEsiste(String evento) {
  try {
    FinestraDelCielo(evento).costoInGiorni;
    return true;
  } catch (mancante) {
    return false;
  }
}

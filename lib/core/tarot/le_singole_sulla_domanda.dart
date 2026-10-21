import '../responsi/la_forma_del_responso.dart';
import 'la_carta_nella_risposta.dart';
import 'la_carta_nella_risposta_scritta.dart';
import 'la_domanda_letta.dart';
import 'le_carte_nella_posizione.dart';
import 'tarot_spread.dart';
import 'tarot_topic.dart';
import 'voce_della_stesa.dart';

/// **LE CARTE SINGOLE LETTE SULLA DOMANDA.** Ordine GA voce GA.06, terzo e
/// quarto giro, 21 ottobre 2026.
///
/// Il lettore cieco indipendente ha trovato le singole *"scritte sul tema
/// della lente e non sulla domanda"*: a chi chiedeva se investire i risparmi
/// in borsa, "Il Papa" diceva *"Cerca un mentore: scrivi oggi a una persona
/// esperta del tuo campo"*; a chi chiedeva dell'esame, nessuna delle quattro
/// singole lo nominava (*"apri casa per un te'"*, *"un vestito che ami"*).
/// Il corpus delle singole e' per gruppo dell'argomento scelto (amore, lavoro,
/// vita), non per domanda.
///
/// **Tre cure, e nessuna finge di sapere cio' che non sa.**
/// - Il gruppo viene dalla domanda quando la domanda lo dice
///   (`LaDomandaLetta.gruppoDelleSingole`): una promozione e' lavoro anche se
///   l'argomento scelto era la vita.
/// - Il "Cosa fare adesso" di una singola viene dai gesti scritti per la
///   SITUAZIONE della domanda (`gestiDellaDomanda`), gli stessi del responso
///   principale: un'azione, una cosa da non fare e la nota della carta nella
///   sua posizione. Non ripete i gesti gia' detti dal responso principale o
///   dalle altre singole.
/// - Su salute, legge e denaro nessuna previsione e nessun gesto: titolo e
///   paragrafo dicono che cosa la carta mostra in quel posto, il "Cosa fare"
///   rimanda a chi e' competente, con cinque testi per tema a rotazione sul
///   posto della carta.
///
/// PADRE: ordine GA voce GA.03 e GA.07 (le singole dal corpus per gruppo
/// dell'argomento), commit del 20 ottobre 2026.
abstract final class LeSingoleSullaDomanda {
  /// Il segno che in `usati` chiude le frasi del responso principale.
  static const segnoDelPrincipale = '#fine-del-principale#';

  static ResponsoInterpretato di(
    DrawnCard d,
    LaDomandaLetta domanda,
    TarotTopic argomento, {
    int uscita = 0,
    int posto = 0,
    int base = 0,
    Set<String>? usati,
  }) {
    final dalCorpus = LeCarteNellaPosizione.responsoDi(
        d, domanda.gruppoDelleSingole(argomento),
        uscita: uscita);
    final sensibile = domanda.sensibile;
    if (sensibile != null) {
      return _delicata(d, sensibile, dalCorpus, base + posto);
    }
    final fare = _cosaFareDellaSituazione(
        d, domanda, argomento, base + posto, usati ?? <String>{});
    return ResponsoInterpretato(
      arte: ArteInterpretata.tarocchi,
      titolo: dalCorpus.titolo,
      risposta: dalCorpus.risposta,
      cosaFare: fare ?? dalCorpus.cosaFare,
    );
  }

  static int _parole(String t) => t.trim().split(RegExp(r'\s+')).length;

  /// **IL COSA FARE DI UNA SINGOLA, dai gesti scritti per la situazione**:
  /// un'azione, una cosa da non fare e la nota della carta nella sua
  /// posizione. I gesti sono quelli del tono della carta (poi gli altri toni,
  /// se i suoi sono finiti) e non ripetono quelli gia' detti ([usati]).
  /// Nullo se nessuna composizione sta fra 40 e 50 parole: allora vale il
  /// "Cosa fare" del corpus.
  static String? _cosaFareDellaSituazione(DrawnCard d, LaDomandaLetta domanda,
      TarotTopic argomento, int salto, Set<String> usati) {
    final gruppo = domanda.gruppoDeiGesti(argomento);
    final tono = LaCartaNellaRisposta.di(d).tono;
    // **Mai i gesti sfavorevoli prima degli altri**: una singola non impone
    // un'impressione di fallimento (*"Fai un elenco onesto di ciò che
    // manca"* detto sotto un'Asso di Coppe). I gesti del tono contrario si
    // usano solo quando gli altri sono finiti.
    final ordine = tono == TonoDellaCarta.favorevole
        ? [
            TonoDellaCarta.favorevole,
            TonoDellaCarta.condizionato,
            TonoDellaCarta.sfavorevole
          ]
        : [
            TonoDellaCarta.condizionato,
            TonoDellaCarta.favorevole,
            TonoDellaCarta.sfavorevole
          ];
    List<String> raccogli(String prefisso, int quanti) {
      final fuori = <String>[];
      for (final t in ordine) {
        final p = gestiDellaDomanda['$gruppo|${t.name}'];
        if (p == null) continue;
        final giri = [
          for (var i = 1; i <= quanti; i++) p['${prefisso}_$i'],
        ].whereType<String>().toList();
        for (var k = 0; k < giri.length; k++) {
          fuori.add(giri[(k + salto) % giri.length]);
        }
      }
      return fuori;
    }

    List<String> primaINuovi(List<String> tutti) => [
          ...tutti.where((g) => !usati.contains(g)),
          ...tutti.where(usati.contains),
        ];
    final azioni = primaINuovi(raccogli('azione', 4));
    final non = primaINuovi(raccogli('non', 3));
    if (azioni.isEmpty || non.isEmpty) return null;
    final ruolo = VoceDellaStesa.ruoloDi(d.position);
    final nota = [
      'Qui ${VoceDellaStesa.laCarta(d)} ${VoceDellaStesa.notaDelRuolo(d)}.',
      'In questo posto ${VoceDellaStesa.laCarta(d)} '
          '${VoceDellaStesa.notaDelRuolo(d)}.',
    ][salto.abs() % 2];
    // Per l'adesso e l'esito esiste anche il testo lungo della carta: con lui
    // bastano un gesto e una cosa da non fare, e i gesti non si consumano.
    final dettaDalPrincipale =
        usati.any((u) => u.contains(VoceDellaStesa.rispostaDelRuolo(d)));
    final lunga = (ruolo == RuoloDellaPosizione.ora ||
                ruolo == RuoloDellaPosizione.esito) &&
            !dettaDalPrincipale
        ? 'Qui ${VoceDellaStesa.laCarta(d)} '
            '${VoceDellaStesa.rispostaDelRuolo(d)}.'
        : null;
    bool dentro(List<String> f) {
      final n = _parole(f.join(' '));
      return n >= 40 && n <= 50;
    }

    // **Vince la composizione che ripete meno gesti gia' detti** (dal
    // responso principale o dalle altre singole): una composizione tutta
    // nuova ferma subito la ricerca, altrimenti si sceglie la meno ripetuta.
    List<String>? migliore;
    var ripetuti = 1 << 20;
    final gia = {...usati};
    // Le frasi che il responso principale ha gia' detto, messe in `usati`
    // prima del [segnoDelPrincipale], pesano il triplo di quelle gia' dette
    // da un'altra singola.
    final delPrincipale = usati.takeWhile((u) => u != segnoDelPrincipale);
    final nelPrincipale = {...delPrincipale};
    cerca:
    for (final a in azioni.take(8)) {
      for (final n in non.take(6)) {
        final prove = <List<String>>[
          if (lunga != null) [a, n, lunga],
          [a, n, nota],
          for (final a2 in azioni.take(8))
            if (a2 != a) ...[
              [a, a2, n],
              [a, a2, n, nota],
              [a, a2, nota],
              for (final a3 in azioni.take(8))
                if (a3 != a && a3 != a2) [a, a2, a3],
            ],
        ];
        for (final f in prove) {
          if (!dentro(f)) continue;
          final r = f.where(gia.contains).length +
              2 * f.where(nelPrincipale.contains).length;
          if (r < ripetuti) {
            ripetuti = r;
            migliore = f;
            if (r == 0) break cerca;
          }
        }
      }
    }
    if (migliore == null) return null;
    usati.addAll(migliore.where((x) => x != nota && x != lunga));
    return migliore.join(' ');
  }

  /// **UNA SINGOLA SU SALUTE, LEGGE O DENARO**: nessuna previsione e nessun
  /// gesto. Il titolo e' il tema della carta (sulla salute il tono), il
  /// paragrafo dice che cosa la carta mostra in quel posto e che non e' un
  /// esito, e il Cosa fare rimanda a chi e' competente.
  static ResponsoInterpretato _delicata(DrawnCard d, TemaSensibile tema,
      ResponsoInterpretato dalCorpus, int variante) {
    final t = _temaSicuro(tema, d);
    final dove = VoceDellaStesa.conMaiuscola(
        VoceDellaStesa.doveSta(d.position, secondoLato: variante.isOdd));
    final registro = tema == TemaSensibile.salute
        ? null
        : LeCarteNellaPosizione.registroDi(d, TarotTopicGroup.vita);
    final aperture = [
      '$dove, la carta mostra $t: è un\'immagine su come vivi la questione, '
          'non un\'indicazione su come va a finire.',
      '$dove, la carta porta $t. Leggila come uno spunto per ordinare i '
          'pensieri, non come una previsione.',
      '$dove, la carta richiama $t, senza dire nulla sull\'esito della '
          'questione né su ciò che devi decidere.',
    ];
    final coda = [
      'Tienila come uno spunto per ascoltarti con calma, senza cercare in lei '
          'una previsione.',
      'Vale come un punto di vista su come stai, non come una risposta.',
      'Serve a fermarti un momento e a capire che cosa ti serve davvero.',
    ][variante % 3];
    // Tre aperture lunghe e una breve, con il registro, con la coda o con
    // tutti e due: la prima composizione fra 40 e 50 parole vince.
    final tutte = [
      ...aperture,
      '$dove, la carta mostra $t: non è una previsione sull\'esito.',
    ];
    final competente = switch (tema) {
      TemaSensibile.salute =>
        'Per ogni dubbio sulla salute conta il parere di un medico.',
      TemaSensibile.legge =>
        'Per le scelte concrete conta il parere di un professionista.',
      TemaSensibile.denaro =>
        'Per le scelte sui soldi conta il parere di chi è abilitato.',
    };
    String? risposta;
    for (var i = 0; i < tutte.length && risposta == null; i++) {
      final a = tutte[(variante + i) % tutte.length];
      final prove = [
        if (registro != null) '$a $registro',
        '$a $coda',
        if (registro != null) '$a $registro $coda',
        if (registro != null) '$a $registro Non è una previsione.',
        '$a $coda Leggila con calma.',
        '$a $coda $competente',
        '$a $competente',
        if (registro != null) '$a $registro $competente',
      ];
      for (final c in prove) {
        final n = _parole(c);
        if (n >= 40 && n <= 50) {
          risposta = c;
          break;
        }
      }
    }
    return ResponsoInterpretato(
      arte: ArteInterpretata.tarocchi,
      titolo: VoceDellaStesa.conMaiuscola(t),
      risposta: risposta ?? dalCorpus.risposta,
      cosaFare: cosaFareSensibile(tema, d, variante),
    );
  }

  static String _temaSicuro(TemaSensibile tema, DrawnCard d) {
    final k = LaCartaNellaRisposta.di(d);
    if (tema != TemaSensibile.salute) return k.tema;
    // **Sulla salute mai il tema della carta, solo il tono**: *"una fine che
    // libera"* accanto a un intervento sarebbe crudele. Tre forme per tono,
    // scelte dalla carta (quarto giro: "un tono sereno" in sei singole su
    // dieci).
    final i = d.card.name.codeUnits.fold<int>(0, (a, b) => a + b) % 3;
    return switch (k.tono) {
      TonoDellaCarta.favorevole => [
          'un tono sereno',
          'un clima di fiducia',
          'una nota di calma'
        ][i],
      TonoDellaCarta.condizionato => [
          'un invito alla pazienza',
          'una pausa da rispettare',
          'un tempo di attesa'
        ][i],
      TonoDellaCarta.sfavorevole => [
          'una tensione comprensibile',
          'una preoccupazione legittima',
          'un momento di fatica'
        ][i],
    };
  }

  /// Il "Cosa fare adesso" di una carta singola su salute, legge o denaro.
  static String cosaFareSensibile(TemaSensibile tema, DrawnCard d, int posto) {
    final testi = _testi[tema]!;
    final t = _temaSicuro(tema, d);
    return testi[posto % testi.length].replaceAll('{t}', t);
  }

  /// Da 38 a 45 parole senza il tema, che ne porta da due a cinque: ogni
  /// testo sta fra 40 e 50 parole con qualunque carta.
  static const Map<TemaSensibile, List<String>> _testi = {
    TemaSensibile.salute: [
      'Qui la carta mostra {t}: vedi in questo un invito a ordinare le '
          'domande da fare, non un\'indicazione sulla cura. Per ogni scelta sulla '
          'salute conta il parere di un medico: scrivi i dubbi, portali alla '
          'prossima visita e ascolta le risposte con calma.',
      'In questo posto la carta indica {t}: non dice nulla sull\'esito né su '
          'ciò che devi fare per la tua salute. Usala per notare come vivi '
          'l\'attesa e per preparare le domande da rivolgere a un medico, '
          'l\'unico a poterti consigliare.',
      'Questa carta richiama {t} e nient\'altro: nessun segno può sostituire '
          'una visita. Se qualcosa ti preoccupa parlane con un medico, annota '
          'sintomi e dubbi prima dell\'incontro e porta con te una persona di '
          'fiducia, se questo ti dà sostegno.',
      'Qui la carta porta {t} e non va letta come una previsione sulla '
          'salute. Serve a ricordarti di ascoltarti con calma. Ogni scelta su '
          'esami, cure e tempi spetta al medico: segna ciò che senti e ciò che '
          'vuoi chiedere, poi parlane apertamente alla prossima visita.',
      'In questa posizione la carta porta {t}, ma non dice nulla sul tuo '
          'stato di salute. Concediti qualche momento di quiete senza cercare '
          'risposte nelle carte. Se qualcosa ti preoccupa, prenota una visita '
          'o chiama un medico: una persona competente può ascoltarti e darti '
          'indicazioni utili.',
    ],
    TemaSensibile.legge: [
      'Qui la carta mostra {t}: riguarda il modo in cui vivi la questione, '
          'non il suo esito. Per le scelte legali conta il parere di un '
          'professionista: metti in ordine date e documenti, scrivi le domande '
          'e portale a chi può valutare il tuo caso.',
      'In questo posto la carta indica {t}, senza dire nulla su come va la '
          'vicenda. Usala per chiarirti che cosa ti preoccupa e con quale '
          'spirito la affronti; le decisioni sulle mosse da compiere spettano '
          'a chi è competente in materia.',
      'Questa carta richiama {t}: è uno spunto per ordinare i pensieri, non un '
          'consiglio giuridico. Raccogli i fatti con le date, annota ciò che '
          'vuoi chiedere e affidati a un professionista abilitato per ogni '
          'scelta che ha conseguenze reali.',
      'Qui la carta porta {t}: non dice chi ha ragione né come finisce la '
          'vicenda. Usala per capire con quale animo la vivi. Per ogni mossa '
          'concreta, dai termini alle firme, affidati a un avvocato e porta '
          'con te tutti i documenti in ordine.',
      'In questa posizione la carta mostra {t}, senza alcun valore '
          'giuridico. Non serve a prevedere un\'udienza né a scegliere una '
          'strategia. Può aiutarti a notare che cosa ti pesa davvero; poi '
          'scrivi le domande e porta tutto a un professionista abilitato.',
    ],
    TemaSensibile.denaro: [
      'Qui la carta mostra {t}: vedi in questo uno spunto sul tuo modo di '
          'guardare il denaro, non un\'indicazione su cosa fare. Per '
          'scegliere su risparmi e investimenti non bastano le carte: scrivi '
          'le domande e portale a un consulente abilitato, prima di agire.',
      'In questo posto la carta indica {t}, senza dire se una scelta '
          'economica convenga. Usala per capire con quale stato d\'animo ti '
          'avvicini alla decisione: prima di muovere qualsiasi somma chiedi sempre '
          'un parere scritto a chi è abilitato a darlo.',
      'Questa carta richiama {t}: una riflessione sul modo di affrontare la '
          'questione, non un verdetto sul denaro. Calcola con calma quanto '
          'puoi permetterti di perdere, annota i dubbi e discutili con un '
          'professionista della finanza prima di impegnarti davvero.',
      'Qui la carta porta {t}: un\'immagine sul tuo rapporto con i soldi, non '
          'un consiglio d\'acquisto. Prima di impegnare qualsiasi somma scrivi '
          'cifre, rischi e scadenze: poi falle verificare da chi è '
          'abilitato a consigliarti, prima di firmare qualunque cosa.',
      'In questa posizione la carta mostra {t}, senza dire se un investimento '
          'o una spesa convenga. Tienila come spunto di riflessione. Per '
          'decidere servono dati, costi e rischi spiegati da chi è abilitato a '
          'farlo: chiedi un parere scritto e prenditi il tempo di leggerlo.',
    ],
  };
}

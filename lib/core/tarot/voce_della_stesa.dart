import '../responsi/la_forma_del_responso.dart';
import '../responsi/scelta_senza_ripetere.dart';
import 'figure_della_stesa.dart';
import 'la_carta_nella_risposta.dart';
import 'la_carta_nella_risposta_scritta.dart';
import 'la_domanda_letta.dart';
import 'tarot_card.dart';
import 'tarot_reading.dart';
import 'tarot_spread.dart';
import 'tarot_topic.dart';
import 'tetti_della_stesa.dart';

// **LAPIDE: `NaturaDellaCarta`, ordine DF voce 04.2, 11 settembre 2026.**
// Qui vivevano quattro "nature" di una carta uscita, compimento, favore,
// prova e attrito, fatte solo dall'arcano e dal verso: un Minore dritto era
// sempre un favore. L'ordine GA voce GA.06 le ha tolte dopo il lettore cieco
// dei Tarocchi del 20 ottobre 2026: il Nove di Spade, l'angoscia della notte,
// apriva *"Con Nove di Spade le carte [...] indicano una situazione che gira a
// tuo favore"*. Il tono di una carta viene dal suo significato documentato,
// per carta e verso: `LaCartaNellaRisposta.tono`. PADRE: ordine DF voce 04.2
// (le nature), portato nella prima frase dall'ordine GA voci 03, 05 e 07,
// commit cb5fa8e3.

/// **IL FILO CON CUI SI SCEGLIE OGNI FORMA.**
/// Ordine DF voce 02, 11 settembre 2026.
///
/// **CHE COSA RISOLVE.** Il fondatore: *"voglio la sicurezza che su 100 domande
/// uguali, nemmeno una sia uguale o simile"*. Il testo vecchio era **uno
/// stampo**: cento letture davano cento volte la stessa frase con dentro nomi
/// diversi, e la persona lo riconosce alla seconda.
///
/// **IL FILO NASCE DALLE CARTE USCITE, e questa e' la scelta che decide
/// tutto.** Non dall'orologio, non dall'utente, non da un contatore: **dalle
/// carte e dai loro versi**. Cento estrazioni diverse danno cento forme
/// diverse; e resta deterministico: le stesse carte nello stesso verso danno
/// sempre lo stesso testo, la bolla non tocca l'LLM, si puo' mettere in cache
/// e le prove restano ripetibili. **La casualita' sta nel mazzo, dove deve
/// stare, e non nel testo.**
///
/// **IL MESCOLATORE E' UN VERO MESCOLATORE.** La prima stesura sceglieva con
/// `(seme ~/ passo) % lunghezza`, e coi passi grandi la misura C dell'ordine
/// e' salita a **88,1 per cento**. Adesso il seme si rimescola a ogni pescata
/// con due giri di moltiplicazione e scorrimento.
class FiloDellaVoce {
  FiloDellaVoce(this.seme);

  /// Il filo di una stesa: le carte e i loro versi, e nient'altro.
  factory FiloDellaVoce.daStesa(TarotSpread spread) {
    var h = 2166136261;
    for (final c in spread.cards) {
      final indice = TarotDeck.cards.indexWhere((x) => x.name == c.card.name);
      h = (h ^ (indice + 1)) * 16777619 & 0x7FFFFFFF;
      h = (h ^ (c.reversed ? 7919 : 104729)) * 16777619 & 0x7FFFFFFF;
    }
    return FiloDellaVoce(h);
  }

  final int seme;

  /// Quante volte si e' gia' pescato: ogni pescata rimescola il filo con un
  /// numero suo.
  int _quante = 0;

  /// Una voce dall'elenco, scelta dal filo.
  T scegli<T>(List<T> elenco) {
    if (elenco.isEmpty) throw StateError('elenco vuoto');
    _quante++;
    var x = (seme ^ (_quante * 0x9E3779B1)) & 0x7FFFFFFF;
    x = ((x ^ (x >> 15)) * 0x2C1B3C6D) & 0x7FFFFFFF;
    x = ((x ^ (x >> 13)) * 0x297A2D39) & 0x7FFFFFFF;
    x = (x ^ (x >> 16)) & 0x7FFFFFFF;
    return elenco[x % elenco.length];
  }
}

/// **I RUOLI DI UNA POSIZIONE**: che cosa vuol dire una carta in quel posto.
/// Ogni carta-verso ha un testo scritto per ognuno
/// (`la_carta_nella_risposta_scritta.dart`): una carta del passato si legge
/// al passato, una fra speranze e timori come una speranza o un timore, mai
/// come un fatto.
enum RuoloDellaPosizione {
  ora,
  passato,
  esito,
  ostacolo,
  influenza,
  ambiente,
  timori
}

/// **UN POSTO DEL PARAGRAFO**: le forme che puo' prendere, in ordine di
/// preferenza, e se e' obbligatorio.
class _Posto {
  const _Posto(this.forme,
      {this.obbligatorio = false, this.lettura, this.diRiserva = false});
  final List<String> forme;
  final bool obbligatorio;

  /// Un posto di riserva entra solo se senza di lui il paragrafo non arriva
  /// a quaranta parole: la ricerca prova prima a farne a meno.
  final bool diRiserva;

  /// Dove la frase si legge nel paragrafo, quando non e' l'ordine di
  /// preferenza.
  final int? lettura;
}

/// **LA PRIMA FRASE CHE RISPONDE**: l'apertura che dice il verdetto e, se la
/// carta della risposta va in una frase sua, la frase che la precede.
class _Verdetto {
  const _Verdetto({
    this.aperture = const [],
    this.frasi = const [],
    required this.titolo,
    this.azioneUsata,
  });

  /// Le aperture che si legano alla carta con i due punti: *"Le carte
  /// inclinano al no: nel futuro, il Due di Coppe rovesciato porta..."*.
  final List<String> aperture;

  /// Oppure le frasi intere che rispondono, e la carta segue in una frase
  /// sua: la domanda sul modo, la scelta col criterio.
  final List<String> frasi;
  final String titolo;

  /// Il gesto della domanda gia' detto nella risposta: il "Cosa fare" non lo
  /// ripete.
  final String? azioneUsata;
}

/// **LA VOCE DELLA STESA, IL RESPONSO PRINCIPALE DI CASA.** Ordine GA voci
/// GA.03, GA.05, GA.06 e GA.07; riscritta due volte dall'ordine GA voce
/// GA.06, il 21 ottobre 2026, dopo i lettori ciechi dei Tarocchi.
///
/// **IL FATTO, DUE VOLTE.** Il primo lettore cieco (`docs/collaudo/GA/
/// lettori_ciechi/esiti/esito_tre_domande_tarocchi.md`): la prima frase
/// rispondeva in otto responsi su quaranta, il "Cosa fare" era pertinente in
/// diciannove, il responso coerente in dieci. La prima cura (commit 9b2d2d29)
/// componeva la risposta a FRAMMENTI: il verdetto dalla carta chiave, le
/// altre carte cucite con formule. Il lettore cieco indipendente l'ha riletta
/// e ha dato 34, 28 e **15** su 40: *"aggiunge un gesto"* in 27 responsi,
/// *"All'esito c'e' X, cioe' Y"* in 19, *"si', perche' Re di Coppe indica che
/// serve calma emotiva"*, un si' strappato a un Due di Coppe rovesciato nel
/// futuro, L'Eremita nel passato letto al presente, gesti per una coppia che
/// vive insieme detti a chi vive a distanza.
///
/// **LA FORMA NUOVA: TESTI SCRITTI, NON FRAMMENTI.**
/// - **La domanda si legge** (`LaDomandaLetta`): forma, tema sensibile,
///   situazione, se e' vaga o doppia, se chiede un distacco o dice un timore.
/// - **La carta della risposta** e' la carta chiave della stesa
///   (`TarotReading.chiaveDi`, con la domanda): l'esito quando la domanda
///   chiede come va a finire, il cuore quando chiede il modo o che cosa c'e'.
/// - **La prima frase** dice il verdetto nella forma della domanda, col tono
///   documentato della carta, e lo motiva con il testo SCRITTO per quella
///   carta in quel ruolo: *"Le carte inclinano al no: nel futuro, il Due di
///   Coppe rovesciato porta verso un'armonia incrinata..."*.
/// - **Le altre carte** entrano col testo scritto per il loro ruolo (il
///   passato al passato, i timori come timori), prima quelle di tono
///   contrario: una carta che dice il contrario del verdetto non si tace.
/// - **Il "Cosa fare adesso"** porta i gesti scritti per la situazione della
///   domanda e per il tono del verdetto (`gestiDellaDomanda`), il gesto
///   scritto della carta della risposta e una cosa da non fare.
///
/// **LA MISURA.** Ogni paragrafo sta fra 40 e 50 parole
/// (`LaFormaDelResponso`); i posti si scelgono in ordine di preferenza fra
/// quelli che stanno nella misura, e nessun testo si tronca (GA.07). Nessuna
/// figura ripetuta fra due pezzi (ordine DS voce 09, `SceltaSenzaRipetere`).
abstract final class VoceDellaStesa {
  // **LAPIDI della prima cura dell'ordine GA voce GA.06 (commit 9b2d2d29)**:
  // `_verdetto` con `dice` e `via` cuciti nella prima frase (*"Si', la
  // tendenza e' favorevole: X dice che..."*), `_conLaTerzaForma`, `_altra`
  // (*"All'esito c'e' X, cioe' Y: e' li' che la cosa puo' arrivare"*, *"Lo
  // conferma X al centro, con..."*), il posto *"Al centro c'e' {tema}: e'
  // questo che decide la risposta"* e il gesto *"X aggiunge un gesto:
  // {via}"*. Le hanno bocciate il lettore cieco indipendente e il fondatore
  // (*"tutto deve essere perfetto"*).

  /// **UNA FORMA CHE VALE PER QUALUNQUE STESA.** Ordine FK aggiunta 2 voce
  /// A8: non nomina il numero tre ne' le posizioni del passato, del presente
  /// e del futuro (i segnaposto fra graffe non contano).
  static bool valeOvunque(String forma) => !RegExp(
          r'(?<![A-Za-zÀ-ÿ])(tre|passato|presente|futuro|spalle)(?![A-Za-zÀ-ÿ])',
          caseSensitive: false)
      .hasMatch(forma.replaceAll(RegExp(r'\{\w+\}'), ''));

  /// **LE OTTO APERTURE DI UNA POSIZIONE.** Ordine DF voce 02, misura C.
  static const List<String> apertureDellaPosizione = [
    'In questa posizione',
    'Qui la carta dice che',
    'Su questo punto',
    'Quello che si legge qui è che',
    'La carta in questa casella racconta che',
    'A questo posto della stesa',
    'Qui',
    'In questo tratto della lettura',
  ];

  /// **LA RIGA DEL CIELO VERO**, in un punto solo. Dall'ordine GA va nel "Da
  /// dove viene", e la mette `TarotReading`.
  static String rigaDelCielo(String cielo) =>
      'Accanto a queste tre carte c\'è il cielo di oggi. $cielo';

  /// L'apertura della posizione [quale], contata da zero, per questa stesa.
  static String aperturaDellaPosizione(TarotSpread spread, int quale) {
    final filo = FiloDellaVoce(FiloDellaVoce.daStesa(spread).seme + quale * 97);
    return filo.scegli(apertureDellaPosizione);
  }

  // --- LE FRASI DI SERVIZIO ---

  /// **LE PAROLE DEI TEMI SENSIBILI**: la prima frase, che dice che le carte
  /// non decidono e chi decide (ordine S voce 17).
  static const Map<TemaSensibile, String> avvisiSensibili = {
    TemaSensibile.salute: 'Le carte non dicono come va un intervento o una '
        'cura: decide un medico.',
    TemaSensibile.legge:
        'Le carte non dicono come finisce una causa: decide un avvocato.',
    TemaSensibile.denaro: 'Le carte non dicono se una spesa o un investimento '
        'conviene: chiedi a un consulente abilitato.',
  };

  /// I titoli dei temi sensibili.
  static const Map<TemaSensibile, String> titoliSensibili = {
    TemaSensibile.salute: 'Qui decide il medico, non le carte',
    TemaSensibile.legge: 'Qui decide un avvocato, non le carte',
    TemaSensibile.denaro: 'Qui serve un consulente, non le carte',
  };

  /// **IL LIMITE DETTO IN BREVE**, in coda alla risposta su un tema
  /// sensibile.
  static const String avvisoBreveSensibile =
      'Nessuna carta sostituisce quel parere.';

  /// **E CHE COSA LE CARTE POSSONO DIRE**, su un tema sensibile.
  static const String soloIlModo =
      'Le carte possono aiutarti a mettere in ordine le domande da fare.';

  /// **LA DOMANDA DOPPIA**: lo si dice prima del verdetto, con la prima
  /// domanda scritta per intero. Il lettore cieco indipendente: *"mai detto
  /// quale sia la prima"* (tarocchi-3, 34, 38).
  static String avvisoDoppia(String? primaParte) => primaParte == null
      ? avvisoDoppiaSenzaTesto
      : 'Le carte rispondono alla prima domanda, «$primaParte».';

  static const String avvisoDoppiaSenzaTesto = 'Le carte rispondono alla prima '
      'domanda, la seconda chiede una stesa sua.';

  /// **E NEL "COSA FARE"**, per la domanda doppia e per la vaga.
  static const String gestoDoppia =
      'Per l\'altra domanda fai una stesa a parte, con quella sola.';
  static const String gestoVaga = 'Per una risposta precisa, rifai la domanda '
      'nominando la cosa che ti sta a cuore.';

  /// **LE FRASI DI SERVIZIO**, uguali per scelta: la guardia della frase
  /// fissa le conta a parte, perche' devono essere sempre le stesse.
  static List<String> get frasiDiServizio => [
        ...avvisiSensibili.values,
        avvisoBreveSensibile,
        soloIlModo,
        avvisoDoppiaSenzaTesto,
        gestoDoppia,
        gestoVaga,
      ];

  // --- LE CARTE NELLA FRASE ---

  /// **IL RUOLO DI UNA POSIZIONE.**
  static RuoloDellaPosizione ruoloDi(SpreadPosition p) => switch (p) {
        SpreadPosition.presente ||
        SpreadPosition.cartaSola ||
        SpreadPosition.consultante ||
        SpreadPosition.copre ||
        SpreadPosition.seStesso =>
          RuoloDellaPosizione.ora,
        SpreadPosition.passato ||
        SpreadPosition.dietro ||
        SpreadPosition.sotto =>
          RuoloDellaPosizione.passato,
        SpreadPosition.futuro ||
        SpreadPosition.esito ||
        SpreadPosition.corona =>
          RuoloDellaPosizione.esito,
        SpreadPosition.attraversa => RuoloDellaPosizione.ostacolo,
        SpreadPosition.lato => RuoloDellaPosizione.influenza,
        SpreadPosition.laCasa => RuoloDellaPosizione.ambiente,
        SpreadPosition.speranzeOTimori => RuoloDellaPosizione.timori,
      };

  /// **DOVE STA UNA CARTA**, detto dentro una frase, in minuscolo. I due
  /// lati della croce si distinguono: [secondoLato] e' il secondo
  /// (il lettore cieco: *"due posizioni si chiamano entrambe Il lato"*).
  static String doveSta(SpreadPosition p, {bool secondoLato = false}) =>
      switch (p) {
        SpreadPosition.passato => 'nel passato',
        SpreadPosition.presente => 'nel presente',
        SpreadPosition.futuro => 'nel futuro',
        SpreadPosition.cartaSola => 'nella sola carta uscita',
        SpreadPosition.consultante => 'su di te',
        SpreadPosition.lato => secondoLato ? 'dall\'altro lato' : 'da un lato',
        SpreadPosition.esito => 'all\'esito',
        SpreadPosition.copre => 'al centro',
        SpreadPosition.attraversa => 'di traverso',
        SpreadPosition.corona => 'in cima',
        SpreadPosition.sotto => 'alla base',
        SpreadPosition.dietro => 'alle spalle',
        SpreadPosition.seStesso => 'su di te',
        SpreadPosition.laCasa => 'intorno a te',
        SpreadPosition.speranzeOTimori => 'fra speranze e timori',
      };

  static String _doveDi(TarotSpread spread, DrawnCard c) {
    var secondo = false;
    if (c.position == SpreadPosition.lato) {
      for (final x in spread.cards) {
        if (identical(x, c)) break;
        if (x.position == SpreadPosition.lato) secondo = true;
      }
    }
    return doveSta(c.position, secondoLato: secondo);
  }

  static String _maiuscola(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// **IL NOME DELLA CARTA DENTRO UNA FRASE**, con l'articolo: *"il Due di
  /// Coppe rovesciato"*, *"l'Asso di Spade"*, *"la Torre"*, *"gli Amanti"*.
  /// I Maggiori hanno l'articolo nel nome, che dentro la frase va in
  /// minuscolo; i Minori lo prendono dal grado.
  static String nomeNellaFrase(DrawnCard c) {
    final n = c.displayName;
    if (c.card.arcana == TarotArcana.maggiore) {
      final m = RegExp(r"^(Il|La|Lo|Gli|I|Le|L')(\s?)").firstMatch(n);
      if (m == null) return n;
      return '${m.group(1)!.toLowerCase()}${m.group(2)}${n.substring(m.end)}';
    }
    if (n.startsWith('Asso') || n.startsWith('Otto')) return 'l\'$n';
    if (n.startsWith('Regina')) return 'la $n';
    return 'il $n';
  }

  static Map<String, String> _testi(DrawnCard c) =>
      testiDelleCarte[LaCartaNellaRisposta.chiaveDi(c)]!;

  /// **IL TESTO DELLA CARTA CHE RISPONDE**, per il suo ruolo: al centro o
  /// sola, cio' che sta succedendo; in fondo, dove la cosa va a finire.
  static String _risposta(DrawnCard c) =>
      ruoloDi(c.position) == RuoloDellaPosizione.esito
          ? _testi(c)['risposta_esito']!
          : _testi(c)['risposta_ora']!;

  static String _nota(DrawnCard c) =>
      _testi(c)['nota_${ruoloDi(c.position).name}']!;

  /// **IL GESTO SCRITTO DELLA CARTA**, una frase intera che vale per
  /// qualunque domanda.
  static String gestoDellaCarta(DrawnCard c) => _testi(c)['gesto']!;

  // --- IL VERDETTO ---

  static String _tema(DrawnCard c) => LaCartaNellaRisposta.di(c).tema;

  /// **LE APERTURE DI UNA RISPOSTA SENZA VERDETTO.** Terzo giro dell'ordine GA
  /// voce GA.06: a *"Lui mi ama ancora?"* o a *"Arrivera' presto la
  /// risposta?"* *"La risposta non e' un si' o un no"* risponde, ma non dice di
  /// che cosa le carte non parlano. Quando la domanda ha una situazione
  /// riconosciuta, l'apertura la nomina; altrimenti restano le generiche.
  static List<String> _apertureSenzaVerdetto(LaDomandaLetta d) {
    final specifiche = switch (d.situazione) {
      Situazione.sentimenti => [
          'Cosa prova l\'altra persona le carte non lo dicono',
          'I sentimenti altrui le carte non li pronunciano',
        ],
      Situazione.ritorno => [
          'Un ritorno le carte non lo promettono',
          'Se ci sia un ritorno le carte non lo dicono',
        ],
      Situazione.fiducia => [
          'Se puoi fidarti le carte non lo dicono',
          'Sulla fiducia le carte non danno un verdetto',
        ],
      Situazione.incontro => [
          'Un incontro le carte non lo annunciano',
          'Su un incontro le carte non si pronunciano',
        ],
      Situazione.attesa => [
          'I tempi della risposta le carte non li indicano',
          'Sui tempi della risposta le carte non si pronunciano',
        ],
      Situazione.esame => [
          'L\'esito dell\'esame le carte non lo dicono',
          'Sull\'esame le carte non danno un verdetto',
        ],
      Situazione.colloquio => [
          'L\'esito del colloquio le carte non lo dicono',
          'Sul colloquio le carte non danno un verdetto',
        ],
      Situazione.promozione => [
          'Sulla promozione le carte non danno un verdetto',
          'Un sì alla promozione le carte non lo pronunciano',
        ],
      Situazione.offerta => [
          'Se accettare le carte non lo decidono',
          'Sull\'offerta le carte non danno un verdetto',
        ],
      Situazione.progetto => [
          'L\'approvazione del progetto le carte non la decidono',
          'Sul progetto le carte non danno un verdetto',
        ],
      _ => const <String>[],
    };
    if (specifiche.isNotEmpty) return specifiche;
    return const [
      'Un sì o un no netto le carte non lo danno',
      'Su questo le carte non danno un sì o un no',
      'La risposta non è un sì o un no',
      'Le carte non decidono al posto tuo',
      'Una risposta secca le carte non la danno',
      'Un verdetto le carte non lo pronunciano',
    ];
  }

  /// **IL VERDETTO** per la forma della domanda [d] e il tono della carta
  /// della risposta [carta]. [azioni] sono i gesti scritti della domanda per
  /// quel tono: a una domanda sul modo risponde il primo.
  static _Verdetto _verdetto(LaDomandaLetta d, DrawnCard carta,
      TarotTopic argomento, List<String> azioni,
      {required bool diretto}) {
    final k = LaCartaNellaRisposta.di(carta);
    final tono = k.tono;
    final tema = k.tema;

    if (d.vaga) {
      return _Verdetto(
        aperture: [
          switch (tono) {
            TonoDellaCarta.favorevole => 'La domanda è ampia, quindi le carte '
                'parlano del periodo, che si presenta favorevole',
            TonoDellaCarta.condizionato => 'La domanda è ampia, quindi le '
                'carte parlano del periodo, che resta aperto',
            TonoDellaCarta.sfavorevole => 'La domanda è ampia, quindi le '
                'carte parlano del periodo, che si presenta impegnativo',
          },
        ],
        titolo: 'Il periodo porta $tema',
      );
    }

    // La scelta fra muoversi e restare risponde con una delle due, anche
    // quando muoversi e' un distacco: *"Mi trasferisco a Milano o resto a
    // Bari?"* aveva *"Non ancora"*, che non sceglie (tarocchi-10).
    final restare = d.sceltaFraMuoversiERestare;
    if (d.forma == FormaDellaDomanda.scelta && restare != null) {
      final aspettare = restare == 'aspettare';
      return switch (tono) {
        TonoDellaCarta.favorevole => _Verdetto(
            aperture: [
              aspettare
                  ? 'Le carte inclinano a muoverti adesso'
                  : 'Le carte inclinano a muoverti',
            ],
            titolo: 'Muoviti, conta $tema',
          ),
        TonoDellaCarta.condizionato => _Verdetto(
            aperture: ['Le carte inclinano a muoverti, ma non subito'],
            titolo: 'Muoviti, ma guarda $tema',
          ),
        TonoDellaCarta.sfavorevole => _Verdetto(
            aperture: [
              aspettare
                  ? 'Le carte inclinano ad aspettare, per ora'
                  : 'Le carte inclinano a restare, per ora',
            ],
            titolo: aspettare ? 'Aspetta, pesa $tema' : 'Resta, pesa $tema',
          ),
      };
    }

    final distacco = d.distacco &&
        (d.forma == FormaDellaDomanda.siNo ||
            d.forma == FormaDellaDomanda.scelta);
    if (distacco) {
      if (k.distacco || (tono == TonoDellaCarta.favorevole && !k.legame)) {
        return _Verdetto(
          aperture: [
            'Sì, le carte sostengono questa scelta',
            'Le carte inclinano a farlo',
          ],
          titolo: 'Sì, conta $tema',
        );
      }
      return switch (tono) {
        TonoDellaCarta.favorevole => _Verdetto(
            aperture: [
              'Per ora no, il legame ha ancora valore',
              'Le carte inclinano a non farlo, per ora',
            ],
            titolo: 'Ora no, conta $tema',
          ),
        TonoDellaCarta.condizionato => _Verdetto(
            aperture: [
              'Non ancora, prima va chiarita una condizione',
              'Non subito, a una condizione',
            ],
            titolo: 'Non ancora, pesa $tema',
          ),
        TonoDellaCarta.sfavorevole => _Verdetto(
            aperture: [
              'Meglio non decidere adesso',
              'Le carte consigliano di non decidere adesso',
            ],
            titolo: 'Non adesso, pesa $tema',
          ),
      };
    }

    switch (d.forma) {
      case FormaDellaDomanda.nessuna:
        return _Verdetto(
          aperture: [
            '${argomento.lente}, le carte vedono ${switch (tono) {
              TonoDellaCarta.favorevole => 'un momento favorevole',
              TonoDellaCarta.condizionato => 'una situazione ancora aperta',
              TonoDellaCarta.sfavorevole => 'una fase difficile',
            }}',
          ],
          titolo: 'Le carte vedono $tema',
        );
      case FormaDellaDomanda.siNo when d.timore && !diretto:
        return _Verdetto(
          aperture: [
            'Le carte non confermano e non smentiscono questo timore',
            'Su questo timore le carte non danno né conferma né smentita',
            'Il timore resta aperto: le carte non lo decidono',
            'Le carte non dicono se il timore è fondato',
          ],
          titolo: switch (tono) {
            TonoDellaCarta.favorevole => 'Nessuna conferma, conta $tema',
            _ => 'Nessuna conferma, pesa $tema',
          },
        );
      case FormaDellaDomanda.siNo when d.timore:
        // A una domanda di timore il si' e' la cosa temuta: una carta che
        // apre risponde no, e una che chiude non trasforma il timore in un
        // fatto, dice che c'e' qualcosa da chiarire.
        return switch (tono) {
          TonoDellaCarta.favorevole => _Verdetto(
              aperture: [
                'No, le carte non confermano questo timore',
                'Il timore non trova conferma nelle carte',
              ],
              titolo: 'No, conta $tema',
            ),
          TonoDellaCarta.condizionato => _Verdetto(
              aperture: [
                'Non è detto, ma c\'è qualcosa da chiarire',
                'Le carte non lo confermano, ma qualcosa va chiarito',
              ],
              titolo: 'Da chiarire, pesa $tema',
            ),
          TonoDellaCarta.sfavorevole => _Verdetto(
              aperture: [
                'Le carte non danno certezze, ma segnalano un disagio reale',
                'Non come certezza, ma il disagio è reale',
              ],
              titolo: 'Da chiarire, pesa $tema',
            ),
        };
      case FormaDellaDomanda.siNo when !diretto:
        // **NIENTE SI' E NIENTE NO DA UNA CARTA CHE NON LO DICE.** Si dice che
        // cosa le carte mostrano.
        return _Verdetto(
          aperture: _apertureSenzaVerdetto(d),
          titolo: switch (tono) {
            TonoDellaCarta.favorevole => 'Senza verdetto, conta $tema',
            _ => 'Senza verdetto, pesa $tema',
          },
        );
      case FormaDellaDomanda.siNo:
        return switch (tono) {
          TonoDellaCarta.favorevole => _Verdetto(
              aperture: [
                'Le carte inclinano al sì',
                'Sì, le carte sono favorevoli',
                'Le carte propendono per il sì',
                'Il sì è la direzione delle carte',
                'Le carte vanno verso il sì',
                'Tutto fa pensare al sì',
              ],
              titolo: 'Sì, conta $tema',
            ),
          TonoDellaCarta.condizionato => _Verdetto(
              aperture: [
                'Sì, a una condizione',
                'Può andare, a una condizione',
                'Sì, ma con una riserva',
                'Possibile, se una cosa cambia',
                'Sì, a patto di una cosa',
                'Dipende da una condizione',
              ],
              titolo: 'Sì, ma pesa $tema',
            ),
          TonoDellaCarta.sfavorevole => _Verdetto(
              aperture: [
                'Le carte inclinano al no',
                'Le carte propendono per il no',
                'Il no è la direzione delle carte',
                'Le carte vanno verso il no',
                'Per ora non è il momento',
                'Così com\'è adesso, no',
              ],
              titolo: 'Ora no, pesa $tema',
            ),
        };
      case FormaDellaDomanda.come:
        // A una domanda sul modo risponde un gesto scritto per quella
        // domanda e per il tono della carta; la carta lo motiva subito dopo.
        // Il gesto che apre la risposta non e' condizionale (*"Prima serve
        // questo: se serve, informati..."* era una frase che non diceva
        // niente).
        final azione = azioni.firstWhere(
            (a) => !a.startsWith('Se ') && !a.toLowerCase().contains(' se '),
            orElse: () => azioni.first);
        final minuscola = azione[0].toLowerCase() + azione.substring(1);
        return _Verdetto(
          frasi: [
            switch (tono) {
              TonoDellaCarta.favorevole => 'Il modo è questo: $minuscola',
              TonoDellaCarta.condizionato =>
                'Il modo c\'è, se prima prepari il terreno: $minuscola',
              TonoDellaCarta.sfavorevole =>
                'Prima di tutto serve questo: $minuscola',
            },
            // La forma breve, quando la carta contraria o la doppia tolgono
            // spazio.
            switch (tono) {
              TonoDellaCarta.favorevole => 'Il modo è questo: $minuscola',
              TonoDellaCarta.condizionato => 'Prima serve questo: $minuscola',
              TonoDellaCarta.sfavorevole => 'Prima serve questo: $minuscola',
            },
          ],
          titolo: switch (tono) {
            TonoDellaCarta.favorevole => 'Punta su $tema',
            TonoDellaCarta.condizionato => 'Tieni conto di $tema',
            TonoDellaCarta.sfavorevole => 'Prima affronta $tema',
          },
          azioneUsata: azione,
        );
      case FormaDellaDomanda.quando when !diretto:
        return _Verdetto(
          aperture: [
            'Sui tempi le carte non si pronunciano',
            'Un momento preciso le carte non lo danno',
            'Le carte non dicono quando',
            'Quanto manchi le carte non lo dicono',
          ],
          titolo: switch (tono) {
            TonoDellaCarta.favorevole => 'Nessun tempo, conta $tema',
            _ => 'Nessun tempo, pesa $tema',
          },
        );
      case FormaDellaDomanda.quando:
        return switch (tono) {
          TonoDellaCarta.favorevole => _Verdetto(
              aperture: ['Non manca molto', 'In tempi brevi, se nulla cambia'],
              titolo: 'A breve, conta $tema',
            ),
          TonoDellaCarta.condizionato => _Verdetto(
              aperture: ['Non subito, prima serve una condizione'],
              titolo: 'Non subito, pesa $tema',
            ),
          TonoDellaCarta.sfavorevole => _Verdetto(
              aperture: ['Non a breve', 'Non in tempi brevi'],
              titolo: 'Non presto, pesa $tema',
            ),
        };
      case FormaDellaDomanda.cosa
          when !diretto &&
              (d.situazione == Situazione.sentimenti ||
                  (d.situazione == null && d.lente == TarotTopic.cosaProva)):
        // **I SENTIMENTI DI UN'ALTRA PERSONA NON SI LEGGONO DA UNA CARTA CHE
        // NON LI DICE**: *"Le carte vedono un sentimento vero, ma ancora
        // trattenuto"* a chi chiedeva cosa prova Marco (terzo giro).
        return _Verdetto(
          aperture: [
            'Cosa prova l\'altra persona le carte non lo dicono',
            'I sentimenti altrui le carte non li pronunciano',
          ],
          titolo: switch (tono) {
            TonoDellaCarta.favorevole => 'Senza verdetto, conta $tema',
            _ => 'Senza verdetto, pesa $tema',
          },
        );
      case FormaDellaDomanda.cosa:
        final sentimenti = d.situazione == Situazione.sentimenti ||
            (d.situazione == null && d.lente == TarotTopic.cosaProva);
        return _Verdetto(
          aperture: [
            sentimenti
                ? switch (tono) {
                    TonoDellaCarta.favorevole =>
                      'Le carte vedono un sentimento sincero',
                    TonoDellaCarta.condizionato =>
                      'Le carte vedono un sentimento vero, ma ancora trattenuto',
                    TonoDellaCarta.sfavorevole =>
                      'Le carte vedono più distanza che slancio',
                  }
                : switch (tono) {
                    TonoDellaCarta.favorevole =>
                      'Le carte vedono un momento favorevole',
                    TonoDellaCarta.condizionato =>
                      'Le carte vedono una situazione ancora aperta',
                    TonoDellaCarta.sfavorevole =>
                      'Le carte vedono una difficoltà da affrontare',
                  },
          ],
          titolo: 'Le carte vedono $tema',
        );
      case FormaDellaDomanda.scelta:
        // Il criterio viene dal tono della carta della risposta: l'opzione
        // in cui c'e' cio' che la carta apre, o quella in cui non pesa cio'
        // che la carta chiude.
        final criterio = switch (tono) {
          TonoDellaCarta.favorevole => 'scegli l\'opzione in cui trovi $tema',
          TonoDellaCarta.condizionato =>
            'scegli l\'opzione che ti lascia il tempo di capire',
          TonoDellaCarta.sfavorevole => 'scarta l\'opzione in cui pesa $tema',
        };
        return _Verdetto(
          frasi: [
            'Le carte non scelgono al posto tuo, ma danno un criterio: '
                '$criterio.',
            'Il criterio è questo: $criterio.',
          ],
          titolo: 'Scegli guardando $tema',
        );
    }
  }

  // --- LA COMPOSIZIONE ---

  /// **SCEGLIE I POSTI DI UN PARAGRAFO** perche' stia fra 40 e 50 parole:
  /// in ordine, gli obbligatori sempre e gli altri quando ci stanno, con la
  /// prima forma libera da figure gia' dette (`SceltaSenzaRipetere`). La
  /// prima composizione nella misura vince.
  static List<String> _scegli(List<_Posto> posti, Set<String> usate,
      {List<_Posto>? alternativa}) {
    List<(int, String)>? trovata;
    List<(int, String)>? vicina;
    var paroleVicina = -1;
    var postiInUso = posti;
    // **IL TETTO IN CARATTERI HA UN MARGINE**: un paragrafo non supera il
    // novanta per cento del tetto (`TettiDellaStesa.consiglio`), cosi' il
    // tetto non sta mai al filo (prova `il tetto di un paragrafo tiene il
    // caso peggiore con margine`). Cinquanta parole lunghe, con la doppia,
    // arrivavano a 351 caratteri su 380.
    const massimoCaratteri = (TettiDellaStesa.consiglio * 9) ~/ 10;
    var caratteri = 0;
    void cerca(int i, List<(int, String)> fin, int parole, Set<String> viste) {
      if (trovata != null ||
          parole > LaFormaDelResponso.massimo ||
          caratteri > massimoCaratteri) {
        return;
      }
      if (i == postiInUso.length) {
        if (parole >= LaFormaDelResponso.minimo) {
          trovata = List.of(fin);
        } else if (parole > paroleVicina) {
          paroleVicina = parole;
          vicina = List.of(fin);
        }
        return;
      }
      final p = postiInUso[i];
      final libere = <String>[];
      final restanti = List.of(p.forme);
      while (restanti.isNotEmpty) {
        final f = SceltaSenzaRipetere.primoLibero(
            restanti, FigureDellaStesa.di, viste);
        if (f == null) break;
        libere.add(f);
        restanti.remove(f);
      }
      // Un posto obbligatorio senza forme libere tiene comunque la sua prima
      // forma: togliere un obbligatorio toglierebbe la risposta.
      final forme = libere.isEmpty && p.obbligatorio ? [p.forme.first] : libere;
      if (p.diRiserva) cerca(i + 1, fin, parole, viste);
      if (trovata != null) return;
      for (final f in forme) {
        caratteri += f.length + 1;
        cerca(
            i + 1,
            [...fin, (p.lettura ?? i * 10, f)],
            parole + LaFormaDelResponso.parole(f),
            {...viste, ...FigureDellaStesa.di(f)});
        caratteri -= f.length + 1;
        if (trovata != null) return;
      }
      if (!p.obbligatorio && !p.diRiserva) cerca(i + 1, fin, parole, viste);
    }

    cerca(0, const [], 0, usate);
    if (trovata == null && alternativa != null) {
      postiInUso = alternativa;
      cerca(0, const [], 0, usate);
    }
    // Nessuna composizione nella misura: la guardia della misura lo dice.
    // Si consegna la composizione piu' vicina, mai un testo tagliato, e se
    // nemmeno quella esiste gli obbligatori.
    final scelta = trovata ?? vicina;
    final scelte = scelta == null
        ? [
            for (final p in postiInUso)
              if (p.obbligatorio) p.forme.first
          ]
        : [for (final e in scelta..sort((a, b) => a.$1.compareTo(b.$1))) e.$2];
    for (final f in scelte) {
      usate.addAll(FigureDellaStesa.di(f));
    }
    return scelte;
  }

  /// Se [b] ripete una parola portante (sei lettere o piu') di [a].
  static bool _ripete(String a, String b) {
    const comuni = {
      'questione',
      'domanda',
      'momento',
      'quindi',
      'perché',
      'anche',
      'invece',
      'ancora',
      'insieme',
      'sempre',
      'dentro',
      'verso',
      'ciascuno'
    };
    Set<String> parole(String t) => {
          for (final m
              in RegExp(r'[a-zàèéìòù]{6,}').allMatches(t.toLowerCase()))
            if (!comuni.contains(m[0])) m[0]!
        };
    final pa = parole(a);
    return parole(b).any(pa.contains);
  }

  /// **LE ALTRE CARTE, in ordine di peso**: prima quelle di tono contrario
  /// al verdetto (non si tacciono), poi il cuore o l'esito, poi le altre
  /// nell'ordine di lettura.
  static List<DrawnCard> _altre(TarotSpread spread, DrawnCard carta) {
    final tono = LaCartaNellaRisposta.di(carta).tono;
    bool contraria(DrawnCard c) {
      final t = LaCartaNellaRisposta.di(c).tono;
      return (tono == TonoDellaCarta.favorevole &&
              t == TonoDellaCarta.sfavorevole) ||
          (tono == TonoDellaCarta.sfavorevole &&
              t == TonoDellaCarta.favorevole);
    }

    final ordine = <DrawnCard>[];
    void metti(DrawnCard? c) {
      if (c == null || identical(c, carta)) return;
      if (ordine.any((x) => identical(x, c))) return;
      ordine.add(c);
    }

    for (final c in [spread.cuore, spread.approdo, ...spread.cards]) {
      if (c != null && contraria(c)) metti(c);
    }
    metti(spread.cuore);
    metti(spread.approdo);
    for (final c in spread.cards) {
      metti(c);
    }
    return ordine;
  }

  /// **I DUE PARAGRAFI DEL RESPONSO PRINCIPALE DI CASA**, la risposta e il
  /// "Cosa fare adesso".
  static List<String> paragrafi(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
    DrawnCard? chiave,
  }) {
    final c = _componi(spread, topic,
        domandaScritta: domandaScritta,
        fattoDelCielo: fattoDelCielo,
        chiave: chiave);
    return [c.risposta, c.cosaFare];
  }

  /// **IL TITOLO DELLA LETTURA DI CASA**, che e' gia' la risposta.
  static String titoloDellaLettura(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
    DrawnCard? chiave,
  }) =>
      _componi(spread, topic,
              domandaScritta: domandaScritta,
              fattoDelCielo: fattoDelCielo,
              chiave: chiave)
          .titolo;

  /// **IL RESPONSO PRINCIPALE DI CASA**: il titolo, la risposta e il "Cosa
  /// fare adesso", ogni paragrafo da 40 a 50 parole. [chiave] e' la carta
  /// della risposta; nulla, la sceglie `TarotReading.chiaveDi` con la
  /// domanda.
  static ({String titolo, String risposta, String cosaFare}) responsoDiCasa(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
    DrawnCard? chiave,
  }) {
    final c = _componi(spread, topic,
        domandaScritta: domandaScritta,
        fattoDelCielo: fattoDelCielo,
        chiave: chiave);
    return (titolo: c.titolo, risposta: c.risposta, cosaFare: c.cosaFare);
  }

  /// **I PEZZI DEL RESPONSO, uno per frase.** Ordine DS voce 09: la guardia
  /// delle figure li conta pezzo per pezzo. Il fatto del cielo e' un pezzo
  /// anche lui, e sta per primo.
  static List<String> pezzi(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
    DrawnCard? chiave,
  }) =>
      _componi(spread, topic,
              domandaScritta: domandaScritta,
              fattoDelCielo: fattoDelCielo,
              chiave: chiave)
          .pezzi;

  /// **LA FRASE DEL TEMA SENSIBILE SULLE CARTE**: sulla salute solo il tono,
  /// mai il tema (*"una fine che libera"* accanto a un intervento sarebbe
  /// crudele) e mai un gesto (il lettore cieco ha letto *"trova il pezzo che
  /// manca e completalo"* come un'indicazione sulla cura, tarocchi-16);
  /// sulla legge e sul denaro il tema, detto come modo e non come esito.
  static String _fraseSensibile(
      TemaSensibile t, TarotSpread spread, DrawnCard carta) {
    final nome = nomeNellaFrase(carta);
    final dove = _doveDi(spread, carta);
    final tono = LaCartaNellaRisposta.di(carta).tono;
    if (t == TemaSensibile.salute) {
      return switch (tono) {
        TonoDellaCarta.favorevole => '${_maiuscola(dove)}, $nome ha un tono '
            'sereno: invita a vivere l\'attesa con fiducia, senza dire nulla '
            'sull\'esito.',
        TonoDellaCarta.condizionato => '${_maiuscola(dove)}, $nome chiede '
            'pazienza e ordine nel modo di vivere l\'attesa, senza dire nulla '
            'sull\'esito.',
        TonoDellaCarta.sfavorevole => '${_maiuscola(dove)}, $nome segnala '
            'una tensione comprensibile: parlarne con chi ti segue aiuta più '
            'di qualunque carta.',
      };
    }
    // Tre forme dello stesso limite, scelte dalla carta: *"riguarda il modo
    // di affrontare la questione, non l'esito"* era la formula stampata
    // sotto ogni causa e ogni investimento (lettore cieco, terzo giro).
    final coda = [
      'È un modo di vivere la questione, non un\'indicazione sul suo esito.',
      'Parla di come affronti la questione, non del suo esito.',
      'È uno spunto sul tuo stato d\'animo, non sul risultato.',
    ][carta.card.name.codeUnits.fold<int>(0, (a, b) => a + b) % 3];
    return '${_maiuscola(dove)}, $nome mostra ${_tema(carta)}. $coda';
  }

  static ({
    String risposta,
    String cosaFare,
    List<String> pezzi,
    String titolo,
  }) _componi(
    TarotSpread spread,
    TarotTopic topic, {
    String? domandaScritta,
    String? fattoDelCielo,
    DrawnCard? chiave,
  }) {
    final filo = FiloDellaVoce.daStesa(spread);
    final cielo = fattoDelCielo?.trim() ?? '';
    final usate = FigureDellaStesa.di(cielo);
    final d = LaDomandaLetta.di(domandaScritta);
    final carta = chiave ??
        TarotReading.chiaveDi(spread, domandaScritta: domandaScritta).drawn;
    final k = LaCartaNellaRisposta.di(carta);
    final tono = k.tono;
    final cartaSola = spread.cards.length == 1;
    final nome = nomeNellaFrase(carta);
    final dove = _doveDi(spread, carta);

    // Il filo mette in ordine le forme: la stessa stesa da' sempre lo stesso
    // testo, due stese diverse cominciano da forme diverse.
    // Una vera permutazione dei gesti, non una rotazione: il filo pesca uno
    // alla volta.
    List<T> mescola<T>(List<T> elenco) {
      final resto = List.of(elenco);
      final fuori = <T>[];
      while (resto.isNotEmpty) {
        final x = filo.scegli(resto);
        resto.remove(x);
        fuori.add(x);
      }
      return fuori;
    }

    List<String> inOrdine(List<String> forme) {
      if (forme.length < 2) return forme;
      final primo = forme.indexOf(filo.scegli(forme));
      return [
        for (var i = 0; i < forme.length; i++)
          forme[(primo + i) % forme.length],
      ];
    }

    final gruppo = d.gruppoDeiGesti(topic);
    final scritti = gestiDellaDomanda['$gruppo|${tono.name}']!;
    final azioniScritte = inOrdine([
      scritti['azione_1']!,
      scritti['azione_2']!,
      scritti['azione_3']!,
      scritti['azione_4']!,
    ]);
    final nonScritti =
        inOrdine([scritti['non_1']!, scritti['non_2']!, scritti['non_3']!]);
    // **UN VERDETTO SOLO DA UNA CARTA CHE LO DICE**, e solo se il resto della
    // stesa non lo contraddice con due carte di tono opposto.
    final opposte = spread.cards.where((c) {
      if (identical(c, carta)) return false;
      final t = LaCartaNellaRisposta.di(c).tono;
      return (tono == TonoDellaCarta.favorevole &&
              t == TonoDellaCarta.sfavorevole) ||
          (tono == TonoDellaCarta.sfavorevole &&
              t == TonoDellaCarta.favorevole);
    }).length;
    final diretto = LaCartaNellaRisposta.daVerdetto(carta) && opposte < 2;
    final v = _verdetto(d, carta, topic, azioniScritte, diretto: diretto);

    // --- LA RISPOSTA ---
    final sensibile = d.sensibile;
    // **DUE COSTRUZIONI DELLA STESSA RISPOSTA**: la prima nomina sempre la
    // carta contraria al centro o all'esito; se con lei il paragrafo non sta
    // nelle cinquanta parole (la domanda sul modo, la scelta, la doppia hanno
    // una prima frase lunga), si prova la seconda, dove e' facoltativa.
    List<_Posto> costruisciRisposta(bool contrariaObbligatoria) {
      final postiRisposta = <_Posto>[
        if (d.doppia) _Posto([avvisoDoppia(d.primaParte)], obbligatorio: true),
      ];
      if (sensibile != null) {
        postiRisposta.addAll([
          _Posto([avvisiSensibili[sensibile]!], obbligatorio: true),
          _Posto([_fraseSensibile(sensibile, spread, carta)],
              obbligatorio: true),
          const _Posto([avvisoBreveSensibile], obbligatorio: true),
          const _Posto([
            'Le carte aiutano a ordinare le domande da fare.',
            soloIlModo,
          ], diRiserva: true),
        ]);
      } else {
        // **LA CARTA CHE RISPONDE HA DUE FORME**: il testo lungo, che dice
        // perche', e la nota breve del suo ruolo. Se la domanda e' doppia, o se
        // una carta di tono contrario sta al centro o all'esito e va nominata,
        // il lungo non ci sta nella misura e si dice il breve.
        final predicato = _risposta(carta);
        final breve = _nota(carta);
        final soggetto =
            cartaSola ? '$nome, la sola carta uscita,' : '$dove, $nome';
        if (v.aperture.isNotEmpty) {
          final aperture = inOrdine(v.aperture);
          // Il filo sceglie anche fra la forma lunga e la breve: due stese
          // con la stessa carta chiave non cominciano dalla stessa frase.
          final lunghe = [
            for (final a in aperture) '$a: $soggetto $predicato.',
          ];
          final brevi = [
            for (final a in aperture) '$a: $soggetto $breve.',
          ];
          postiRisposta.add(_Posto(
              filo.scegli([true, false, false, false])
                  ? [...lunghe, ...brevi]
                  : [...brevi, ...lunghe],
              obbligatorio: true));
        } else {
          postiRisposta
            ..add(_Posto(v.frasi, obbligatorio: true))
            ..add(_Posto([
              if (cartaSola) ...[
                '${_maiuscola(nome)}, la sola carta uscita, $predicato.',
                '${_maiuscola(nome)}, la sola carta uscita, $breve.',
              ] else ...[
                '${_maiuscola(dove)}, $nome $predicato.',
                '${_maiuscola(dove)}, $nome $breve.',
              ],
            ], obbligatorio: true));
        }
        if (cartaSola) {
          // La carta sola non ha altre carte: dice anche dove la cosa puo'
          // andare, col suo testo dell'esito.
          // Il nome si ripete: *"la stessa carta indicano"* (Gli Amanti) era un
          // errore di accordo, e la frase breve non ha altro da dire.
          // La carta e' una sola: non si ripete il suo nome, si dice "la
          // carta", e il filo sceglie quale delle sue letture entra.
          final letture = [
            for (final (ruolo, apertura) in mescola([
              (
                'esito',
                mescola(
                    ['Guardando avanti, ', 'Più avanti, ', 'In prospettiva, '])
              ),
              (
                'ambiente',
                mescola(['Intorno a te, ', 'Nel contesto, ', 'Attorno a te, '])
              ),
              (
                'ostacolo',
                mescola([
                  'Da tenere d\'occhio: ',
                  'Un punto delicato: ',
                  'Con un limite: '
                ])
              ),
              (
                'influenza',
                mescola(['Sullo sfondo, ', 'In generale, ', 'Nel complesso, '])
              ),
            ]))
              '${apertura.first}la carta ${_testi(carta)['nota_$ruolo']}.',
          ];
          // **NON SI DICE DUE VOLTE LA STESSA COSA**: una lettura che ripete
          // una parola portante della prima frase (*"tensioni"*, *"tenuta"*)
          // sta fuori (lettore cieco, terzo giro: *"tiene a bada le tensioni"*
          // e *"regge anche le tensioni"* a una frase di distanza).
          var gia = '$predicato $breve';
          for (final l in letture) {
            if (_ripete(gia, l)) continue;
            gia = '$gia $l';
            postiRisposta.add(_Posto([l]));
          }
          postiRisposta.add(const _Posto([
            'Una carta sola va letta insieme alla tua domanda.',
            'Una carta sola va letta insieme alla domanda che hai posto e al '
                'momento che stai vivendo.',
          ], diRiserva: true));
        }
        final altre = _altre(spread, carta);
        final connettori = mescola(tono == TonoDellaCarta.sfavorevole
            ? ['In compenso', 'Però', 'D\'altra parte', 'Eppure']
            : ['Però', 'Eppure', 'D\'altro canto', 'Allo stesso tempo']);
        var contrarie = 0;
        var obbligataGia = false;
        for (final c in altre) {
          final t = LaCartaNellaRisposta.di(c).tono;
          final contraria = (tono == TonoDellaCarta.favorevole &&
                  t == TonoDellaCarta.sfavorevole) ||
              (tono == TonoDellaCarta.sfavorevole &&
                  t == TonoDellaCarta.favorevole);
          final doveC = _doveDi(spread, c);
          // "D'altro canto, da un lato, il Nove di Spade": due modi di dire
          // l'altra parte in una frase sola. Il lato non si dice dopo un
          // connettore.
          final delLato =
              doveC.startsWith('da un lato') || doveC.startsWith('dall\'altro');
          final frase = contraria
              ? (delLato
                  ? '${connettori[contrarie++ % connettori.length]}, '
                      '${nomeNellaFrase(c)} ${_nota(c)}.'
                  : '${connettori[contrarie++ % connettori.length]}, $doveC, '
                      '${nomeNellaFrase(c)} ${_nota(c)}.')
              : (delLato
                  ? 'Di fianco, ${nomeNellaFrase(c)} ${_nota(c)}.'
                  : '${_maiuscola(doveC)}, ${nomeNellaFrase(c)} ${_nota(c)}.');
          // **LA CARTA CHE DICE IL CONTRARIO, AL CENTRO O ALL'ESITO, NON SI
          // TACE** (lettore cieco indipendente: *"la carta della rottura e'
          // taciuta"*, tarocchi-12): la prima si nomina sempre.
          final aCuore =
              identical(c, spread.cuore) || identical(c, spread.approdo);
          // **UNA SECONDA CARTA SI NOMINA SEMPRE**: la risposta poggia sulla
          // carta che regge e sulla prima delle altre, nel modo breve se il
          // lungo non ci sta (ordine GA voce GA.06, prova P.09).
          final obbligatoria =
              (contrariaObbligatoria && contraria && aCuore && !obbligataGia) ||
                  (contrariaObbligatoria && identical(c, altre.first));
          if (obbligatoria) obbligataGia = true;
          postiRisposta.add(_Posto([frase], obbligatorio: obbligatoria));
        }
        // **IL RESTO DELLA STESA, DETTO PER CIO' CHE E'**: entra solo se il
        // paragrafo non arriva a quaranta parole.
        if (altre.isNotEmpty) {
          final concordi = altre.every((c) =>
              LaCartaNellaRisposta.di(c).tono == tono ||
              LaCartaNellaRisposta.di(c).tono == TonoDellaCarta.condizionato);
          postiRisposta.add(_Posto(
              inOrdine(concordi
                  ? [
                      'Le altre carte non smentiscono questa lettura.',
                      'Le altre carte confermano la direzione.',
                      'Il resto della stesa va nella stessa direzione.',
                    ]
                  : [
                      'Il resto della stesa è più sfumato.',
                      'Le altre carte non vanno tutte nella stessa direzione.',
                      'Le altre carte pesano in modo diverso.',
                    ]),
              diRiserva: true));
        }
      }
      return postiRisposta;
    }

    final scelteRisposta = _scegli(costruisciRisposta(true), usate,
        alternativa: costruisciRisposta(false));

    // --- IL "COSA FARE ADESSO" ---
    final List<String> azioni;
    final List<String> nonFare;
    if (sensibile != null) {
      azioni = inOrdine(d.azioni(topic));
      nonFare = inOrdine(d.nonFare(topic));
    } else {
      azioni = [
        for (final a in azioniScritte)
          if (a != v.azioneUsata) a,
      ];
      nonFare = nonScritti;
    }
    final letture = mescola([30, 40, 50, 60, 70, 80, 85]);
    final postiFare = <_Posto?>[
      if (d.doppia) const _Posto([gestoDoppia], obbligatorio: true),
      if (d.vaga) const _Posto([gestoVaga], obbligatorio: true),
      if (azioni.isNotEmpty)
        _Posto([azioni.first], obbligatorio: true, lettura: 20),
      // **L'ORDINE DEI GESTI LO DA' IL FILO**: il primo e' sempre l'azione
      // della domanda, gli altri si dispongono secondo la stesa. Due stese
      // che pescano gli stessi gesti non li leggono nello stesso ordine.
      _Posto([nonFare.first], obbligatorio: true, lettura: letture[0]),
      // **LE RISERVE ENTRANO SOLO SE IL PARAGRAFO NON ARRIVA A QUARANTA
      // PAROLE**, e l'ordine in cui si provano lo sceglie il filo. **Nessun
      // gesto di una carta**: il terzo giro del lettore cieco ha trovato in
      // coda al "Cosa fare" frasi estranee alla domanda (*"Offri la tua calma
      // a chi oggi ne ha bisogno"* a chi chiedeva di un incontro, *"Rivolgi
      // oggi un incoraggiamento preciso a una persona"* a chi chiedeva di un
      // esame). I gesti sono tutti scritti per la situazione della domanda.
      for (final k in mescola(['0', '1', '2', '3', '4']))
        switch (k) {
          '0' when azioni.length > 1 => _Posto([azioni[1]],
              lettura: letture[1], diRiserva: sensibile == null),
          '1' when nonFare.length > 1 =>
            _Posto([nonFare[1]], lettura: letture[2], diRiserva: true),
          '2' when azioni.length > 2 =>
            _Posto([azioni[2]], lettura: letture[3], diRiserva: true),
          '3' when azioni.length > 3 =>
            _Posto([azioni[3]], lettura: letture[4], diRiserva: true),
          '4' when nonFare.length > 2 =>
            _Posto([nonFare[2]], lettura: letture[5], diRiserva: true),
          _ => null,
        }
    ].whereType<_Posto>().toList();
    final scelteFare = _scegli(postiFare, usate);

    return (
      risposta: scelteRisposta.join(' '),
      cosaFare: scelteFare.join(' '),
      pezzi: [if (cielo.isNotEmpty) cielo, ...scelteRisposta, ...scelteFare],
      titolo: sensibile != null ? titoliSensibili[sensibile]! : v.titolo,
    );
  }
}

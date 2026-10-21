import '../responsi/la_forma_del_responso.dart';
import '../responsi/scelta_senza_ripetere.dart';
import 'figure_della_stesa.dart';
import 'la_carta_nella_risposta.dart';
import 'la_domanda_letta.dart';
import 'tarot_card.dart';
import 'tarot_reading.dart';
import 'tarot_spread.dart';
import 'tarot_topic.dart';

// **LAPIDE: `NaturaDellaCarta`, ordine DF voce 04.2, 11 settembre 2026.**
// Qui vivevano quattro "nature" di una carta uscita, compimento, favore,
// prova e attrito, fatte solo dall'arcano e dal verso: un Minore dritto era
// sempre un favore. L'ordine GA voce GA.06 le ha tolte dopo il lettore cieco
// dei Tarocchi del 20 ottobre 2026: il Nove di Spade, l'angoscia della notte,
// apriva *"Con Nove di Spade le carte [...] indicano una situazione che gira a
// tuo favore"*; il Tre di Spade *"la risposta e' buona"*; il Dieci di Spade
// *"un favore concreto e vicino"*; Il Diavolo *"un compimento vero"*. Il tono
// di una carta adesso viene dal suo significato documentato, per carta e
// verso: `LaCartaNellaRisposta.tono`. PADRE: ordine DF voce 04.2 (le nature),
// portato nella prima frase dall'ordine GA voci 03, 05 e 07, commit
// cb5fa8e3.

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
/// tre carte e dai loro versi**. Due conseguenze, tutte e due volute:
///
/// **Uno, cento estrazioni diverse danno cento forme diverse.** E' cio' che
/// l'ordine chiede, e siccome l'estrazione e' casuale davvero, due letture
/// consecutive non hanno nessuna ragione di somigliarsi.
///
/// **Due, resta deterministico.** Le stesse tre carte nello stesso verso danno
/// sempre lo stesso testo: la bolla piu' lunga dell'app continua a non toccare
/// l'LLM, si puo' ancora mettere in cache, e le prove restano ripetibili. **La
/// casualita' sta nel mazzo, dove deve stare, e non nel testo.**
///
/// **IL MESCOLATORE E' UN VERO MESCOLATORE, e la prima stesura non lo era.**
/// Sceglieva con `(seme ~/ passo) % lunghezza`, e coi passi grandi il quoziente
/// aveva pochissimi valori distinti: la misura C dell'ordine e' salita a
/// **88,1 per cento** perche' due estrazioni diverse cadevano sulle stesse
/// quattro forme su cinque. Adesso il seme si rimescola a ogni pescata con due
/// giri di moltiplicazione e scorrimento, che e' il mestiere di un hash e non
/// di una divisione.
class FiloDellaVoce {
  FiloDellaVoce(this.seme);

  /// Il filo di una stesa: le tre carte e i loro versi, e nient'altro.
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

  /// Quante volte si e' gia' pescato: ogni slot rimescola il filo con un numero
  /// suo, altrimenti due elenchi della stessa lunghezza uscirebbero sempre
  /// allineati e le forme si muoverebbero in blocco.
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

/// **IL VERDETTO DI UNA DOMANDA**: la prima frase, cio' che va detto prima e
/// dopo di lei, il titolo, e se il gesto della carta e' gia' stato usato.
class _Verdetto {
  const _Verdetto({
    required this.frasi,
    required this.titolo,
    this.prima,
    this.dopo,
    this.viaUsata = false,
    this.azioneUsata,
  });

  /// Le forme della prima frase che risponde, in ordine di preferenza.
  final List<String> frasi;

  /// Una frase obbligatoria prima del verdetto: la domanda doppia.
  final String? prima;

  /// Una frase obbligatoria dopo il verdetto: il perche' quando la prima frase
  /// non lo porta (il tema sensibile, la scelta col criterio).
  final String? dopo;
  final String titolo;
  final bool viaUsata;

  /// Il gesto della situazione gia' detto nella risposta (la domanda sul
  /// modo): il "Cosa fare" non lo ripete.
  final String? azioneUsata;
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
  /// preferenza: il gesto di una carta si preferisce a un secondo gesto
  /// della domanda, ma la cosa da non fare si legge in fondo.
  final int? lettura;
}

/// **LA VOCE DELLA STESA, IL RESPONSO PRINCIPALE DI CASA.** Ordine GA voci
/// GA.03, GA.05, GA.06 e GA.07, riscritta dall'ordine GA voce GA.06 il 21
/// ottobre 2026 dopo il lettore cieco dei Tarocchi.
///
/// **IL FATTO.** Su quaranta responsi di casa (`docs/collaudo/GA/
/// lettori_ciechi/tarocchi.json`, seme 606) la prima frase rispondeva alla
/// domanda in otto, il "Cosa fare" era concreto e pertinente in diciannove,
/// il responso era coerente con le carte e la domanda in dieci
/// (`docs/collaudo/GA/lettori_ciechi/esiti/esito_tre_domande_tarocchi.md`).
/// Le cause, una per una: la prima frase era una forma fissa con dentro il
/// nome della carta, scelta da una "natura" che non guardava il significato;
/// la carta nominata era quella della prima posizione e non la carta chiave
/// (19 stese su 30); la lente dell'argomento entrava nella prima frase anche
/// quando era sbagliata (*"sul ritorno che aspetti"* su una causa legale); il
/// "Cosa fare" girava su otto gesti per natura che non conoscevano la
/// domanda; nessuna domanda vaga, doppia, di salute, di legge o di denaro era
/// riconosciuta.
///
/// **LA FORMA NUOVA, scelta e misurata.**
/// - **La domanda si legge** (`LaDomandaLetta`): la sua forma (si' o no, come,
///   cosa, quando, scelta fra due), il tema sensibile, la situazione, se e'
///   vaga o doppia, se chiede un distacco.
/// - **La carta chiave decide** (`TarotReading.chiaveDi`, la stessa che la
///   schermata marca come chiave), e porta cio' che il suo significato dice
///   (`LaCartaNellaRisposta`): il tono, il tema, il perche', il gesto.
/// - **La prima frase risponde alla domanda nella sua forma**, col tono della
///   carta chiave, il suo nome e il suo perche': *"Per ora no: Nove di Spade
///   dice che l'ansia e i pensieri della notte ingigantiscono le paure."*
///   Sulla salute, la legge e il denaro dice che le carte non decidono e chi
///   decide; sulla domanda doppia dice che risponde alla prima; sulla vaga
///   risponde sul periodo e invita a precisare.
/// - **Le frasi dopo poggiano sulle altre carte**, ognuna col suo tema e col
///   rapporto col verdetto (conferma, contrasta, attenua), e sull'approdo
///   letto per cio' che e': una carta di dolore all'esito e' un rischio da
///   guardare, mai una meta.
/// - **Il "Cosa fare adesso"** porta il gesto della carta chiave, il gesto
///   concreto della situazione della domanda e una cosa da non fare.
///
/// **LA MISURA.** Ogni paragrafo sta fra 40 e 50 parole
/// (`LaFormaDelResponso`): i posti di un paragrafo si scelgono in ordine di
/// preferenza fra quelli che stanno nella misura, e nessun testo si tronca
/// (GA.07). Nessuna figura ripetuta fra due pezzi (ordine DS voce 09): le
/// scelte passano dall'impianto unico `SceltaSenzaRipetere`.
abstract final class VoceDellaStesa {
  // **LAPIDI dell'ordine GA voci 03, 05 e 07 (commit cb5fa8e3)**:
  // `verdettiDelCuore`, `cosaDiceIlPresente`, `cosaVuolDire`,
  // `titoliDelPresente`, `aggancioDellAzione`, `gestoPerNatura`,
  // `formeDellApprodo`, `percheFarlo`, `senzaRipetere` e `riempi`. Erano le
  // otto forme per natura di ogni fessura: *"Con {presente} le carte,
  // {inLente}, indicano una situazione che gira a tuo favore"*, chiunque fosse
  // la carta. Le frasi che il lettore cieco ha trovato ripetute (*"Su questa
  // questione il tempo lavora dalla tua parte, a patto di cominciare"* sette
  // volte su quaranta) venivano da li'.

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

  // --- LE FORME DELLA RISPOSTA ---

  /// **LE PAROLE DEI TEMI SENSIBILI**: la prima frase, che risponde dicendo
  /// che le carte non decidono e chi decide (ordine S voce 17).
  static const Map<TemaSensibile, String> avvisiSensibili = {
    TemaSensibile.salute: 'Le carte non dicono come va un intervento o una '
        'cura: decide il tuo medico.',
    TemaSensibile.legge:
        'Le carte non dicono come finisce una causa: decide il tuo avvocato.',
    TemaSensibile.denaro: 'Le carte non dicono se un investimento conviene: '
        'chiedi a un consulente abilitato.',
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

  /// **LA DOMANDA DOPPIA**: lo si dice prima del verdetto.
  static const String avvisoDoppia = 'Le domande sono due: le carte rispondono '
      'alla prima, la seconda chiede una stesa sua.';

  /// **E NEL "COSA FARE"**, per la domanda doppia e per la vaga.
  static const String gestoDoppia =
      'Per l\'altra domanda fai una stesa a parte, con quella sola.';
  static const String gestoVaga = 'Per una risposta precisa, rifai la domanda '
      'nominando la cosa che ti sta a cuore.';

  /// **LE FRASI DI SERVIZIO**, uguali per scelta: gli avvisi dei temi
  /// sensibili, della domanda doppia e della vaga. La guardia della frase
  /// fissa le conta a parte, perche' devono essere sempre le stesse.
  static List<String> get frasiDiServizio => [
        ...avvisiSensibili.values,
        avvisoBreveSensibile,
        avvisoDoppia,
        gestoDoppia,
        gestoVaga,
      ];

  /// **DOVE STA UNA CARTA**, detto in poche parole dentro una frase.
  static String doveSta(SpreadPosition p) => switch (p) {
        SpreadPosition.passato => 'alle spalle',
        SpreadPosition.presente => 'nel presente',
        SpreadPosition.futuro => 'davanti a te',
        SpreadPosition.cartaSola => 'sul tavolo',
        SpreadPosition.consultante => 'su di te',
        SpreadPosition.lato => 'di lato',
        SpreadPosition.esito => 'all\'esito',
        SpreadPosition.copre => 'al centro',
        SpreadPosition.attraversa => 'di traverso',
        SpreadPosition.corona => 'sopra',
        SpreadPosition.sotto => 'alla base',
        SpreadPosition.dietro => 'dietro di te',
        SpreadPosition.seStesso => 'su di te',
        SpreadPosition.laCasa => 'intorno a te',
        SpreadPosition.speranzeOTimori => 'fra speranze e timori',
      };

  static String _maiuscola(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// **IL VERBO ACCORDATO AL NOME DELLA CARTA**: Gli Amanti e' il solo nome
  /// plurale del mazzo (`ReversedAgreement.maschilePlurale`), e *"Gli Amanti
  /// dice"* si legge subito come un errore.
  static String _v(DrawnCard c, String singolare, String plurale) =>
      c.card.reversedAgreement == ReversedAgreement.maschilePlurale
          ? plurale
          : singolare;

  /// **LA TERZA FORMA DEL VERDETTO**: *"Per ora no: X dice che..."* si dice
  /// anche *"X risponde: per ora no, perche'..."*. La carta e la risposta
  /// restano nella prima frase; due letture con la stessa carta chiave non
  /// aprono sempre allo stesso modo.
  static List<String> _conLaTerzaForma(List<String> frasi, DrawnCard chiave) {
    final n = chiave.displayName;
    final k = LaCartaNellaRisposta.di(chiave);
    final mezzo = ': $n ${_v(chiave, 'dice', 'dicono')} che ${k.dice}.';
    return [
      ...frasi,
      for (final f in frasi)
        if (f.endsWith(mezzo) &&
            !f.startsWith('Le carte') &&
            !f.startsWith('La domanda') &&
            !f.startsWith('In generale'))
          '$n ${_v(chiave, 'risponde', 'rispondono')}: '
              '${f[0].toLowerCase()}${f.substring(1, f.length - mezzo.length)}, '
              'perché ${k.dice}.',
    ];
  }

  /// **IL VERDETTO**, la prima frase che risponde, per la forma della domanda
  /// [d] e il tono della carta chiave [chiave]. [azioni] sono i gesti della
  /// situazione della domanda: a una domanda sul modo risponde il primo.
  static _Verdetto _verdetto(LaDomandaLetta d, DrawnCard chiave,
      TarotTopic argomento, List<String> azioni) {
    final k = LaCartaNellaRisposta.di(chiave);
    final n = chiave.displayName;
    final dice = k.dice;
    final via = k.via;
    final tema = k.tema;
    final diceV = _v(chiave, 'dice', 'dicono');
    String perche(String apertura) => '$apertura: $n $diceV che $dice.';
    String percheB(String apertura) =>
        '$apertura, perché $n ${_v(chiave, 'indica', 'indicano')} che $dice.';
    final prima = d.doppia ? avvisoDoppia : null;

    if (d.sensibile != null) {
      return _Verdetto(
        frasi: [avvisiSensibili[d.sensibile]!],
        // Il perche' della carta non entra: detto accanto a un intervento
        // o a una causa, *"le cose riescono"* suonerebbe come un esito. La
        // carta dice come attraversarla, col suo gesto.
        dopo: '$n ${_v(chiave, 'parla', 'parlano')} del modo di viverla e non '
            'dell\'esito; ${_v(chiave, 'chiede', 'chiedono')} questo: $via.',
        titolo: titoliSensibili[d.sensibile]!,
        viaUsata: true,
      );
    }
    final tono = k.tono;
    if (d.vaga) {
      return _Verdetto(
        frasi: [
          perche(d.forma == FormaDellaDomanda.siNo
              ? switch (tono) {
                  TonoDellaCarta.favorevole =>
                    'In generale sì, anche se la domanda è ampia',
                  TonoDellaCarta.condizionato =>
                    'In generale sì, a una condizione, ma la domanda è ampia',
                  TonoDellaCarta.sfavorevole =>
                    'In generale non ancora, anche se la domanda è ampia',
                }
              : switch (tono) {
                  TonoDellaCarta.favorevole => 'La domanda è ampia, quindi sul '
                      'periodo le carte vedono una cosa buona',
                  TonoDellaCarta.condizionato =>
                    'La domanda è ampia, quindi sul '
                        'periodo le carte vedono una cosa in sospeso',
                  TonoDellaCarta.sfavorevole =>
                    'La domanda è ampia, quindi sul '
                        'periodo le carte vedono una difficoltà',
                }),
        ],
        prima: prima,
        titolo: 'Il periodo porta $tema',
      );
    }
    final distacco = d.distacco &&
        (d.forma == FormaDellaDomanda.siNo ||
            d.forma == FormaDellaDomanda.scelta);
    if (distacco) {
      if (k.distacco || (tono == TonoDellaCarta.favorevole && !k.legame)) {
        return _Verdetto(
          frasi: [
            perche('Sì, le carte sostengono questo passo'),
            percheB('Sì, è il momento di andare'),
          ],
          prima: prima,
          titolo: 'Sì, conta $tema',
        );
      }
      return switch (tono) {
        TonoDellaCarta.favorevole => _Verdetto(
            frasi: [
              perche('Per ora no, perché il legame ha ancora valore'),
              percheB('Per ora no, il legame vale ancora'),
            ],
            prima: prima,
            titolo: 'Ora no, conta $tema',
          ),
        TonoDellaCarta.condizionato => _Verdetto(
            frasi: [
              perche('Non ancora, prima serve una condizione'),
              percheB('Non ancora'),
            ],
            prima: prima,
            titolo: 'Non ancora, pesa $tema',
          ),
        TonoDellaCarta.sfavorevole => _Verdetto(
            frasi: [
              perche('Non decidere adesso'),
              percheB('Non decidere adesso'),
            ],
            prima: prima,
            titolo: 'Non adesso, pesa $tema',
          ),
      };
    }
    switch (d.forma) {
      case FormaDellaDomanda.nessuna:
        return _Verdetto(
          frasi: [perche('${argomento.lente}, le carte vedono $tema')],
          titolo: 'Le carte vedono $tema',
        );
      case FormaDellaDomanda.siNo when d.timore:
        // A una domanda di timore il si' e' la cosa temuta: una carta che
        // apre risponde no, e una che chiude non trasforma il timore in un
        // fatto, dice che c'e' qualcosa da chiarire.
        return switch (tono) {
          TonoDellaCarta.favorevole => _Verdetto(
              frasi: [
                perche('No, le carte non vedono quello che temi'),
                percheB('No, il timore non trova conferma'),
              ],
              prima: prima,
              titolo: 'No, conta $tema',
            ),
          TonoDellaCarta.condizionato => _Verdetto(
              frasi: [
                perche('Non è detto, ma c\'è qualcosa da chiarire'),
                percheB('Non è detto, ma va chiarito'),
              ],
              prima: prima,
              titolo: 'Da chiarire, pesa $tema',
            ),
          TonoDellaCarta.sfavorevole => _Verdetto(
              frasi: [
                perche('Non come certezza, ma c\'è qualcosa da chiarire'),
                percheB('Non come certezza, ma il disagio è reale'),
              ],
              prima: prima,
              titolo: 'Da chiarire, pesa $tema',
            ),
        };
      case FormaDellaDomanda.siNo:
        return switch (tono) {
          TonoDellaCarta.favorevole => _Verdetto(
              frasi: [
                perche('Sì, la tendenza è favorevole'),
                percheB('La risposta delle carte è sì'),
              ],
              prima: prima,
              titolo: 'Sì, conta $tema',
            ),
          TonoDellaCarta.condizionato => _Verdetto(
              frasi: [
                perche('Sì, ma a una condizione'),
                percheB('Sì, se rispetti una condizione'),
              ],
              prima: prima,
              titolo: 'Sì, ma pesa $tema',
            ),
          TonoDellaCarta.sfavorevole => _Verdetto(
              frasi: [
                perche('Per ora no'),
                percheB('Così com\'è adesso no'),
              ],
              prima: prima,
              titolo: 'Ora no, pesa $tema',
            ),
        };
      case FormaDellaDomanda.come:
        // A una domanda sul modo risponde un gesto: quello della situazione
        // quando la carta apre, la condizione della carta quando apre a una
        // condizione, la difficoltà da affrontare quando chiude.
        final azione = azioni.first;
        final minuscola = azione[0].toLowerCase() + azione.substring(1);
        return switch (tono) {
          TonoDellaCarta.favorevole => _Verdetto(
              frasi: ['Il modo è questo: $minuscola'],
              dopo: 'Lo ${_v(chiave, 'sostiene', 'sostengono')} $n: $diceV '
                  'che $dice.',
              prima: prima,
              titolo: 'Punta su $tema',
              azioneUsata: azione,
            ),
          TonoDellaCarta.condizionato => _Verdetto(
              frasi: ['Il modo c\'è, a una condizione: $via.'],
              dopo: '$n $diceV che $dice.',
              prima: prima,
              titolo: 'Prima cura $tema',
              viaUsata: true,
            ),
          TonoDellaCarta.sfavorevole => _Verdetto(
              frasi: [
                perche('Prima va affrontata una difficoltà'),
                percheB('Prima c\'è una difficoltà da affrontare'),
              ],
              prima: prima,
              titolo: 'Prima affronta $tema',
            ),
        };
      case FormaDellaDomanda.quando:
        return switch (tono) {
          TonoDellaCarta.favorevole => _Verdetto(
              frasi: [perche('Non manca molto, se la tendenza resta questa')],
              prima: prima,
              titolo: 'A breve, conta $tema',
            ),
          TonoDellaCarta.condizionato => _Verdetto(
              frasi: [perche('Non subito, prima serve una condizione')],
              prima: prima,
              titolo: 'Non subito, pesa $tema',
            ),
          TonoDellaCarta.sfavorevole => _Verdetto(
              frasi: [perche('Non a breve'), percheB('Non a breve')],
              prima: prima,
              titolo: 'Non presto, pesa $tema',
            ),
        };
      case FormaDellaDomanda.cosa:
        return _Verdetto(
          frasi: [
            perche(switch (tono) {
              TonoDellaCarta.favorevole => 'Le carte vedono una cosa buona',
              TonoDellaCarta.condizionato =>
                'Le carte vedono una cosa ancora in sospeso',
              TonoDellaCarta.sfavorevole => 'Le carte vedono una difficoltà',
            }),
          ],
          prima: prima,
          titolo: 'Le carte vedono $tema',
        );
      case FormaDellaDomanda.scelta:
        final restare = d.sceltaFraMuoversiERestare;
        if (restare == null) {
          // Il criterio viene dal tono della carta chiave: l'opzione in cui
          // c'e' cio' che la carta apre, o quella in cui non pesa cio' che
          // la carta chiude.
          final criterio = switch (tono) {
            TonoDellaCarta.favorevole => 'scegli l\'opzione in cui trovi $tema',
            TonoDellaCarta.condizionato =>
              'scegli l\'opzione che ti lascia il tempo di capire, perché '
                  'c\'è $tema',
            TonoDellaCarta.sfavorevole => 'scarta l\'opzione in cui pesa $tema',
          };
          return _Verdetto(
            frasi: [
              'Le carte non scelgono al posto tuo, ma danno il criterio: '
                  '$criterio.',
            ],
            dopo: 'Lo ${_v(chiave, 'indica', 'indicano')} $n, con un consiglio '
                'preciso: $via.',
            prima: prima,
            titolo: 'Scegli guardando $tema',
            viaUsata: true,
          );
        }
        return switch (tono) {
          TonoDellaCarta.favorevole => _Verdetto(
              frasi: [perche('Le carte inclinano a muoverti')],
              prima: prima,
              titolo: 'Muoviti, conta $tema',
            ),
          TonoDellaCarta.condizionato => _Verdetto(
              frasi: [perche('Prima di scegliere serve una condizione')],
              prima: prima,
              titolo: 'Prima guarda $tema',
            ),
          TonoDellaCarta.sfavorevole => _Verdetto(
              frasi: [
                perche(restare == 'aspettare'
                    ? 'Le carte inclinano ad aspettare, per ora'
                    : 'Le carte inclinano a restare, per ora'),
              ],
              prima: prima,
              titolo: restare == 'aspettare'
                  ? 'Aspetta, pesa $tema'
                  : 'Resta, pesa $tema',
            ),
        };
    }
  }

  /// **UNA CARTA ACCANTO AL VERDETTO**: il suo tema e il suo rapporto con la
  /// carta chiave; l'approdo detto per cio' che e'.
  static List<String> _altra(DrawnCard c, TonoDellaCarta tonoChiave,
      {required bool approdo}) {
    final a = LaCartaNellaRisposta.di(c);
    final n = c.displayName;
    final dove = doveSta(c.position);
    final ce = _v(c, 'c\'è', 'ci sono');
    if (approdo) {
      final inizio = _maiuscola(dove);
      return switch (a.tono) {
        // Un approdo che apre dopo una chiave che chiude non e' una meta
        // gia' raggiunta: dice che la cosa puo' ancora girare.
        TonoDellaCarta.favorevole
            when tonoChiave == TonoDellaCarta.sfavorevole =>
          [
            '$inizio $ce $n, cioè ${a.tema}: la cosa può ancora girare, se '
                'cambi qualcosa adesso.',
            '$inizio $ce $n, cioè ${a.tema}.',
          ],
        TonoDellaCarta.favorevole => [
            '$inizio $ce $n, cioè ${a.tema}: è lì che la cosa può arrivare.',
            '$inizio $ce $n, cioè ${a.tema}.',
          ],
        TonoDellaCarta.condizionato => [
            '$inizio $ce $n, cioè ${a.tema}: un esito che chiede ancora un '
                'impegno.',
            '$inizio $ce $n, cioè ${a.tema}.',
          ],
        TonoDellaCarta.sfavorevole => [
            '$inizio $ce $n, cioè ${a.tema}: un rischio da guardare adesso, '
                'non una meta.',
            '$inizio $ce $n, cioè ${a.tema}: un rischio, non una meta.',
          ],
      };
    }
    final verbo = switch ((tonoChiave, a.tono)) {
      (_, TonoDellaCarta.condizionato) => null,
      (TonoDellaCarta.favorevole, TonoDellaCarta.favorevole) ||
      (TonoDellaCarta.sfavorevole, TonoDellaCarta.sfavorevole) =>
        _v(c, 'Lo conferma', 'Lo confermano'),
      (TonoDellaCarta.favorevole, TonoDellaCarta.sfavorevole) ||
      (TonoDellaCarta.condizionato, TonoDellaCarta.sfavorevole) =>
        _v(c, 'Lo contrasta', 'Lo contrastano'),
      (TonoDellaCarta.sfavorevole, TonoDellaCarta.favorevole) =>
        _v(c, 'Lo attenua', 'Lo attenuano'),
      (TonoDellaCarta.condizionato, TonoDellaCarta.favorevole) =>
        _v(c, 'Lo sostiene', 'Lo sostengono'),
    };
    if (verbo == null) {
      return ['Accanto $ce $n $dove, con ${a.tema}: una cosa da curare.'];
    }
    return ['$verbo $n $dove, con ${a.tema}.'];
  }

  /// **SCEGLIE I POSTI DI UN PARAGRAFO** perche' stia fra 40 e 50 parole:
  /// in ordine, gli obbligatori sempre e gli altri quando ci stanno, con la
  /// prima forma libera da figure gia' dette (`SceltaSenzaRipetere`). La
  /// prima composizione nella misura vince; i posti prima nell'elenco
  /// vengono preferiti.
  static List<String> _scegli(List<_Posto> posti, Set<String> usate) {
    List<(int, String)>? trovata;
    void cerca(int i, List<(int, String)> fin, int parole, Set<String> viste) {
      if (trovata != null || parole > LaFormaDelResponso.massimo) return;
      if (i == posti.length) {
        if (parole >= LaFormaDelResponso.minimo) trovata = List.of(fin);
        return;
      }
      final p = posti[i];
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
        cerca(
            i + 1,
            [...fin, (p.lettura ?? i * 10, f)],
            parole + LaFormaDelResponso.parole(f),
            {...viste, ...FigureDellaStesa.di(f)});
        if (trovata != null) return;
      }
      if (!p.obbligatorio && !p.diRiserva) cerca(i + 1, fin, parole, viste);
    }

    cerca(0, const [], 0, usate);
    // Nessuna composizione nella misura: la guardia della misura lo dice.
    // Si consegnano gli obbligatori, mai un testo tagliato.
    final scelte = trovata == null
        ? [
            for (final p in posti)
              if (p.obbligatorio) p.forme.first
          ]
        : [
            for (final e in trovata!..sort((a, b) => a.$1.compareTo(b.$1))) e.$2
          ];
    for (final f in scelte) {
      usate.addAll(FigureDellaStesa.di(f));
    }
    return scelte;
  }

  /// **LE CARTE ACCANTO ALLA CHIAVE**, in ordine: l'approdo, il cuore della
  /// stesa, poi le altre nell'ordine di lettura.
  static List<(DrawnCard, bool)> _accanto(
      TarotSpread spread, DrawnCard chiave) {
    final fuori = <(DrawnCard, bool)>[];
    final approdo = spread.approdo;
    if (approdo != null && !identical(approdo, chiave)) {
      fuori.add((approdo, true));
    }
    for (final c in [spread.cuore, ...spread.cards]) {
      if (identical(c, chiave)) continue;
      if (fuori.any((e) => identical(e.$1, c))) continue;
      fuori.add((c, false));
    }
    return fuori;
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

  /// **IL RESPONSO PRINCIPALE DI CASA NELLA FORMA NUOVA**: il titolo, la
  /// risposta e il "Cosa fare adesso", ogni paragrafo da 40 a 50 parole.
  /// [chiave] e' la carta chiave della stesa; nulla, la sceglie
  /// `TarotReading.chiaveDi`.
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
  /// anche lui, e sta per primo: non sta nei paragrafi, ma si legge nella
  /// stessa schermata, nel "Da dove viene".
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
    final laChiave = chiave ?? TarotReading.chiaveDi(spread).drawn;
    final k = LaCartaNellaRisposta.di(laChiave);
    final n = laChiave.displayName;
    final cartaSola = spread.cards.length == 1;

    // Il filo mette in ordine le forme: la stessa stesa da' sempre lo stesso
    // testo, due stese diverse cominciano da forme diverse.
    List<String> inOrdine(List<String> forme) {
      if (forme.length < 2) return forme;
      final primo = forme.indexOf(filo.scegli(forme));
      return [
        for (var i = 0; i < forme.length; i++)
          forme[(primo + i) % forme.length],
      ];
    }

    final accanto = _accanto(spread, laChiave);
    final tutteLeAzioni = inOrdine(d.azioni(topic));
    final v = _verdetto(d, laChiave, topic, tutteLeAzioni);

    // --- LA RISPOSTA ---
    var viaUsata = v.viaUsata;
    final postiRisposta = <_Posto>[
      if (v.prima != null) _Posto([v.prima!], obbligatorio: true),
      _Posto(
          inOrdine(d.forma == FormaDellaDomanda.nessuna
              ? v.frasi
              : _conLaTerzaForma(v.frasi, laChiave)),
          obbligatorio: true),
      if (v.dopo != null) _Posto([v.dopo!], obbligatorio: true),
      // La condizione della carta, detta: *"chiede prima una condizione"*
      // senza dirla era un difetto trovato dal lettore cieco.
      if (!viaUsata &&
          k.tono == TonoDellaCarta.condizionato &&
          d.sensibile == null)
        _Posto(inOrdine([
          switch (d.forma) {
            FormaDellaDomanda.siNo ||
            FormaDellaDomanda.quando ||
            FormaDellaDomanda.scelta =>
              'La condizione è questa: ${k.via}.',
            _ => 'Il consiglio della carta è questo: ${k.via}.',
          },
          'Prima, però, ${k.via}.',
          'Prima serve questo: ${k.via}.',
        ])),
      // La carta sola non ha altre carte da mettere accanto: dice come
      // sostenere o come cambiare la tendenza.
      if (cartaSola &&
          !viaUsata &&
          v.azioneUsata == null &&
          k.tono != TonoDellaCarta.condizionato &&
          d.sensibile == null)
        _Posto([
          k.tono == TonoDellaCarta.sfavorevole
              ? 'Per cambiare questa tendenza, ${k.via}.'
              : 'Per sostenere questa tendenza, ${k.via}.',
        ]),
      for (final (c, approdo) in accanto.take(3))
        _Posto(_altra(c, k.tono, approdo: approdo)),
      // Sui temi sensibili il limite si ripete in breve: nessuna carta
      // prende il posto di chi e' competente.
      if (d.sensibile != null) const _Posto([avvisoBreveSensibile]),
      // Il tema della carta chiave detto per nome, e il suo consiglio quando
      // il "Cosa fare" non lo porta gia': frasi che stanno solo sotto questa
      // carta. LAPIDE: "X e' la carta chiave di questa stesa", "X e'
      // l'unica carta uscita: decide tutto" e "E' cio' che X mostra adesso:
      // la direzione e' buona", che col nome tolto erano la stessa frase
      // sotto qualunque carta.
      _Posto(
          inOrdine([
            'Al centro c\'è ${k.tema}: è questo che decide la risposta.',
            'Il punto è ${k.tema}: da questo dipende la risposta.',
            'Al centro c\'è ${k.tema}.',
          ]),
          diRiserva: true),
      if (!viaUsata && !cartaSola && d.sensibile == null)
        _Posto(['Il suo consiglio è chiaro: ${k.via}.']),
    ];
    final scelteRisposta = _scegli(postiRisposta, usate);
    if (scelteRisposta.any((f) => f.contains(k.via))) viaUsata = true;

    // --- IL "COSA FARE ADESSO" ---
    final azioni = [
      for (final a in tutteLeAzioni)
        if (a != v.azioneUsata) a,
    ];
    final nonFare = inOrdine(d.nonFare(topic));
    final postiFare = <_Posto>[
      if (d.doppia) const _Posto([gestoDoppia], obbligatorio: true),
      if (d.vaga) const _Posto([gestoVaga], obbligatorio: true),
      // **IL GESTO DI UN'ALTRA CARTA**, preferito a quello della chiave, che
      // ha gia' il suo verdetto nella risposta: senza, il "Cosa fare" di due
      // letture con la stessa domanda e la stessa carta chiave sarebbe lo
      // stesso (la misura D di `cento_letture_uguali_test.dart` l'ha presa:
      // otto volte lo stesso paragrafo su cento letture, e la C oltre il
      // quaranta per cento). La carta sola, che non ha un'altra carta, porta
      // il suo gesto quando la risposta non lo dice gia'. LAPIDE: "E' il modo
      // pratico di stare dentro cio' che X chiede", che col nome tolto era la
      // stessa frase sotto qualunque carta sola.
      if (accanto.isNotEmpty)
        _Posto([
          '${accanto.first.$1.displayName} ${doveSta(accanto.first.$1.position)} '
              '${_v(accanto.first.$1, 'aggiunge', 'aggiungono')} un gesto: '
              '${LaCartaNellaRisposta.di(accanto.first.$1).via}.',
        ], lettura: 30),
      if (!viaUsata)
        _Posto(
            inOrdine([
              'Il gesto che $n ${_v(laChiave, 'chiede', 'chiedono')} è questo: '
                  '${k.via}.',
              'Prima di tutto, ${k.via}.',
              'In pratica, ${k.via}.',
            ]),
            lettura: 20),
      if (azioni.isNotEmpty) _Posto(azioni, obbligatorio: true, lettura: 50),
      _Posto(nonFare, obbligatorio: true, lettura: 90),
      if (azioni.length > 1) _Posto([azioni[1]], lettura: 60),
      // La seconda cosa da non fare e il terzo gesto vengono per ultimi:
      // con piu' frasi della domanda, due letture con la stessa domanda si
      // somiglierebbero per meta' riquadro.
      if (nonFare.length > 1)
        _Posto([nonFare[1]], lettura: 95, diRiserva: true),
      if (azioni.length > 2) _Posto([azioni[2]], lettura: 70, diRiserva: true),
    ];
    final scelteFare = _scegli(postiFare, usate);

    return (
      risposta: scelteRisposta.join(' '),
      cosaFare: scelteFare.join(' '),
      pezzi: [if (cielo.isNotEmpty) cielo, ...scelteRisposta, ...scelteFare],
      titolo: v.titolo,
    );
  }
}

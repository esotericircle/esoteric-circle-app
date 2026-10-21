import 'dart:async';
import '../chat/il_filo_del_consulto.dart';
import '../maestro/consiglio_finale.dart';
import '../maestro/maestro.dart';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../chat/il_blocco_di_cortesia.dart';
import '../chat/la_risposta_ripulita.dart';
import '../chat/le_forme_del_genere.dart';
import '../chat/user_profile.dart';
import '../config/la_regione_dei_dati.dart';
import '../l10n/la_lingua_del_modello.dart';
import '../responsi/confine_del_responso.dart';
import '../responsi/la_forma_del_responso.dart';
import '../viaggio/la_domanda_capita.dart';
import 'le_carte_nella_posizione.dart';
import 'tarot_reading.dart';
import 'tarot_topic.dart';
import 'la_chiave_di_lettura.dart';
import 'tarot_spread.dart';
import '../../services/ai/l_etichetta_della_funzione.dart';

/// La firma di una chiamata al modello: l'istruzione e la richiesta, la
/// risposta come testo JSON. Le prove ne passano una finta.
typedef ChiamataDellaStesa = Future<String?> Function(
    String istruzione, String richiesta, Map<String, Schema> campi);

/// **LA LETTURA SCRITTA DAL MODELLO: IL SOLO RESPONSO PRINCIPALE.** Ordine GA
/// voci GA.03, GA.05 e GA.07, 20 ottobre 2026, decisione del fondatore
/// "Carte dal corpus": in ogni stesa, da una, tre, quattro o dieci carte, le
/// singole carte vengono dal corpus (`LeCarteNellaPosizione.responsoDi`) e il
/// modello scrive soltanto il responso principale, letto sulla domanda e su
/// tutte le carte: il titolo, la risposta, il "Cosa fare adesso" e, nella
/// Lunga, l'approfondimento. Ogni paragrafo da 40 a 50 parole
/// (`LaFormaDelResponso`).
///
/// **LAPIDE: "un pezzo per ogni cosa che la persona deve trovare: la
/// risposta, le tre carte nella loro posizione, il legame e il consiglio".**
/// Dall'ordine EQ voce 04 all'ordine GA il modello scriveva anche un testo
/// per ogni carta (i campi `passato`, `presente`, `futuro` o i nomi delle
/// posizioni delle altre stese), il legame e i due approfondimenti della
/// Lunga (ordine FN): erano i gettoni d'uscita che il conto dei piani
/// (`tool/i_limiti_degli_annuali.py`, voce GA.02) non reggeva.
class LetturaDelModello {
  LetturaDelModello({
    required this.risposta,
    required this.cosaFare,
    this.titolo = '',
    this.approfondimento = '',
  });

  /// **IL TITOLO, ordine FK aggiunta voce A1.** Il fondatore, 3 settembre
  /// 2026: *"le risposte devono partire con un titolo diretto che riassume
  /// tutto"*. Il modello lo scrive per ultimo, dopo la lettura che riassume.
  /// Vuoto quando non arriva o non regge: allora il titolo e' quello della
  /// lettura di casa (`TarotReading.titolo`): la schermata non resta mai
  /// senza.
  final String titolo;

  /// Il paragrafo della risposta: la prima frase risponde alla domanda
  /// (voce GA.06).
  final String risposta;

  /// Il paragrafo del riquadro "Cosa fare adesso": che cosa fare o non fare.
  final String cosaFare;

  /// **IL PARAGRAFO DELLA LUNGA**, voce GA.03: approfondisce la risposta.
  /// Vuoto alla profondita' Breve: `campiPer` non lo chiede nemmeno. Il
  /// quarto paragrafo, la contemplazione propiziatoria, non lo scrive il
  /// modello: viene dal corpus dei riti (voce GA.04).
  final String approfondimento;

  /// **OGNI PEZZO PASSA DALLE REGOLE DI LINGUA DI CASA**, come le risposte
  /// dei Maestri (`LaRispostaRipulita`): il trattino lungo e la virgola
  /// seguita da "e" si correggono, invece di buttare una lettura buona per
  /// una virgola.
  LetturaDelModello ripulita() => LetturaDelModello(
        risposta: LaRispostaRipulita.applica(risposta),
        cosaFare: LaRispostaRipulita.applica(cosaFare),
        titolo: LaRispostaRipulita.applica(titolo),
        approfondimento: LaRispostaRipulita.applica(approfondimento),
      );

  Map<String, String> toJson() => {
        'risposta': risposta,
        'cosaFare': cosaFare,
        if (approfondimento.isNotEmpty) 'approfondimento': approfondimento,
        if (titolo.isNotEmpty) 'titolo': titolo,
      };

  /// Null se manca un pezzo: una lettura a meta' non si mostra. **Il titolo
  /// non e' fra i pezzi che la fanno cadere**: senza, la lettura resta e il
  /// titolo lo da' la lettura di casa. **Nella Lunga ([lunga]) anche
  /// l'approfondimento e' obbligatorio**: un responso Lungo senza il suo
  /// terzo paragrafo non ha la forma di GA.03, e la richiesta si ripete.
  static LetturaDelModello? daJson(Map<String, Object?>? j,
      {bool lunga = false}) {
    if (j == null) return null;
    String? pezzo(String k) {
      final v = j[k];
      if (v is! String) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    final r = pezzo('risposta');
    final c = pezzo('cosaFare');
    final a = pezzo('approfondimento');
    if (r == null || c == null || (lunga && a == null)) return null;
    return LetturaDelModello(
      risposta: r,
      cosaFare: c,
      titolo: pezzo('titolo') ?? '',
      approfondimento: lunga ? a! : '',
    );
  }
}

/// **LA STESA CHE INTERPRETA DAVVERO.** Ordine EQ voce 04, 27 settembre 2026.
///
/// Il fondatore: *"facendo una stesa tarocchi con domanda generica, ma anche
/// con domanda specifica e personale LE RISPOSTE SONO TROPPO CRIPTICHE, SONO
/// QUASI SENZA SENSO"*, e *"una interpretazione la fa veramente o sono testi
/// buttati lì tanto per accontentare?"*. Era la seconda: il consiglio si
/// componeva da elenchi di frasi fisse scelte da un filo nato dalle tre
/// carte, e delle carte si guardava solo se fossero Maggiori o Minori, dritte
/// o capovolte. La domanda era citata e non aveva risposta.
///
/// **La via scelta.** Una chiamata sola a Flash, il modello che il fondatore
/// ha approvato (*"Sì, con Flash"*), che riceve la domanda, l'argomento, la
/// carta chiave e per ogni carta il suo significato tradizionale.
///
/// **DALL'ORDINE GA SCRIVE IL SOLO RESPONSO PRINCIPALE**, 20 ottobre 2026:
/// la decisione del fondatore "Carte dal corpus" mette le singole carte nel
/// corpus delle posizioni (titolo, paragrafo e cosa fare per carta, verso,
/// posizione e ambito), e al modello resta la cosa che solo lui sa fare:
/// rispondere alla domanda leggendo tutte le carte insieme. La forma e la
/// regola della risposta diretta gli arrivano da `LaFormaDelResponso
/// .perIlModello`, una volta sola (voce GA.07).
///
/// **IL TESTO DELLA POSIZIONE NON ARRIVA AL MODELLO**, e lo dice una
/// misura. Con lui il modello lo parafrasava e nominava appena la domanda
/// (*"riguardo a questa amicizia"*): carte lette sulla domanda 23 su 30 alla
/// sonda 13; senza, 24 su 30 alla sonda 14, cioe' la stessa cosa con meno
/// parafrasi. **Le guardie guardano a valle** quello che torna, come per il
/// Sigillo: una lettura che non regge non si mostra, e parla la lettura di
/// casa.
abstract final class LaLetturaDellaStesa {
  static const String modello = 'gemini-2.5-flash';

  /// **QUANTO SI ASPETTA**, dal tocco su "Leggi le carte", tentativi
  /// compresi. Il filo e la scena di Medora che riflette ne durano quasi
  /// cinque: la prima chiamata parte al tocco e quasi sempre arriva dentro di
  /// loro. Oltre, parla la lettura di casa.
  static const Duration pazienza = Duration(seconds: 10);

  /// **LA PAZIENZA CRESCE CON LE CARTE. Ordine FS, 13 ottobre 2026.** Dieci
  /// secondi bastano a tre carte: una chiamata ne prende circa due e mezzo.
  /// Sulla Croce Celtica la chiamata vera prende da sei a dieci secondi
  /// (misurato col modello vero, `docs/collaudo/FS/la_croce_celtica_lunga.txt`):
  /// con dieci secondi di pazienza una risposta scartata dalle guardie non
  /// aveva piu' tempo per il secondo tentativo, e parlava la lettura di casa,
  /// che i due paragrafi della Lunga non li ha. Due secondi e un quarto per
  /// ogni carta oltre la terza: dieci carte, venticinque secondi e mezzo,
  /// cioe' due tentativi interi. Fino a tre carte resta la pazienza di prima.
  ///
  /// **DALL'ORDINE GA IL MODELLO NON SCRIVE PIU' LE CARTE**, e una chiamata
  /// sulla Croce Celtica scrive quanto una a tre carte: la richiesta pero'
  /// resta piu' lunga (dieci carte col loro significato), e la misura col
  /// modello vero della forma nuova non c'e' ancora (chiede il si' del
  /// fondatore, regola SPESE). La pazienza resta quella misurata: aspettare
  /// di piu' non costa niente se la risposta arriva prima.
  static Duration pazienzaPer(int carte) => carte <= 3
      ? pazienza
      : pazienza + Duration(milliseconds: (carte - 3) * 2250);

  /// **QUANTE VOLTE SI CHIEDE LA LETTURA.** Un'altra solo se quella di prima
  /// e' tornata e le guardie l'hanno scartata, col motivo scritto nella
  /// richiesta, e solo se restano [tempoPerRitentare] della pazienza. Se la
  /// rete manca o il tempo e' finito non si ritenta: come il Sigillo.
  ///
  /// **TRE, E LO HANNO DETTO LE SONDE.** Con la forma neutra, la piu' difficile
  /// e quella di chi salta la domanda all'onboarding, due letture su dieci
  /// cadevano anche al secondo tentativo per un participio al maschile
  /// (`docs/collaudo/EQ/tarocchi/sonda_2` e `sonda_3`). Una chiamata dura
  /// intorno ai due secondi e mezzo: tre stanno quasi sempre nella pazienza.
  static const int tentativi = 3;

  /// Il tempo che deve restare perche' valga la pena ritentare.
  static const Duration tempoPerRitentare = Duration(seconds: 3);

  /// Il tempo che deve restare per riscrivere le sole frasi col genere: una
  /// richiesta breve, che torna in circa un secondo.
  static const Duration tempoPerRiscrivere = Duration(seconds: 2);

  /// **LA RICHIESTA DI RISERVA.** Ordine EQ voce 04, 27 settembre 2026: sul
  /// Realme una stesa su tre e' finita nella lettura di casa a 10.001
  /// millesimi, perche' una chiamata sola non e' tornata e si e' presa tutta
  /// la pazienza (`docs/collaudo/EQ/realme/eq04_build_eq_attesa_della_stesa.txt`).
  /// Le altre tornavano in circa quattro secondi. Se dopo [riservaDopo] la
  /// chiamata non e' tornata, ne parte una seconda uguale, e vince la prima
  /// che torna: una chiamata in piu' solo quando la prima e' lenta.
  static const Duration riservaDopo = Duration(milliseconds: 4500);

  /// Quante richieste di riserva sono partite nell'ultima lettura.
  static int ultimeRiserve = 0;

  /// La prima risposta che torna fra [chiama] e, se tarda oltre [dopo], una
  /// sua copia. Se la prima che torna e' un errore, si aspetta l'altra.
  static Future<String?> primaCheTorna(
    Future<String?> Function() chiama, {
    Duration dopo = riservaDopo,
  }) {
    final esito = Completer<String?>();
    var inVolo = 0;
    Object? ultimoErrore;
    StackTrace? ultimaTraccia;
    void parti() {
      inVolo++;
      chiama().then((testo) {
        if (!esito.isCompleted) esito.complete(testo);
      }, onError: (Object errore, StackTrace traccia) {
        ultimoErrore = errore;
        ultimaTraccia = traccia;
        inVolo--;
        if (inVolo == 0 && !esito.isCompleted) {
          esito.completeError(ultimoErrore!, ultimaTraccia);
        }
      });
    }

    parti();
    final riserva = Timer(dopo, () {
      if (esito.isCompleted) return;
      ultimeRiserve++;
      parti();
    });
    return esito.future.whenComplete(riserva.cancel);
  }

  /// **L'ISTRUZIONE DELLA RISCRITTURA.** Ordine EQ voce 04: nel giro di prova
  /// tre letture su venti, con la forma neutra, cadevano per una frase sola
  /// col genere anche al terzo tentativo. Rigenerare tutta la lettura
  /// ripeteva lo sbaglio in un'altra frase; qui si riscrivono soltanto le
  /// frasi colpevoli, tenendo il nome della carta.
  ///
  /// **LA PAROLA DA TOGLIERE SI NOMINA.** Nella prima stesura il correttore
  /// riceveva le frasi e la regola, e rimandava indietro *"sei arrivat…"* e
  /// *"restare bloccat…"* quasi uguali (sonda 12): accanto a ogni frase adesso
  /// c'e' la parola che la guardia ha trovato, e le sostituzioni tipiche.
  /// **Dall'ordine GA la frase riscritta tiene anche la sua lunghezza**: il
  /// paragrafo deve restare fra 40 e 50 parole, e la guardia lo rimisura.
  static const String istruzioneDellaRiscrittura = 'Sei un correttore di '
      'bozze italiano. Ricevi alcune frasi di una lettura dei tarocchi, '
      'rivolte a una persona col tu, che può essere un uomo o una donna. '
      'Accanto a ogni frase, fra quadre, c\'è la parola che dice se chi legge '
      'è un uomo o una donna: riscrivi la frase senza quella parola e senza '
      'nessun\'altra parola che cambierebbe fra un uomo e una donna, con un '
      'verbo attivo o un nome. Per esempio «sei arrivat… a» diventa «hai '
      'raggiunto», «rischi di restare bloccat…» diventa «rischi di non '
      'muoverti», «stare attent…» diventa «fare attenzione», «ti vede '
      'impegnat…» diventa «ti vede all\'opera», «te stess…» diventa «te». '
      'Tieni lo stesso senso, il tu, più o meno lo stesso numero di parole '
      'e, se c\'è, il nome della carta così com\'è scritto. Rispondi solo con '
      'un oggetto JSON col campo "frasi": le frasi riscritte, senza le '
      'quadre, una per riga, nello stesso ordine.';

  // **LAPIDE: I TETTI IN CARATTERI DEI PEZZI.** Dall'ordine EQ voce 04
  // all'ordine GA la lettura cadeva oltre 380 caratteri di risposta, 560 per
  // carta, 360 di legame, 260 di consiglio e 420 per ogni approfondimento
  // (ordine FN). Dall'ordine GA ogni paragrafo si misura in parole, da 40 a
  // 50 (`LaFormaDelResponso.aMisura`): fuori misura si scarta e si ripiega
  // sulla lettura di casa, mai si tronca (voce GA.07).

  /// Il tetto del titolo: da tre a otto parole, scritte grandi in cima.
  static const int tettoDelTitolo = 70;

  /// **QUANTI CARATTERI PUO' AVERE AL PIU' UN PARAGRAFO A MISURA**, per il
  /// tetto dei gettoni ([tettoDeiGettoni]): cinquanta parole a otto
  /// caratteri l'una, spazio compreso. Misurato sui 1.404 "cosa fare" del
  /// corpus delle carte, tutti fra 40 e 50 parole: il piu' lungo ha 316
  /// caratteri, la parola media piu' lunga 7,02 caratteri; otto tiene un
  /// margine del quattordici per cento su quella parola media.
  static const int caratteriDelParagrafo = LaFormaDelResponso.massimo * 8;

  /// **I CAMPI DEL SOLO RESPONSO PRINCIPALE**, nell'ordine in cui il modello
  /// li scrive: la risposta, il cosa fare, nella Lunga l'approfondimento, e
  /// il titolo per ultimo, perche' riassume la lettura. **Uguali per ogni
  /// stesa** (voce GA.05: le carte vengono dal corpus): la stesa entra solo
  /// nella richiesta. LAPIDE: un campo per carta (`passato`, `lato_1`,
  /// `copre`...) e `legame`, `consiglio`, `approfondimento1` e
  /// `approfondimento2`, dall'ordine EQ voce 04 all'ordine GA.
  static Map<String, Schema> campiPer(TarotSpread spread,
          {bool profonda = false}) =>
      {
        'risposta': Schema.string(),
        'cosaFare': Schema.string(),
        if (profonda) 'approfondimento': Schema.string(),
        'titolo': Schema.string(),
      };

  /// **COSA VUOL DIRE OGNI POSIZIONE**, detto al modello nella richiesta.
  /// Dalle glosse di Waite (The Pictorial Key to the Tarot, Parte III,
  /// sezione 7) per le posizioni della Croce Celtica, e dalle specifiche del
  /// corpus del Cerchio per le altre.
  static const Map<SpreadPosition, String> cosaDiceLaPosizione = {
    SpreadPosition.passato: 'che cosa ha portato fin qui',
    SpreadPosition.presente: 'che cosa è in gioco adesso',
    SpreadPosition.futuro: 'dove va la situazione',
    SpreadPosition.cartaSola: 'è la sola carta della stesa: risponde da sola '
        'alla domanda',
    SpreadPosition.consultante: 'chi domanda e come sta davanti alla sua '
        'questione',
    SpreadPosition.lato: 'una forza che agisce di lato sulla questione, a '
        'favore o contro',
    SpreadPosition.esito: 'dove la questione tende ad arrivare',
    SpreadPosition.copre: 'la forza che agisce sulla questione adesso',
    SpreadPosition.attraversa: 'ciò che la incrocia e le si oppone',
    SpreadPosition.corona: 'il meglio che la questione può raggiungere',
    SpreadPosition.sotto: 'il fondamento, ciò su cui la questione poggia',
    SpreadPosition.dietro: 'ciò che sta passando o è appena passato',
    SpreadPosition.seStesso: 'come chi domanda vive la sua questione',
    SpreadPosition.laCasa: 'l\'ambiente e le persone intorno alla questione',
    SpreadPosition.speranzeOTimori: 'ciò che chi domanda spera o teme',
  };

  /// L'istruzione, con la voce di Medora e le regole della lettura.
  ///
  /// La [chiave] entra come voce prima delle regole di lettura (ordine FI
  /// voce 07, spostata in cima dall'ordine FS: in fondo perdeva contro le
  /// regole della RISPOSTA e delle CARTE, e sedici letture vere non si
  /// distinguevano fra le chiavi, `docs/collaudo/FS/le_chiavi_dal_modello.txt`);
  /// la Predittiva non aggiunge niente, e l'istruzione resta quella di sempre.
  ///
  /// **DALL'ORDINE GA LA FORMA E LA RISPOSTA DIRETTA ARRIVANO DA UN PUNTO
  /// SOLO**, `LaFormaDelResponso.perIlModello` (voci GA.03, GA.06 e GA.07):
  /// qui restano la voce di Medora, le carte della stesa, le regole di
  /// prudenza e di lingua di casa e il formato del JSON. LAPIDE: le regole
  /// RISPOSTA "due frasi", LE CARTE "per ciascuna carta due o tre frasi",
  /// LEGAME, CONSIGLIO "una frase sola", TITOLO e APPROFONDIMENTO1 e 2
  /// "al massimo trecentottanta caratteri", scritte qui dall'ordine EQ voce 04
  /// all'ordine GA.
  static String istruzione(CourtesyForm forma,
          {ReadingKey chiave = ReadingKey.predittiva, bool profonda = false}) =>
      '''
Sei Medora, la Maestra dell'astrologia e della cartomanzia di Esoteric Circle. Una persona ha fatto una stesa dei Tarocchi Rider-Waite: la richiesta ti dice quante carte, in quali posizioni, che cosa vuol dire ciascuna posizione e il significato tradizionale di ogni carta nel verso in cui è uscita. Le carte una per una la persona le legge già sotto il tuo responso: tu scrivi il responso principale della stesa, la risposta alla sua domanda letta su tutte le carte insieme. Scrivi in ${LaLinguaDelModello.nome}, rivolgendoti alla persona col tu, con parole semplici e dirette, come una persona esperta e franca.

${chiave.voce == null ? '' : '${chiave.voce}\n\n'}${LaFormaDelResponso.perIlModello(arte: ArteInterpretata.tarocchi, lunga: profonda)}

COME SI LEGGE LA STESA:
- La risposta parte dalla carta chiave che ti indico e la nomina col suo nome; le altre carte le nomini quando dicono qualcosa sulla domanda, ciascuna letta nella sua posizione. Il titolo non nomina le carte.
- Un sì o un no si dice con la sua condizione e come lettura delle carte («le carte indicano di sì, se...», «le carte non mostrano un ritorno, finché...»), mai come un fatto certo o una promessa («non tornerà», «ce la farai»). Niente premesse, niente giochi di parole.
- Di un'altra persona non dire mai che cosa pensa, che cosa sente, che cosa nasconde o che cosa farà come se fosse un fatto: di' che cosa le carte mostrano di quella situazione (un ritorno, un segreto, un rapporto) come un segno e non come una certezza; poi che cosa può fare chi domanda.
- Nomina con parole tue la cosa di cui parla la domanda (l'offerta, il rapporto, i soldi per la casa, l'amore, il momento che vive): un testo che andrebbe bene per qualunque domanda non va bene.
- Niente cifre: i numeri si scrivono in lettere.
- Nelle frasi rivolte alla persona non scrivere mai queste parole: $paroleDelConfine. Se la domanda tocca uno di questi temi, parla di come la persona può affrontare la situazione, non dell'esito. La carta La Morte si scrive sempre così, con la maiuscola.
- Niente verbi al futuro, né per la persona (troverai, affronterai, tenderai, saprai, potrai) né per le cose (sarà, porterà, arriverà, accadrà). Niente «sicuramente», «senza dubbio», «è certo che», «è in arrivo»: per ciò che viene scrivi al presente, «tendi a», «puoi», «potresti», «rischi di», «la situazione tende a». Vale anche quando la domanda è al futuro («Quando diventerò padre?», «Troverò lavoro?»): non riprendere il suo verbo, rispondi con «le carte mostrano», «il momento tende a», «puoi».
- Accorda articoli, verbi, aggettivi e participi al nome della carta: «Gli Amanti indicano», «la Torre ti mostra».
${LaLinguaDelModello.ilGenereDelleCarte}
${forma.agree(masculine: '', feminine: '', neutral: senzaGenere)}
${ConfineDelResponso.perIlModello}

${IlBloccoDiCortesia.perForma(forma)}
Rispondi solo con un oggetto JSON con i campi "risposta", "cosaFare"${profonda ? ', "approfondimento"' : ''} e "titolo", in quest'ordine.''';

  /// **LE PAROLE DEL CONFINE, DETTE AL MODELLO.** Ordine EQ voce 04: la
  /// guardia a valle (`ConfineDelResponso`) scarta la frase rivolta alla
  /// persona che le contiene, e nel primo giro del collaudo la prima lettura
  /// e' caduta cosi'. Ogni radice di `ConfineDelResponso.temiDelicati` sta
  /// dentro una di queste parole, e la prova lo pretende.
  static const String paroleDelConfine = 'malattia, diagnosi, guarigione, '
      'morire, morte, gravidanza, incinta, divorzio, tribunale, processo '
      'penale, eredità, licenziato, licenziamento, investimenti, mutuo';

  /// **Gli esempi sono radici tronche**, *"sei passat…"*: la guardia
  /// `il_genere_non_si_indovina` legge ogni stringa di `lib`, e una forma
  /// intera qui dentro sembrerebbe detta a chi legge. Il modello le capisce
  /// lo stesso.
  ///
  /// **LA RIGA PER CHI NON HA SCELTO UNA FORMA, PER COSTRUZIONE.** Nel primo
  /// giro del collaudo due letture su tre sono cadute per *"sei passato"* e
  /// *"impegnato"*; con un elenco di esempi, nelle due sonde dopo, per *"te
  /// stesso"*, *"ti sei dedicato"* ed *"essere solo"*: il modello scivola sul
  /// maschile ogni volta che un verbo di stato regge un aggettivo o un
  /// participio. La regola quindi nomina la costruzione, come i controlli con
  /// cui e' stato scritto il corpus delle carte nella posizione. Il blocco di
  /// cortesia resta la regola; qui c'e' come si rispetta in una stesa.
  static const String senzaGenere = '- Chi legge può essere un uomo o una '
      'donna. Nelle frasi su chi legge non scrivere mai essere, sentirsi, '
      'restare, rimanere, stare o diventare seguiti da un aggettivo o da un '
      'participio («sei passat…», «ti sei dedicat…», «essere sol…», '
      '«sentirti pront…»), né «te stess…», «entramb…». Il passato si '
      'scrive con avere: «hai attraversato», «hai dedicato tempo», «hai '
      'trovato», non «sei andat…» o «sei riuscit…»; anche i riflessivi: «hai '
      'preso le distanze», non «ti sei allontanat…». Per uno stato scrivi un '
      'verbo attivo o un nome: «ti manca compagnia», «hai quello che serve», '
      '«c\'è calma fra voi».';

  /// La richiesta: la domanda, l'argomento, la carta chiave e le carte,
  /// ciascuna con la sua posizione e il suo significato tradizionale.
  /// [scartataPerche] e' il motivo per cui la lettura di prima non si e'
  /// potuta mostrare.
  ///
  /// **DALL'ORDINE GA OGNI STESA DICE LE SUE POSIZIONI**, anche quella a tre
  /// carte, e nessuna carta ha piu' un campo suo (LAPIDE: la riga "Campo:"
  /// dell'ordine FK aggiunta 2 voce A9): il modello legge le carte insieme e
  /// scrive il solo responso principale.
  static String richiesta(TarotSpread spread,
      {required String domanda,
      required String argomento,
      TarotTopicGroup? gruppo,
      ReadingKey chiave = ReadingKey.predittiva,
      String? scartataPerche}) {
    final righe = <String>[
      'Domanda della persona: $domanda',
      'Argomento: $argomento',
      // **LA CARTA CHIAVE E' QUELLA DELLA SCHERMATA**: la risposta parte da
      // lei, e la bolla che porta "LA CHIAVE" e' la stessa.
      'Carta chiave: ${TarotReading.chiaveDi(spread, domandaScritta: domanda).drawn.displayName}',
      'Stesa: ${spread.cards.length} '
          '${spread.cards.length == 1 ? 'carta' : 'carte'}',
    ];
    for (var i = 0; i < spread.cards.length; i++) {
      final d = spread.cards[i];
      righe
        ..add('')
        ..add('${d.position.etichetta.toUpperCase()}: ${d.displayName}')
        ..add('La posizione vuol dire: '
            '${cosaDiceLaPosizione[d.position] ?? d.position.etichetta}')
        ..add('Significato tradizionale: ${d.meaning}');
      // **IL REGISTRO ARRIVA AL MODELLO, lo scheletro no** (ordine FI,
      // aggiunta A3; decisione dell'Architetto, ordine FJ voce 23). Il
      // registro dice di che cosa parla la carta nell'ambito della domanda
      // e il modello lo usa come taglio; lo scheletro della posizione resta
      // alla lettura di casa, perche' nelle sonde 13 e 14 dell'ordine EQ il
      // modello lo parafrasava invece di leggere la carta sulla domanda.
      // **Si rivede solo con la misura appaiata dell'ordine FJ voce 24**:
      // le due condizioni nello stesso giro, sulle stesse domande, giudicate
      // alla cieca e bilanciate; due giri separati ballano di nove punti.
      final registro =
          gruppo == null ? null : LeCarteNellaPosizione.registroDi(d, gruppo);
      if (registro != null) {
        righe.add('In ${gruppo!.label.toLowerCase()} parla di: $registro');
      }
    }
    // **LA CHIAVE ANCHE QUI, accanto alle carte. Ordine FS.** Nell'istruzione
    // la voce della chiave sta in cima; letta di nuovo dopo le carte, dove il
    // modello scrive, la chiave Riflessione e l'Archetipica smettono di
    // comparire a giri alterni (`docs/collaudo/FS/le_chiavi_dal_modello.txt`).
    final promemoria = chiave.promemoria;
    if (promemoria != null) {
      righe
        ..add('')
        ..add(promemoria);
    }
    if (scartataPerche != null) {
      righe
        ..add('')
        ..add('La lettura che hai scritto prima non si può mostrare: '
            '$scartataPerche. Riscrivila tutta senza questo difetto e '
            'senza nessun altro dello stesso tipo.');
      // **IL GENERE SI RIPETE PER INTERO**: nelle sonde il modello correggeva
      // la frase indicata e sbagliava la successiva, e con una domanda che
      // nomina "il mio compagno" o "la mia amica" dava per scontato chi
      // scrive. La regola torna tutta, non solo la frase.
      if (scartataPerche.startsWith(motivoDelGenere)) {
        righe.add('Chi legge può essere un uomo o una donna, anche se la '
            'domanda nomina un compagno o un\'amica: nessun participio e '
            'nessun aggettivo riferito a chi legge, in nessuna frase.');
      }
    }
    return righe.join('\n');
  }

  /// **LA LETTURA, o null se non arriva o non regge.** Null vuol dire che
  /// parla la lettura di casa: la schermata non resta mai senza testo.
  static Future<LetturaDelModello?> leggi({
    required TarotSpread spread,
    required String domanda,
    required String argomento,
    required CourtesyForm forma,
    TarotTopicGroup? gruppo,
    ReadingKey chiave = ReadingKey.predittiva,
    ChiamataDellaStesa? chiamata,
    Duration? entro,
    // **LA PROFONDITA' LUNGA CHIEDE IL PARAGRAFO IN PIU'. Ordine FN, 13
    // ottobre 2026, e ordine GA voce GA.03 (un approfondimento solo, il rito
    // viene dal corpus).** Falso di default: ogni chiamata gia' scritta
    // (prove, strumenti) resta la lettura breve.
    bool profonda = false,
  }) async {
    // **LA STESA LEGGE IL FILO E CI SCRIVE. Ordine FE voce 08.** Era una
    // delle strade che non usavano la memoria del consulto
    // (docs/collaudo/FE/fe08_le_strade_verso_un_maestro.md, strada 14): una
    // stesa dopo una domanda a Calìgo non sapeva cosa le aveva detto.
    final lettura = await _leggi(
        spread: spread,
        domanda: domanda,
        argomento: argomento,
        forma: forma,
        gruppo: gruppo,
        chiave: chiave,
        chiamata: chiamata,
        entro: entro,
        profonda: profonda);
    if (lettura != null) {
      IlFiloDelConsulto.annota(
          maestro: Maestro.medora,
          domanda: domanda,
          risposta: '${lettura.risposta}\n'
              '${ConsiglioFinale.stella} ${lettura.cosaFare}');
    }
    return lettura;
  }

  static Future<LetturaDelModello?> _leggi({
    required TarotSpread spread,
    required String domanda,
    required String argomento,
    required CourtesyForm forma,
    TarotTopicGroup? gruppo,
    ReadingKey chiave = ReadingKey.predittiva,
    ChiamataDellaStesa? chiamata,
    Duration? entro,
    bool profonda = false,
  }) async {
    final tetto = entro ?? pazienzaPer(spread.cards.length);
    final cronometro = Stopwatch()..start();
    String? scartataPerche;
    LetturaDelModello? daCurare;
    ultimiTentativi = 0;
    ultimeRiserve = 0;
    ultimeRiscritture = 0;
    ultimiScarti.clear();
    ultimaCurata = false;
    ultimaRiscritta = false;
    for (var tentativo = 0; tentativo < tentativi; tentativo++) {
      final resta = tetto - cronometro.elapsed;
      if (tentativo > 0 && resta < tempoPerRitentare) break;
      ultimiTentativi = tentativo + 1;
      String? testo;
      try {
        final perQuesta = scartataPerche;
        testo = await primaCheTorna(
          () => (chiamata ?? _chiamataVera)(
            IlFiloDelConsulto.conIlFilo(
                istruzione(forma, chiave: chiave, profonda: profonda),
                Maestro.medora,
                domanda,
                argomento: argomento),
            richiesta(spread,
                domanda: domanda,
                argomento: argomento,
                gruppo: gruppo,
                chiave: chiave,
                scartataPerche: perQuesta),
            campiPer(spread, profonda: profonda),
          ),
        ).timeout(resta);
      } catch (errore) {
        // Rete assente, tempo scaduto, servizio spento: non si ritenta, e
        // se nessuna lettura di prima si puo' curare parla quella di casa.
        // L'errore non si nasconde a chi guarda il registro.
        ultimoScarto = 'la chiamata non è tornata: $errore';
        ultimiScarti.add(ultimoScarto!);
        break;
      }
      final grezza = LetturaDelModello.daJson(_json(testo), lunga: profonda);
      if (grezza == null) {
        scartataPerche = 'la risposta non porta tutti i pezzi';
        ultimoScarto = scartataPerche;
        ultimiScarti.add(scartataPerche);
        continue;
      }
      final lettura = grezza.ripulita();
      final motivo = scarto(lettura, spread, forma: forma);
      if (motivo == null) {
        ultimoScarto = null;
        return lettura;
      }
      if (motivo.startsWith(motivoDelGenere)) {
        daCurare = lettura;
        // **PRIMA DI RIGENERARE, SI RISCRIVE.** Se il solo difetto e' il
        // genere, una richiesta breve riscrive le frasi che lo danno; se la
        // lettura riscritta regge, e' quella. Altrimenti si ritenta.
        final perRiscrivere = tetto - cronometro.elapsed;
        if (perRiscrivere >= tempoPerRiscrivere) {
          ultimeRiscritture++;
          final riscritta = await _riscriviIlGenere(
              lettura, forma, chiamata ?? _chiamataVera, perRiscrivere);
          if (riscritta != null) {
            final dopo = scarto(riscritta, spread, forma: forma);
            if (dopo == null) {
              ultimoScarto = null;
              ultimaRiscritta = true;
              return riscritta;
            }
            ultimiScarti.add('dopo la riscrittura: $dopo');
            if (dopo.startsWith(motivoDelGenere)) daCurare = riscritta;
          }
        }
      }
      scartataPerche = motivo;
      ultimoScarto = motivo;
      ultimiScarti.add(motivo);
    }
    // **L'ULTIMA CURA**, quando i tentativi sono finiti: dall'ultima lettura
    // caduta per il genere si tolgono le frasi che lo danno, e se cio' che
    // resta passa tutte le guardie si mostra. Nel primo giro del collaudo
    // una lettura su otto, con la forma neutra, cadeva per una frase sola,
    // e al suo posto arrivava la lettura di casa, quella che il fondatore ha
    // chiamato criptica.
    final curata =
        daCurare == null ? null : senzaLeFrasiColGenere(daCurare, forma);
    if (curata != null && scarto(curata, spread, forma: forma) == null) {
      ultimoScarto = null;
      ultimaCurata = true;
      return curata;
    }
    return null;
  }

  /// **LA RISCRITTURA DELLE SOLE FRASI COL GENERE.** Nulla se non c'e' niente
  /// da riscrivere, se la chiamata non torna o se torna un numero di frasi
  /// diverso: in quei casi si va avanti coi tentativi.
  static Future<LetturaDelModello?> _riscriviIlGenere(LetturaDelModello l,
      CourtesyForm forma, ChiamataDellaStesa chiamata, Duration entro) async {
    final pezzi = l.toJson();
    final daRiscrivere = <String>[
      for (final pezzo in pezzi.values)
        for (final frase in pezzo.split(RegExp(r'(?<=[.!?])\s+')))
          if (formeContrarieAllaForma(frase, forma).isNotEmpty) frase,
    ];
    if (daRiscrivere.isEmpty) return null;
    String? testo;
    try {
      testo = await chiamata(
        istruzioneDellaRiscrittura,
        [
          for (final f in daRiscrivere)
            '- $f [${formeContrarieAllaForma(f, forma).join(', ')}]',
        ].join('\n'),
        {'frasi': Schema.string()},
      ).timeout(entro);
    } catch (errore) {
      ultimiScarti.add('la riscrittura non è tornata: $errore');
      return null;
    }
    final righe = (_json(testo)?['frasi'] as String?)
        ?.split('\n')
        .map((r) => r
            .trim()
            .replaceFirst(RegExp(r'^[-•]\s*'), '')
            // Se il correttore rimanda anche la quadra, si toglie.
            .replaceFirst(RegExp(r'\s*\[[^\]]*\]$'), ''))
        .where((r) => r.isNotEmpty)
        .toList();
    if (righe == null || righe.length != daRiscrivere.length) return null;
    var nuovi = Map<String, Object?>.from(pezzi);
    for (var i = 0; i < daRiscrivere.length; i++) {
      nuovi = nuovi.map((k, v) =>
          MapEntry(k, (v as String).replaceFirst(daRiscrivere[i], righe[i])));
    }
    return LetturaDelModello.daJson(nuovi, lunga: l.approfondimento.isNotEmpty)
        ?.ripulita();
  }

  /// **LE FRASI COL GENERE SI TOLGONO**, ordine EQ voce 04: la regola di
  /// casa, *"dove un testo si puo' togliere, si toglie"*, e la stessa mano
  /// di `LaRispostaRipulita`, che toglie le frasi fatte. Mai dalla risposta,
  /// che e' la risposta alla domanda: se il genere sta li', nulla. Nulla
  /// anche se un pezzo resta vuoto.
  ///
  /// **TOGLIERE UNA FRASE NON DEVE ROMPERE LA MISURA**, ordine GA voce
  /// GA.07: un paragrafo a cui si toglie una frase puo' scendere sotto le
  /// quaranta parole. La lettura curata non si mostra per questo: chi la
  /// chiama la ripassa da [scarto], che rimisura ogni paragrafo in parole e la
  /// scarta se un paragrafo e' uscito dalla misura (parla la lettura di
  /// casa). Mai si tronca e mai si allunga a mano.
  static LetturaDelModello? senzaLeFrasiColGenere(
      LetturaDelModello l, CourtesyForm forma) {
    if (formeContrarieAllaForma(l.risposta, forma).isNotEmpty) return null;
    String? senza(String pezzo) {
      final tenute = [
        for (final frase in pezzo.split(RegExp(r'(?<=[.!?])\s+')))
          if (formeContrarieAllaForma(frase, forma).isEmpty) frase,
      ];
      final t = tenute.join(' ').trim();
      return t.isEmpty ? null : t;
    }

    final cosaFare = senza(l.cosaFare);
    if (cosaFare == null) return null;
    // **IL PARAGRAFO DELLA LUNGA PASSA DALLA CURA. Ordine FS.** Prima la
    // lettura curata nasceva senza, e la Lunga arrivava a video senza i suoi
    // paragrafi: misurato col modello vero sulla Croce Celtica, una lettura
    // Lunga su due (`docs/collaudo/FS/la_croce_celtica_lunga.txt`).
    // PROVENIENZA: ordine FN voce 01, che aveva aggiunto i campi e non li
    // aveva portati qui.
    final approfondimento =
        l.approfondimento.isEmpty ? '' : senza(l.approfondimento);
    if (approfondimento == null) return null;
    return LetturaDelModello(
      risposta: l.risposta,
      cosaFare: cosaFare,
      // Il titolo col genere non si cura: si toglie: parla quello di casa.
      titolo: formeContrarieAllaForma(l.titolo, forma).isEmpty ? l.titolo : '',
      approfondimento: approfondimento,
    );
  }

  /// Vero se l'ultima lettura mostrata e' passata dall'ultima cura, per il
  /// registro.
  static bool ultimaCurata = false;

  /// Vero se l'ultima lettura mostrata ha avuto le frasi col genere
  /// riscritte, e quante riscritture ha chiesto: per il registro.
  static bool ultimaRiscritta = false;
  static int ultimeRiscritture = 0;

  /// Perche' l'ultima lettura non e' stata mostrata, per il registro.
  static String? ultimoScarto;

  /// L'inizio del motivo quando la guardia trova un genere dato a chi legge:
  /// il tentativo dopo ripete la regola per intero.
  static const String motivoDelGenere = 'un genere dato a chi legge';

  /// Quante chiamate ha fatto l'ultima lettura, per il registro.
  static int ultimiTentativi = 0;

  /// I motivi di ogni tentativo scartato dell'ultima lettura, in ordine.
  static final List<String> ultimiScarti = [];

  /// **LE GUARDIE DELLA LETTURA.** Null se regge, altrimenti il motivo.
  ///
  /// Si guarda cio' che si puo' guardare a macchina: la misura in parole di
  /// ogni paragrafo, il titolo, una carta della stesa nominata, niente cifre
  /// e niente trattino lungo, il confine del responso su ogni pezzo, e nessun
  /// genere dato a chi legge contro la forma che ha scelto
  /// (`formeContrarieAllaForma`, la stessa porta dei testi del Viaggio). Il
  /// resto, se la lettura risponde e se interpreta, lo misurano i lettori
  /// ciechi della voce GA.06 e, col si' del fondatore, il collaudo con Gemini
  /// vero.
  static String? scarto(LetturaDelModello l, TarotSpread spread,
      {CourtesyForm forma = CourtesyForm.unknown}) {
    // **LA MISURA IN PAROLE, ordine GA voci GA.03 e GA.07.** Ogni paragrafo
    // da 40 a 50 parole, contate come le conta chi legge: fuori misura la
    // lettura si scarta col motivo e il numero (il tentativo dopo lo legge),
    // mai si tronca. LAPIDE: i tetti in caratteri dall'ordine EQ voce 04.
    String? fuoriMisura(String nome, String testo) {
      if (LaFormaDelResponso.aMisura(testo)) return null;
      return '$nome ha ${LaFormaDelResponso.parole(testo)} parole, ne servono '
          'da ${LaFormaDelResponso.minimo} a ${LaFormaDelResponso.massimo}';
    }

    final misura = fuoriMisura('la risposta', l.risposta) ??
        fuoriMisura('il cosa fare', l.cosaFare) ??
        (l.approfondimento.isEmpty
            ? null
            : fuoriMisura('l\'approfondimento', l.approfondimento));
    if (misura != null) return misura;
    // **IL TITOLO SI GUARDA, quando c'e'.** Collaudo dell'ordine FK
    // aggiunta voce A1 (docs/collaudo/FK/il_titolo_dal_modello_giro_1.txt):
    // una lettura su quattro titolava "Vendita casa: lascio andare o resto",
    // coi due punti che l'istruzione vietava e in prima persona. Un titolo
    // vuoto non fa cadere la lettura (parla quello di casa); uno sbagliato
    // si fa riscrivere, perche' il titolo di casa non conosce la risposta
    // del modello e potrebbe contraddirla.
    if (l.titolo.length > tettoDelTitolo) return 'titolo troppo lungo';
    if (RegExp(r'[:?]').hasMatch(l.titolo)) {
      return 'il titolo ha i due punti o il punto di domanda';
    }
    for (final d in spread.cards) {
      if (l.titolo.isNotEmpty && nominaLaCarta(l.titolo, d.card.name)) {
        return 'il titolo nomina ${d.card.name}';
      }
    }
    // **LA RISPOSTA POGGIA SULLE CARTE USCITE**, voce GA.06: il responso
    // principale nomina almeno una carta della stesa (l'istruzione chiede la
    // carta chiave). LAPIDE: dall'ordine EQ voce 04 ogni testo di carta
    // doveva nominare la sua; dall'ordine GA le carte vengono dal corpus.
    if (!spread.cards.any(
        (d) => nominaLaCarta('${l.risposta} ${l.cosaFare}', d.card.name))) {
      return 'il responso non nomina nessuna carta della stesa';
    }
    for (final pezzo in l.toJson().values) {
      if (RegExp(r'\d').hasMatch(pezzo)) return 'una cifra nella lettura';
      if (pezzo.contains('\u2014') || pezzo.contains('\u2013')) {
        return 'un trattino lungo nella lettura';
      }
      final fuori = ConfineDelResponso.violazioni(pezzo);
      if (fuori.isNotEmpty) {
        return 'fuori dal confine: ${fuori.first.regola} '
            '("${fuori.first.trovato}")';
      }
      final genere = formeContrarieAllaForma(pezzo, forma);
      if (genere.isNotEmpty) {
        // La frase intera, e non la sola parola: la legge il modello nel
        // tentativo dopo, e la legge chi guarda il registro.
        return '$motivoDelGenere: ${genere.first}, nella frase '
            '«${fraseCon(pezzo, genere.first)}»';
      }
    }
    return null;
  }

  /// La frase di [testo] che contiene [parola], o il testo intero se non la
  /// trova: le frasi finiscono col punto, l'interrogativo o l'esclamativo.
  static String fraseCon(String testo, String parola) {
    for (final frase in testo.split(RegExp(r'(?<=[.!?])\s+'))) {
      if (frase.contains(parola)) return frase.trim();
    }
    return testo.trim();
  }

  /// Vero se [testo] nomina la carta [nome], con o senza il suo articolo.
  static bool nominaLaCarta(String testo, String nome) {
    final senzaArticolo =
        nome.replaceFirst(RegExp(r"^(Il |Lo |La |Le |Gli |I |L'|L’)"), '');
    return testo.toLowerCase().contains(senzaArticolo.toLowerCase());
  }

  static Map<String, Object?>? _json(String? testo) {
    if (testo == null) return null;
    try {
      final j = jsonDecode(testo);
      return j is Map ? j.cast<String, Object?>() : null;
    } catch (errore) {
      // Un JSON rotto vale come nessuna risposta: parla la lettura di casa.
      return null;
    }
  }

  /// **IL TETTO SALE CON LE CARTE, NON SOLO CON LA LUNGA.** Ordine FR voce
  /// 03, 13 ottobre 2026. Il fondatore, a video sulla Croce Celtica: scelta
  /// la profondita' Lunga, i due paragrafi dell'approfondimento non
  /// arrivavano mai. Il tetto di 2000 gettoni (ordine FN) bastava per la
  /// stesa a tre carte, dove l'ordine FN lo aveva provato: risposta, legame,
  /// consiglio, titolo e tre testi di carta restano sotto i mille gettoni
  /// visibili, e ne restava la meta' per i due paragrafi. Sulla Croce
  /// Celtica le carte sono dieci, non tre: i loro testi da soli chiedono
  /// quasi quattromila caratteri, e il modello finisce il tetto PRIMA di
  /// arrivare ai due campi che la richiesta mette per ultimi
  /// nell'ordinamento (`campiPer`), approfondimento1 e approfondimento2:
  /// restano vuoti, non per un rifiuto, per mancanza di spazio.
  ///
  /// **IL TETTO DALLA MISURA NUOVA, ordine GA voce GA.07.** Dall'ordine GA
  /// il modello scrive il solo responso principale, uguale per ogni stesa:
  /// due paragrafi nella Breve, tre nella Lunga, e il titolo. Il tetto e' la
  /// somma dei caratteri che quei campi possono avere al piu'
  /// ([caratteriDelParagrafo] per paragrafo, [tettoDelTitolo] per il titolo),
  /// piu' venti caratteri a campo per le chiavi e le virgolette del JSON, a
  /// DUE caratteri per gettone: l'italiano ne fa circa quattro, e il doppio
  /// del margine serve perche' un paragrafo fuori misura arrivi intero e si
  /// scarti col suo motivo, invece di arrivare troncato come un JSON rotto.
  /// Il ragionamento del modello e' a zero (`LaDomandaCapita.ragionamentoPer`)
  /// e non entra nel conto.
  ///
  /// LAPIDE: dall'ordine FR voce 03 all'ordine GA il tetto saliva con le
  /// carte (dieci testi di carta sulla Croce Celtica) e non scendeva mai
  /// sotto 1.400 gettoni, o 2.000 nella Lunga.
  static int tettoDeiGettoni(Map<String, Schema> campi,
      {required bool profonda}) {
    final paragrafi = campi.keys.where((k) => k != 'titolo').length;
    final caratteri = paragrafi * caratteriDelParagrafo +
        (campi.containsKey('titolo') ? tettoDelTitolo : 0) +
        campi.length * 20;
    return (caratteri / 2).ceil();
  }

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta, Map<String, Schema> campi) async {
    // **IL TETTO SALE CON L'APPROFONDIMENTO.** Ordine FN, 13 ottobre 2026: il
    // paragrafo in piu' della Lunga si scrive DAVVERO solo se c'e' posto per
    // scriverlo. Si deduce dalla stessa mappa dei campi che va allo schema,
    // non da un parametro in piu' su questa firma: e' la stessa che le prove
    // passano con la loro `chiamata` finta.
    final profonda = campi.containsKey('approfondimento');
    final m =
        FirebaseAI.vertexAI(location: LaRegioneDeiDati.regione).generativeModel(
      model: modello,
      httpClient: ClientConEtichetta(LeFunzioniDelModello.letturaTarocchi),
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: tettoDeiGettoni(campi, profonda: profonda),
        thinkingConfig: LaDomandaCapita.ragionamentoPer(modello),
        responseMimeType: 'application/json',
        // **I CAMPI NEL LORO ORDINE**: senza, il modello li scrive in ordine
        // alfabetico, cioe' il consiglio per primo e la risposta per ultima,
        // e la lettura si costruisce al contrario di come si legge.
        responseSchema: Schema.object(
            properties: campi, propertyOrdering: campi.keys.toList()),
      ),
    );
    final r = await m.generateContent([Content.text(richiesta)]);
    return r.text;
  }
}

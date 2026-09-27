import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../chat/il_blocco_di_cortesia.dart';
import '../chat/la_risposta_ripulita.dart';
import '../chat/le_forme_del_genere.dart';
import '../chat/user_profile.dart';
import '../config/la_regione_dei_dati.dart';
import '../l10n/la_lingua_del_modello.dart';
import '../responsi/confine_del_responso.dart';
import '../viaggio/la_domanda_capita.dart';
import 'tarot_reading.dart';
import 'tarot_spread.dart';

/// La firma di una chiamata al modello: l'istruzione e la richiesta, la
/// risposta come testo JSON. Le prove ne passano una finta.
typedef ChiamataDellaStesa = Future<String?> Function(
    String istruzione, String richiesta, Map<String, Schema> campi);

/// **LA LETTURA SCRITTA DAL MODELLO**, un pezzo per ogni cosa che la persona
/// deve trovare: la risposta, le tre carte nella loro posizione, il legame e
/// il consiglio.
class LetturaDelModello {
  const LetturaDelModello({
    required this.risposta,
    required this.passato,
    required this.presente,
    required this.futuro,
    required this.legame,
    required this.consiglio,
  });

  /// Le prime due frasi: rispondono alla domanda.
  final String risposta;
  final String passato;
  final String presente;
  final String futuro;

  /// Come le tre carte si legano fra loro.
  final String legame;

  /// Il passo concreto.
  final String consiglio;

  /// Il testo della carta in [posizione].
  String della(SpreadPosition posizione) => switch (posizione) {
        SpreadPosition.passato => passato,
        SpreadPosition.presente => presente,
        SpreadPosition.futuro => futuro,
      };

  /// **OGNI PEZZO PASSA DALLE REGOLE DI LINGUA DI CASA**, come le risposte
  /// dei Maestri (`LaRispostaRipulita`): il trattino lungo e la virgola
  /// seguita da "e" si correggono, invece di buttare una lettura buona per
  /// una virgola.
  LetturaDelModello ripulita() => LetturaDelModello(
        risposta: LaRispostaRipulita.applica(risposta),
        passato: LaRispostaRipulita.applica(passato),
        presente: LaRispostaRipulita.applica(presente),
        futuro: LaRispostaRipulita.applica(futuro),
        legame: LaRispostaRipulita.applica(legame),
        consiglio: LaRispostaRipulita.applica(consiglio),
      );

  Map<String, String> toJson() => {
        'risposta': risposta,
        'passato': passato,
        'presente': presente,
        'futuro': futuro,
        'legame': legame,
        'consiglio': consiglio,
      };

  /// Null se manca un pezzo: una lettura a meta' non si mostra.
  static LetturaDelModello? daJson(Map<String, Object?>? j) {
    if (j == null) return null;
    String? pezzo(String k) {
      final v = j[k];
      if (v is! String) return null;
      final t = v.trim();
      return t.isEmpty ? null : t;
    }

    final r = pezzo('risposta');
    final pa = pezzo('passato');
    final pr = pezzo('presente');
    final fu = pezzo('futuro');
    final le = pezzo('legame');
    final co = pezzo('consiglio');
    if (r == null ||
        pa == null ||
        pr == null ||
        fu == null ||
        le == null ||
        co == null) {
      return null;
    }
    return LetturaDelModello(
      risposta: r,
      passato: pa,
      presente: pr,
      futuro: fu,
      legame: le,
      consiglio: co,
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
/// carta chiave e per ogni carta il suo significato tradizionale, e scrive la
/// lettura intera: la risposta, le tre carte lette nella posizione e rispetto
/// alla domanda, il legame, il consiglio.
///
/// **IL TESTO DELLA POSIZIONE NON ARRIVA PIU' AL MODELLO**, e lo dice una
/// misura. Con lui il modello lo parafrasava e nominava appena la domanda
/// (*"riguardo a questa amicizia"*): carte lette sulla domanda 23 su 30 alla
/// sonda 13; senza, 24 su 30 alla sonda 14, cioe' la stessa cosa con meno
/// parafrasi. Resta alla lettura di casa, dove sotto ogni carta si legge lui. **Le guardie guardano a valle**
/// quello che torna, come per il Sigillo: una lettura che non regge non si
/// mostra, e parla la lettura di casa.
abstract final class LaLetturaDellaStesa {
  static const String modello = 'gemini-2.5-flash';

  /// **QUANTO SI ASPETTA**, dal tocco su "Leggi le carte", tentativi
  /// compresi. Il filo e la scena di Medora che riflette ne durano quasi
  /// cinque: la prima chiamata parte al tocco e quasi sempre arriva dentro di
  /// loro. Oltre, parla la lettura di casa.
  static const Duration pazienza = Duration(seconds: 10);

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
  /// col genere anche al terzo tentativo, e quella frase era spesso la stessa
  /// che nominava la carta: togliendola, la carta restava senza nome.
  /// Rigenerare tutta la lettura ripeteva lo sbaglio in un'altra frase; qui
  /// si riscrivono soltanto le frasi colpevoli, tenendo il nome della carta.
  ///
  /// **LA PAROLA DA TOGLIERE SI NOMINA.** Nella prima stesura il correttore
  /// riceveva le frasi e la regola, e rimandava indietro *"sei arrivat…"* e
  /// *"restare bloccat…"* quasi uguali (sonda 12): accanto a ogni frase adesso
  /// c'e' la parola che la guardia ha trovato, e le sostituzioni tipiche.
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
      'Tieni lo stesso senso, il tu e, se c\'è, il nome della carta così '
      'com\'è scritto. Rispondi solo con un oggetto JSON col campo "frasi": '
      'le frasi riscritte, senza le quadre, una per riga, nello stesso '
      'ordine.';

  /// I tetti dei pezzi, in caratteri: sopra, la lettura non si mostra.
  static const int tettoDellaRisposta = 380;
  static const int tettoDellaCarta = 560;
  static const int tettoDelLegame = 360;
  static const int tettoDelConsiglio = 260;

  /// I campi che il modello deve restituire, tutti obbligatori.
  static final Map<String, Schema> campi = {
    'risposta': Schema.string(),
    'passato': Schema.string(),
    'presente': Schema.string(),
    'futuro': Schema.string(),
    'legame': Schema.string(),
    'consiglio': Schema.string(),
  };

  /// L'istruzione, con la voce di Medora e le regole della lettura.
  static String istruzione(CourtesyForm forma) => '''
Sei Medora, la Maestra dell'astrologia e della cartomanzia di Esoteric Circle. Una persona ha fatto una stesa di tre carte dei Tarocchi Rider-Waite, nelle posizioni passato, presente e futuro. Leggila in ${LaLinguaDelModello.nome}, rivolgendoti alla persona col tu, con parole semplici e dirette, come una persona esperta e franca.

COME SI LEGGE:
- RISPOSTA: due frasi. La prima risponde alla domanda in modo diretto: se chiede se una cosa accadrà o se farla, dice che cosa indicano le carte, sì, no o a quali condizioni; se chiede che cosa fare o come farlo, dice il gesto concreto da fare, con chi o quando, mai un atteggiamento; se la domanda è un argomento generale, dice in concreto che cosa le carte mostrano della sua situazione in quell'ambito. La seconda dice perché, partendo dalla carta chiave che ti indico. Un sì o un no si dice con la sua condizione e come lettura delle carte («le carte indicano di sì, se...», «le carte non mostrano un ritorno, finché...»), mai come un fatto certo o una promessa («non tornerà», «ce la farai»). Niente premesse, niente giochi di parole.
- Di un'altra persona non dire mai che cosa pensa, che cosa sente, che cosa nasconde o che cosa farà come se fosse un fatto: di' che cosa le carte mostrano di quella situazione (un ritorno, un segreto, un rapporto) come un segno e non come una certezza; poi che cosa può fare chi domanda. Vale anche per ogni carta: ognuna dice che cosa mostra di quella situazione.
- PASSATO, PRESENTE, FUTURO: per ciascuna carta due o tre frasi. Nomina la carta col suo nome. Parti dal suo significato tradizionale, che ti do: leggila nella sua posizione (che cosa ha portato fin qui, che cosa è in gioco adesso, dove va la situazione) e sempre rispetto alla domanda della persona. In ogni carta nomina con parole tue la cosa di cui parla la domanda (l'offerta, il rapporto, i soldi per la casa, l'amore, il momento che vive) e di' che cosa la carta indica su quella cosa: un testo che andrebbe bene per qualunque domanda non va bene. Il testo di ogni carta risponde anch'esso alla domanda, dal suo punto: che cosa ha portato fin qui, che cosa è in gioco adesso o dove va, proprio per quello che la persona ha chiesto.
- LEGAME: una o due frasi su come le tre carte si legano fra loro: una causa, un passaggio, un contrasto.
- CONSIGLIO: una frase sola, un passo concreto che la persona può fare, con un momento o un modo definiti.
- Niente frasi che andrebbero bene per qualunque stesa. Nessuna previsione data per certa, nessuna promessa su salute, denaro, leggi, gravidanza o morte. Niente cifre: i numeri si scrivono in lettere.
- Nelle frasi rivolte alla persona non scrivere mai queste parole: $paroleDelConfine. Se la domanda tocca uno di questi temi, parla di come la persona può affrontare la situazione, non dell'esito. La carta La Morte si scrive sempre così, con la maiuscola.
- Niente verbi al futuro, né per la persona (troverai, affronterai, tenderai, saprai, potrai) né per le cose (sarà, porterà, arriverà, accadrà). Niente «sicuramente», «senza dubbio», «è certo che», «è in arrivo»: per ciò che viene scrivi al presente, «tendi a», «puoi», «potresti», «rischi di», «la situazione tende a».
- Accorda articoli, verbi, aggettivi e participi al nome della carta: «Gli Amanti indicano», «la Torre ti mostra».
${LaLinguaDelModello.ilGenereDelleCarte}
${forma.agree(masculine: '', feminine: '', neutral: senzaGenere)}
${ConfineDelResponso.perIlModello}

${IlBloccoDiCortesia.perForma(forma)}
Rispondi solo con un oggetto JSON con i campi "risposta", "passato", "presente", "futuro", "legame" e "consiglio".''';

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

  /// La richiesta: la domanda, l'argomento, la carta chiave e le tre carte,
  /// ciascuna col suo significato tradizionale. [scartataPerche] e' il motivo
  /// per cui la lettura di prima non si e' potuta mostrare.
  static String richiesta(TarotSpread spread,
      {required String domanda,
      required String argomento,
      String? scartataPerche}) {
    final righe = <String>[
      'Domanda della persona: $domanda',
      'Argomento: $argomento',
      // **LA CARTA CHIAVE E' QUELLA DELLA SCHERMATA**: la seconda frase della
      // risposta parte da lei, e la bolla che porta "LA CHIAVE" e' la stessa.
      'Carta chiave: ${TarotReading.chiaveDi(spread).drawn.displayName}',
    ];
    for (final d in [spread.passato, spread.presente, spread.futuro]) {
      righe
        ..add('')
        ..add('${d.position.label.toUpperCase()}: ${d.displayName}')
        ..add('Significato tradizionale: ${d.meaning}');
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
    ChiamataDellaStesa? chiamata,
    Duration? entro,
  }) async {
    final tetto = entro ?? pazienza;
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
            istruzione(forma),
            richiesta(spread,
                domanda: domanda,
                argomento: argomento,
                scartataPerche: perQuesta),
            campi,
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
      final grezza = LetturaDelModello.daJson(_json(testo));
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
    return LetturaDelModello.daJson(nuovi)?.ripulita();
  }

  /// **LE FRASI COL GENERE SI TOLGONO**, ordine EQ voce 04: la regola di
  /// casa, *"dove un testo si puo' togliere, si toglie"*, e la stessa mano
  /// di `LaRispostaRipulita`, che toglie le frasi fatte. Mai dalla risposta,
  /// che e' la risposta alla domanda: se il genere sta li', nulla. Nulla
  /// anche se un pezzo resta vuoto.
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

    final passato = senza(l.passato);
    final presente = senza(l.presente);
    final futuro = senza(l.futuro);
    final legame = senza(l.legame);
    final consiglio = senza(l.consiglio);
    if (passato == null ||
        presente == null ||
        futuro == null ||
        legame == null ||
        consiglio == null) {
      return null;
    }
    return LetturaDelModello(
      risposta: l.risposta,
      passato: passato,
      presente: presente,
      futuro: futuro,
      legame: legame,
      consiglio: consiglio,
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
  /// Si guarda cio' che si puo' guardare a macchina: i tetti, il nome di ogni
  /// carta nel suo pezzo, niente cifre e niente trattino lungo, il confine
  /// del responso su ogni pezzo, e nessun genere dato a chi legge contro la
  /// forma che ha scelto (`formeContrarieAllaForma`, la stessa porta dei
  /// testi del Viaggio). Il resto, se la lettura risponde e se interpreta, lo
  /// misura il collaudo con Gemini vero (`tool/collaudo_eq04.dart`).
  static String? scarto(LetturaDelModello l, TarotSpread spread,
      {CourtesyForm forma = CourtesyForm.unknown}) {
    if (l.risposta.length > tettoDellaRisposta) return 'risposta troppo lunga';
    if (l.legame.length > tettoDelLegame) return 'legame troppo lungo';
    if (l.consiglio.length > tettoDelConsiglio) return 'consiglio troppo lungo';
    for (final d in [spread.passato, spread.presente, spread.futuro]) {
      final t = l.della(d.position);
      if (t.length > tettoDellaCarta) {
        return '${d.position.label} troppo lungo';
      }
      if (!nominaLaCarta(t, d.card.name)) {
        return '${d.position.label} non nomina ${d.card.name}';
      }
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

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta, Map<String, Schema> campi) async {
    final m =
        FirebaseAI.vertexAI(location: LaRegioneDeiDati.regione).generativeModel(
      model: modello,
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 1400,
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

import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../maestro/natal_context.dart';
import '../rituals/animal_catalog.dart';
import 'diario_dei_viaggi.dart';
import 'il_tetto_delle_chiamate.dart';
import 'la_domanda_capita.dart';
import 'scena_del_viaggio.dart';
import 'vocabolario_del_viaggio.dart';
import '../chat/il_blocco_di_cortesia.dart';
import '../chat/user_profile.dart';
import 'la_voce_del_mondo_di_sotto.dart';
import 'le_guardie_del_responso.dart';

/// **I QUATTRO PEZZI CHE IL MODELLO HA SCELTO**, per id.
typedef PezziScelti = ({
  PezzoDellaScena luogo,
  PezzoDellaScena cosa,
  PezzoDellaScena gesto,
  PezzoDellaScena momento,
});

/// **I PEZZI CHE LA RISPOSTA PUO' CONTENERE**, id per id: sono gli elenchi
/// chiusi dello schema della risposta. Ordine DI voce 16: vedi
/// [LaScenaDalModello.ammessi].
typedef PezziAmmessi = ({
  List<String> luoghi,
  List<String> cose,
  List<String> gesti,
  List<String> momenti,
});

/// **LA SCENA E I TESTI DEL MODELLO, da una chiamata sola.** Ordine DL voci 07
/// e 13: i pezzi, quando reggono, e il titolo, la risposta e il gesto che
/// hanno retto alle guardie. Nulli i pezzi, decide la composizione
/// deterministica; nulli i testi, parla la voce di casa.
typedef LaScenaScritta = ({PezziScelti? pezzi, TestiDelModello testi});

/// La firma di una chiamata al modello per la scena, iniettabile nelle prove:
/// riceve anche i pezzi ammessi, da cui la chiamata vera costruisce lo schema.
typedef ChiamataDellaScena = Future<String?> Function(
    String istruzione, String richiesta, PezziAmmessi ammessi);

/// **UNO STRATO GIA' DATO**, come il Diario lo conserva: il titolo, la
/// risposta e l'azione che la persona ha letto. Ordine DQ voce 02.
typedef StratoGiaDato = ({String titolo, String risposta, String azione});

/// **CIO' CHE IL MODELLO SA DELLA PERSONA, per scegliere la scena.** Ordine DI
/// voce 03: *"la domanda per esteso, il tema classificato, il nome
/// dell'animale, i dati della carta natale gia' disponibili nel profilo, il
/// riassunto della memoria e gli elementi delle ultime cinque scene di quella
/// persona"*.
class CioCheSiSa {
  const CioCheSiSa({
    required this.domanda,
    required this.tema,
    required this.animale,
    required this.natale,
    required this.memoria,
    required this.ultimeScene,
    this.oggetto,
    this.forma,
    this.titoliGiaDati = const [],
    this.strato,
    this.stratiPrecedenti = const [],
  });

  final String domanda;

  /// **LO STRATO DI OGGI**, da uno a quattro, fino al riconoscimento; nullo
  /// dopo, quando si scende per chiedere. Ordine DQ voce 02.
  final int? strato;

  /// **GLI STRATI GIA' DATI** nel cammino, dal primo. Ordine DQ voce 02: se
  /// al terzo strato il modello ricevesse solo la domanda, riscriverebbe il
  /// primo con parole diverse, e la progressione non esisterebbe.
  final List<StratoGiaDato> stratiPrecedenti;

  /// **SI SCENDE SOLTANTO PER INCONTRARLO**, dentro un cammino: allora i
  /// quattro strati parlano dell'incontro. Ordine DQ voce 04.
  bool get soloIncontro => domanda.trim().isEmpty && strato != null;

  /// Il tema per esteso, *Una scelta da fare*; nullo senza domanda.
  final String? tema;
  final GuideAnimal animale;
  final NatalContext natale;

  /// Il riassunto che il Diario gia' scrive per i Maestri.
  final String memoria;

  /// Gli id dei pezzi delle scene di prima, dalla piu' recente: **tutta la
  /// storia che il Diario conserva**, ordine DI voce 16. Al modello se ne
  /// elencano cinque; la lettura della risposta le guarda tutte.
  final List<List<String>> ultimeScene;

  /// **L'OGGETTO DELLA DOMANDA**, in due o tre parole prese dalla domanda:
  /// *"tua sorella"*, *"quel lavoro"*. Ordine DL voce 08, dal classificatore.
  final String? oggetto;

  /// La forma di cortesia della persona; nulla, quella di chi usa l'app.
  final CourtesyForm? forma;

  /// **I TITOLI GIA' DATI A QUESTA PERSONA**, dalla discesa piu' recente.
  /// Ordine DL voce 07: la prova a cento discese col modello vero ha
  /// trovato lo stesso titolo ventisei volte su cento per la stessa
  /// domanda. Il modello ne riceve alcuni, e la lettura scarta il titolo
  /// che ne ripete uno qualsiasi: vale la riserva, che non si ripete.
  final List<String> titoliGiaDati;
}

/// **LA SCENA NASCE DALLA PERSONA, NON DA UN HASH.** Ordine DI voce 03,
/// 12 settembre 2026.
///
/// **La misura dell'ordine:** *"il codice dichiara da se' che la via buona non
/// e' montata: 'La porta al modello non e' ancora aperta'. Quella che gira e'
/// ScenaSenzaModello.componi, che sceglie i quattro pezzi con quattro
/// divisioni intere su un hash di domanda, giorno e numero della discesa."*
///
/// **Adesso la porta e' aperta.** Il modello riceve cio' che si sa della
/// persona e sceglie **quattro id dal vocabolario chiuso**, e nient'altro: la
/// risposta e' vincolata a quattro elenchi (`application/json` con quattro
/// enumerazioni), quindi un id inventato non puo' uscire. Se esce lo stesso,
/// o se esce una combinazione che la composizione non accetta, si scarta tutto
/// e **si cade sulla via deterministica, dichiarata nel registro dei guasti e
/// mai alla persona**. La via deterministica resta e non si cancella.
///
/// **Il costo dichiarato dall'ordine**: circa 1.200 token in ingresso e 60 in
/// uscita, cioe' circa due decimi di centesimo a discesa.
abstract final class LaScenaDalModello {
  /// **IL MODELLO**, in una costante sola.
  ///
  /// **L'ordine nomina Gemini 3.6 Flash**, e come Gemini 3.5 Flash Lite per la
  /// domanda capita esiste soltanto sull'endpoint `global`: verificato il 12
  /// settembre 2026 contando i token. **Il fondatore ha scelto, ordine DJ
  /// voce 03**: `gemini-2.5-flash` in `europe-west1`, dove stanno i dati, e
  /// *"non e' un ripiego"*. Un modello nuovo si nomina solo se risponde nella
  /// regione dei dati: vedi `LaRegioneDeiDati`.
  static const String modello = 'gemini-2.5-flash';

  static String get regione => LaDomandaCapita.regione;

  /// **QUANTO SI ASPETTA: SEI SECONDI IN TUTTO, DALLA PARTENZA.** Ordine DK
  /// voce 03.
  ///
  /// **Erano due secondi per tentativo**, e la chiamata partiva a discesa
  /// finita: col modello vero la scena arrivava in tempo in 66-99 discese su
  /// cento, e i tempi scaduti si concentravano nei momenti di rete lenta.
  /// Allungare l'attesa alla fine avrebbe fatto pagare la lentezza della rete
  /// a chi vuole la risposta. **Adesso la chiamata parte al tocco di Scendi**,
  /// e fra quel tocco e la risalita ci sono gli otto secondi del filmato, la
  /// nebbia e l'incontro, in cui nessuno aspetta niente: sei secondi al
  /// modello non costano un istante a nessuno. **I sei secondi valgono per
  /// tutti e due i tentativi insieme**, contati dalla partenza: la scena
  /// scartata si richiede solo col tempo che resta.
  static const Duration pazienza = Duration(seconds: 6);

  /// **L'ISTRUZIONE**, costruita dal vocabolario e dal repertorio: niente si
  /// ricopia a mano, e il giorno che una figura cambia nome l'istruzione la
  /// segue da sola.
  static String istruzione(GuideAnimal animale,
      {CourtesyForm? forma, int? strato, bool soloIncontro = false}) {
    final chi = '${animale.articolo}${animale.name}';
    final chiMaiuscolo = '${chi[0].toUpperCase()}${chi.substring(1)}';
    final b = StringBuffer(
        'Componi la scena di un viaggio sciamanico nel Mondo di Sotto. '
        '$chiMaiuscolo '
        'accompagna la persona. Scegli ESATTAMENTE quattro pezzi, uno per '
        'elenco, solo fra quelli scritti qui: non inventarne altri.\n');
    void elenco(String titolo, List<PezzoDellaScena> pezzi) {
      b.writeln('$titolo:');
      for (final p in pezzi) {
        b.writeln('- ${p.id}: ${p.nome}');
      }
    }

    elenco('luogo (dove ti porta)', VocabolarioDelViaggio.luoghi);
    elenco('cosa (ciò che si trova lì)', VocabolarioDelViaggio.cose);
    elenco('gesto (cosa fa $chi)', GestiDellAnimale.di(animale.name));
    elenco('momento', VocabolarioDelViaggio.momenti);
    // **LE SCENE PRECEDENTI SERVONO A NON RIPETERSI**, e lo dice la prova
    // col modello vero: con la prima stesura, *"se un elemento ha senso,
    // riprendilo"*, il modello riprendeva qualcosa in ventisei scene su
    // ventisette, e un profilo tornava dieci volte al bivio col seme.
    // L'ordine DE voce 11 vuole il richiamo raro: *"una continuita'
    // inventata vale meno di nessuna continuita'"*.
    b.write('La scena è la risposta simbolica alla domanda. Scegli i pezzi '
        'perché parlino di quella domanda e di quella persona, del suo tema, '
        'della sua carta natale e di ciò che ricorda. Le scene precedenti '
        'servono a non ripeterti: la scena di oggi deve essere nuova. I luoghi '
        'e i gesti delle scene precedenti non si possono ripetere; la cosa può '
        'tornare, soltanto se oggi ha un senso preciso. Non scegliere due pezzi '
        'che ripetono la stessa parola.\n\n');
    b.write(_iTreTesti(forma, strato: strato, soloIncontro: soloIncontro));
    return b.toString();
  }

  /// **I QUATTRO STRATI DELLA RISPOSTA**, ordine DQ voce 02, e sono quattro
  /// cose diverse, non quattro varianti della stessa. Ognuno ha la sua
  /// istruzione.
  static const List<String> stratiConDomanda = [
    "CHE COSA HAI PORTATO GIÙ DAVVERO: la domanda dietro la domanda, che "
        "quasi mai è quella scritta. Il titolo e la risposta dicono quella.",
    "CHE COSA TI TRATTIENE: l'ostacolo, detto come un fatto e mai come una "
        "colpa.",
    "CHE COSA HAI GIÀ IN MANO: la risorsa che la persona non sta contando.",
    "CHE COSA FARE: la risposta piena, che raccoglie gli strati di prima in "
        "una cosa sola. Oggi l'animale si rivela.",
  ];

  /// **I QUATTRO STRATI DI CHI SCENDE SENZA DOMANDA**, ordine DQ voce 04:
  /// cambiano oggetto, e parlano dell'incontro invece che della domanda.
  static const List<String> stratiDellIncontro = [
    "CHE COSA TI HA PORTATO A CERCARLO: che cosa, nel momento che la persona "
        "vive, l'ha fatta scendere. Leggilo dalla memoria e dalla carta "
        "natale.",
    "CHE COSA DELL'ANIMALE TI SOMIGLIA: un suo modo di essere o di muoversi "
        "che la persona ha anche in sé.",
    "CHE COSA TI CHIEDE: la cosa che l'animale chiede alla persona.",
    "CHI È: oggi l'animale si rivela. La risposta dice chi è per la persona, "
        "col suo nome.",
  ];

  /// Il numero dello strato in lettere, al femminile: la discesa.
  static const List<String> _laDiscesa = ['prima', 'seconda', 'terza', 'quarta'];

  /// **I TRE TESTI PER LA PERSONA**, ordine DL voci 07 e 13. Le regole sono
  /// quelle delle guardie in `LeGuardieDelResponso`: il modello le riceve
  /// scritte, e la lettura le verifica comunque.
  ///
  /// **GLI ESEMPI SONO DELLA VOCE DI CASA**, come chiede l'ordine: una
  /// manciata di titoli e di gesti veri, cosi' il modello scrive nella
  /// nostra voce e non nella sua. Da non copiare, e la lettura lo guarda.
  static String _iTreTesti(CourtesyForm? forma,
      {int? strato, bool soloIncontro = false}) {
    final titoli = [
      for (final t in LaVoceDelMondoDiSotto.titoliPerTema.values) t[3],
    ];
    final gesti = [
      for (final g in LaVoceDelMondoDiSotto.gestiColTempo) g,
      LaVoceDelMondoDiSotto.cosaPuoiFare[10],
      LaVoceDelMondoDiSotto.cosaPuoiFare[16],
    ];
    final s = strato == null ? null : strato.clamp(1, 4) - 1;
    return [
      if (!soloIncontro)
        'POI SCRIVI TRE TESTI PER LA PERSONA, sulla sua domanda vera, quella '
            'scritta nella richiesta. Se la domanda è "nessuna", lasciali '
            'vuoti.'
      else
        'POI SCRIVI TRE TESTI PER LA PERSONA. Non ha una domanda: è scesa '
            "soltanto per incontrare l'animale. I tre testi parlano "
            "dell'incontro.",
      // **LO STRATO**, ordine DQ voce 02: quattro discese sulla stessa
      // domanda, e ogni discesa risale con uno strato diverso.
      if (s != null) ...[
        'QUESTA È LA ${_laDiscesa[s].toUpperCase()} DISCESA DI QUATTRO '
            '${soloIncontro ? "DELLO STESSO INCONTRO" : "SULLA STESSA DOMANDA"}. '
            'Ogni discesa risale con uno strato diverso della stessa '
            'risposta. Lo strato di oggi è '
            '${(soloIncontro ? stratiDellIncontro : stratiConDomanda)[s]}',
        'Gli strati già dati sono nella richiesta: aggiungi e non ripetere. '
            'Non riprendere le loro frasi, le loro immagini e la loro azione.',
        if (s < 3)
          "Non nominare l'animale: né il suo nome né la sua specie. Si "
              'rivela alla quarta discesa.',
      ],
      // **LE REGOLE DETTE COME LE LEGGE IL MODELLO**, ordine DL voce 07: la
      // sonda col modello vero, dodici domande, ha trovato quattro titoli
      // oltre le sei parole, cinque gesti senza tempo e due virgole seguite
      // da "e". Il numero da solo non basta: serve l'esempio contato.
      '- titolo: da due a ${LeGuardieDelResponso.paroleDelTitolo} parole, '
          'MAI DI PIÙ: contale. "Quello che cerchi non sta dove guardi" sono '
          'sette parole, troppe; "Quello che cerchi è vicino" va bene. È '
          'già una '
          'risposta, si legge da solo e non è una domanda. Parla alla '
          'persona in seconda persona singolare. Niente due punti, niente '
          'punto finale. Nessuna parola di tempo, né "ora" né "oggi": il '
          "tempo lo dice l'azione. Non ripete nessuno dei titoli già dati. "
          'Non usa '
          'le parole del luogo, della cosa, del gesto e del momento che '
          'hai scelto per la scena: la scena arriva dopo. Se la cosa è la '
          'porta chiusa, il titolo non dice porta; se l\'animale aspetta, '
          'il titolo non dice aspettare.',
      '- risposta: ${LeGuardieDelResponso.frasiDellaRisposta} frasi al '
          'massimo. '
          '${soloIncontro ? "Parla dell'incontro e del momento della persona." : "Nomina la cosa di cui la persona ha chiesto, con le sue parole, non la categoria."} '
          'Non raccontare la scena e non usarla '
          'come immagine: nella risposta non compaiono il luogo, la cosa e '
          'il momento che hai scelto, perché la scena la racconta Caligo '
          'dopo, come fonte.',
      '- azione: una cosa sola, concreta, che si fa oggi o nei prossimi '
          'giorni e di cui si capisce se è stata fatta. COMINCIA DAL SUO '
          'TEMPO: "Stasera ...", "Domani mattina ...", "Entro sabato '
          '...". Un tempo solo. Non è un consiglio di vita, non è una '
          'massima, non è un invito a riflettere. NIENTE FUOCO: non si '
          'brucia, non si accende e non si incendia niente. Al posto del '
          'fuoco: strappare il foglio, seppellirlo, gettarlo nell\'acqua '
          'corrente, chiuderlo in un cassetto e non riaprirlo, metterlo '
          'sotto una pietra.',
      'REGOLE DEI TRE TESTI:',
      '- Non dire se la cosa accadrà, se non accadrà o se è già accaduta: '
          'non lo sai. "Tua sorella avrà un bambino" no; "la casa è già '
          'venduta" no; "non è ancora il momento" no. Parla di ciò che la '
          'persona può guardare o fare adesso.',
      '- Nessuna promessa su salute, denaro, morte, gravidanza, cause '
          'legali o eventi garantiti. Niente che somigli a una diagnosi o a '
          'un consiglio medico.',
      '- Nessun nome proprio che la persona non ha scritto.',
      // **ORDINE DN VOCI 02 E 04, e nessun esempio del NO.** La misura a
      // cento discese ha trovato l'esempio vietato ricopiato parola per
      // parola: prima quello dell'ordine, *"Il desiderio di tua sorella e' un
      // processo che si sta sviluppando"*, poi quello scritto al suo posto,
      // *"Il suo desiderio e' un cammino che ha i suoi tempi"*, e la risposta
      // alla domanda sulla sorella cadeva tre volte su quattro. Un esempio
      // del NO il modello lo prende per un modello. **Il soggetto e' chi
      // legge**, detto in positivo, e solo esempi del SI', su un cugino.
      "- Dell'altra persona non sai niente: né cosa prova, né cosa vuole, "
          'né cosa vive, né cosa le succederà. Quando la domanda parla di '
          'qualcuno, OGNI FRASE ha per soggetto chi legge e dice ciò che '
          'chi legge può o non può fare: "Puoi...", "Non puoi...", "Tocca '
          'a te...", "Con lei puoi...". "Con tuo cugino puoi scegliere tu '
          'quando parlare" e "La decisione di tuo cugino non è tua da '
          'prendere" vanno bene. Vale anche per "quella persona", "lui", '
          '"lei" e "il suo".',
      '- Puoi prendere una parte, ma non ordinare una decisione grave: '
          'lasciare il lavoro o una persona, separarsi, tagliare i '
          'rapporti, trasferirsi, vendere casa. Su queste dici cosa '
          'guardare, mai cosa fare.',
      '- Parole comuni, non da consulente e non da corso motivazionale: '
          'niente "processo", "il tuo percorso", "è tempo di", "lascia '
          'andare", "ascolta il tuo cuore", "il tuo vero io", "la tua '
          'essenza", "energia positiva", "apriti a", "devi solo", '
          '"abbraccia il cambiamento", "è già in te", "già dentro di te", '
          '"risuona".',
      '- L\'azione non chiede di fare a un\'altra persona qualcosa che possa '
          'ferirla o mettere in imbarazzo chi legge: niente confronti, '
          'accuse, pretese, rotture o rivelazioni. Niente salute, farmaci, '
          'soldi da spendere o investire, atti legali.',
      '- Italiano con gli accenti veri. Niente trattino lungo. MAI una '
          'virgola seguita da "e" o da "ed": al suo posto metti un punto. '
          'Niente prima persona.',
      'ESEMPI DELLA NOSTRA VOCE, solo per il tono e da non copiare.',
      'Titoli: ${titoli.map((t) => '"$t"').join(', ')}.',
      'Azioni: ${gesti.map((g) => '"$g"').join(', ')}.',
      '',
      IlBloccoDiCortesia.perForma(forma),
    ].join('\n');
  }

  /// **LA RICHIESTA**, cioe' cio' che si sa della persona, per esteso.
  /// Quanti titoli gia' dati arrivano al modello: dieci bastano a fargli
  /// cambiare strada, e costano un centinaio di token. La lettura li
  /// guarda tutti.
  static const int titoliNellaRichiesta = 10;

  /// **QUANTI TITOLI INDIETRO NON SI RIPETONO**: ventiquattro, la
  /// finestra della misura F dell'ordine DJ voce 11.
  static const int titoliDaNonRipetere = 24;

  /// I titoli gia' dati, dal Diario, dalla discesa piu' recente.
  static List<String> titoliDalDiario(List<UnViaggio> viaggi) => [
        for (final v in viaggi.take(titoliDaNonRipetere))
          if (v.titolo != null && v.titolo!.isNotEmpty) v.titolo!,
      ];

  static String richiesta(CioCheSiSa s,
      {List<RigaScartata> daCorreggere = const []}) {
    final n = s.natale;
    final b = StringBuffer()
      ..writeln('Domanda: ${s.domanda.trim().isEmpty ? 'nessuna, la '
          'discesa è soltanto per incontrarlo' : s.domanda.trim()}')
      ..writeln('Tema: ${s.tema ?? 'nessuno'}')
      // **LA DOMANDA PARLA DI UN'ALTRA PERSONA, E GLIELO SI DICE**, ordine
      // DN voce 08: la regola in positivo scartava quasi tutte le risposte
      // del modello sulle domande che parlano di un altro, perche' il
      // modello non sapeva che per quella domanda valeva. Adesso lo legge
      // nella richiesta, con la forma che la guardia pretende.
      ..write(LeGuardieDelResponso.parlaDiUnTerzo(s.domanda)
          ? 'La domanda parla di un\'altra persona: il titolo e OGNI frase '
              'della risposta cominciano da chi legge, "Puoi", "Non puoi", '
              '"Tocca a te", "Scegli", "Guarda". Dell\'altra persona non '
              'dire niente di ciò che prova, pensa, vede, vuole o fa.\n'
          : '')
      // **SENZA OGGETTO LA RIGA NON C'E'**, ordine DL voce 08: con *"non
      // noto"* il modello prendeva le due parole per la cosa chiesta, e
      // scriveva *"Quel 'non noto' che e' finito"*. Trovato leggendo le
      // risposte della prova a cento discese.
      ..write(s.oggetto == null ? '' : 'Oggetto della domanda: ${s.oggetto}\n')
      ..writeln(
          'Titoli già dati, da non ripetere: ${s.titoliGiaDati.isEmpty ? 'nessuno' : s.titoliGiaDati.take(titoliNellaRichiesta).map((t) => '"$t"').join(', ')}')
      ..writeln('Animale: ${s.animale.name}');
    // **GLI STRATI GIA' DATI**, ordine DQ voce 02, col loro testo intero.
    if (s.strato != null) {
      b.writeln('Strato di oggi: ${s.strato} di 4');
    }
    if (s.stratiPrecedenti.isNotEmpty) {
      b.writeln('Strati già dati in questo cammino, da non ripetere:');
      for (var i = 0; i < s.stratiPrecedenti.length; i++) {
        final p = s.stratiPrecedenti[i];
        b.writeln('${i + 1}. titolo "${p.titolo}"; risposta "${p.risposta}"; '
            'azione "${p.azione}"');
      }
    }
    final natale = [
      if (n.sunSign != null) 'Sole in ${n.sunSign}',
      if (n.moonSign != null) 'Luna in ${n.moonSign}',
      if (n.ascendant != null) 'Ascendente ${n.ascendant}',
      if (n.lifeNumber != null) 'numero di vita ${n.lifeNumber}',
    ];
    b.writeln(
        'Carta natale: ${natale.isEmpty ? 'non nota' : natale.join(', ')}');
    b.writeln('Memoria: ${s.memoria.isEmpty ? 'prima discesa' : s.memoria}');
    if (s.ultimeScene.isEmpty) {
      b.write('Scene precedenti: nessuna');
    } else {
      b.writeln('Scene precedenti, dalla più recente:');
      for (final scena
          in s.ultimeScene.take(IlRichiamoDelleScene.quanteSceneIndietro)) {
        b.writeln('- ${scena.join(', ')}');
      }
    }
    // **LA SECONDA CHIAMATA SA PERCHE' LA PRIMA E' STATA SCARTATA**, ordine
    // DQ voce 06: la riga, il motivo per nome e la regola in parole sue.
    if (daCorreggere.isNotEmpty) {
      b
        ..writeln()
        ..writeln()
        ..writeln('LA RISPOSTA DI PRIMA È STATA SCARTATA IN PARTE. Riscrivi '
            'questi testi rispettando la regola che hanno violato:');
      for (final r in daCorreggere) {
        b.writeln('- ${r.pezzo} "${r.testo}": scartato per ${r.motivo.name}, '
            'cioè ${LeGuardieDelResponso.perIlModello(r.motivo)}.');
      }
    }
    return b.toString().trimRight();
  }

  /// **I PEZZI AMMESSI OGGI**: tutti, tranne i luoghi e i gesti delle ultime
  /// cinque scene. Ordine DI voce 16, 13 settembre 2026.
  ///
  /// **La misura.** La prova a cento discese col modello vero ha trovato
  /// **scartate da 38 a 51 scene su cento**: sulla lunga distanza il modello
  /// torna sui suoi pezzi preferiti e ne riprende piu' di uno dalle cinque
  /// scene di prima, e la lettura, giustamente, lo scarta. Meta' delle discese
  /// ricadeva sulla composizione deterministica, cioe' su una scena che non
  /// nasce dalla persona. Nella prova da dieci discese della voce DI.03 non si
  /// vedeva.
  ///
  /// **Adesso la regola sta nello schema**, come gli id: la risposta non puo'
  /// contenere un luogo o un gesto gia' visto. **La cosa puo' tornare**, perche'
  /// e' l'unico pezzo che il richiamo guarda, e il momento, che ne ha quattro
  /// in tutto. Cosi' al massimo un pezzo e' ripreso, per costruzione.
  ///
  /// **MA LA COSA NON TORNA SUBITO, e non torna sempre.** Con la cosa libera
  /// del tutto il modello, per una sorella che aspetta un figlio, tornava sul
  /// seme una discesa su tre: il richiamo compariva in trentadue discese su
  /// cento, e la stessa riga quattro volte. L'ordine DE voce 11 lo vuole raro.
  /// Non torna una cosa delle **due** scene di prima, e non torna una cosa
  /// gia' tornata due volte nelle cinque.
  ///
  /// **E NON TORNA CIO' CHE TORNA SEMPRE.** Per la stessa domanda il modello
  /// si addensa sugli stessi posti e sugli stessi oggetti, la grotta e la
  /// pietra spaccata per il blocco, e appena lo schema glielo permette ci
  /// ritorna: due responsi con tre pezzi su quattro uguali superavano il
  /// quaranta per cento di somiglianza, misurato 41,3. Non torna un luogo ne'
  /// una cosa gia' usati due volte nelle ultime [memoriaDeiRitorni] scene.
  static PezziAmmessi ammessi(
      GuideAnimal animale, List<List<String>> ultimeScene) {
    final dieci = <String, int>{};
    for (final s in ultimeScene.take(memoriaDeiRitorni)) {
      for (final id in s.toSet()) {
        dieci[id] = (dieci[id] ?? 0) + 1;
      }
    }
    bool tornaTroppo(String id) => (dieci[id] ?? 0) >= 2;
    final cinque =
        ultimeScene.take(IlRichiamoDelleScene.quanteSceneIndietro).toList();
    final visti = {for (final s in cinque) ...s};
    final vicine = {for (final s in cinque.take(2)) ...s};
    final volte = <String, int>{};
    for (final s in cinque) {
      for (final id in s.toSet()) {
        volte[id] = (volte[id] ?? 0) + 1;
      }
    }
    List<String> fuori(List<PezzoDellaScena> tutti, {bool nuovi = true}) => [
          for (final p in tutti)
            if (!nuovi || !visti.contains(p.id)) p.id,
        ];
    return (
      luoghi: [
        for (final l in fuori(VocabolarioDelViaggio.luoghi))
          if (!tornaTroppo(l)) l,
      ],
      cose: [
        for (final c in VocabolarioDelViaggio.cose)
          if (!vicine.contains(c.id) &&
              (volte[c.id] ?? 0) < 2 &&
              !tornaTroppo(c.id))
            c.id,
      ],
      gesti: fuori(GestiDellAnimale.di(animale.name)),
      momenti: fuori(VocabolarioDelViaggio.momenti, nuovi: false),
    );
  }

  /// **QUANTE SCENE RICORDA LO SCHEMA PER I RITORNI**: dieci.
  static const int memoriaDeiRitorni = 10;

  /// **CHIEDE I QUATTRO PEZZI.** Nullo quando decide la via deterministica:
  /// tetto tecnico raggiunto, modello muto o lento, risposta fuori dal
  /// vocabolario, combinazione che la composizione non accetta. Il perche'
  /// va a [seGuasto].
  ///
  /// **UNA SCENA SCARTATA SI RICHIEDE UNA VOLTA**, ordine DI voce 16, senza
  /// il luogo e la cosa della risposta scartata. La prova a cento discese col
  /// modello vero: con la regola della scena rifatta la lettura ne scartava
  /// meta', e meta' delle discese tornava a nascere da un hash invece che
  /// dalla persona. Il tempo c'e': la chiamata parte a discesa finita e si
  /// aspetta solo alla risalita, dopo la nebbia, l'incontro e il velo. La
  /// seconda chiamata passa dal tetto tecnico come la prima.
  static Future<PezziScelti?> chiedi(
    CioCheSiSa s, {
    ChiamataDellaScena? chiamata,
    Future<bool> Function() prendiUnaChiamata = IlTettoDelleChiamate.sempre,
    void Function(Object errore)? seGuasto,
    Duration attesa = pazienza,
  }) async =>
      (await chiediTutto(s,
              chiamata: chiamata,
              prendiUnaChiamata: prendiUnaChiamata,
              seGuasto: seGuasto,
              attesa: attesa))
          .pezzi;

  /// **LA SCENA E I TRE TESTI, dalla stessa chiamata.** Ordine DL voci 07 e
  /// 13: *"nessuna chiamata in piu': la stessa, con qualche decina di token
  /// in uscita in piu'"*. I pezzi si leggono come prima; i testi passano
  /// dalle guardie uno per uno, e [seScartata] riceve ogni riga scartata.
  ///
  /// **I TESTI VENGONO DALLA STESSA RISPOSTA DEI PEZZI** quando i pezzi
  /// reggono: la risposta non deve anticipare la scena, e la scena e'
  /// quella. Quando nessun pezzo regge, restano i testi dell'ultima
  /// risposta: la scena la compone la riserva, e i testi parlano della
  /// domanda, non della scena.
  static Future<LaScenaScritta> chiediTutto(
    CioCheSiSa s, {
    ChiamataDellaScena? chiamata,
    Future<bool> Function() prendiUnaChiamata = IlTettoDelleChiamate.sempre,
    void Function(Object errore)? seGuasto,
    void Function(RigaScartata riga)? seScartata,
    Duration attesa = pazienza,
  }) async {
    final chiedi = chiamata ?? _chiamataVera;
    var consentiti = ammessi(s.animale, s.ultimeScene);
    var testi = TestiDelModello.nessuno;
    // **LE RIGHE DA CORREGGERE**, ordine DQ voce 06: gli scarti della prima
    // chiamata, che la seconda riceve per nome.
    var daCorreggere = const <RigaScartata>[];
    // **LA SCENA GIA' BUONA**, quando la seconda chiamata serve solo ai
    // testi: resta quella, e ogni elenco dello schema ha soltanto il suo
    // pezzo.
    PezziScelti? sceltiPrima;
    // **UNA SCADENZA SOLA**, dalla partenza: vedi [pazienza].
    final orologio = Stopwatch()..start();
    for (var tentativo = 0; tentativo < 2; tentativo++) {
      final resta = attesa - orologio.elapsed;
      if (resta <= Duration.zero) {
        seGuasto?.call(TimeoutException(
            'la scena scartata non ha più tempo per la seconda richiesta',
            attesa));
        return (pezzi: sceltiPrima, testi: testi);
      }
      // **IL TETTO SI PRENDE UNA VOLTA PER DISCESA**, ordine DL voce 09:
      // chi chiama passa il permesso gia' preso, e la seconda richiesta
      // della scena scartata non conta una discesa in piu'.
      if (!await prendiUnaChiamata()) {
        return (pezzi: sceltiPrima, testi: testi);
      }
      try {
        final risposta = await chiedi(
                istruzione(s.animale,
                    forma: s.forma,
                    strato: s.strato,
                    soloIncontro: s.soloIncontro),
                richiesta(s, daCorreggere: daCorreggere),
                consentiti)
            .timeout(resta);
        final scelti = sceltiPrima ??
            leggi(risposta, s.animale, ultimeScene: s.ultimeScene);
        final letti = leggiTesti(risposta, s, pezzi: scelti);
        for (final r in letti.scarti) {
          seScartata?.call(r);
        }
        if (sceltiPrima != null) {
          // **LA SECONDA CHIAMATA DEI TESTI**: di ogni pezzo vale la riga
          // della prima se aveva retto, altrimenti quella della seconda se
          // regge. Se nessuna delle due regge, vale la voce di casa.
          return (pezzi: sceltiPrima, testi: _unisci(testi, letti));
        }
        if (!letti.vuoti || testi.vuoti) {
          testi = tentativo == 0 ? letti : _unisci(testi, letti);
        }
        if (scelti != null) {
          // **UNA RIGA SCARTATA FA RICHIAMARE IL MODELLO UNA VOLTA SOLA**,
          // ordine DQ voce 06: la scena resta quella della prima risposta.
          // Alla seconda chiamata non si arriva mai due volte.
          if (tentativo == 0 && letti.scarti.isNotEmpty) {
            daCorreggere = letti.scarti;
            sceltiPrima = scelti;
            consentiti = _soloQuesti(scelti);
            continue;
          }
          return (pezzi: scelti, testi: testi);
        }
        seGuasto?.call(ScenaFuoriDalVocabolario(risposta));
        consentiti = _senzaLaScartata(consentiti, risposta);
        // **LA SCENA RIFATTA PORTA ANCHE I MOTIVI DEI TESTI**: e' la stessa
        // seconda chiamata, e non se ne fa una terza.
        daCorreggere = letti.scarti;
      } catch (errore) {
        // Un modello muto o lento non si richiama: la risalita non aspetta.
        seGuasto?.call(errore);
        return (pezzi: sceltiPrima, testi: testi);
      }
    }
    return (pezzi: sceltiPrima, testi: testi);
  }

  /// **I TESTI DELLE DUE CHIAMATE**, pezzo per pezzo: vale la prima riga che
  /// ha retto. Le righe della prima scartate e riprese dalla seconda si
  /// segnano, col motivo della prima: ordine DQ voce 06.
  static TestiDelModello _unisci(TestiDelModello prima, TestiDelModello dopo) {
    final recuperate = <RigaScartata>[];
    final dallaSeconda = <String>{};
    String? scegli(String pezzo, String? a, String? b) {
      if (a != null) return a;
      if (b == null) return null;
      dallaSeconda.add(pezzo);
      recuperate.addAll(prima.scarti.where((r) => r.pezzo == pezzo));
      return b;
    }

    return TestiDelModello(
      titolo: scegli('titolo', prima.titolo, dopo.titolo),
      risposta: scegli('risposta', prima.risposta, dopo.risposta),
      azione: scegli('azione', prima.azione, dopo.azione),
      scarti: [...prima.scarti, ...dopo.scarti],
      recuperate: recuperate,
      dallaSeconda: dallaSeconda,
    );
  }

  /// Gli elenchi dello schema con il solo pezzo gia' scelto: alla seconda
  /// chiamata dei testi la scena non cambia.
  static PezziAmmessi _soloQuesti(PezziScelti p) => (
        luoghi: [p.luogo.id],
        cose: [p.cosa.id],
        gesti: [p.gesto.id],
        momenti: [p.momento.id],
      );

  /// **LEGGE I TRE TESTI** della risposta e li fa passare dalle guardie.
  /// Una risposta senza i campi dei testi, come quelle delle prove scritte
  /// prima dell'ordine DL, da' nessun testo: parla la voce di casa.
  static TestiDelModello leggiTesti(String? risposta, CioCheSiSa s,
      {PezziScelti? pezzi}) {
    if (risposta == null) return TestiDelModello.nessuno;
    final Object? j;
    try {
      j = jsonDecode(risposta);
    } catch (errore) {
      return TestiDelModello.nessuno;
    }
    if (j is! Map) return TestiDelModello.nessuno;
    return LeGuardieDelResponso.leggi(
      j,
      domanda: s.domanda,
      forma: s.forma ?? LaMarcaDelGenere.formaCorrente,
      oggetto: s.oggetto,
      tema: s.tema,
      nomiDellaScena: pezzi == null
          ? const []
          : [pezzi.luogo.nome, pezzi.cosa.nome, pezzi.momento.nome],
      // **IL NOME DELL'ANIMALE SOLO ALLA QUARTA**, ordine DQ voce 02: prima
      // del riconoscimento il suo nome non e' ammesso, e la guardia lo
      // scarta.
      nomiAmmessi: s.strato != null && s.strato! < 4
          ? const {}
          : {s.animale.name.toLowerCase()},
      titoliGiaDati: s.titoliGiaDati,
      soloIncontro: s.soloIncontro,
      animaleNonAncoraDetto:
          s.strato != null && s.strato! < 4 ? s.animale.name : null,
      giaDetti: [
        for (final p in s.stratiPrecedenti) ...[p.titolo, p.risposta, p.azione],
      ],
    );
  }

  /// I pezzi ammessi, senza il luogo e la cosa della risposta scartata,
  /// finche' ne resta almeno uno per elenco.
  static PezziAmmessi _senzaLaScartata(PezziAmmessi a, String? risposta) {
    Object? j;
    try {
      j = risposta == null ? null : jsonDecode(risposta);
    } catch (errore) {
      // Una risposta che non e' JSON non dice cosa togliere: resta com'era.
      return a;
    }
    if (j is! Map) return a;
    List<String> senza(List<String> l, Object? id) {
      final r = [
        for (final x in l)
          if (x != id) x
      ];
      return r.isEmpty ? l : r;
    }

    return (
      luoghi: senza(a.luoghi, j['luogo']),
      cose: senza(a.cose, j['cosa']),
      gesti: a.gesti,
      momenti: a.momenti,
    );
  }

  /// **LEGGE LA RISPOSTA**, e la scarta tutta al primo pezzo che non torna.
  ///
  /// Non basta che i quattro id esistano: il gesto deve essere uno che quel
  /// corpo sa fare, e nessun pezzo deve ripetere una parola piena di un altro.
  /// Sono le stesse regole della composizione deterministica, ordine DI voci
  /// 04 e 05, e valgono per il modello come per lei.
  ///
  /// **E NON PIU' DI UN PEZZO GIA' VISTO** nelle ultime cinque scene, fra
  /// luogo, cosa e gesto: il momento ne ha quattro in tutto e si ripete per
  /// forza. E' la stessa regola che l'istruzione chiede, letta sull'uscita.
  static PezziScelti? leggi(String? risposta, GuideAnimal animale,
      {List<List<String>> ultimeScene = const []}) {
    if (risposta == null) return null;
    final Object? j;
    try {
      j = jsonDecode(risposta);
    } catch (errore) {
      // **UNA RISPOSTA CHE NON E' JSON SI SCARTA**: `chiedi` la manda al
      // registro dei guasti come scena fuori dal vocabolario, e decide la via
      // deterministica.
      return null;
    }
    final dati = j is Map ? j : null;
    if (dati == null) return null;
    PezzoDellaScena? tra(List<PezzoDellaScena> tutti, Object? id) =>
        tutti.where((p) => p.id == id).firstOrNull;
    final luogo = tra(VocabolarioDelViaggio.luoghi, dati['luogo']);
    final cosa = tra(VocabolarioDelViaggio.cose, dati['cosa']);
    final gesto = tra(GestiDellAnimale.di(animale.name), dati['gesto']);
    final momento = tra(VocabolarioDelViaggio.momenti, dati['momento']);
    if (luogo == null || cosa == null || gesto == null || momento == null) {
      return null;
    }
    if (ScenaSenzaModello.siRipetono(cosa, [luogo]) ||
        ScenaSenzaModello.siRipetono(gesto, [luogo, cosa, momento])) {
      return null;
    }
    final visti = {
      for (final s
          in ultimeScene.take(IlRichiamoDelleScene.quanteSceneIndietro))
        ...s,
    };
    final ripresi =
        [luogo, cosa, gesto].where((p) => visti.contains(p.id)).length;
    if (ripresi > 1) return null;
    // **NESSUNA SCENA RIFATTA**, ordine DI voce 16: per la stessa domanda il
    // modello torna, a settimane di distanza, esattamente sulla stessa scena.
    // La prova a cento discese l'ha trovata identica in tutti e quattro i
    // pezzi, e i due responsi si somigliavano al 41,3 per cento. Una scena
    // che rifa' luogo, cosa e gesto di una qualsiasi della storia si scarta,
    // e si richiede. **Il momento non si conta**: ne ha quattro in tutto, e
    // contandolo la lettura scartava meta' delle scene del modello anche
    // dopo la seconda richiesta, misurato; senza, le scene del modello sono
    // salite da 62-81 a 89-98 discese su cento, con la somiglianza piu' bassa.
    final oggi = [luogo.id, cosa.id, gesto.id];
    for (final s in ultimeScene) {
      var comuni = 0;
      for (var k = 0; k < s.length && k < 3; k++) {
        if (s[k] == oggi[k]) comuni++;
      }
      if (comuni >= 3) return null;
    }
    return (luogo: luogo, cosa: cosa, gesto: gesto, momento: momento);
  }

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta, PezziAmmessi ammessi) async {
    final m = FirebaseAI.vertexAI(location: regione).generativeModel(
      model: modello,
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        // **SEICENTO TOKEN**, ordine DL voce 07: oltre ai quattro id, il
        // titolo, la risposta e il gesto. Duecento in piu' a discesa.
        maxOutputTokens: 640,
        thinkingConfig: LaDomandaCapita.ragionamentoPer(modello),
        responseMimeType: 'application/json',
        // **QUATTRO ELENCHI CHIUSI** per la scena, per costruzione, e i tre
        // testi dell'ordine DL, che passano dalle guardie.
        responseSchema: Schema.object(properties: {
          'luogo': Schema.enumString(enumValues: ammessi.luoghi),
          'cosa': Schema.enumString(enumValues: ammessi.cose),
          'gesto': Schema.enumString(enumValues: ammessi.gesti),
          'momento': Schema.enumString(enumValues: ammessi.momenti),
          'titolo': Schema.string(),
          'risposta': Schema.string(),
          'azione': Schema.string(),
        }),
      ),
    );
    final r = await m.generateContent([Content.text(richiesta)]);
    return r.text;
  }
}

/// Il modello ha risposto fuori dal vocabolario, o con una combinazione che la
/// composizione non accetta.
class ScenaFuoriDalVocabolario implements Exception {
  const ScenaFuoriDalVocabolario(this.risposta);
  final String? risposta;
  @override
  String toString() =>
      'la scena del modello non è nel vocabolario: "$risposta"';
}

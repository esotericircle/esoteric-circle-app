import '../domande/domande_del_cerchio.dart';
import 'dart:convert';

import '../chat/user_profile.dart';
import '../responsi/i_riti_propiziatori.dart';
import '../responsi/la_forma_del_responso.dart';
import 'il_titolo_della_gettata.dart';
import 'la_risposta_della_gettata.dart';
import 'le_risposte_dirette.dart';
import 'le_risposte_dirette.g.dart';
import 'le_voci_neutre.g.dart';
import 'rune_cast.dart';
import 'rune_lore.g.dart';

/// **IL PRESAGIO DELLE RUNE DAL CORPUS, SENZA MODELLO. Ordine EX voce 03.**
///
/// Il fondatore: *"pensavo che l'estrazione rune fosse a zero AI"*, *"Voglio
/// corpus grandi, non voglio ripetizioni per almeno 60gg"*. La lettura che
/// oggi scrive Gemini (la risposta, il cosa puoi fare, il da dove viene) si
/// compone qui da cinque campi del corpus dell'Architetto, divisi in gruppi
/// (`docs/corpus/rune/SPECIFICA.md`): RISPOSTA e GESTO per la pietra che
/// decide, VERDETTO per il tono e la famiglia, PIETRA per ogni pietra, LEGAME
/// per la gettata e il tono.
///
/// **Finche' il corpus non e' entrato tutto, la lettura resta quella del
/// modello**: [CorpusDelPresagio.completo] e' falso e chi legge le rune non
/// passa di qui. Code non scrive nessun testo: i testi sono dell'Architetto.
///
/// **LA FORMA DELL'ORDINE GA, voci GA.03, GA.04, GA.05 e GA.07, 20 ottobre
/// 2026.** Il fondatore, 19 ottobre 2026 alle 23:08: *"tutte le risposte
/// composte da paragrafi ognuno con tra 40 a 50 parole ognuno. Per le
/// risposte brevi 2 paragrafi di cui il secondo messo in evidenza in un
/// riquadro e questo riquadro deve intitolarsi "cosa fare adesso" [...] Per
/// le risposte lunghe aggiungi 2 paragrafi sempre con il primo in riquadro.
/// Sotto sempre il paragrafo in corsivo "da dove viene". Restano all'inizio i
/// titoli, anche per le singola carte o le singole rune."* Il presagio adesso
/// e' un [IlPresagioComposto]: il responso principale nella forma comune
/// ([ResponsoInterpretato]: il titolo dalla pietra che decide, la risposta
/// RISPOSTA piu' VERDETTO, il riquadro "Cosa fare adesso" col GESTO e, nella
/// Lunga, l'approfondimento col LEGAME e il galdr propiziatorio) e una scheda
/// breve per ogni pietra (PIETRA e CONSIGLIO) quando le pietre sono piu' di
/// una. Il "Da dove viene" e' uno solo e lo compone il codice dalle fonti
/// delle rune uscite ([daDoveViene]), non il corpus. Il corpus e' completo e
/// le rune non chiamano mai il modello.

/// I sei campi del corpus, nell'ordine della specifica. **CONSIGLIO e'
/// dell'ordine GA voce GA.07**: il riquadro "Cosa fare adesso" della scheda
/// di ogni runa, coi gruppi di PIETRA.
abstract final class CampiDelPresagio {
  static const String risposta = 'risposta';
  static const String verdetto = 'verdetto';
  static const String pietra = 'pietra';
  static const String legame = 'legame';
  static const String gesto = 'gesto';
  static const String consiglio = 'consiglio';
  static const List<String> tutti = [
    risposta,
    verdetto,
    pietra,
    legame,
    gesto,
    consiglio,
  ];
}

/// **IL PRESAGIO COMPOSTO**, ordine GA voci GA.03 e GA.05: il responso
/// principale della gettata e le schede delle rune singole.
class IlPresagioComposto {
  const IlPresagioComposto({required this.principale, this.schede = const []});

  /// Il responso principale, nella forma comune: breve per il Viandante,
  /// lungo dall'Iniziato in su. Porta il "Da dove viene" di tutta la
  /// consultazione, che la schermata mostra una volta sola in fondo.
  final ResponsoInterpretato principale;

  /// Una scheda breve per pietra, nell'ordine della gettata (il titolo e' la
  /// riga della runa nel suo verso, poi PIETRA e il riquadro col CONSIGLIO),
  /// senza "Da dove viene". Vuota quando la pietra e' una sola: la Runa di
  /// Odino e' gia' il responso principale (voce GA.05, *"senza ripetere un
  /// secondo blocco per la stessa carta"*).
  final List<ResponsoInterpretato> schede;

  /// Il responso principale senza il "Da dove viene", come sta nella bolla
  /// del presagio: la fonte chiude la consultazione, non la bolla.
  ResponsoInterpretato get principaleSenzaLaFonte => ResponsoInterpretato(
        arte: principale.arte,
        titolo: principale.titolo,
        risposta: principale.risposta,
        cosaFare: principale.cosaFare,
        approfondimento: principale.approfondimento,
        rito: principale.rito,
      );

  /// Il testo per condividere e custodire: i paragrafi del responso
  /// principale nell'ordine in cui si leggono, poi il "Da dove viene". La
  /// prima frase e' la risposta (voce GA.06), ed e' quella che la card da
  /// condividere porta in coda.
  String get inParole => [
        ...principale.paragrafi,
        if (principale.daDoveViene != null) principale.daDoveViene!,
      ].join('\n\n');
}

/// Il corpus: per campo, per gruppo, le voci nell'ordine dell'Architetto.
/// L'identificativo di una voce e' `campo/gruppo/numero`, col numero da uno,
/// e non si riusa.
class CorpusDelPresagio {
  const CorpusDelPresagio(this.voci);

  /// Il corpus vuoto: oggi, finche' i file dell'Architetto non entrano.
  static const CorpusDelPresagio vuoto = CorpusDelPresagio({});

  final Map<String, Map<String, List<String>>> voci;

  /// Vero quando ogni gruppo di ogni campo ha almeno una voce.
  bool get completo {
    for (final campo in CampiDelPresagio.tutti) {
      for (final gruppo in IlPresagioDalCorpus.gruppiDi(campo)) {
        if ((voci[campo]?[gruppo] ?? const []).isEmpty) return false;
      }
    }
    return true;
  }

  /// Quante voci ha il corpus, in tutto.
  int get quante => voci.values
      .expand((g) => g.values)
      .fold(0, (somma, elenco) => somma + elenco.length);
}

/// **LA MEMORIA DI CIO' CHE LA PERSONA HA LETTO**, per sessanta giorni.
///
/// Per ogni voce letta, il giorno in cui l'ha letta; e per oggi, il presagio
/// dato a ogni gettata, perche' la stessa gettata con la stessa domanda, lo
/// stesso giorno, ridia lo stesso presagio (Linee Guida, sezione 5).
///
/// **LA MEMORIA E' VERSIONATA, ordine GA voce GA.07.** Fino all'ordine EX il
/// presagio di oggi si ricordava come un elenco di identificativi in
/// posizione fissa (la risposta per prima, poi il verdetto, poi una pietra
/// per pietra, il legame e il gesto per ultimo): con i campi nuovi lo stesso
/// elenco letto con la regola nuova avrebbe scambiato le parti. Adesso ogni
/// identificativo sta sotto il NOME della sua parte ([IlPresagioDalCorpus.parteDellaPietra]
/// e le chiavi `risposta`, `verdetto`, `gesto`, `legame`), il testo porta
/// `versione: 2`, e un testo della versione di prima conserva solo cio' che
/// resta vero, le voci lette e il loro giorno ([daTesto]).
class LaMemoriaDelPresagio {
  LaMemoriaDelPresagio({
    Map<String, String>? letti,
    Map<String, Map<String, String>>? diOggi,
    this.giornoDiOggi = '',
  })  : letti = letti ?? {},
        diOggi = diOggi ?? {};

  /// La versione del testo salvato, dall'ordine GA voce GA.07.
  static const int versione = 2;

  /// Identificativo della voce, giorno "aaaa-mm-gg" dell'ultima lettura.
  final Map<String, String> letti;

  /// Il giorno a cui si riferisce [diOggi].
  String giornoDiOggi;

  /// Per firma della gettata, il presagio dato oggi: per nome della parte,
  /// l'identificativo della voce.
  final Map<String, Map<String, String>> diOggi;

  /// Quanti giorni una voce letta non torna.
  static const int finestra = 60;

  static String chiaveDelGiorno(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Toglie le letture piu' vecchie della finestra e il presagio di ieri.
  void pota(DateTime oggi) {
    final limite =
        chiaveDelGiorno(DateTime(oggi.year, oggi.month, oggi.day - finestra));
    letti.removeWhere((_, giorno) => giorno.compareTo(limite) <= 0);
    final adesso = chiaveDelGiorno(oggi);
    if (giornoDiOggi != adesso) {
      diOggi.clear();
      giornoDiOggi = adesso;
    }
  }

  String comeTesto() => jsonEncode({
        'versione': versione,
        'letti': letti,
        'giornoDiOggi': giornoDiOggi,
        'diOggi': diOggi,
      });

  /// La memoria da un testo salvato. **Un testo senza `versione: 2` e' della
  /// forma dell'ordine EX**: si tengono le voci lette, che portano gli stessi
  /// identificativi (una voce riscritta tiene il suo numero, SPECIFICA.md
  /// sezione 8), e si lascia il presagio di oggi, che era un elenco in
  /// posizione fissa e qui verrebbe letto con le parti scambiate.
  static LaMemoriaDelPresagio daTesto(String? testo) {
    if (testo == null || testo.isEmpty) return LaMemoriaDelPresagio();
    try {
      final j = jsonDecode(testo) as Map<String, dynamic>;
      final letti = (j['letti'] as Map? ?? {}).cast<String, String>();
      if (j['versione'] != versione) {
        return LaMemoriaDelPresagio(letti: {...letti});
      }
      return LaMemoriaDelPresagio(
        letti: {...letti},
        giornoDiOggi: j['giornoDiOggi'] as String? ?? '',
        diOggi: {
          for (final e in (j['diOggi'] as Map? ?? {}).entries)
            '${e.key}': {...(e.value as Map).cast<String, String>()},
        },
      );
    } on FormatException {
      return LaMemoriaDelPresagio();
    } on TypeError {
      return LaMemoriaDelPresagio();
    }
  }
}

/// La composizione.
abstract final class IlPresagioDalCorpus {
  /// Le otto rune simmetriche, che non escono mai in ombra.
  static const Set<String> simmetriche = {
    'Gebo',
    'Hagalaz',
    'Isa',
    'Jera',
    'Eihwaz',
    'Sowilo',
    'Ingwaz',
    'Dagaz',
  };

  /// Le ventiquattro rune, nell'ordine del Futhark.
  static const List<String> rune = [
    'Fehu', 'Uruz', 'Thurisaz', 'Ansuz', 'Raidho', 'Kenaz', 'Gebo', 'Wunjo',
    'Hagalaz', 'Nauthiz', 'Isa', 'Jera', 'Eihwaz', 'Perthro', 'Algiz', //
    'Sowilo', 'Tiwaz', 'Berkano', 'Ehwaz', 'Mannaz', 'Laguz', 'Ingwaz',
    'Dagaz', 'Othala',
  ];

  static const List<String> famiglie = ['Freyr', 'Hagal', 'Tyr'];
  static const List<String> toni = ['luce', 'misto', 'ombra'];
  static const List<String> gettate = ['odino', 'norne', 'croce', 'telo'];

  /// I gruppi di un campo, come li vuole la specifica.
  static List<String> gruppiDi(String campo) => switch (campo) {
        CampiDelPresagio.verdetto => [
            for (final t in toni)
              for (final f in famiglie) '$t/$f'
          ],
        CampiDelPresagio.legame => [
            for (final g in gettate)
              for (final t in toni)
                // La Runa di Odino ha una pietra sola: niente misto.
                if (!(g == 'odino' && t == 'misto')) '$g/$t'
          ],
        _ => [
            for (final r in rune) ...[
              '$r/dritta',
              if (!simmetriche.contains(r)) '$r/ombra',
            ]
          ],
      };

  /// La pietra che decide: l'unica di Odino, Skuld delle Norne, l'Esito
  /// della Croce, quella al centro del telo.
  static int indiceDellaPietraCheDecide(String gettata) =>
      switch (gettata) { 'norne' => 2, 'croce' => 4, _ => 0 };

  static String gruppoDellaPietra(RunaGettata r) =>
      '${r.rune.name}/${r.inOmbra ? 'ombra' : 'dritta'}';

  /// Luce se nessuna pietra e' in ombra, ombra se piu' della meta' lo e',
  /// misto altrimenti.
  static String tono(List<RunaGettata> pietre) {
    final ombre = pietre.where((r) => r.inOmbra).length;
    if (ombre == 0) return 'luce';
    return ombre * 2 > pietre.length ? 'ombra' : 'misto';
  }

  static String famigliaDi(String runa) => famiglie[rune.indexOf(runa) ~/ 8];

  /// La famiglia con piu' pietre; a parita' quella della pietra che decide.
  static String famigliaCheDomina(List<RunaGettata> pietre, String chiave) {
    final conti = <String, int>{};
    for (final p in pietre) {
      final f = famigliaDi(p.rune.name);
      conti[f] = (conti[f] ?? 0) + 1;
    }
    final massimo = conti.values.fold(0, (a, b) => a > b ? a : b);
    final pari =
        conti.entries.where((e) => e.value == massimo).map((e) => e.key);
    final suaFamiglia = famigliaDi(chiave);
    if (pari.contains(suaFamiglia)) return suaFamiglia;
    return (pari.toList()..sort()).first;
  }

  /// Un numero dal testo, stabile fra le esecuzioni (FNV-1a a 32 bit).
  static int seme(String testo) {
    var h = 0x811c9dc5;
    for (final c in testo.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h;
  }

  /// **LE VOCI TRATTENUTE, IN ATTESA DELL'ARCHITETTO.** Ordine EX, EX
  /// Aggiunta 2: "Se una prova si ferma per un testo, Code lo scrive nel
  /// rapporto... e il testo lo corregge l'Architetto". Una voce che una
  /// guardia ferma resta nel corpus parola per parola, ma qui dentro non si
  /// sceglie mai, finche' l'Architetto non la corregge.
  ///
  /// **Vuoto dal 2 ottobre 2026.** Ci sono state PIETRA Uruz dritta 56
  /// ("resti ben piantato") e PIETRA Mannaz in ombra 38 ("giudichi te
  /// stesso"), che la guardia del genere aveva fermato; l'Architetto le ha
  /// corrette lo stesso giorno e sono tornate a uscire.
  static const Set<String> vociTrattenute = <String>{};

  /// Le voci che chiedono al corpo uno sforzo: camminare, correre, salire,
  /// sollevare, fare attivita' fisica. Su una domanda di salute non si
  /// scelgono (ordine GA voce GA.06).
  /// Le voci che spingono a muovere beni: spendere, scambiare, mettere in
  /// gioco, far circolare. Su una domanda di denaro non si scelgono.
  static final RegExp spintaAMuovereBeni = LaDomandaLetta.parola(
      r'muov\w* il bene|metti in circolo|mettil\w* in circolo|fai circolare|'
      r'far circolare|investi\w*|spend\w*|compra\w*|vend\w*|capitale|'
      r'risparmi\w*|scambial\w*|usalo|offrilo|metti in gioco|mettil\w* in '
      r'gioco|presta\w*|regala\w*|dona\w*|acquist\w*|bene che hai fermo');

  static final RegExp sforzoFisico = LaDomandaLetta.parola(
      r'cammin\w*|corri|correre|corsa|corsetta|salit\w*|sali[lr]\w*|scal[ae]|'
      r'scalinat\w*|'
      r'sentier\w*|passo sostenuto|attività fisica|esercizi\w*|palestr\w*|'
      r'nuot\w*|sport\w*|sposta\w* (un |i |dei )?mobil\w*|sollev\w*|'
      r'il corpo|al corpo|del corpo|fatica fisica|sforzo fisico|'
      r'braccia|in movimento|muovi il corpo|salti');

  /// **LA SCELTA.** Fra le voci del gruppo, nell'ordine proprio di questa
  /// persona (una permutazione seminata dal suo identificativo), la prima
  /// che non ha letto nei sessanta giorni; se le ha lette tutte, quella
  /// letta da piu' tempo. Mai una voce gia' presa in questo presagio.
  static String scegli({
    required String campo,
    required String gruppo,
    required int quante,
    required String persona,
    required LaMemoriaDelPresagio memoria,
    required Set<String> giaPresi,
    bool Function(int indice)? vuota,
  }) {
    // **UNA VOCE TOLTA NON SI SCEGLIE.** L'Architetto toglie una voce
    // lasciando il suo numero senza testo (SPECIFICA.md, sezione 3): il
    // numero resta, perche' la memoria di chi l'ha letta resti giusta.
    final ordine = [
      for (var i = 0; i < quante; i++)
        if (vuota == null || !vuota(i)) i
    ];
    // Fisher-Yates con un generatore lineare dal seme della persona.
    var stato = seme('$persona|$campo|$gruppo');
    for (var i = ordine.length - 1; i > 0; i--) {
      stato = (stato * 1103515245 + 12345) & 0x7fffffff;
      final j = stato % (i + 1);
      final t = ordine[i];
      ordine[i] = ordine[j];
      ordine[j] = t;
    }
    String id(int i) => '$campo/$gruppo/${i + 1}';
    for (final i in ordine) {
      final v = id(i);
      if (!memoria.letti.containsKey(v) && !giaPresi.contains(v)) return v;
    }
    // Tutte lette: quella letta da piu' tempo.
    final disponibili = [
      for (final i in ordine)
        if (!giaPresi.contains(id(i))) id(i)
    ];
    disponibili.sort(
        (a, b) => (memoria.letti[a] ?? '').compareTo(memoria.letti[b] ?? ''));
    return disponibili.first;
  }

  /// **LA FIRMA DI UNA GETTATA**, per ridare lo stesso presagio lo stesso
  /// giorno alla stessa gettata con la stessa domanda.
  static String firma(EsitoGettata esito, String domanda) => [
        esito.gettata.id,
        for (final r in esito.rune) gruppoDellaPietra(r),
        domanda.trim().toLowerCase(),
      ].join('|');

  /// La pietra che decide di una gettata: quella su cui poggiano il titolo,
  /// la risposta, il gesto e il galdr.
  static RunaGettata pietraCheDecide(EsitoGettata esito) =>
      esito.rune[indiceDellaPietraCheDecide(esito.gettata.id)
          .clamp(0, esito.rune.length - 1)];

  /// **I NOMI DELLE PARTI NELLA MEMORIA DI OGGI**, ordine GA voce GA.07: le
  /// quattro del responso principale e due per ogni pietra della scheda.
  static const String parteRisposta = 'risposta';
  static const String parteVerdetto = 'verdetto';
  static const String parteGesto = 'gesto';
  static const String parteLegame = 'legame';
  static String parteDellaPietra(String campo, String runa) => '$campo|$runa';

  /// **IL PRESAGIO**, nella forma dell'ordine GA (voci GA.03, GA.04 e
  /// GA.05): il responso principale e le schede delle rune singole.
  ///
  /// [cosa] e' cio' di cui la persona chiede, con l'articolo (vedi
  /// [cosaDellaDomanda]); [persona] l'identificativo che semina l'ordine
  /// delle voci; [memoria] si aggiorna con le voci lette. [lunga] aggiunge
  /// al responso principale l'approfondimento (LEGAME) e il galdr
  /// propiziatorio della pietra che decide: dall'Iniziato in su
  /// (`RigaDelPiano.runeLunga`), mai alle schede (voce GA.05).
  ///
  /// [neutre]: le coppie di PIETRA/CONSIGLIO e RISPOSTA/GESTO che non
  /// presuppongono una situazione (`le_voci_neutre.g.dart`); le prove sulla
  /// scelta con un corpus di prova passano `{}`, perche' quell'elenco e'
  /// scritto sui numeri del corpus vero.
  ///
  /// **Si sceglie solo cio' che si mostra**: il LEGAME solo nella Lunga, le
  /// schede solo con piu' di una pietra. Lo stesso giorno, la stessa
  /// gettata con la stessa domanda ridà le stesse voci; se nel frattempo si
  /// e' aperta la Lunga, la parte che mancava si sceglie adesso e si
  /// aggiunge al presagio di oggi.
  static IlPresagioComposto componi({
    required CorpusDelPresagio corpus,
    required EsitoGettata esito,
    required String domanda,
    required String persona,
    required DateTime oggi,
    required LaMemoriaDelPresagio memoria,
    bool lunga = false,
    CourtesyForm? forma,
    Map<String, Map<String, List<(int, int)>>>? neutre,
  }) {
    memoria.pota(oggi);
    final pietre = esito.rune;
    final gettata = esito.gettata.id;
    final decide = pietraCheDecide(esito);
    final laFirma = firma(esito, domanda);
    final diOggi = memoria.diOggi.putIfAbsent(laFirma, () => {});
    final giorno = LaMemoriaDelPresagio.chiaveDelGiorno(oggi);
    // Mai la stessa voce due volte nello stesso presagio, nemmeno fra una
    // parte gia' data oggi e una scelta adesso.
    final presi = <String>{...diOggi.values};
    final letta = LaDomandaLetta.di(domanda);
    // **SU UNA DOMANDA DI SALUTE LE SCHEDE NON CHIEDONO SFORZI FISICI**,
    // ordine GA voce GA.06: i lettori ciechi hanno letto "Cammina all'aperto
    // subito dopo un momento difficile" sotto un'operazione al ginocchio. Le
    // voci di PIETRA e CONSIGLIO che chiedono al corpo uno sforzo non si
    // scelgono quando la domanda tocca la salute (se un gruppo le avesse
    // tutte, si sceglie come sempre).
    //
    // **E SU UNA DOMANDA DI DENARO NON SPINGONO A MUOVERE BENI**: il lettore
    // cieco indipendente ha letto "Muovi il bene che hai fermo ... Usalo,
    // scambialo, offrilo" sotto "Conviene investire i miei risparmi in
    // borsa?". Stessa regola, con le voci che spingono a spendere,
    // scambiare, mettere in gioco.
    final perLaSalute = letta.delicato == AmbitoDelicato.salute;
    final perIlDenaro = letta.delicato == AmbitoDelicato.denaro;
    String prendi(String parte, String campo, String gruppo,
        {List<String>? fonte}) {
      final gia = diOggi[parte];
      if (gia != null) return gia;
      final voci = fonte ?? corpus.voci[campo]?[gruppo] ?? const <String>[];
      final n = voci.length;
      if (n == 0) {
        throw StateError('corpus incompleto: $campo/$gruppo');
      }
      bool vuota(int i) =>
          voci[i].trim().isEmpty ||
          vociTrattenute.contains('$campo/$gruppo/${i + 1}');
      final scheda = campo == CampiDelPresagio.consiglio ||
          campo == CampiDelPresagio.pietra;
      final faticosa = scheda && perLaSalute
          ? (int i) => sforzoFisico.hasMatch(voci[i])
          : scheda && perIlDenaro
              ? (int i) => spintaAMuovereBeni.hasMatch(voci[i])
              : null;
      final restano = faticosa == null
          ? true
          : [for (var i = 0; i < n; i++) i]
              .any((i) => !vuota(i) && !faticosa(i));
      final v = scegli(
        campo: campo,
        gruppo: gruppo,
        quante: n,
        persona: persona,
        memoria: memoria,
        giaPresi: presi,
        vuota: faticosa != null && restano
            ? (i) => vuota(i) || faticosa(i)
            : vuota,
      );
      presi.add(v);
      diOggi[parte] = v;
      memoria.letti[v] = giorno;
      return v;
    }

    final cosa = cosaDellaDomanda(domanda);
    String testo(String id, {String? cosaQui}) {
      final parti = id.split('/');
      final campo = parti.first;
      final numero = int.parse(parti.last);
      final gruppo = parti.sublist(1, parti.length - 1).join('/');
      final t = corpus.voci[campo]![gruppo]![numero - 1]
          .replaceAll('{cosa}', cosaQui ?? cosa)
          .replaceAll('{gettata}', esito.gettata.nome.toLowerCase());
      return LaMarcaDelGenere.risolvi(t, forma: forma);
    }

    // **LA RISPOSTA DIRETTA, ordine GA voce GA.06, la cura delle Rune, 21
    // ottobre 2026.** Qui il paragrafo era RISPOSTA piu' VERDETTO e il
    // riquadro era GESTO: nessuno dei tre dipendeva dalla domanda, e il
    // VERDETTO, scritto per una famiglia di rune, parlava di pietre che non
    // c'erano (lettori ciechi: la prima frase rispondeva in 6 responsi su
    // 40, il cosa fare era pertinente in 7). Adesso la domanda si legge
    // ([LaDomandaLetta]) e la prima frase risponde, dalla pietra che decide
    // nel suo verso e dal tema; il tono si conta sulle pietre vere; poi la
    // RISPOSTA del corpus spiega. Il riquadro e' scritto per la domanda nel
    // modo della pietra che decide; il GESTO resta per chi getta senza
    // domanda. Salute, legge e denaro hanno il loro limite per primo, e la
    // RISPOSTA del corpus li' non entra. Tutto in `la_risposta_della_gettata.dart`.
    final t = tono(pietre);
    final ambito = letta.delicato;
    // La stessa persona che rifa' la stessa domanda non legge sempre le
    // stesse forme.
    final variante = seme('$persona|$giorno|${letta.tipo.name}') % 7;
    final tipoDiretto = LeRisposteDirette.tipoDelCorpus(letta, domanda);
    final licenze = {
      ...LeRisposteDirette.licenze(domanda),
      // Una scelta di vita col suo lato di denaro: le schede leggono la
      // pietra sulla scelta e non spingono a muovere beni.
      if (letta.sceltaDiVita) 'denaro',
      // Le domande sugli altri hanno sempre una controparte.
      if (LeRisposteDirette.tipoDelCorpus(letta, domanda) == 'altrui')
        'controparte',
    };
    final note = letta.doppia
        ? LaRispostaDellaGettata.notaDellaSeconda(letta)
        : const [''];
    String voce(String v) => LaMarcaDelGenere.risolvi(v, forma: forma);

    // **LA POSTURA DEL PRESAGIO**: se il principale chiede di attendere,
    // nessuna scheda chiede di agire subito, e viceversa; e le schede non si
    // contraddicono fra loro (lettore cieco dell'ultimo giro: "Sospendi per
    // tre settimane ogni discorso decisivo" accanto a "chiedi entro tre giorni
    // un momento a quattr'occhi"). Si riempie dopo il principale.
    final posturaVietata = <String>{};

    /// **LA COPPIA: LA VOCE N DEL PARAGRAFO E LA VOCE N DEL RIQUADRO.** Gli
    /// scrittori hanno scritto l'azione che segue il suo paragrafo; sceglierle
    /// in due estrazioni separate dava un cosa fare che non seguiva la sua
    /// risposta (rune-21: "togli peso all'esito" sopra "dopo una settimana
    /// rileggi", lettore cieco, riapertura della voce GA.06). Si sceglie il
    /// paragrafo e il riquadro e' quello che gli sta accanto. Restituisce il
    /// paragrafo e il riquadro riempiti, o null se nessuna coppia sta nella
    /// misura con le parole della domanda.
    ///
    /// Con [nonRipetere] (le schede) un gruppo le cui voci la persona ha gia'
    /// lette tutte nei sessanta giorni non dà una coppia: la scheda passa alla
    /// coppia neutra e la voce non torna finche' ne resta una non letta. I
    /// gruppi "come" hanno cinque voci (otto per le pietre simmetriche): a chi
    /// getta tre volte al giorno finirebbero in due giorni.
    ({String paragrafo, String riquadro})? coppia(String parteDiretta,
        String parteAzione, String gruppo, List<String> valori, List<String> n,
        {String? preferito, bool nonRipetere = false}) {
      final persona = LeRisposteDirette.laPersona(
          letta, domanda, LeRisposteDirette.tipoDelCorpus(letta, domanda));
      final dirette = leRisposteDirette['diretta']?[gruppo];
      final azioni = leRisposteDirette['azione']?[gruppo];
      if (dirette == null ||
          azioni == null ||
          dirette.isEmpty ||
          dirette.length != azioni.length) {
        return null;
      }
      // Il primo valore (dal piu' fedele) per cui c'e' una coppia che sta
      // nella misura e non e' gia' stata presa in questo presagio.
      final ordine = [
        if (preferito != null && valori.contains(preferito)) preferito,
        ...valori.where((v) => v != preferito),
      ];
      final stato = diOggi[parteDiretta];
      for (final v in ordine) {
        final scelta = LeRisposteDirette.scegliValore(
          dirette: dirette,
          azioni: azioni,
          valori: [v],
          note: n,
          chiude: letta.chiude,
          forma: forma,
          licenze: {...licenze, ...posturaVietata},
          // Le voci gia' prese in questo presagio (o gia' lette, per le
          // schede) non contano: il livello dei filtri si sceglie su quelle
          // che restano, senza cadere al neutro perche' l'unica voce che
          // stava con i filtri piu' severi e' gia' del principale.
          soloSicuri: nonRipetere,
          occupata: (i) =>
              stato == null &&
              (presi.contains('diretta/$gruppo/${i + 1}') ||
                  (nonRipetere &&
                      memoria.letti.containsKey('diretta/$gruppo/${i + 1}'))),
        );
        if (scelta == null) continue;
        final fonte = [
          for (var i = 0; i < dirette.length; i++)
            scelta.stanno[i] &&
                    (stato != null ||
                        !presi.contains('diretta/$gruppo/${i + 1}'))
                ? dirette[i]
                : '',
        ];
        if (!fonte.any((x) => x.trim().isNotEmpty) && stato == null) continue;
        if (nonRipetere &&
            stato == null &&
            !List.generate(fonte.length, (i) => i).any((i) =>
                fonte[i].trim().isNotEmpty &&
                !memoria.letti.containsKey('diretta/$gruppo/${i + 1}'))) {
          continue;
        }
        final idDiretta = prendi(parteDiretta, 'diretta', gruppo, fonte: fonte);
        final numero = int.parse(idDiretta.split('/').last);
        final idAzione = 'azione/$gruppo/$numero';
        if (diOggi[parteAzione] == null) {
          diOggi[parteAzione] = idAzione;
          presi.add(idAzione);
          memoria.letti[idAzione] = giorno;
        }
        var p1 =
            LeRisposteDirette.riempi(voce(dirette[numero - 1]), [v], note: n);
        var p2 = LeRisposteDirette.riempi(voce(azioni[numero - 1]), [v],
            comeAzione: true);
        // La persona della domanda al posto di "chi e' coinvolto": solo se il
        // testo resta a misura.
        if (persona != null && p1 != null && p2 != null) {
          final q1 = LeRisposteDirette.conLaPersona(p1, persona);
          final q2 = LeRisposteDirette.conLaPersona(p2, persona);
          if (LaFormaDelResponso.aMisura(q1)) p1 = q1;
          if (LaFormaDelResponso.aMisura(q2)) p2 = q2;
        }
        if (p1 != null && p2 != null) return (paragrafo: p1, riquadro: p2);
      }
      return null;
    }

    /// **LA COPPIA NEUTRA: LA VOCE N DI UN CAMPO E LA VOCE N DEL SUO
    /// SEGUITO** (PIETRA e CONSIGLIO, RISPOSTA e GESTO). Il consiglio segue
    /// il suo paragrafo, e scegliere i due in estrazioni separate dava una
    /// scheda con il cosa fare slegato dalla sua risposta (lettore cieco,
    /// riapertura della voce GA.06). Si scelgono solo le coppie che non
    /// presuppongono una situazione (`le_voci_neutre.g.dart`).
    ({String a, String b}) coppiaNeutra(String campoA, String campoB,
        String parteA, String parteB, String gruppo) {
      final voci = corpus.voci[campoA]?[gruppo] ?? const <String>[];
      final strette = (neutre ?? leVociNeutre)[campoA]?[gruppo];
      // **PRIMA LE STRETTE, POI LE LARGHE, POI LA PIU' VECCHIA.** Le coppie
      // strette sono quelle che non presuppongono niente (cinque o piu' per
      // gruppo, non abbastanza per chi getta ogni giorno); quando la persona
      // le ha lette tutte nei sessanta giorni, la scelta passa alle larghe
      // (senza i divieti duri) invece di ripetere una voce: la regola dei
      // sessanta giorni (ordine EX voce 03) vale quanto la coerenza, e
      // vince su una voce che qui e li' puo' presupporre qualcosa.
      List<(int, int)>? largheQui;
      if (neutre == null) largheQui = leVociNeutreLarghe[campoA]?[gruppo];
      final stretteLette = strette != null &&
          strette.isNotEmpty &&
          diOggi[parteA] == null &&
          strette.every(
              (c) => memoria.letti.containsKey('$campoA/$gruppo/${c.$1}'));
      // Senza coppie strette per questo gruppo, le larghe: mai tutte le voci.
      final senzaStrette = strette == null || strette.isEmpty;
      var coppie = stretteLette
          ? [...strette, ...?largheQui]
          : senzaStrette
              ? largheQui
              : strette;
      // Una scheda non chiede di agire dove il presagio chiede di attendere,
      // e non presuppone una paura o un conflitto che la domanda non porta:
      // le coppie che lo fanno restano fuori, se ne resta qualcuna.
      if (coppie != null) {
        final seguiti = corpus.voci[campoB]?[gruppo] ?? const <String>[];
        bool vietata((int, int) c) {
          final a = c.$1 >= 1 && c.$1 <= voci.length ? voci[c.$1 - 1] : '';
          final b =
              c.$2 >= 1 && c.$2 <= seguiti.length ? seguiti[c.$2 - 1] : '';
          final p = LeRisposteDirette.postura(b);
          if ((p == 'azione' && posturaVietata.contains('noAzione')) ||
              (p == 'attesa' && posturaVietata.contains('noAttesa'))) {
            return true;
          }
          final testo = '$a $b';
          return (!licenze.contains('paura') &&
                  LeRisposteDirette.haLaPaura(testo)) ||
              (!licenze.contains('conflitto') &&
                  LeRisposteDirette.haIlConflitto(testo)) ||
              (licenze.contains('breve') &&
                  !licenze.contains('senzaBreve') &&
                  LeRisposteDirette.haUnTempoLungo(b));
        }

        // Il filtro e' una preferenza, non un divieto: la regola dei sessanta
        // giorni (ordine EX voce 03) vince. Si preferisce una coppia
        // ammessa e non ancora letta; se non ce n'e', una non ancora letta
        // anche se il filtro l'avrebbe tolta (meglio una voce che qui e li'
        // presuppone che una voce ripetuta); se tutte sono lette, fra le
        // ammesse.
        bool nonLetta((int, int) c) =>
            !memoria.letti.containsKey('$campoA/$gruppo/${c.$1}');
        final ammesse = [
          for (final c in coppie)
            if (!vietata(c)) c,
        ];
        if (ammesse.any(nonLetta)) {
          coppie = ammesse;
        } else if (!coppie.any(nonLetta) && ammesse.isNotEmpty) {
          coppie = ammesse;
        }
      }
      final scelti = {for (final c in coppie ?? const <(int, int)>[]) c.$1};
      final fonte = scelti.isEmpty
          ? null
          : [
              for (var i = 0; i < voci.length; i++)
                scelti.contains(i + 1) ? voci[i] : '',
            ];
      final idA = prendi(parteA, campoA, gruppo, fonte: fonte);
      final numero = int.parse(idA.split('/').last);
      // La voce che segue la scelta: quella che la somiglia, non sempre la
      // stessa numerata (il generato lo dice).
      final segue =
          coppie?.where((c) => c.$1 == numero).map((c) => c.$2).firstOrNull ??
              numero;
      final idB = diOggi[parteB] ?? '$campoB/$gruppo/$segue';
      if (diOggi[parteB] == null) {
        diOggi[parteB] = idB;
        presi.add(idB);
        memoria.letti[idB] = giorno;
      }
      return (a: idA, b: idB);
    }

    // **LE RISPOSTE DIRETTE, SCRITTE PER PIETRA E PER TIPO DI DOMANDA.**
    // Ordine GA voce GA.06, il secondo giro della cura delle Rune: il
    // lettore cieco indipendente, sulla prima cura (paragrafi montati da
    // frammenti), ha contato il cosa fare concreto in 25 responsi su 40 e la
    // coerenza in 24, con formule ripetute ("Lo chiede la pietra che decide"
    // 21 volte) e la persona della domanda sparita dietro un ambito. Qui il
    // paragrafo e il riquadro sono testi interi di `diretta.md` e
    // `azione.md`, scritti per la pietra che decide nel suo verso e per il
    // tipo della domanda, con la cosa della domanda nelle parole di chi
    // chiede (`LOggettoDellaDomanda`). Salute, legge e denaro restano col
    // loro limite; la giornata e le domande aperte del Cerchio restano come
    // prima.
    String? paragrafo;
    String? riquadroDiretto;
    String? gestoId;
    if (tipoDiretto != null) {
      final c = coppia(
        'diretta',
        'azione',
        '${gruppoDellaPietra(decide)}/$tipoDiretto',
        LeRisposteDirette.valori(letta, domanda, tipoDiretto),
        note,
      );
      if (c != null) {
        paragrafo = c.paragrafo;
        riquadroDiretto = c.riquadro;
      }
    }
    if (paragrafo != null) {
      // Le risposte dirette hanno gia' il paragrafo e il riquadro.
    } else if (ambito != null) {
      paragrafo = LaRispostaDellaGettata.paragrafoDelicato(
          domanda: letta, esito: esito, variante: variante);
    } else {
      final rg = coppiaNeutra(CampiDelPresagio.risposta, CampiDelPresagio.gesto,
          parteRisposta, parteGesto, gruppoDellaPietra(decide));
      gestoId = rg.b;
      final risposta = testo(rg.a);
      paragrafo = LaRispostaDellaGettata.paragrafoDellaRisposta(
          domanda: letta, esito: esito, risposta: risposta);
      // La riserva, che la prova `la_risposta_della_gettata_test.dart`
      // pretende mai usata: la forma di prima, sempre a misura.
      paragrafo ??=
          '$risposta ${testo(prendi(parteVerdetto, CampiDelPresagio.verdetto, '$t/${famigliaCheDomina(pietre, decide.rune.name)}'))}';
    }
    paragrafo ??= LaRispostaDellaGettata.primeFrasi(letta, esito).first;
    // Il riquadro: la risposta diretta; per salute, legge e denaro (e per
    // una domanda doppia che non trova la sua) quello composto; per la
    // giornata e le domande aperte del Cerchio il GESTO della pietra, un
    // gesto concreto che la formula composta non sapeva dare.
    final cosaFare = riquadroDiretto ??
        (ambito != null || letta.doppia
            ? LaRispostaDellaGettata.riquadro(
                domanda: letta, esito: esito, variante: variante)
            : null) ??
        testo(gestoId ??
            prendi(
                parteGesto, CampiDelPresagio.gesto, gruppoDellaPietra(decide)));
    // **L'APPROFONDIMENTO DELLA LUNGA E' COMPOSTO DALLE PIETRE USCITE**, non
    // scelto per tono dal corpus LEGAME: il tono non dice la direzione del
    // responso, e "il tempo e' maturo" stava sotto un "nessun verdetto"
    // (lettore cieco indipendente, riapertura della voce GA.06). Il LEGAME
    // resta il ripiego se la composizione non sta nella misura.
    // Il responso ha una direzione quando dice un verdetto: le decisioni e le
    // scelte, e le domande aperte e la giornata, che aprono con "la gettata
    // indica ... è il momento di muoverti" (percorso di prima).
    final direzione = tipoDiretto == 'decisione' ||
            tipoDiretto == 'scelta' ||
            (tipoDiretto == null && ambito == null)
        ? LaRispostaDellaGettata.classe(esito, chiude: letta.chiude)
        : null;
    final legame = lunga
        ? (LaRispostaDellaGettata.approfondimento(
              esito: esito,
              direzione: direzione,
              ambito: ambito,
              variante: variante,
            ) ??
            testo(prendi(parteLegame, CampiDelPresagio.legame, '$gettata/$t')))
        : null;
    final galdr = lunga ? galdrDi(decide, forma: forma) : null;

    // **LE SCHEDE DELLE SINGOLE PIETRE.** Ordine GA voce GA.06, riapertura: il
    // lettore cieco ha contato 21 schede su 34 con il "Cosa fare" slegato
    // dalla domanda o dalla propria risposta, perche' PIETRA e CONSIGLIO sono
    // scritti per ogni domanda (CONSIGLIO non porta nemmeno lo spazio della
    // cosa). Adesso la scheda di una pietra e' la coppia "come" di quella
    // pietra: il suo modo per la cosa della domanda, e l'azione che gli sta
    // accanto, senza un verdetto che potrebbe contraddire quello della pietra
    // che decide. Su salute, legge e denaro la scheda dice il limite e manda
    // a chi e' competente, come il principale.
    final posturaDelPrincipale =
        LeRisposteDirette.posturaDelVerdetto(paragrafo) ??
            LeRisposteDirette.postura(cosaFare);
    if (posturaDelPrincipale == 'attesa') posturaVietata.add('noAzione');
    if (posturaDelPrincipale == 'azione') posturaVietata.add('noAttesa');
    final schede = <ResponsoInterpretato>[];
    if (pietre.length > 1) {
      // La scelta di vita col suo lato di denaro (lasciare il lavoro, aprire
      // un'attivita') ha il limite nel principale e le schede come una
      // decisione: ognuna legge la sua pietra sulla scelta, senza ripetere il
      // rinvio al consulente e senza conti presunti.
      final ambitoSchede = letta.sceltaDiVita ? null : ambito;
      final tipoSchede = LeRisposteDirette.tipoDelleSchede(
          letta.sceltaDiVita ? 'decisione' : tipoDiretto);
      final valoriSchede = ambitoSchede == null && tipoSchede != null
          ? LeRisposteDirette.valoriPerLeSchede(
              letta, domanda, letta.sceltaDiVita ? 'decisione' : tipoDiretto)
          : const <String>[];
      // Lo stesso nome per la cosa in tutte le schede, se tutte le pietre lo
      // reggono: la persona della domanda non cambia da una scheda all'altra.
      String? comune;
      if (ambitoSchede == null && tipoSchede != null) {
        for (final v in valoriSchede) {
          final tutte = pietre.every((p) {
            final gr = '${gruppoDellaPietra(p)}/$tipoSchede';
            final dd = leRisposteDirette['diretta']?[gr];
            final aa = leRisposteDirette['azione']?[gr];
            if (dd == null || aa == null || dd.length != aa.length) {
              return false;
            }
            return LeRisposteDirette.scegliValore(
                  dirette: dd,
                  azioni: aa,
                  valori: [v],
                  note: const [''],
                  chiude: letta.chiude,
                  forma: forma,
                  licenze: {...licenze, ...posturaVietata},
                ) !=
                null;
          });
          if (tutte) {
            comune = v;
            break;
          }
        }
      }
      for (var i = 0; i < pietre.length; i++) {
        final p = pietre[i];
        String? rispostaScheda;
        String? cosaFareScheda;
        if (ambitoSchede != null) {
          rispostaScheda = LaRispostaDellaGettata.schedaDelicata(
              ambito: ambitoSchede, pietra: p, indice: i, variante: variante);
          cosaFareScheda = LaRispostaDellaGettata.consiglioDelicato(
              ambito: ambitoSchede,
              indice: i,
              variante: variante,
              escludi: cosaFare);
        } else if (tipoSchede != null) {
          final c = coppia(
            parteDellaPietra('diretta', p.rune.name),
            parteDellaPietra('azione', p.rune.name),
            '${gruppoDellaPietra(p)}/$tipoSchede',
            i.isOdd
                ? [
                    LeRisposteDirette.genericoPerLeSchede(tipoSchede),
                    ...valoriSchede,
                  ]
                : valoriSchede,
            const [''],
            preferito: i.isOdd
                ? LeRisposteDirette.genericoPerLeSchede(tipoSchede)
                : comune,
            nonRipetere: true,
          );
          rispostaScheda = c?.paragrafo;
          cosaFareScheda = c?.riquadro;
        }
        // Le vaghe, la giornata e le domande aperte del Cerchio non portano
        // una situazione: la scheda e' la coppia PIETRA/CONSIGLIO della
        // pietra, scelta fra le neutre. Lo stesso se nessuna coppia "come"
        // sta nella misura.
        if (rispostaScheda == null || cosaFareScheda == null) {
          final pc = coppiaNeutra(
              CampiDelPresagio.pietra,
              CampiDelPresagio.consiglio,
              parteDellaPietra(CampiDelPresagio.pietra, p.rune.name),
              parteDellaPietra(CampiDelPresagio.consiglio, p.rune.name),
              gruppoDellaPietra(p));
          // La cosa lunga della domanda ("ciò che non guardi di te") non apre
          // ogni scheda: le dispari dicono "questo momento" (lettura severa
          // del terzo giro, la cucitura ripetuta).
          final cosaQui =
              i.isOdd && cosa.split(' ').length >= 3 ? 'questo momento' : cosa;
          rispostaScheda = testo(pc.a, cosaQui: cosaQui);
          cosaFareScheda = testo(pc.b, cosaQui: cosaQui);
        }
        if (posturaVietata.isEmpty) {
          final ps = LeRisposteDirette.postura(cosaFareScheda);
          if (ps == 'attesa') posturaVietata.add('noAzione');
          if (ps == 'azione') posturaVietata.add('noAttesa');
        }
        schede.add(ResponsoInterpretato(
          arte: ArteInterpretata.rune,
          // **IL TITOLO LEGGE LA POSIZIONE**, ordine GA voce GA.06: era la
          // riga della runa, uguale in ogni posto, e una pietra
          // nell'Ostacolo si leggeva come un favore.
          titolo: LaRispostaDellaGettata.titoloDellaScheda(p,
              delicata: ambitoSchede != null),
          risposta: rispostaScheda,
          cosaFare: cosaFareScheda,
        ));
      }
    }
    return IlPresagioComposto(
      principale: ResponsoInterpretato(
        arte: ArteInterpretata.rune,
        titolo: ambito != null
            ? LaRispostaDellaGettata.titoloDelicato(ambito, decide,
                sceltaDiVita: letta.sceltaDiVita)
            : IlTitoloDellaGettata.di(esito),
        risposta: paragrafo,
        cosaFare: cosaFare,
        approfondimento: legame,
        rito: galdr,
        daDoveViene: daDoveViene(esito, lunga: lunga),
      ),
      schede: schede,
    );
  }

  /// **IL GALDR PROPIZIATORIO DELLA PIETRA CHE DECIDE**, ordine GA voce
  /// GA.04: *"Per le rune 'il galdr propiziatorio'"*. Il canto del nome della
  /// runa nel suo verso, da `docs/corpus/riti/galdr_delle_rune.md` (una voce
  /// per runa e verso, la stessa ogni volta che quella pietra decide: e' un
  /// gesto da ripetere ed e' fuori dalla regola dei sessanta giorni,
  /// SPECIFICA.md sezione 2).
  static String? galdrDi(RunaGettata pietra, {CourtesyForm? forma}) {
    final rito = IRitiPropiziatori.rito(IRitiPropiziatori.galdr,
        [pietra.rune.name, pietra.inOmbra ? 'in ombra' : 'dritta']);
    return rito == null ? null : LaMarcaDelGenere.risolvi(rito, forma: forma);
  }

  /// I poemi runici col loro nome italiano, nell'ordine in cui si citano.
  static const Map<String, String> _poemi = {
    'Old English Rune Poem': 'anglosassone',
    'Old Icelandic Rune Poem': 'islandese',
    'Old Norwegian Rune Rhyme': 'norvegese',
  };

  static String _elenco(List<String> voci) => voci.length < 2
      ? voci.join()
      : '${voci.sublist(0, voci.length - 1).join(', ')} e ${voci.last}';

  /// **IL "DA DOVE VIENE" DELLA GETTATA, composto dal codice**, ordine GA
  /// voce GA.05: *"Il 'Da dove viene' chiude la consultazione una volta sola
  /// in fondo e cita le fonti di tutte le carte o le rune uscite"*. Le fonti
  /// sono i poemi runici in cui le rune uscite sono attestate (`kRuneLore`,
  /// da `docs/corpus/rune.md`) e, nella Lunga, la pratica del galdr
  /// (Thorsson, voce GA.04: *"il 'Da dove viene' lo dice così"*). Non lo
  /// scrive il corpus: una fonte e' un fatto, e si legge dove sta.
  static String daDoveViene(EsitoGettata esito, {required bool lunga}) {
    final nomi = <String>[];
    for (final p in esito.rune) {
      if (!nomi.contains(p.rune.name)) nomi.add(p.rune.name);
    }
    final trovati = <String>{
      for (final n in nomi)
        for (final s in kRuneLore[n]?.strofe ?? const <StrofaRunica>[])
          if (_poemi.containsKey(s.fonte)) s.fonte,
    };
    final poemi = [
      for (final e in _poemi.entries)
        if (trovati.contains(e.key)) e.value,
    ];
    final da = switch (poemi.length) {
      0 => 'dalla tradizione runica del Futhark antico',
      1 => 'dal poema runico ${poemi.first}',
      _ => 'dai poemi runici medievali, ${_elenco([
              for (final p in poemi) p == 'norvegese' ? 'il $p' : 'l’$p'
            ])}',
    };
    final parti = [
      'Il senso di ${_elenco(nomi)}, nel verso in cui '
          '${nomi.length == 1 ? 'è uscita' : 'sono uscite'}, viene $da.',
      if (lunga)
        IRitiPropiziatori.fonte(IRitiPropiziatori.galdr, [
              pietraCheDecide(esito).rune.name,
              pietraCheDecide(esito).inOmbra ? 'in ombra' : 'dritta',
            ]) ??
            '',
    ];
    return parti.where((p) => p.trim().isNotEmpty).join(' ');
  }

  /// **CIO' DI CUI LA PERSONA CHIEDE**, con l'articolo. Per le domande del
  /// Cerchio un valore fisso, per una domanda scritta a mano la cosa
  /// riconosciuta dalle famiglie di parole, altrimenti "ciò che hai
  /// chiesto"; senza domanda "la tua giornata".
  ///
  /// **ORDINE GA VOCE GA.06, la cura delle Rune, 21 ottobre 2026.** I
  /// lettori ciechi hanno letto "ciò che hai chiesto" al posto del tema in
  /// 20 risposte su 40, e "l'amore" su una domanda di famiglia ("il pranzo
  /// di Natale con la famiglia di lui": la famiglia "lui" vinceva perche'
  /// era la prima dell'elenco). Adesso vince la famiglia la cui parola viene
  /// PRIMA nella domanda, i confini di parola sono scritti a mano (`\b` in
  /// Dart non vede "città", "papà"), le famiglie sono di piu' (il progetto,
  /// il cambiamento, l'attesa di una risposta, il trasferimento, lo studio
  /// con l'esame e il corso), e una domanda che tocca salute, legge o denaro
  /// ha per tema "il tuo stato d’animo": e' l'unica cosa di cui le rune
  /// parlano li' (ordine S voce 17), e le schede non leggono piu' l'esito di
  /// un'operazione, di una causa o di un investimento.
  static String cosaDellaDomanda(String domanda) {
    final d = LaDomandaLetta.normalizza(domanda);
    if (d.isEmpty) return 'la tua giornata';
    for (final e in _delCerchio.entries) {
      if (d == LaDomandaLetta.normalizza(e.key)) return e.value;
    }
    final delicato = LaDomandaLetta.ambitoDelicato(d);
    if (delicato != null) return LaRispostaDellaGettata.cosaDelicata(delicato);
    String? migliore;
    var dove = 1 << 30;
    final citta = _lasciareUnLuogo.firstMatch(domanda.trim());
    if (citta != null) {
      migliore = 'il trasferimento';
      dove = citta.start;
    }
    for (final (regola, cosa) in _famiglieCompilate) {
      final m = regola.firstMatch(d);
      if (m != null && m.start < dove) {
        dove = m.start;
        migliore = cosa;
      }
    }
    if (migliore != null) return migliore;
    if (LaDomandaLetta.parlaDiUnAltro(d)) return 'questo legame';
    if (LaDomandaLetta.eVaga(d)) return 'questo momento';
    return 'ciò che hai chiesto';
  }

  /// "Devo lasciare Roma": un luogo con la maiuscola dopo "lasciare" e' un
  /// trasferimento.
  static final RegExp _lasciareUnLuogo =
      RegExp(r'(?:^|\s)(?:lasciare|lascio|lasciando)\s+[A-ZÀ-Ý][a-zà-ÿ]+');

  static final List<(RegExp, String)> _famiglieCompilate = [
    for (final e in _famiglie.entries) (LaDomandaLetta.parola(e.key), e.value),
  ];

  /// **LE DOMANDE DEL CERCHIO VENGONO DAL PUNTO UNICO**
  /// (`DomandeDelCerchio`, ordine S voce 21): qui stanno solo le cose della
  /// specifica (SPECIFICA.md, sezione 2), nello stesso ordine delle otto
  /// generiche e delle quattro personali della gettata.
  static const List<String> _coseDelleDomande = [
    'il tuo momento',
    'l’amore',
    'il lavoro',
    'la scelta che ti blocca',
    'questa situazione',
    'ciò che va lasciato',
    'ciò su cui insistere',
    'ciò che non guardi di te',
    'ciò che continua da ieri sera',
    'la parola di stamattina',
    'il tuo animale guida',
    'il tuo archetipo',
  ];

  static final Map<String, String> _delCerchio = () {
    final domande = [
      ...DomandeDelCerchio.generichePerLaGettata,
      ...DomandeDelCerchio.personaliPerLaGettata,
    ];
    assert(domande.length == _coseDelleDomande.length);
    return {
      for (var i = 0; i < domande.length && i < _coseDelleDomande.length; i++)
        domande[i].testo: _coseDelleDomande[i],
    };
  }();

  /// Le famiglie di parole: una regola sulla domanda in minuscolo con gli
  /// apostrofi dritti, i confini di parola li mette [LaDomandaLetta.parola].
  /// Vince la famiglia la cui parola viene prima nella domanda. Il denaro non
  /// c'e' piu' (ordine GA voce GA.06): e' un ambito delicato, e il suo tema e'
  /// "il tuo stato d’animo".
  static const Map<String, String> _famiglie = {
    r'amor\w*|innamorat\w*|fidanzat\w*|marit[oi]|mogli\w*|spos\w*|relazion\w*|compagn[oa]|ragazz[oa]|partner|ex|mi ama|lui|lei':
        'l’amore',
    r'lavor\w*|capo|capi|colleg[ah]\w*|colloqui\w*|carrier\w*|uffici\w*|promozion\w*|aziend\w*|attività|impieg\w*|assunzion\w*|licenzia\w*|client\w*':
        'il lavoro',
    r'cas[ae]|appartament\w*|trasloc\w*': 'la casa',
    r'trasferi\w*|andare a vivere|cambiare città|emigra\w*': 'il trasferimento',
    r'madre|padre|mamma|papà|sorell\w*|fratell\w*|figli\w*|famigli\w*|genitor\w*|suocer\w*|nonn[aoie]|nipot\w*|parent\w*':
        'la tua famiglia',
    r'amic\w*': 'l’amicizia',
    r'studi\w*|esam[ei]|universit\w*|scuola|laurea|master|cors[oi]|maturità|concors\w*':
        'lo studio',
    r'progett\w*': 'il progetto',
    r'cambiament\w*': 'il cambiamento',
    r'(risposta|notizia|chiamata) che aspett\w*|aspett\w* (una|la) (risposta|notizia)':
        'la risposta che aspetti',
    r'periodo|stallo': 'questo periodo',
    r'incontrer\w*|qualcuno di importante|anima gemella':
        'l’incontro che cerchi',
    r'scelt\w*|decid\w*|decision\w*': 'la tua scelta',
  };
}

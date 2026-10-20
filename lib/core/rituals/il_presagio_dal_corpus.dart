import '../domande/domande_del_cerchio.dart';
import 'dart:convert';

import '../chat/user_profile.dart';
import '../responsi/i_riti_propiziatori.dart';
import '../responsi/la_forma_del_responso.dart';
import 'il_titolo_della_gettata.dart';
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
  static int _seme(String testo) {
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
    var stato = _seme('$persona|$campo|$gruppo');
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
    String prendi(String parte, String campo, String gruppo) {
      final gia = diOggi[parte];
      if (gia != null) return gia;
      final n = corpus.voci[campo]?[gruppo]?.length ?? 0;
      if (n == 0) {
        throw StateError('corpus incompleto: $campo/$gruppo');
      }
      final v = scegli(
        campo: campo,
        gruppo: gruppo,
        quante: n,
        persona: persona,
        memoria: memoria,
        giaPresi: presi,
        vuota: (i) =>
            corpus.voci[campo]![gruppo]![i].trim().isEmpty ||
            vociTrattenute.contains('$campo/$gruppo/${i + 1}'),
      );
      presi.add(v);
      diOggi[parte] = v;
      memoria.letti[v] = giorno;
      return v;
    }

    final cosa = cosaDellaDomanda(domanda);
    String testo(String id) {
      final parti = id.split('/');
      final campo = parti.first;
      final numero = int.parse(parti.last);
      final gruppo = parti.sublist(1, parti.length - 1).join('/');
      final t = corpus.voci[campo]![gruppo]![numero - 1]
          .replaceAll('{cosa}', cosa)
          .replaceAll('{gettata}', esito.gettata.nome.toLowerCase());
      return LaMarcaDelGenere.risolvi(t, forma: forma);
    }

    // **IL VERDETTO SEGUE IL TONO VERO DELLA GETTATA**, non quello della
    // sola pietra che decide: dice come pesa l'insieme, e una gettata in
    // ombra con la pietra che decide dritta resta in ombra nel suo insieme
    // (nota degli scrittori dell'ordine GA, R2).
    final t = tono(pietre);
    final risposta = testo(prendi(
        parteRisposta, CampiDelPresagio.risposta, gruppoDellaPietra(decide)));
    final verdetto = testo(prendi(parteVerdetto, CampiDelPresagio.verdetto,
        '$t/${famigliaCheDomina(pietre, decide.rune.name)}'));
    final gesto = testo(
        prendi(parteGesto, CampiDelPresagio.gesto, gruppoDellaPietra(decide)));
    final legame = lunga
        ? testo(prendi(parteLegame, CampiDelPresagio.legame, '$gettata/$t'))
        : null;
    final galdr = lunga ? galdrDi(decide, forma: forma) : null;
    final schede = <ResponsoInterpretato>[
      if (pietre.length > 1)
        for (final p in pietre)
          ResponsoInterpretato(
            arte: ArteInterpretata.rune,
            titolo: p.riga.trim(),
            risposta: testo(prendi(
                parteDellaPietra(CampiDelPresagio.pietra, p.rune.name),
                CampiDelPresagio.pietra,
                gruppoDellaPietra(p))),
            cosaFare: testo(prendi(
                parteDellaPietra(CampiDelPresagio.consiglio, p.rune.name),
                CampiDelPresagio.consiglio,
                gruppoDellaPietra(p))),
          ),
    ];
    return IlPresagioComposto(
      principale: ResponsoInterpretato(
        arte: ArteInterpretata.rune,
        titolo: IlTitoloDellaGettata.di(esito),
        risposta: '$risposta $verdetto',
        cosaFare: gesto,
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
  static String cosaDellaDomanda(String domanda) {
    final d = domanda.trim().toLowerCase();
    if (d.isEmpty) return 'la tua giornata';
    for (final e in _delCerchio.entries) {
      if (d == e.key.toLowerCase()) return e.value;
    }
    for (final e in _famiglie.entries) {
      if (RegExp(e.key, caseSensitive: false).hasMatch(d)) return e.value;
    }
    return 'ciò che hai chiesto';
  }

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

  static const Map<String, String> _famiglie = {
    r'\b(amor\w*|innamorat\w*|fidanzat\w*|marit\w*|mogli\w*|sposar\w*|relazion\w*|lui|lei)\b':
        'l’amore',
    r'\b(lavor\w*|cap[oi]\b|colloqui\w*|carrier\w*|uffici\w*|promozion\w*)':
        'il lavoro',
    r'\b(cas[ae]|trasloc\w*|trasferi\w*|citt[aà])\b': 'la casa',
    r'\b(madre|padre|mamma|pap[aà]|sorell\w*|fratell\w*|figli\w*|famigli\w*)\b':
        'la tua famiglia',
    r'\b(amic\w*)\b': 'l’amicizia',
    r'\b(soldi|denaro|debit\w*|spes[ae]\w*|prestit\w*)\b': 'il denaro',
    r'\b(studi\w*|esam\w*|universit\w*|scuola)\b': 'lo studio',
    r'\b(scelt\w*|decid\w*|decision\w*)\b': 'la tua scelta',
  };
}

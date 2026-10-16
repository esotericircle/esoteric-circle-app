import '../domande/domande_del_cerchio.dart';
import 'dart:convert';

import '../chat/user_profile.dart';
import '../responsi/anatomia_del_responso.dart';
import 'rune_cast.dart';

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

/// I cinque campi del corpus, nell'ordine della specifica.
abstract final class CampiDelPresagio {
  static const String risposta = 'risposta';
  static const String verdetto = 'verdetto';
  static const String pietra = 'pietra';
  static const String legame = 'legame';
  static const String gesto = 'gesto';
  static const List<String> tutti = [risposta, verdetto, pietra, legame, gesto];
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
class LaMemoriaDelPresagio {
  LaMemoriaDelPresagio({
    Map<String, String>? letti,
    Map<String, List<String>>? diOggi,
    this.giornoDiOggi = '',
  })  : letti = letti ?? {},
        diOggi = diOggi ?? {};

  /// Identificativo della voce, giorno "aaaa-mm-gg" dell'ultima lettura.
  final Map<String, String> letti;

  /// Il giorno a cui si riferisce [diOggi].
  String giornoDiOggi;

  /// Per firma della gettata, gli identificativi del presagio dato oggi.
  final Map<String, List<String>> diOggi;

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
        'letti': letti,
        'giornoDiOggi': giornoDiOggi,
        'diOggi': diOggi,
      });

  static LaMemoriaDelPresagio daTesto(String? testo) {
    if (testo == null || testo.isEmpty) return LaMemoriaDelPresagio();
    try {
      final j = jsonDecode(testo) as Map<String, dynamic>;
      return LaMemoriaDelPresagio(
        letti: (j['letti'] as Map? ?? {}).cast<String, String>(),
        giornoDiOggi: j['giornoDiOggi'] as String? ?? '',
        diOggi: {
          for (final e in (j['diOggi'] as Map? ?? {}).entries)
            '${e.key}': (e.value as List).cast<String>(),
        },
      );
    } on FormatException {
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

  /// **IL PRESAGIO**, nelle tre parti che la persona vede oggi.
  ///
  /// [cosa] e' cio' di cui la persona chiede, con l'articolo (vedi
  /// [cosaDellaDomanda]); [persona] l'identificativo che semina l'ordine
  /// delle voci; [memoria] si aggiorna con le voci lette.
  static Responso componi({
    required CorpusDelPresagio corpus,
    required EsitoGettata esito,
    required String domanda,
    required String persona,
    required DateTime oggi,
    required LaMemoriaDelPresagio memoria,
    CourtesyForm? forma,
  }) {
    memoria.pota(oggi);
    final pietre = esito.rune;
    final gettata = esito.gettata.id;
    final decide =
        pietre[indiceDellaPietraCheDecide(gettata).clamp(0, pietre.length - 1)];
    final laFirma = firma(esito, domanda);
    final gia = memoria.diOggi[laFirma];
    final presi = <String>[];
    String prendi(String campo, String gruppo) {
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
        giaPresi: presi.toSet(),
        vuota: (i) =>
            corpus.voci[campo]![gruppo]![i].trim().isEmpty ||
            vociTrattenute.contains('$campo/$gruppo/${i + 1}'),
      );
      presi.add(v);
      return v;
    }

    final List<String> ids;
    if (gia != null) {
      ids = gia;
    } else {
      final t = tono(pietre);
      ids = [
        prendi(CampiDelPresagio.risposta, gruppoDellaPietra(decide)),
        prendi(CampiDelPresagio.verdetto,
            '$t/${famigliaCheDomina(pietre, decide.rune.name)}'),
        for (final p in pietre)
          prendi(CampiDelPresagio.pietra, gruppoDellaPietra(p)),
        prendi(CampiDelPresagio.legame, '$gettata/$t'),
        prendi(CampiDelPresagio.gesto, gruppoDellaPietra(decide)),
      ];
      final giorno = LaMemoriaDelPresagio.chiaveDelGiorno(oggi);
      for (final v in ids) {
        memoria.letti[v] = giorno;
      }
      memoria.diOggi[laFirma] = ids;
    }

    final cosa = cosaDellaDomanda(domanda);
    String testo(String id, {RunaGettata? pietra}) {
      final parti = id.split('/');
      final campo = parti.first;
      final numero = int.parse(parti.last);
      final gruppo = parti.sublist(1, parti.length - 1).join('/');
      var t = corpus.voci[campo]![gruppo]![numero - 1];
      t = t
          .replaceAll('{cosa}', cosa)
          .replaceAll('{gettata}', esito.gettata.nome.toLowerCase());
      if (pietra != null) {
        t = t
            .replaceAll('{posizione}', pietra.posizione.titolo)
            .replaceAll('{glossa}', pietra.posizione.glossa);
      }
      return LaMarcaDelGenere.risolvi(t, forma: forma);
    }

    final daPietre = [
      for (var i = 0; i < pietre.length; i++)
        testo(ids[2 + i], pietra: pietre[i])
    ];
    return Responso(
      risposta: '${testo(ids[0])} ${testo(ids[1])}',
      cosaPuoiFare: testo(ids.last),
      daDoveViene: [...daPietre, testo(ids[ids.length - 2])].join(' '),
    );
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

/// **IL LINGUAGGIO DEL CERCHIO, ordine EY voci 10, 11 e 12.** Un file di dati
/// e non righe sparse: i segni con le loro risposte, le reazioni, i doni.
///
/// **ZERO TESTO LIBERO.** In nessun punto del motore sociale una persona
/// scrive una frase che un'altra leggera': si sceglie un segno, si risponde
/// scegliendo, si reagisce con una figura. Cosi' lo scambio esiste senza aprire
/// il testo, e con lui gli insulti, le molestie e la moderazione.
///
/// **I TESTI SONO SEGNAPOSTO DICHIARATI.** Le frasi dei segni e delle risposte
/// le scrive l'Architetto: queste sono di Code, scritte perche' il motore si
/// possa provare a video, e vanno riscritte. Gli identificativi invece restano:
/// sono quelli che il server conosce (`RISPOSTE_PER_SEGNO` in
/// `functions/src/sociale.ts`), e una prova pretende che i due elenchi
/// coincidano, con lo stesso numero di risposte.
enum CategoriaDelSegno {
  personali('Personali'),
  astrali('Astrali'),
  richieste('Facciamo insieme');

  const CategoriaDelSegno(this.titolo);
  final String titolo;
}

/// Il disegno di un segno: ogni segno arriva come una cosa da guardare prima
/// che da leggere, nella palette del Maestro di chi lo manda.
enum MotivoDelSegno {
  fiamma,
  luna,
  stella,
  spirale,
  sole,
  onda,
  mano,
  sentiero,
  pianeta,
  carta,
  runa,
  respiro,
}

/// Cosa apre una richiesta, al tocco di chi la riceve.
enum ArteDellaRichiesta { confronto, tarocchi, rune, meditazione, oroscopo }

class SegnoDelCerchio {
  const SegnoDelCerchio({
    required this.id,
    required this.categoria,
    required this.testo,
    required this.risposte,
    required this.motivo,
    this.apre,
  });

  final String id;
  final CategoriaDelSegno categoria;
  final String testo;

  /// Da due a quattro risposte, scelte da chi riceve.
  final List<String> risposte;
  final MotivoDelSegno motivo;

  /// Per le richieste: la funzione che si apre al tocco di chi riceve.
  final ArteDellaRichiesta? apre;
}

abstract final class ISegniDelCerchio {
  static const List<SegnoDelCerchio> tutti = [
    // PERSONALI
    SegnoDelCerchio(
        id: 'tiPenso',
        categoria: CategoriaDelSegno.personali,
        testo: 'Ti penso',
        risposte: ['Anch’io ti penso', 'Mi fa bene saperlo', 'Grazie'],
        motivo: MotivoDelSegno.fiamma),
    SegnoDelCerchio(
        id: 'miManchi',
        categoria: CategoriaDelSegno.personali,
        testo: 'Mi manchi',
        risposte: ['Anche tu', 'Sentiamoci presto', 'Ti abbraccio'],
        motivo: MotivoDelSegno.luna),
    SegnoDelCerchio(
        id: 'buonCammino',
        categoria: CategoriaDelSegno.personali,
        testo: 'Buon cammino',
        risposte: ['Anche a te', 'Ne avevo bisogno'],
        motivo: MotivoDelSegno.sentiero),
    SegnoDelCerchio(
        id: 'sonoQui',
        categoria: CategoriaDelSegno.personali,
        testo: 'Sono qui per te',
        risposte: ['Lo so', 'Grazie', 'Ci conto'],
        motivo: MotivoDelSegno.mano),
    SegnoDelCerchio(
        id: 'coraggio',
        categoria: CategoriaDelSegno.personali,
        testo: 'Coraggio',
        risposte: ['Grazie', 'Ce la farò'],
        motivo: MotivoDelSegno.stella),
    SegnoDelCerchio(
        id: 'grazieDiEsserci',
        categoria: CategoriaDelSegno.personali,
        testo: 'Grazie di esserci',
        risposte: ['Sempre', 'Grazie a te'],
        motivo: MotivoDelSegno.spirale),
    // ASTRALI
    SegnoDelCerchio(
        id: 'ilTuoCielo',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Hai visto il tuo cielo di oggi?',
        risposte: ['Sì, l’ho visto', 'Lo guardo adesso', 'Non ancora'],
        motivo: MotivoDelSegno.stella),
    SegnoDelCerchio(
        id: 'martePerTe',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Guarda cosa dice Marte per te',
        risposte: ['Lo guardo adesso', 'Già visto', 'Grazie'],
        motivo: MotivoDelSegno.pianeta),
    SegnoDelCerchio(
        id: 'lunaPerTe',
        categoria: CategoriaDelSegno.astrali,
        testo: 'La Luna stanotte è per te',
        risposte: ['La guarderò', 'Che bello', 'Grazie'],
        motivo: MotivoDelSegno.luna),
    SegnoDelCerchio(
        id: 'venerePerTe',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Venere oggi ti guarda',
        risposte: ['Lo sento', 'Speriamo', 'Grazie'],
        motivo: MotivoDelSegno.pianeta),
    SegnoDelCerchio(
        id: 'ilSoleTiCerca',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Il Sole oggi ti cerca',
        risposte: ['Mi faccio trovare', 'Grazie'],
        motivo: MotivoDelSegno.sole),
    SegnoDelCerchio(
        id: 'stelleDiStanotte',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Guarda le stelle stanotte',
        risposte: ['Lo farò', 'Insieme', 'Grazie'],
        motivo: MotivoDelSegno.stella),
    // RICHIESTE: non sono messaggi, sono inviti a fare una cosa insieme.
    SegnoDelCerchio(
        id: 'confrontiamoICieli',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Confrontiamo i cieli di oggi',
        risposte: ['Sì, confrontiamoli', 'Più tardi'],
        motivo: MotivoDelSegno.onda,
        apre: ArteDellaRichiesta.confronto),
    SegnoDelCerchio(
        id: 'facciamoLaSinastria',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Facciamo la sinastria',
        risposte: ['Sì, facciamola', 'Più tardi'],
        motivo: MotivoDelSegno.spirale,
        apre: ArteDellaRichiesta.confronto),
    SegnoDelCerchio(
        id: 'stessaCarta',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Estraiamo oggi la stessa carta',
        risposte: ['Estraggo adesso', 'Più tardi'],
        motivo: MotivoDelSegno.carta,
        apre: ArteDellaRichiesta.tarocchi),
    SegnoDelCerchio(
        id: 'stessaRuna',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Gettiamo le rune insieme',
        risposte: ['Le getto adesso', 'Più tardi'],
        motivo: MotivoDelSegno.runa,
        apre: ArteDellaRichiesta.rune),
    SegnoDelCerchio(
        id: 'respiriamoInsieme',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Respiriamo insieme',
        risposte: ['Respiro con te', 'Più tardi'],
        motivo: MotivoDelSegno.respiro,
        apre: ArteDellaRichiesta.meditazione),
    SegnoDelCerchio(
        id: 'alzaLoSguardo',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Leggiamo il cielo di oggi',
        risposte: ['Lo leggo adesso', 'Più tardi'],
        motivo: MotivoDelSegno.sole,
        apre: ArteDellaRichiesta.oroscopo),
  ];

  static SegnoDelCerchio? perId(String id) {
    for (final s in tutti) {
      if (s.id == id) return s;
    }
    return null;
  }

  static List<SegnoDelCerchio> di(CategoriaDelSegno c) => [
        for (final s in tutti)
          if (s.categoria == c) s
      ];
}

/// **LE REAZIONI, ordine EY voce 11.** Una reazione RISPONDE a un segno
/// ricevuto, un gesto PARTE da zero: il verso negativo esiste solo qui. Tutte
/// gratuite, la pernacchia compresa, e le negative restano private fra i due.
enum Reazione {
  luce('Luce', negativa: false),
  abbraccio('Abbraccio', negativa: false),
  grazie('Grazie', negativa: false),
  sorriso('Sorriso', negativa: false),
  pensiero('Ci penso', negativa: false),
  pernacchia('Pernacchia', negativa: true),
  occhiAlCielo('Occhi al cielo', negativa: true);

  const Reazione(this.nome, {required this.negativa});
  final String nome;
  final bool negativa;

  static Reazione? da(String? id) {
    for (final r in values) {
      if (r.name == id) return r;
    }
    return null;
  }
}

/// **I DONI, ordine EY voce 12**, tutti nel verso positivo. Il prezzo NON sta
/// qui: sta nel listino degli Eos (`ListinoDegliEos.scintilla` e
/// `.sigilloDaDonare`), dove vivono tutti i prezzi. Il dono non conia Eos a
/// chi lo riceve: resta nel suo profilo come ornamento.
enum Dono {
  cenno('Un cenno', 'Il saluto del Cerchio'),
  scintilla('Una scintilla', 'Una luce piccola che resta'),
  sigillo('Un sigillo', 'Il dono più alto del Cerchio');

  const Dono(this.nome, this.riga);
  final String nome;
  final String riga;

  static Dono? da(String? id) {
    for (final d in values) {
      if (d.name == id) return d;
    }
    return null;
  }
}

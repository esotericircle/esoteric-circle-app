/// **IL LINGUAGGIO DEL CERCHIO, ordine EY voci 10, 11 e 12.** Un file di dati
/// e non righe sparse: i segni con le loro risposte, le reazioni, i doni.
///
/// **ZERO TESTO LIBERO.** In nessun punto del motore sociale una persona
/// scrive una frase che un'altra leggera': si sceglie un segno, si risponde
/// scegliendo, si reagisce con una figura. Cosi' lo scambio esiste senza aprire
/// il testo, e con lui gli insulti, le molestie e la moderazione.
///
/// **I TESTI SONO DELL'ARCHITETTO, ordine EZ voce 08.** Nell'ordine EY
/// erano segnaposto dichiarati di Code; il 4 ottobre 2026 l'Architetto li ha
/// scritti, e i segnaposto sono usciti tutti. Gli identificativi invece
/// restano: sono quelli che il server conosce (`RISPOSTE_PER_SEGNO` in
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

/// Cosa apre una richiesta, al tocco di chi la riceve (ordine EZ voce 08).
enum ArteDellaRichiesta {
  confronto,
  sinastria,
  tarocchi,
  rune,
  archetipo,
  glifo
}

class SegnoDelCerchio {
  const SegnoDelCerchio({
    required this.id,
    required this.categoria,
    required this.testo,
    required this.rigaDiChiRiceve,
    required this.risposte,
    required this.motivo,
    this.apre,
  });

  final String id;
  final CategoriaDelSegno categoria;

  /// Il titolo sul pulsante di chi manda.
  final String testo;

  /// La riga che legge chi riceve. **Non nomina mai la persona**: il nome lo
  /// mette la cornice, cosi' la stessa riga vale per tutti e non si compone a
  /// mano. "Qualcuno" sta dove chi riceve non ha ancora aperto il segno; dove
  /// il nome e' gia' a schermo, la cornice lo mostra e la riga resta com'e'.
  final String rigaDiChiRiceve;

  /// Da due a quattro risposte, scelte da chi riceve.
  final List<String> risposte;
  final MotivoDelSegno motivo;

  /// Per le richieste: la funzione che si apre al tocco di chi riceve, sulla
  /// prima risposta.
  final ArteDellaRichiesta? apre;
}

/// **I DICIOTTO SEGNI DEL CERCHIO, coi testi dell'Architetto, ordine EZ voce
/// 08 (4 ottobre 2026).** I testi provvisori di Code dell'ordine EY sono
/// usciti tutti. Gli identificativi NON sono cambiati, perche' li conosce il
/// server (`RISPOSTE_PER_SEGNO` in `functions/src/sociale.ts`): ai diciotto
/// identificativi di prima stanno i diciotto segni nuovi, nella stessa
/// categoria. Per sei di loro l'identificativo dice ancora la cosa di prima
/// (`coraggio`, `grazieDiEsserci`, `martePerTe`, `venerePerTe`,
/// `ilSoleTiCerca`, `stelleDiStanotte` fra personali e astrali,
/// `respiriamoInsieme` e `alzaLoSguardo` fra le richieste): e' un nome
/// interno che nessuno legge, e cambiarlo vorrebbe dire cambiare il server.
abstract final class ISegniDelCerchio {
  static const List<SegnoDelCerchio> tutti = [
    // PERSONALI
    SegnoDelCerchio(
        id: 'tiPenso',
        categoria: CategoriaDelSegno.personali,
        testo: 'Ti penso',
        rigaDiChiRiceve: 'Qualcuno nel Cerchio ti ha pensato.',
        risposte: ['Anch’io', 'Grazie, ci voleva', 'Raccontami'],
        motivo: MotivoDelSegno.fiamma),
    SegnoDelCerchio(
        id: 'buonCammino',
        categoria: CategoriaDelSegno.personali,
        testo: 'Buon cammino',
        rigaDiChiRiceve: 'Che il tuo passo oggi sia leggero.',
        risposte: ['Anche il tuo', 'Mi serviva'],
        motivo: MotivoDelSegno.sentiero),
    SegnoDelCerchio(
        id: 'miManchi',
        categoria: CategoriaDelSegno.personali,
        testo: 'Mi manchi',
        rigaDiChiRiceve: 'Qualcuno sente la tua mancanza nel Cerchio.',
        risposte: ['Anche tu a me', 'Torno presto'],
        motivo: MotivoDelSegno.spirale),
    SegnoDelCerchio(
        id: 'sonoQui',
        categoria: CategoriaDelSegno.personali,
        testo: 'Sono con te',
        rigaDiChiRiceve: 'Qualcuno è con te in questo passaggio.',
        risposte: ['Lo sentivo', 'Grazie di esserci'],
        motivo: MotivoDelSegno.mano),
    SegnoDelCerchio(
        id: 'coraggio',
        categoria: CategoriaDelSegno.personali,
        testo: 'Hai fatto molta strada',
        // La riga dell'Architetto e' al maschile: si marca (ordine DL), e il
        // neutro la riformula, l'unico ritocco al suo testo.
        rigaDiChiRiceve:
            '[Qualcuno ha visto quanto sei arrivato lontano.|Qualcuno ha visto '
            'quanto sei arrivata lontano.|Qualcuno ha visto quanta strada hai '
            'fatto.]',
        risposte: ['Grazie', 'Un pezzo è merito tuo'],
        motivo: MotivoDelSegno.stella),
    SegnoDelCerchio(
        id: 'grazieDiEsserci',
        categoria: CategoriaDelSegno.personali,
        testo: 'Buona notte',
        rigaDiChiRiceve: 'Che la notte ti sia amica.',
        risposte: ['Anche a te', 'Ne avevo bisogno'],
        motivo: MotivoDelSegno.luna),
    // ASTRALI
    //
    // **UN SEGNO INVITA A GUARDARE IL CIELO, NON DICHIARA MAI UN FATTO DEL
    // CIELO.** "La Luna è nel tuo segno" mandato da una persona a un'altra
    // sarebbe falso per quasi tutti quelli che lo ricevono: un fatto del cielo
    // si calcola e si mostra come responso, non si manda come segno. Nessuno
    // dei sei qui sotto afferma niente: tutti e sei mandano a vedere. La
    // prova `i_segni_del_cerchio_hanno_i_testi_veri` lo pretende.
    SegnoDelCerchio(
        id: 'ilTuoCielo',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Guarda il tuo cielo',
        rigaDiChiRiceve: 'Qualcuno ti manda a leggere il tuo cielo di oggi.',
        risposte: ['L’ho letto', 'Ci vado adesso'],
        motivo: MotivoDelSegno.pianeta),
    SegnoDelCerchio(
        id: 'lunaPerTe',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Chiedi alla Luna',
        rigaDiChiRiceve: 'Qualcuno ti manda dalla Luna di stanotte.',
        risposte: ['Lo faccio', 'Dimmi cosa hai visto tu'],
        motivo: MotivoDelSegno.luna),
    SegnoDelCerchio(
        id: 'martePerTe',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Pesca la tua carta',
        rigaDiChiRiceve: 'Qualcuno ti manda a scoprire la tua carta di oggi.',
        risposte: ['Pescata', 'Quale è uscita a te?'],
        motivo: MotivoDelSegno.carta),
    SegnoDelCerchio(
        id: 'venerePerTe',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Getta una runa',
        rigaDiChiRiceve: 'Qualcuno ti manda a gettare una runa.',
        risposte: ['Gettata', 'Quale è uscita a te?'],
        motivo: MotivoDelSegno.runa),
    SegnoDelCerchio(
        id: 'ilSoleTiCerca',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Chiedi a un Maestro',
        rigaDiChiRiceve:
            'Qualcuno ti manda a fare la domanda che non fai a nessuno.',
        risposte: ['Ci vado', 'L’ho già fatta'],
        motivo: MotivoDelSegno.respiro),
    SegnoDelCerchio(
        id: 'stelleDiStanotte',
        categoria: CategoriaDelSegno.astrali,
        testo: 'Cerca il tuo animale',
        rigaDiChiRiceve: 'Qualcuno ti manda a cercare il tuo animale guida.',
        risposte: ['Ci vado', 'È arrivato'],
        motivo: MotivoDelSegno.sentiero),
    // RICHIESTE: non sono messaggi, sono inviti a fare una cosa insieme, e
    // ognuna apre la sua funzione al tocco della prima risposta.
    SegnoDelCerchio(
        id: 'confrontiamoICieli',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Confrontiamo i cieli',
        rigaDiChiRiceve: 'Qualcuno vuole mettere il suo cielo accanto al tuo.',
        risposte: ['Apriamolo', 'Non adesso'],
        motivo: MotivoDelSegno.onda,
        apre: ArteDellaRichiesta.confronto),
    SegnoDelCerchio(
        id: 'facciamoLaSinastria',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Facciamo la sinastria',
        rigaDiChiRiceve: 'Qualcuno vuole sapere come state insieme, nel cielo.',
        risposte: ['Vediamo', 'Non adesso'],
        motivo: MotivoDelSegno.spirale,
        apre: ArteDellaRichiesta.sinastria),
    SegnoDelCerchio(
        id: 'stessaCarta',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Stessa carta, oggi',
        rigaDiChiRiceve:
            'Qualcuno vuole estrarre la carta nello stesso momento tuo.',
        risposte: ['Estraiamo', 'Più tardi'],
        motivo: MotivoDelSegno.carta,
        apre: ArteDellaRichiesta.tarocchi),
    SegnoDelCerchio(
        id: 'stessaRuna',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Mostrami la tua runa',
        rigaDiChiRiceve: 'Qualcuno vuole vedere quale runa ti è uscita oggi.',
        risposte: ['Te la mostro', 'Oggi non l’ho gettata'],
        motivo: MotivoDelSegno.runa,
        apre: ArteDellaRichiesta.rune),
    SegnoDelCerchio(
        id: 'respiriamoInsieme',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Che archetipo sei',
        rigaDiChiRiceve: 'Qualcuno vuole conoscere il tuo archetipo.',
        risposte: ['Te lo dico', 'Devo ancora scoprirlo'],
        motivo: MotivoDelSegno.stella,
        apre: ArteDellaRichiesta.archetipo),
    SegnoDelCerchio(
        id: 'alzaLoSguardo',
        categoria: CategoriaDelSegno.richieste,
        testo: 'Guarda il nostro glifo',
        rigaDiChiRiceve:
            'Qualcuno ti invita a guardare il segno del vostro legame.',
        risposte: ['Lo guardo', 'Quanti tratti ci restano?'],
        motivo: MotivoDelSegno.sole,
        apre: ArteDellaRichiesta.glifo),
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

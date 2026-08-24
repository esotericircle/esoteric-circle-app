import '../domande/cornici_del_presagio.dart';
import '../responsi/anatomia_del_responso.dart';
import 'rune_cast.dart';

/// Il presagio, sistema ibrido: intreccia le rune uscite in una lettura sola,
/// nella voce di Caligo, composto in modo deterministico dai nomi, dai versi e
/// dalle posizioni. Nessuna AI nella Demo.
///
/// Segnali di sintesi: quante rune escono in merkstave, l'aett dominante, il
/// verso della posizione d'esito. Il gancio [rifinitura] e' predisposto per una
/// futura personalizzazione Gemini sul cielo della persona: quando ci sara',
/// riceve il presagio deterministico e lo rifinisce. Ora e' sempre null e non e'
/// collegato, cosi' la Demo resta senza AI a runtime.
///
/// **IL PRESAGIO HA LA FORMA DELL'ANATOMIA, ordine S voce 19.** Prima era un
/// paragrafo unico che apriva col nome della gettata e poi nominava una runa per
/// posizione: il simbolo veniva PRIMA della risposta, e non c'era niente da fare
/// dopo averlo letto. Adesso e' un [Responso] a tre parti: la risposta, cosa puoi
/// fare, da dove viene. **Il nome della runa compare solo nella terza**, che e'
/// la regola dell'anatomia, e la seconda e' la parte che fa tornare.
///
/// **E RISPONDE ALLA DOMANDA POSTA.** Con una domanda il presagio si apre
/// dicendo che a quella sta rispondendo; senza, parla alla giornata. La domanda
/// non si cita a parole sue: sta gia' a schermo, nella sua scatola, subito sopra
/// il presagio, e ripeterla sarebbe leggerla due volte. Questa era la parte che
/// la voce S.19 aspettava, perche' la domanda e' nata con la voce S.21.
class RunePresagio {
  const RunePresagio._();

  /// Compone il presagio dall'[esito], in parole. Con [rifinitura] non nulla, una
  /// funzione futura potra' arricchire il testo base senza cambiare questo motore.
  static String componi(
    EsitoGettata esito, {
    String domanda = '',
    String Function(String base)? rifinitura,
  }) {
    final base = componiIlResponso(esito, domanda: domanda).inParole;
    return rifinitura?.call(base) ?? base;
  }

  /// IL PRESAGIO COME RESPONSO, tre parti e un ordine solo.
  ///
  /// Chi ha in mano questo non puo' mettere il simbolo per primo nemmeno
  /// volendo: l'ordine non e' una convenzione, e' la forma dell'oggetto.
  static Responso componiIlResponso(
    EsitoGettata esito, {
    String domanda = '',
  }) {
    // **LA CORNICE SI TROVA PER TESTO ESATTO DELLA DOMANDA**, come chiede
    // l'allegato B: non per posizione nell'elenco, cosi' se domani l'ordine delle
    // domande cambia le cornici restano attaccate a quella giusta. Per una
    // domanda scritta con parole della persona non esiste cornice, e in ripiego
    // il responso parla alla giornata.
    // **SENZA CORNICE VALE LA DICIASSETTESIMA, quella della giornata**, e non una
    // delle sedici: usare la cornice di una domanda per chi non l'ha scelta
    // direbbe alla persona che ha chiesto qualcosa che non ha chiesto. Vale per chi
    // non scegli niente e per chi scrive la domanda con parole sue, che non ha una
    // cornice sua.
    final corniceScelta = CorniciDelPresagio.perDomanda(domanda);
    // **IL RIPIEGO NON MENTE A CHI HA SCRITTO, ordine BF voce 05.a.** Fatto
    // del fondatore sulla 2200: domanda scritta a mano, modello caduto, e il
    // presagio apriva con la diciassettesima cornice, "Non hai chiesto
    // niente". La cornice della giornata resta per chi davvero non ha
    // chiesto; per una domanda con parole della persona nessuna cornice
    // esiste, e allora apertura e chiusura della giornata SI OMETTONO invece
    // di dire il falso: restano le letture per posizione e l'equilibrio, che
    // sono corpus vero, e la domanda sta gia' scritta nella card qui sopra.
    // Non si inventa una riga: si toglie la riga che mentiva.
    final domandaPersonale = domanda.trim().isNotEmpty && corniceScelta == null;
    final cornice = corniceScelta ?? CorniciDelPresagio.dellaGiornata;
    return Responso(
      risposta: domandaPersonale
          ? _rispostaSenzaCornice(esito)
          : _risposta(esito, cornice),
      // **LA PARTE 2 VIENE SEMPRE DALL'ALLEGATO.** Le nove indicazioni per
      // famiglia e equilibrio che avevo scritto io non esistono piu': la
      // diciassettesima cornice copre il caso che coprivano loro, e cio' che la
      // persona legge lo scrive l'Architetto. Con la domanda personale la
      // chiusura della giornata direbbe "domani la domanda ce l'hai gia'",
      // che e' falso oggi: si omette, non si riscrive.
      cosaPuoiFare: domandaPersonale ? '' : cornice.chiusura,
      daDoveViene: _daDoveViene(esito),
    );
  }

  /// LA PRIMA PARTE: cosa la lettura vede, senza nominare nessuna runa.
  ///
  /// **I nomi non stanno qui**, e non e' una sfumatura: un responso che apre col
  /// simbolo chiede alla persona di sapere cosa vuol dire quel simbolo prima di
  /// riceverne una risposta. Le posizioni invece restano, perche' dicono di CHE
  /// COSA si sta parlando (cio' che fu, cio' che diviene, cio' che sara').
  static String _risposta(EsitoGettata esito, CorniceDelPresagio cornice) {
    // **L'APERTURA DELLA CORNICE, e la frase della runa si innesta dopo.** E' il
    // montaggio dell'allegato B, in quest'ordine: apertura, frase della runa dal
    // corpus che non si tocca, chiusura, e poi la riga che nomina la runa.
    //
    // **IL TESTO PROVVISORIO NON C'E' PIU'.** Fino al 13 agosto 2026 il caso senza
    // domanda apriva con una riga scritta da me, dichiarata provvisoria: adesso
    // apre con la diciassettesima cornice dell'allegato, e non c'e' una sola riga
    // di responso che non venga da Mauro.
    final apertura = cornice.apertura;
    final parti = <String>[apertura, ..._perPosizione(esito.rune)];
    parti.add(esito.gettata.libera
        ? _equilibrioLibera(esito)
        : _equilibrio(esito));
    return parti.join(' ');
  }

  /// IL MONTAGGIO SENZA CORNICE, per la domanda personale in ripiego: solo
  /// le letture per posizione e l'equilibrio, corpus intoccato, nessuna riga
  /// scritta da me. Ordine BF voce 05.a.
  static String _rispostaSenzaCornice(EsitoGettata esito) {
    final parti = <String>[..._perPosizione(esito.rune)];
    parti.add(esito.gettata.libera
        ? _equilibrioLibera(esito)
        : _equilibrio(esito));
    return parti.join(' ');
  }

  /// LE LETTURE PER POSIZIONE, e **una glossa non si ripete due volte**.
  ///
  /// **Il difetto e' nato con questa voce e si e' visto nell'anteprima del getto
  /// sul telo.** Nelle gettate fisse ogni posizione ha la sua glossa e ogni frase
  /// comincia in modo diverso; sul telo la posizione si legge per prossimita' al
  /// centro, quindi cinque rune su sei stanno "verso i margini della luce" e la
  /// prima parte diventava una litania: sei righe di fila che cominciavano con le
  /// stesse cinque parole. Prima non si notava perche' ogni riga portava anche il
  /// nome della runa, che almeno le distingueva, e il nome adesso e' scesso nella
  /// terza parte dove l'anatomia lo vuole.
  ///
  /// Le rune con la stessa glossa si raccolgono: la glossa si dice UNA volta e le
  /// letture seguono come frasi loro, con la maiuscola, perche' da sole stanno in
  /// piedi. Nelle gettate fisse il comportamento non cambia di una virgola.
  static List<String> _perPosizione(List<RunaGettata> rune) {
    final fuori = <String>[];
    var i = 0;
    while (i < rune.length) {
      final glossa = rune[i].posizione.glossa;
      var j = i;
      while (j < rune.length && rune[j].posizione.glossa == glossa) {
        j++;
      }
      if (j - i == 1) {
        fuori.add('Per $glossa, ${_minuscola(_primaFrase(rune[i].riga))}.');
      } else {
        final frasi = [
          for (var k = i; k < j; k++) '${_primaFrase(rune[k].riga)}.',
        ];
        fuori.add('Per $glossa, più segni parlano insieme. '
            '${frasi.join(' ')}');
      }
      i = j;
    }
    return fuori;
  }

  // **LE NOVE INDICAZIONI PER FAMIGLIA SONO STATE TOLTE, il 13 agosto 2026.**
  // Erano tre famiglie di rune per tre equilibri di luce e ombra, scritte da me
  // per il caso senza domanda, e coprivano il posto che adesso occupa la
  // diciassettesima cornice dell'allegato B. Tenerle sarebbe stato lasciare due
  // testi possibili per la stessa parte del responso, cioe' la famiglia delle due
  // porte, con la differenza che una delle due porte non e' materiale
  // dell'Architetto.

  /// LA TERZA PARTE: qui, e solo qui, compaiono le rune coi loro versi.
  static String _daDoveViene(EsitoGettata esito) {
    final pezzi = <String>[];
    for (final r in esito.rune) {
      final verso = r.verso == RuneVerso.merkstave
          // Merkstave si traduce, ordine AS voce 09: la parola giusta resta,
          // e accanto c'e' cosa vuol dire.
          ? (esito.gettata.libera ? 'rovesciata' : 'in merkstave (rovesciata)')
          : (esito.gettata.libera ? 'dritta' : 'diritta');
      pezzi.add('${r.rune.name} $verso per ${r.posizione.glossa}');
    }
    return 'Da dove viene: ${_daQualeGettata(esito.gettata)}. '
        '${pezzi.join('; ')}. '
        '${_famiglia(_aettDominante(esito.rune))}';
  }

  /// DA QUALE GETTATA, in una forma che possa seguire i due punti.
  ///
  /// **Non e' l'apertura minuscolizzata, ed e' la ragione per cui esiste.** La
  /// prima stesura riusava l'apertura e si leggeva "Da dove viene: Le tre Norne
  /// hanno teso", con la maiuscola dopo i due punti, cioe' la cucitura di due
  /// frasi diverse. Minuscolizzarla non si poteva: "Odino" e' un nome, e "odino
  /// ha parlato" e' peggio della maiuscola. Quindi qui la frase e' scritta per il
  /// posto che occupa, e l'apertura non serve piu' a nessuno.
  static String _daQualeGettata(GettataRune gettata) {
    switch (gettata.id) {
      case 'odino':
        return 'la gettata di Odino, un segno solo';
      case 'norne':
        return 'le tre Norne, il filo del tempo';
      case 'croce':
        return 'la croce aperta in cinque punti';
      default:
        return 'le rune cadute sparse sul telo di Tacito';
    }
  }

  /// L'EQUILIBRIO DEL TELO, per il getto libero: si legge per prossimita' al
  /// centro invece che per posizione fissa.
  ///
  /// **Il cuore del getto non e' piu' qui.** Diceva "Al centro pesa Othala" e
  /// nominava la runa dentro la prima parte, che e' esattamente cio' che
  /// l'anatomia vieta: adesso quel nome vive nella terza parte, con gli altri.
  static String _equilibrioLibera(EsitoGettata esito) {
    final dritte =
        esito.sparse.where((s) => s.verso == RuneVerso.dritto).length;
    final rovesce =
        esito.sparse.where((s) => s.verso == RuneVerso.merkstave).length;
    if (rovesce == 0) {
      return 'Tutte le rune sono cadute dritte: il telo si mostra aperto, '
          'nessun segno rema contro.';
    }
    if (dritte <= rovesce) {
      return 'Molte rune rovesciate: il telo chiede prudenza, i segni lavorano '
          'in controluce.';
    }
    return 'Più rune dritte che rovesciate: il telo parla chiaro, qualche '
        'segno va preso al contrario.';
  }

  /// L'EQUILIBRIO DELLA GETTATA: quanta luce, quanta ombra, come pende l'esito.
  ///
  /// **La riga della famiglia non e' piu' qui**, e' scesa nella terza parte: la
  /// famiglia di Freyr o di Tyr e' tradizione runica, cioe' da dove viene la
  /// lettura, non cio' che la lettura vede.
  static String _equilibrio(EsitoGettata esito) {
    final rune = esito.rune;
    final n = rune.length;
    final ombre = rune.where((r) => r.inOmbra).length;

    final String merk;
    if (ombre == 0) {
      merk = 'Tutte le rune escono diritte: il segno \u00e8 aperto, la via corre '
          'libera.';
    } else if (ombre * 2 > n) {
      merk = 'Molte rune pendono in penombra: il cammino chiede prudenza, non '
          'un no.';
    } else {
      merk = 'Qualche runa in penombra tempera il resto: luce e ombra si '
          'parlano.';
    }

    final esitoRiga = rune.last.inOmbra
        ? 'L\u2019esito pende in penombra: non \u00e8 un rifiuto ma un tempo che '
            'chiede cura.'
        : 'L\u2019esito esce diritto: la sorte pende dalla tua parte, muoviti con '
            'misura.';
    return '$merk $esitoRiga';
  }

  /// La riga della famiglia dominante, riusata da entrambe le sintesi.
  static String _famiglia(String aett) {
    switch (aett) {
      case 'Freyr':
        return 'La famiglia di Freyr guida la gettata: forze di sostanza e di '
            'crescita.';
      case 'Hagal':
        return 'La famiglia di Hagal guida la gettata: prova e trasformazione '
            'al lavoro.';
      default:
        return "La famiglia di Tyr guida la gettata: volontà e legami in gioco.";
    }
  }

  /// L'aett piu' presente. A parita', vince l'ordine tradizionale: Freyr, poi
  /// Hagal, poi Tyr.
  static String _aettDominante(List<RunaGettata> rune) {
    final conteggi = <String, int>{'Freyr': 0, 'Hagal': 0, 'Tyr': 0};
    for (final r in rune) {
      final a = RuneCast.aett(r.rune);
      conteggi[a] = (conteggi[a] ?? 0) + 1;
    }
    var dominante = 'Freyr';
    var massimo = -1;
    for (final a in const ['Freyr', 'Hagal', 'Tyr']) {
      if (conteggi[a]! > massimo) {
        massimo = conteggi[a]!;
        dominante = a;
      }
    }
    return dominante;
  }

  /// LA PRIMA FRASE DI UNA RIGA, aperta alle prove.
  ///
  /// Serve al presidio che pretende la lettura di OGNI runa uscita dentro la
  /// prima parte: senza questa porta la prova dovrebbe ricopiare il taglio della
  /// frase, e due tagli scritti in due posti diventano due regole.
  static String primaFraseDiProva(String riga) => _primaFrase(riga);

  /// La prima frase di una riga del corpus, il titolo breve dell'orientamento.
  static String _primaFrase(String riga) {
    final i = riga.indexOf('.');
    return i < 0 ? riga : riga.substring(0, i);
  }

  /// La stessa frase, ma che possa seguire una virgola.
  ///
  /// **Le righe del corpus cominciano con la maiuscola**, perche' nate per stare
  /// da sole. Nella prima parte del responso seguono "Per cio' che fu," e senza
  /// questa minuscola si leggeva "Per cio' che fu, Una luce si accende", che e' la
  /// cucitura di due frasi diverse.
  static String _minuscola(String frase) => frase.isEmpty
      ? frase
      : frase[0].toLowerCase() + frase.substring(1);
}

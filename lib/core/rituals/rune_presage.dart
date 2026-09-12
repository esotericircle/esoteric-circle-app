import '../domande/cornici_del_presagio.dart';
import '../responsi/anatomia_del_responso.dart';
import '../responsi/filo_della_voce.dart';
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
    final filo = _filo(esito);
    final apertura = cornice.apertura;
    final parti = <String>[apertura, ..._perPosizione(esito.rune, filo)];
    parti.add(
        esito.gettata.libera ? _equilibrioLibera(esito) : _equilibrio(esito));
    return parti.join(' ');
  }

  /// IL MONTAGGIO SENZA CORNICE, per la domanda personale in ripiego: solo
  /// le letture per posizione e l'equilibrio, corpus intoccato, nessuna riga
  /// scritta da me. Ordine BF voce 05.a.
  static String _rispostaSenzaCornice(EsitoGettata esito) {
    final parti = <String>[..._perPosizione(esito.rune, _filo(esito))];
    parti.add(
        esito.gettata.libera ? _equilibrioLibera(esito) : _equilibrio(esito));
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
  static List<String> _perPosizione(List<RunaGettata> rune,
      FiloDellaVoce filo) {
    final fuori = <String>[];
    var i = 0;
    while (i < rune.length) {
      final glossa = rune[i].posizione.glossa;
      var j = i;
      while (j < rune.length && rune[j].posizione.glossa == glossa) {
        j++;
      }
      if (j - i == 1) {
        fuori.add(filo
            .scegli(formeDellaPosizione)
            .replaceAll('{suGlossa}', _maiuscola(_articolata('su', glossa)))
            .replaceAll('{diGlossa}', _articolata('di', glossa))
            .replaceAll('{aGlossa}', _articolata('a', glossa))
            .replaceAll('{Glossa}', _maiuscola(glossa))
            .replaceAll('{glossa}', glossa)
            // **LA RIGA INTERA DELLA RUNA, e non piu la sola prima frase.**
            // Ordine DF voce 05, 11 settembre 2026. Prendendo una frase sola
            // il corpus portava una trentina di parole per gettata contro le
            // cinquanta dell impalcatura e della cornice: la somiglianza
            // massima a coppie restava al settantatre per cento anche dopo
            // aver dato otto forme alla cucitura, perche **il testo era fatto
            // per meta di parti che non guardano le rune**.
            //
            // Con la riga intera il corpus diventa la parte grande del
            // responso, che e anche cio che la persona e venuta a leggere.
            .replaceAll('{riga}', _minuscola(rune[i].riga)));
      } else {
        final frasi = [
          for (var k = i; k < j; k++) '${_primaFrase(rune[k].riga)}.',
        ];
        fuori.add(filo
            .scegli(formeDelCoro)
            .replaceAll('{suGlossa}', _maiuscola(_articolata('su', glossa)))
            .replaceAll('{Glossa}', _maiuscola(glossa))
            .replaceAll('{glossa}', glossa)
            .replaceAll('{frasi}', frasi.join(' ')));
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

  /// **LE OTTO FORME CON CUI SI INTRODUCE UNA POSIZIONE.**
  /// Ordine DF voce 05, 11 settembre 2026.
  ///
  /// **Il numero che le ha fatte nascere.** Il presagio apriva ogni posizione
  /// con *"Per {glossa},"*, sempre, tre volte per gettata: su cento gettate
  /// con la stessa domanda la somiglianza massima a coppie era del **82,8 per
  /// cento**, contro una soglia del quaranta. Le righe del corpus delle rune
  /// cambiavano, l'impalcatura che le teneva no, e l'impalcatura era la meta'
  /// delle parole.
  ///
  /// **Il corpus non si tocca**: le righe delle rune sono materiale
  /// dell'Architetto e restano parola per parola. Quello che cambia e' **la
  /// cucitura**, che e' mia.
  static const List<String> formeDellaPosizione = [
    'Per {glossa}, {riga}',
    '{Glossa}: {riga}',
    '{suGlossa} il segno dice che {riga}',
    'Guardando {glossa}, {riga}',
    '{Glossa}. {riga}',
    'La runa {diGlossa} racconta che {riga}',
    'Dalla parte {diGlossa}, {riga}',
    'Per quello che riguarda {glossa}, {riga}',
    '{suGlossa}: {riga}',
    'Quanto {aGlossa}, {riga}',
    'Il segno {diGlossa}: {riga}',
    '{suGlossa} cade una runa che dice: {riga}',
    'Qui parla {glossa}: {riga}',
    'Verso {glossa}, {riga}',
    '{Glossa}. Il segno dice: {riga}',
    'Guardando {glossa}: {riga}',
  ];

  /// **LE OTTO FORME CON CUI PIU' SEGNI PARLANO INSIEME**, per il getto sul
  /// telo, dove piu' rune condividono la stessa glossa.
  static const List<String> formeDelCoro = [
    'Per {glossa}, più segni parlano insieme. {frasi}',
    '{Glossa}: qui non parla una runa sola. {frasi}',
    '{suGlossa} cadono più segni. {frasi}',
    'Più rune si affacciano su {glossa}. {frasi}',
    'Quanto a {glossa}, i segni sono più di uno. {frasi}',
    'Per {glossa} il telo risponde con più voci. {frasi}',
    'Attorno a {glossa} si raccolgono più segni. {frasi}',
    '{suGlossa} le rune non dicono una cosa sola. {frasi}',
  ];

  /// **LE OTTO FORME DELLA TERZA PARTE**, quella che nomina le rune.
  static const List<String> formeDelDaDoveViene = [
    'Da dove viene: {gettata}. {pezzi}. {famiglia}',
    'Questo presagio nasce così: {gettata}. {pezzi}. {famiglia}',
    'Le rune che hanno parlato: {gettata}. {pezzi}. {famiglia}',
    'Il segno viene da {gettata}. {pezzi}. {famiglia}',
    'Come si e formato: {gettata}. {pezzi}. {famiglia}',
    'Dietro queste righe c e {gettata}. {pezzi}. {famiglia}',
    'La fonte: {gettata}. {pezzi}. {famiglia}',
    'Questo lo dicono {gettata}. {pezzi}. {famiglia}',
    'Viene da {gettata}. {pezzi}. {famiglia}',
    'Le pietre: {gettata}. {pezzi}. {famiglia}',
    'Cosa e caduto: {gettata}. {pezzi}. {famiglia}',
    'Il getto era {gettata}. {pezzi}. {famiglia}',
    'Hanno parlato {gettata}. {pezzi}. {famiglia}',
    'Sul telo: {gettata}. {pezzi}. {famiglia}',
    'In chiaro: {gettata}. {pezzi}. {famiglia}',
    'Le rune uscite, da {gettata}. {pezzi}. {famiglia}',
  ];

  /// **LE FORME DELL'EQUILIBRIO, corte e dodici per caso.**
  /// Ordine DF voce 05, 11 settembre 2026.
  ///
  /// **Perche' corte.** La misura C dell'ordine conta le **sequenze di cinque
  /// parole** in comune: una frase di quattro parole non ne produce nessuna,
  /// quindi due gettate che cadono sulla stessa forma corta **non si
  /// somigliano per questo**. Le forme lunghe fanno il contrario: danno
  /// varieta' alla misura B e regalano parole in comune alla C. E' la stessa
  /// lezione imparata sulla scena del Viaggio, dove le aperture lunghe avevano
  /// portato la C dal ventotto al quarantanove per cento.
  static const Map<String, List<String>> formeDeiVersiGettati = {
    'dritte': [
      'Tutte diritte.',
      'Nessuna in penombra.',
      'Il segno è aperto.',
      'Niente ombre, qui.',
      'La via corre libera.',
      'Tre rune, tre diritte.',
      'Nessun freno nel getto.',
      'Segno pulito.',
      'Non c\'è nulla di trattenuto.',
      'Le pietre stanno dritte tutte.',
      'Via libera.',
      'Nessuna riserva.',
    ],
    'molte': [
      'Molte in penombra.',
      'L\'ombra è la maggioranza.',
      'Più ombra che luce.',
      'Il getto pende in penombra.',
      'Le pietre sono quasi tutte girate.',
      'Prudenza, non un no.',
      'Il cammino chiede cautela.',
      'Più rune trattenute che aperte.',
      'Qui si va piano.',
      'Il segno è per lo più coperto.',
      'Prevale il rovescio.',
      'Poca luce nel getto.',
    ],
    'qualcuna': [
      'Qualcuna in penombra.',
      'Luce e ombra si parlano.',
      'Una sola è girata.',
      'Il resto tiene.',
      'Un\'ombra fra le diritte.',
      'Un freno, non un muro.',
      'Il getto è misto.',
      'C\'è un\'ombra e c\'è la luce.',
      'Una pietra sola trattiene.',
      'Nel getto c\'è una riserva.',
      'Quasi tutte aperte.',
      'Un rovescio soltanto.',
    ],
  };

  /// **LE FORME DELL'ESITO**, corte anche loro.
  static const Map<String, List<String>> formeDellEsito = {
    'ombra': [
      'L\'esito è in penombra: non un rifiuto, un tempo.',
      'L\'ultima pietra è girata: chiede cura.',
      'In fondo c\'è un\'ombra: rallenta.',
      'L\'esito trattiene.',
      'L\'ultima runa non dice di no: dice non ora.',
      'La fine è coperta: aspetta.',
      'L\'esito chiede tempo.',
      'L\'ultima è in ombra.',
    ],
    'luce': [
      'L\'esito esce diritto: muoviti con misura.',
      'L\'ultima pietra sta dritta: la sorte è dalla tua.',
      'In fondo c\'è luce.',
      'L\'esito è aperto.',
      'L\'ultima runa dice di sì, senza fretta.',
      'La fine è scoperta: vai.',
      'L\'esito non trattiene niente.',
      'L\'ultima sta dritta.',
    ],
  };

  /// **LE FORME DELLA FAMIGLIA DOMINANTE**, corte e otto per aett.
  static const Map<String, List<String>> formeDellaFamiglia = {
    'Freyr': [
      'Domina Freyr: sostanza e crescita.',
      'La gettata è di Freyr.',
      'Pesa la famiglia di Freyr.',
      'Freyr guida: cose che crescono.',
      'Il getto è del primo aett.',
      'Freyr è la famiglia in gioco.',
      'Tocca a Freyr.',
      'Comanda Freyr, cioè la sostanza.',
    ],
    'Hagal': [
      'Domina Hagal: prova e trasformazione.',
      'La gettata è di Hagal.',
      'Pesa la famiglia di Hagal.',
      'Hagal guida: qualcosa si trasforma.',
      'Il getto è del secondo aett.',
      'Hagal è la famiglia in gioco.',
      'Tocca a Hagal.',
      'Comanda Hagal, cioè la prova.',
    ],
    'Tyr': [
      'Domina Tyr: volontà e legami.',
      'La gettata è di Tyr.',
      'Pesa la famiglia di Tyr.',
      'Tyr guida: si decide e ci si lega.',
      'Il getto è del terzo aett.',
      'Tyr è la famiglia in gioco.',
      'Tocca a Tyr.',
      'Comanda Tyr, cioè la volontà.',
    ],
  };

  /// **IL FILO DI UNA GETTATA**, dalle rune cadute e dai loro versi.
  static FiloDellaVoce _filo(EsitoGettata esito) => FiloDellaVoce.da([
        for (final r in esito.rune) ...[r.rune.name, r.verso.name],
      ]);

  /// **LE PREPOSIZIONI ARTICOLATE, e servono davvero.**
  ///
  /// Le glosse delle posizioni sono gruppi nominali col loro articolo: *il
  /// consiglio essenziale*, *cio' che fu*, *la radice*. Una forma che scrive
  /// *"Su {glossa}"* produce **"Su il consiglio essenziale"**, che e' un
  /// errore di italiano, e la guardia della lingua di questo progetto lo
  /// prende. Qui la preposizione si fonde con l'articolo, come si fa in
  /// italiano.
  static String _articolata(String prep, String nome) {
    const tavola = <String, Map<String, String>>{
      'su': {
        'il ': 'sul ',
        'lo ': 'sullo ',
        'la ': 'sulla ',
        'i ': 'sui ',
        'gli ': 'sugli ',
        'le ': 'sulle ',
        'l\'': 'sull\'',
      },
      'di': {
        'il ': 'del ',
        'lo ': 'dello ',
        'la ': 'della ',
        'i ': 'dei ',
        'gli ': 'degli ',
        'le ': 'delle ',
        'l\'': 'dell\'',
      },
      'a': {
        'il ': 'al ',
        'lo ': 'allo ',
        'la ': 'alla ',
        'i ': 'ai ',
        'gli ': 'agli ',
        'le ': 'alle ',
        'l\'': 'all\'',
      },
    };
    final mappa = tavola[prep];
    if (mappa != null) {
      for (final e in mappa.entries) {
        if (nome.startsWith(e.key)) {
          return '${e.value}${nome.substring(e.key.length)}';
        }
      }
    }
    return '$prep $nome';
  }

  static String _maiuscola(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// LA TERZA PARTE: qui, e solo qui, compaiono le rune coi loro versi.
  static String _daDoveViene(EsitoGettata esito) {
    final pezzi = <String>[];
    for (final r in esito.rune) {
      final verso = r.verso == RuneVerso.merkstave
          // Merkstave si traduce, ordine AS voce 09: la parola giusta resta,
          // e accanto c'e' cosa vuol dire.
          ? (esito.gettata.libera ? 'rovesciata' : 'in merkstave (rovesciata)')
          : (esito.gettata.libera ? 'dritta' : 'diritta');
      // **IL SIGNIFICATO DELLA RUNA NON ENTRA QUI, e la ragione e il
      // confine del responso.** Ordine DF voce 05, 11 settembre 2026.
      //
      // Ci era entrato per dare varieta al testo, e la guardia del confine lo
      // ha respinto in tre casi su seimilasettecentottantuno: il significato
      // di Othala porta la parola **eredita**, che e un tema delicato, e un
      // responso rivolto alla persona non la puo nominare. Le altre
      // ventitre rune non c entravano niente: bastava una.
      //
      // **La varieta si e recuperata altrove**, con sedici forme corte per la
      // posizione e sedici per questa terza parte, senza toccare il corpus.
      pezzi.add('${r.rune.name} $verso per ${r.posizione.glossa}');
    }
    return _filo(esito)
        .piu(31)
        .scegli(formeDelDaDoveViene)
        .replaceAll(
            '{gettata}', _daQualeGettata(esito.gettata, _filo(esito).piu(71)))
        .replaceAll('{pezzi}', pezzi.join('; '))
        .replaceAll('{famiglia}',
            _famiglia(_aettDominante(esito.rune), _filo(esito).piu(53)));
  }

  /// DA QUALE GETTATA, in una forma che possa seguire i due punti.
  ///
  /// **Non e' l'apertura minuscolizzata, ed e' la ragione per cui esiste.** La
  /// prima stesura riusava l'apertura e si leggeva "Da dove viene: Le tre Norne
  /// hanno teso", con la maiuscola dopo i due punti, cioe' la cucitura di due
  /// frasi diverse. Minuscolizzarla non si poteva: "Odino" e' un nome, e "odino
  /// ha parlato" e' peggio della maiuscola. Quindi qui la frase e' scritta per il
  /// posto che occupa, e l'apertura non serve piu' a nessuno.
  static const Map<String, List<String>> formeDellaGettata = {
    'odino': [
      'la gettata di Odino',
      'un segno solo, alla maniera di Odino',
      'il getto singolo',
      'una runa sola',
      'Odino, con una pietra sola',
      'il tiro breve',
      'la pietra unica',
      'un solo segno',
    ],
    'norne': [
      'le tre Norne',
      'il filo del tempo, in tre pietre',
      'tre rune e tre tempi',
      'la gettata delle Norne',
      'il filo teso in tre',
      'tre segni, uno per tempo',
      'la trina delle Norne',
      'tre pietre in fila',
    ],
    'croce': [
      'la croce aperta',
      'cinque punti in croce',
      'la croce di cinque rune',
      'il getto a croce',
      'cinque pietre disposte',
      'la croce delle cinque',
      'il segno a cinque punte',
      'cinque rune in croce',
    ],
    'telo': [
      'le rune sparse sul telo',
      'il telo di Tacito',
      'il getto libero',
      'le pietre cadute a caso',
      'la gettata sul telo',
      'il tiro sparso',
      'le rune libere sul panno',
      'il telo aperto',
    ],
  };

  static String _daQualeGettata(GettataRune gettata, FiloDellaVoce filo) =>
      filo.scegli(
          formeDellaGettata[gettata.id] ?? formeDellaGettata['telo']!);

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

    final filo = _filo(esito).piu(17);
    final quale =
        ombre == 0 ? 'dritte' : (ombre * 2 > n ? 'molte' : 'qualcuna');
    final merk = filo.scegli(formeDeiVersiGettati[quale]!);
    final esitoRiga =
        filo.scegli(formeDellEsito[rune.last.inOmbra ? 'ombra' : 'luce']!);
    return '$merk $esitoRiga';
  }

  /// La riga della famiglia dominante, riusata da entrambe le sintesi.
  static String _famiglia(String aett, FiloDellaVoce filo) =>
      filo.scegli(formeDellaFamiglia[aett] ?? formeDellaFamiglia['Tyr']!);

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
  static String _minuscola(String frase) =>
      frase.isEmpty ? frase : frase[0].toLowerCase() + frase.substring(1);
}

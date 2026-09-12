import 'la_domanda_del_viaggio.dart';

/// **IL TEMA DI UNA DOMANDA SCRITTA A MANO, capito dalle sue parole.** Ordine
/// DI voce 02, 12 settembre 2026.
///
/// **Il difetto che chiude.** Per l'app la frase della persona era un numero:
/// entrava in un punto solo, come ingresso di un hash che sceglie i pezzi della
/// scena. Nessuno la leggeva, e la risposta cadeva sempre sul ramo scritto per
/// chi non ha chiesto niente.
///
/// **Questa e' la via di riserva, e deve funzionare sempre, anche senza
/// rete.** La via principale e' il modello, che riceve la domanda e i sei temi
/// e restituisce un id solo; quando non risponde in tempo, o risponde fuori dai
/// sei, si cade qui senza che la persona se ne accorga.
///
/// **COME RAGIONA.** Ogni tema ha i suoi indizi, e ogni indizio un peso. Si
/// sommano i pesi degli indizi trovati, e vince il tema col totale piu' alto.
/// **A parita', o a zero, il tema resta nullo**, e si usa il ramo senza
/// domanda, che resta legittimo: indovinare un tema e' peggio che non averlo.
///
/// **PERCHE' I PESI NON SONO TUTTI UGUALI.** Una domanda dice **di chi o di
/// cosa** si parla, e **cosa si sta chiedendo**, e il tema e' la seconda cosa.
/// *"Mia sorella diventera' presto mamma?"* parla di una persona, ma chiede
/// **quando**: e' un tempo che non arriva. Per questo le locuzioni che dicono
/// la domanda pesano tre, e i nomi che dicono l'argomento pesano uno. Le
/// perdite pesano quattro, perche' quando in una domanda c'e' una morte o una
/// fine, e' di quella che si sta parlando, qualunque altra parola ci sia
/// accanto.
///
/// **COME SONO SCRITTI GLI INDIZI.** In italiano vero, con gli accenti: la
/// tabella li normalizza con la stessa funzione che normalizza la domanda, e
/// li confronta cosi'. Fino al 12 settembre 2026 erano scritti gia' senza
/// accenti, *"riusciro"*, *"piu"*, e le guardie di casa li leggevano come
/// testo con l'accento perso. Un indizio che finisce con
/// l'asterisco e' una **radice**, e prende tutte le forme della parola che
/// cominciano cosi': `decid*` prende *decido*, *decidere*, *decidero'*. Gli
/// altri si cercano come parole o locuzioni intere, mai dentro un'altra
/// parola: `fine` non si trova in *finire* ne' in *finalmente*.
abstract final class IlTemaDellaDomandaLibera {
  /// **IL TEMA, dalle parole sole.** Nullo a zero indizi o a parita'.
  static TemaDellaDomanda? perParole(String domanda) {
    final punti = puntiPerTema(domanda);
    if (punti.isEmpty) return null;
    final ordinati = punti.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // **UNA PAROLA D'ARGOMENTO DA SOLA NON DECIDE.** Misurato il 12
    // settembre 2026 su dodici domande scritte dopo aver congelato la
    // tabella: su tre capite, due erano SBAGLIATE, e sbagliate per un indizio
    // solo di peso uno (*"figlia"* scambiata per attesa, *"dovrei"* per
    // scelta). Una risposta sul tema sbagliato e' peggio del ramo senza
    // domanda, quindi per vincere un tema deve avere almeno una locuzione o
    // due indizi: la tabella deve capire quando e' evidente e **non
    // sbagliare mai**, il capire vero spetta al modello.
    if (ordinati.first.value < minimoPerDecidere) return null;
    if (ordinati.length > 1 && ordinati[1].value == ordinati.first.value) {
      return null;
    }
    return ordinati.first.key;
  }

  /// **IL MINIMO PER DECIDERE**: due punti. Vedi la nota in [perParole].
  static const int minimoPerDecidere = 2;

  /// I punti di ogni tema, per chi deve spiegare una scelta: il rapporto
  /// dell'ordine li riporta accanto a ogni domanda.
  static Map<TemaDellaDomanda, int> puntiPerTema(String domanda) {
    final testo = ' ${normalizza(domanda)} ';
    final parole = testo.trim().split(' ');
    final punti = <TemaDellaDomanda, int>{};
    for (final voce in _indizi.entries) {
      var somma = 0;
      for (final (indizio, peso) in voce.value) {
        somma += _quante(indizio, testo, parole) * peso;
      }
      if (somma > 0) punti[voce.key] = somma;
    }
    return punti;
  }

  /// **LA DOMANDA NORMALIZZATA**: minuscola, senza accenti, senza apostrofi
  /// ne' punteggiatura, con uno spazio solo fra le parole. L'apostrofo
  /// tipografico dei telefoni, `’`, vale come quello dritto.
  static String normalizza(String s) {
    const accenti = {
      'à': 'a', 'á': 'a', 'â': 'a', 'è': 'e', 'é': 'e', 'ê': 'e', //
      'ì': 'i', 'í': 'i', 'î': 'i', 'ò': 'o', 'ó': 'o', 'ô': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u',
    };
    final b = StringBuffer();
    for (final c in s.toLowerCase().split('')) {
      final senza = accenti[c] ?? c;
      final lettera = RegExp(r'[a-z0-9]').hasMatch(senza);
      b.write(lettera ? senza : ' ');
    }
    return b.toString().replaceAll(RegExp(r' +'), ' ').trim();
  }

  static int _quante(String indizio, String testo, List<String> parole) {
    // **L'INDIZIO SI NORMALIZZA COME LA DOMANDA**: si scrive in italiano vero,
    // con gli accenti, e si confronta nella stessa forma senza accenti.
    final radicale = indizio.endsWith('*');
    final forma = normalizza(
        radicale ? indizio.substring(0, indizio.length - 1) : indizio);
    if (radicale) {
      if (!forma.contains(' ')) {
        return parole.where((p) => p.startsWith(forma)).length;
      }
      // Una locuzione che finisce con una radice: l'ultima parola si prende
      // per inizio, le altre intere.
      return RegExp(' ${RegExp.escape(forma)}[a-z0-9]*').allMatches(testo).length;
    }
    return RegExp(' ${RegExp.escape(forma)} ').allMatches(testo).length;
  }

  /// **GLI INDIZI DEI SEI TEMI, col loro peso.** Tre per le locuzioni che
  /// dicono cosa si sta chiedendo, uno per le parole che dicono l'argomento,
  /// quattro per le perdite.
  static const Map<TemaDellaDomanda, List<(String, int)>> _indizi = {
    TemaDellaDomanda.attesa: [
      ('quando', 3),
      ('tra quanto', 3),
      ('fra quanto', 3),
      ('presto', 3),
      ('finalmente', 3),
      ('aspett*', 3),
      ('attes*', 3),
      ('arriverà', 3),
      ('arriva', 1),
      ('arrivare', 1),
      ('diventerà', 3),
      ('succederà', 3),
      ('riuscirò', 3),
      ('verrà', 2),
      ('avrò', 2),
      ('potrò', 2),
      ('ancora non', 2),
      ('non arriva', 3),
      ('notizi*', 1),
      ('rispost*', 1),
      ('esito', 1),
      ('tempo', 1),
      ('incint*', 2),
      ('gravidanz*', 2),
    ],
    TemaDellaDomanda.scelta: [
      ('devo', 1),
      ('dovrei', 1),
      ('scegl*', 3),
      ('scelt*', 3),
      ('decid*', 3),
      ('decisione', 3),
      ('quale', 2),
      ('meglio', 2),
      ('oppure', 3),
      // La 'o' da sola, cioe' l'alternativa: in una domanda e' quasi sempre
      // "questo o quello".
      ('o', 2),
      ('accett*', 2),
      ('rifiut*', 2),
      ('restare', 2),
      ('rimanere', 2),
      ('lasciare o', 3),
      ('conviene', 3),
      ('proposta', 2),
      ('offert*', 2),
      ('contratto', 1),
      ('firm*', 1),
      ('trasferirmi', 2),
      ('dico di sì', 3),
      ('dire di sì', 3),
      ('non so se', 3),
    ],
    TemaDellaDomanda.persona: [
      ('prova per me', 3),
      ('cosa prova', 3),
      ('pensa di me', 3),
      ('mi ama', 3),
      ('mi vuole', 3),
      ('fidarmi', 3),
      ('fidarsi', 3),
      ('rapporto con', 3),
      ('mi nasconde', 3),
      ('nascondendo', 3),
      ('madre', 1),
      ('padre', 1),
      ('mamma', 1),
      ('papà', 1),
      ('sorella', 1),
      ('fratello', 1),
      // **Il figlio e' una persona**, e stava nell'attesa per colpa di
      // *"avere un figlio"*: li' l'attesa la dicono gia' *riusciro'* e
      // *finalmente*, e un nome non deve decidere il tema al posto loro.
      ('figli*', 1),
      ('marito', 1),
      ('moglie', 1),
      ('fidanzat*', 1),
      ('compagn*', 1),
      ('amic*', 1),
      ('collega', 1),
      ('capo', 1),
      ('ex', 1),
      ('lui', 1),
      ('lei', 1),
      ('con me', 2),
      ('per me', 1),
    ],
    TemaDellaDomanda.blocco: [
      ('non riesco', 3),
      ('non ce la faccio', 3),
      ('blocc*', 3),
      ('paura', 3),
      ('ansia', 3),
      ('rimand*', 3),
      ('smettere', 3),
      ('sabot*', 3),
      ('impedisce', 3),
      ('ostacol*', 3),
      ('superare', 2),
      ('ogni volta', 2),
      ('sempre lo stesso', 3),
      ('ci ricado', 3),
      ('come faccio', 2),
      ('mai', 1),
    ],
    TemaDellaDomanda.direzione: [
      ('strada', 3),
      ('direzione', 3),
      ('scopo', 3),
      ('senso della', 3),
      ('mi sento perso', 3),
      ('sono perso', 3),
      ('mi sento persa', 3),
      ('sono persa', 3),
      ('da grande', 3),
      ('della mia vita', 3),
      ('nella vita', 3),
      ('dove sto andando', 4),
      ('verso dove', 3),
      ('futuro', 2),
      ('percorso', 2),
      ('cammino', 2),
      ('cosa voglio', 3),
      ('cosa fare', 2),
    ],
    TemaDellaDomanda.finito: [
      ('morto', 4),
      ('morta', 4),
      ('mort*', 2),
      ('lutto', 4),
      ('non c’è più', 4),
      ('fine', 3),
      ('è finita', 4),
      ('è finito', 4),
      ('finita con', 4),
      ('lasciat*', 3),
      ('separa*', 4),
      ('divorzi*', 4),
      ('licenzia*', 4),
      ('ho perso', 4),
      ('perdita', 4),
      ('addio', 3),
      ('rottura', 4),
      ('andare avanti', 2),
      ('e adesso', 2),
      ('ricominciare', 2),
    ],
  };
}

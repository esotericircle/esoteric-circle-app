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
class RunePresagio {
  const RunePresagio._();

  /// Compone il presagio dall'[esito]. Con [rifinitura] non nulla, una funzione
  /// futura potra' arricchire il testo base senza cambiare questo motore.
  static String componi(
    EsitoGettata esito, {
    String Function(String base)? rifinitura,
  }) {
    final base = _base(esito);
    return rifinitura?.call(base) ?? base;
  }

  static String _base(EsitoGettata esito) {
    final parti = <String>[_apertura(esito.gettata)];
    for (final r in esito.rune) {
      parti.add(_fraseRuna(r));
    }
    parti.add(_sintesi(esito));
    return parti.join(' ');
  }

  static String _apertura(GettataRune gettata) {
    switch (gettata.id) {
      case 'odino':
        return 'Odino ha parlato con un segno solo.';
      case 'norne':
        return 'Le tre Norne hanno teso il filo del tempo.';
      case 'croce':
        return "La croce si è aperta in cinque punti.";
      default:
        return 'Le rune si sono posate sul panno.';
    }
  }

  static String _fraseRuna(RunaGettata r) {
    final verso = r.inOmbra ? 'in merkstave' : 'diritta';
    return 'Per ${r.posizione.glossa}, ${r.rune.name} $verso: '
        '${_primaFrase(r.riga)}.';
  }

  static String _sintesi(EsitoGettata esito) {
    final rune = esito.rune;
    final n = rune.length;
    final ombre = rune.where((r) => r.inOmbra).length;

    final String merk;
    if (ombre == 0) {
      merk = "Tutte le rune escono diritte: il segno è aperto, la via corre "
          "libera.";
    } else if (ombre * 2 > n) {
      merk = 'Molte rune pendono in penombra: il cammino chiede prudenza, non '
          'un no.';
    } else {
      merk = 'Qualche runa in penombra tempera il resto: luce e ombra si '
          'parlano.';
    }

    final aett = _aettDominante(rune);
    final String fam;
    switch (aett) {
      case 'Freyr':
        fam = 'La famiglia di Freyr guida la gettata: forze di sostanza e di '
            'crescita.';
        break;
      case 'Hagal':
        fam = 'La famiglia di Hagal guida la gettata: prova e trasformazione '
            'al lavoro.';
        break;
      default:
        fam = "La famiglia di Tyr guida la gettata: volontà e legami in gioco.";
    }

    final ultima = rune.last;
    final esitoRiga = ultima.inOmbra
        ? "L'esito pende in penombra: non è un rifiuto ma un tempo che chiede "
            "cura."
        : "L'esito esce diritto: la sorte pende dalla tua parte, muoviti con "
            "misura.";

    return '$merk $fam $esitoRiga';
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

  /// La prima frase di una riga del corpus, il titolo breve dell'orientamento.
  static String _primaFrase(String riga) {
    final i = riga.indexOf('.');
    return i < 0 ? riga : riga.substring(0, i);
  }
}

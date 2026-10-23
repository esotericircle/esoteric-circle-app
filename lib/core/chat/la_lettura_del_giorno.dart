import '../maestro/maestro.dart';

import 'chat_message.dart';

/// **LA STESSA DOMANDA NELLO STESSO GIORNO DA' LA STESSA LETTURA.** Ordine DS
/// voce 08, 17 settembre 2026.
///
/// **Il fatto**, sulle catture di un fondatore: la stessa domanda a Medora,
/// a due minuti di distanza, e due letture opposte, *"il cielo si vela di
/// un'ombra sottile, suggerendo una pausa di riflessione"* contro *"una luce
/// inattesa filtra tra le nubi, promettendo chiarezza"*. Stesso giorno, stesso
/// cielo, stessa persona. Il modello gira a temperatura alta e senza memoria
/// del giorno: due chiamate sono due estrazioni.
///
/// **La regola non e' nuova, e' del progetto**: il briefing operativo, sezione
/// 15, *"La regola di coerenza dei responsi"*: la stessa domanda nello stesso
/// giorno da' lo stesso responso, perche' il cielo del giorno e' quello, e
/// cambia il giorno dopo. Lo rispettavano gli oracoli, non la chat.
///
/// **Come si fa senza un archivio nuovo.** La lettura data e' gia' nella
/// conversazione, che si ricarica dalla memoria: si cerca li' la stessa
/// domanda nello stesso giorno, e la risposta che l'ha seguita. Il Maestro la
/// ridice dichiarandolo, e il modello non viene chiamato.
abstract final class LaLetturaDelGiorno {
  /// **LA RIGA CHE PRECEDE LA LETTURA RIDETTA, E LA DICE OGNUNO CON LA SUA
  /// VOCE.** Ordine EC voce 03, 21 settembre 2026.
  ///
  /// **Come e' stato trovato**: dal collaudo con Gemini vero, al primo giro,
  /// sulla mossa 10 del catalogo dell'ordine EB fatta ad Aura. Qui c'era una
  /// frase sola per tutti e tre, e diceva *"Il cielo di oggi non e'
  /// cambiato"*: **cielo e' una parola di firma di Medora**, e la dicevano
  /// anche Aura e Caligo. E' lo stesso difetto del benvenuto della voce
  /// EB.08, in un secondo punto che quell'ordine non aveva guardato.
  ///
  /// **Pesa piu' di quanto sembri**: e' una delle pochissime frasi che il
  /// Maestro dice senza passare dal modello, quindi nessuna istruzione puo'
  /// correggerla. Quello che e' scritto qui e' quello che la persona legge.
  static String premessaDi(Maestro maestro) => switch (maestro) {
        // Medora misura il tempo, e il cielo e' parola sua.
        Maestro.medora => 'Me l’hai già chiesto oggi. Il cielo non si '
            'è mosso da allora: la lettura resta questa.',
        // Aura sta nel corpo e nel presente, e il cielo non lo nomina.
        Maestro.aura => 'Me l’hai già chiesto oggi. Da allora non è '
            'cambiato niente: la lettura resta questa.',
        // Caligo custodisce i segni.
        Maestro.caligo => 'Me l’hai già chiesto oggi. Il segno non è '
            'mutato: la lettura resta questa.',
      };

  /// La domanda ridotta a cio' che conta: minuscole, niente accenti, niente
  /// punteggiatura, spazi semplici. *"Cosa mi dice il cielo, oggi?!"* e
  /// *"cosa mi dice il cielo oggi"* sono la stessa domanda.
  static String impronta(String domanda) {
    const accenti = {
      'à': 'a',
      'á': 'a',
      'è': 'e',
      'é': 'e',
      'ì': 'i',
      'í': 'i',
      'ò': 'o',
      'ó': 'o',
      'ù': 'u',
      'ú': 'u',
    };
    final minuscola = domanda.toLowerCase();
    final b = StringBuffer();
    for (final r in minuscola.runes) {
      final c = String.fromCharCode(r);
      b.write(accenti[c] ?? c);
    }
    return b
        .toString()
        .replaceAll(RegExp(r"[^a-z0-9 ]"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static bool _stessoGiorno(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// La lettura gia' data oggi per [domanda], oppure null.
  ///
  /// Conta solo una risposta VERA: non un ripiego, non un guasto, non un
  /// invito verso una funzione, non il messaggio del limite. Una lettura che
  /// non c'e' stata non si ripete.
  static String? giaData({
    required String domanda,
    required List<ChatMessage> messaggi,
    required DateTime oggi,
  }) {
    final cercata = impronta(domanda);
    if (cercata.isEmpty) return null;
    for (var i = messaggi.length - 1; i >= 0; i--) {
      final m = messaggi[i];
      if (!m.isUser || m.at == null || !_stessoGiorno(m.at!, oggi)) continue;
      if (impronta(m.text) != cercata) continue;
      for (var j = i + 1; j < messaggi.length; j++) {
        final r = messaggi[j];
        if (r.isUser) break;
        if (r.pending || !r.portaUnResponso) continue;
        if (r.text.trim().isEmpty) continue;
        return senzaPremessa(r.text);
      }
    }
    return null;
  }

  /// La lettura senza la premessa, se l'aveva gia': ridire tre volte non deve
  /// accumulare tre premesse.
  /// **Si toglie la premessa di CHIUNQUE, non di uno solo.** Ordine EC voce
  /// 03: da quando ogni Maestro ha la sua, una lettura salvata puo' portare
  /// la premessa di un altro, e riconoscerne una sola lascerebbe la seconda
  /// attaccata al testo.
  static String senzaPremessa(String testo) {
    final t = testo.trimLeft();
    for (final maestro in Maestro.values) {
      final p = premessaDi(maestro);
      if (t.startsWith(p)) return t.substring(p.length).trim();
    }
    return testo;
  }

  /// Cio' che il Maestro dice quando la domanda torna nello stesso giorno.
  /// La lettura ridetta: prima si dichiara che si sta ridicendo, con
  /// la voce di chi la ridice, poi si ridice.
  static String ridetta(String lettura, Maestro maestro) =>
      '${premessaDi(maestro)}\n\n$lettura';
}

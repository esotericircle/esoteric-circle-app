import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// IL FILO CHE LEGA I MOMENTI DELLA GIORNATA. Ordine P voce 18, e voce 09.
///
/// **Il difetto che chiude.** La Parola del Giorno aveva una ragione d'essere
/// che non si vedeva: nasceva all'alba, restava a schermo un minuto e non
/// tornava piu'. La domanda che Medora lascia in fondo alla stesa aveva lo
/// stesso destino: un finale carino che nessuno ricorda. Un dono che si
/// esaurisce quando lo apri non produce ritorni.
///
/// **Cosa fa.** Tiene i tre fili che attraversano la giornata e la notte:
/// - la PAROLA del mattino, che il Sigillo del Sogno richiama la sera con la
///   formula "Stamattina la tua parola era X";
/// - la DOMANDA lasciata da Medora nella stesa, che ricompare nel dono del
///   mattino successivo con la formula "Ieri Medora ti ha lasciato questa
///   domanda";
/// - la runa del tramonto ha gia' la sua cerniera in `SunsetRuneMemory` e non
///   se ne apre una seconda qui: due porte per la stessa cosa e' la famiglia di
///   difetti piu' frequente di questo progetto.
///
/// **Il giorno e' quello RITUALE, non la mezzanotte del calendario.** Chi apre
/// il Sigillo del Sogno all'una di notte sta chiudendo il giorno prima, e la sua
/// parola del mattino e' quella di ieri: il filo si spezzerebbe proprio nel
/// momento in cui deve tenere.
///
/// Best-effort come gli altri store: se le preferenze non ci sono, non lancia,
/// torna il vuoto.
class FiloDelGiorno {
  const FiloDelGiorno._();

  static const String _chiaveParola = 'filo.parola_del_giorno';
  static const String _chiaveDomanda = 'filo.domanda_di_medora';

  /// L'ora prima della quale si sta ancora chiudendo il giorno precedente.
  ///
  /// Le cinque fasce dei doni finiscono col Sigillo del Sogno alle 22:30; chi
  /// arriva dopo la mezzanotte e prima delle cinque sta ancora vivendo quella
  /// sera, non la mattina dopo.
  static const int albaDelGiornoRituale = 5;

  /// Il giorno rituale di [adesso], in ISO yyyy-MM-dd.
  static String giornoRituale(DateTime adesso) {
    final riferimento = adesso.hour < albaDelGiornoRituale
        ? adesso.subtract(const Duration(days: 1))
        : adesso;
    return '${riferimento.year.toString().padLeft(4, '0')}-'
        '${riferimento.month.toString().padLeft(2, '0')}-'
        '${riferimento.day.toString().padLeft(2, '0')}';
  }

  // --- LA PAROLA DEL MATTINO ---

  /// Segna la parola ricevuta all'alba di [adesso].
  static Future<void> segnaLaParola(String parola, DateTime adesso) async {
    if (parola.trim().isEmpty) return;
    await _scrivi(_chiaveParola, {
      'giorno': giornoRituale(adesso),
      'testo': parola,
    });
  }

  /// La parola di STAMATTINA, oppure nulla se non c'e' o se e' di un altro
  /// giorno rituale.
  ///
  /// La sera si richiama solo la parola di oggi: "Stamattina la tua parola era
  /// X" con la parola di tre giorni fa sarebbe una bugia, e per giunta una
  /// bugia che la persona riconosce.
  static Future<String?> parolaDiStamattina(DateTime adesso) async =>
      _leggiDelGiorno(_chiaveParola, giornoRituale(adesso));

  /// La formula con cui il Sigillo del Sogno richiama la parola del mattino.
  /// **IL RICHIAMO CHIUDE IL GIRO, e prima lo apriva soltanto.**
  /// Ordine CQ voce 2.09, 3 settembre 2026.
  ///
  /// Diceva *"Stamattina la tua parola era X."* e finiva li': e' un fatto,
  /// non una risposta. Chi la legge la sera ha in mano una parola presa dodici
  /// ore prima e nessuno gli dice che farsene adesso. **Il Sigillo del Sogno
  /// e' il rito che chiude la giornata**, e la parola e' l'unica cosa che
  /// l'attraversa da capo a capo: la riga lo dice, invece di lasciarlo capire.
  ///
  /// **Non promette niente e non chiede niente**, che e' la legge dei testi di
  /// questa app: dice cosa e' successo alla parola, cioe' che ha attraversato
  /// il giorno ed e' arrivata qui.
  static String richiamoDellaParola(String parola) =>
      'Stamattina la tua parola era $parola, e ha attraversato il giorno con '
      'te: adesso si chiude qui.';

  // --- LA DOMANDA DI MEDORA ---

  /// Segna la domanda con cui Medora ha chiuso la stesa di [adesso].
  static Future<void> segnaLaDomanda(String domanda, DateTime adesso) async {
    if (domanda.trim().isEmpty) return;
    await _scrivi(_chiaveDomanda, {
      'giorno': giornoRituale(adesso),
      'testo': domanda,
    });
  }

  /// La domanda lasciata IERI, oppure nulla.
  ///
  /// **Ieri e non oggi.** La domanda torna nel dono del MATTINO SUCCESSIVO: se
  /// tornasse lo stesso giorno sarebbe la stessa schermata che si ripete, non un
  /// filo fra due giornate. E non torna dopo due giorni: una domanda vecchia di
  /// quarantotto ore non e' piu' la domanda che ti era stata lasciata.
  static Future<String?> domandaDiIeri(DateTime adesso) async {
    final ieri = giornoRituale(adesso.subtract(const Duration(days: 1)));
    return _leggiDelGiorno(_chiaveDomanda, ieri);
  }

  /// La formula con cui il dono del mattino richiama la domanda di ieri.
  static String richiamoDellaDomanda(String domanda) =>
      'Ieri Medora ti ha lasciato questa domanda. $domanda';

  // --- Il magazzino ---

  static Future<void> _scrivi(String chiave, Map<String, String> dato) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(chiave, jsonEncode(dato));
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: senza preferenze il filo non si tiene, e il richiamo semplicemente non compare.
      // Best-effort: senza preferenze il filo non si tiene, e la sera il
      // richiamo semplicemente non compare. Mai un errore in faccia a chi
      // stava compiendo un rito.
    }
  }

  static Future<String?> _leggiDelGiorno(String chiave, String giorno) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grezzo = prefs.getString(chiave);
      if (grezzo == null) return null;
      final dato = jsonDecode(grezzo) as Map<String, dynamic>;
      if (dato['giorno'] != giorno) return null;
      final testo = dato['testo'] as String?;
      return (testo == null || testo.isEmpty) ? null : testo;
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: senza preferenze il filo non si tiene, e il richiamo semplicemente non compare.
      return null;
    }
  }
}

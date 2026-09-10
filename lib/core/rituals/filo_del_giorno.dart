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

  /// **IL GIORNO DI CHI APRE LA GIORNATA, che non e' quello di chi la
  /// chiude.** Ordine CY, voce rimasta aperta, curata il 9 settembre 2026.
  ///
  /// **Il fatto**: *"l'alba dichiara che la parola verra' ripresa la sera nel
  /// sigillo del sogno, ma a me non sembra proprio che accada"*.
  ///
  /// **La causa era il confine delle cinque, applicato dalla parte
  /// sbagliata.** Quel confine e' giusto e serve: chi compie il Sigillo
  /// all'una di notte sta ancora chiudendo la sera di ieri, e il giorno
  /// rituale glielo riconosce. **Ma l'Alba e' il rito che APRE la giornata**:
  /// chi la compie alle due o alle quattro del mattino non sta chiudendo
  /// ieri, sta cominciando oggi. La sua parola finiva sotto il giorno prima, e
  /// la sera dello stesso giorno il Sigillo la cercava sotto oggi e **non la
  /// trovava**.
  ///
  /// **Misurato prima di curare**: con l'Alba alle 2 e il Sigillo alle 22:30
  /// dello stesso giorno la parola ritrovata era **nessuna**; con l'Alba alle
  /// 4 e il Sigillo alle 23, **nessuna**.
  ///
  /// **La cura non tocca il confine, tocca chi lo applica.** L'Alba segna col
  /// giorno CIVILE, perche' apre quel giorno li'; tutto il resto continua a
  /// leggere col giorno rituale, e il Sigillo dopo la mezzanotte continua a
  /// ritrovare la parola del mattino precedente perche' il giorno rituale
  /// glielo riporta indietro.
  static String giornoDiChiApre(DateTime adesso) =>
      '${adesso.year.toString().padLeft(4, '0')}-'
      '${adesso.month.toString().padLeft(2, '0')}-'
      '${adesso.day.toString().padLeft(2, '0')}';

  /// Segna la parola ricevuta all'alba di [adesso].
  static Future<void> segnaLaParola(String parola, DateTime adesso) async {
    if (parola.trim().isEmpty) return;
    await _scrivi(_chiaveParola, {
      'giorno': giornoDiChiApre(adesso),
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
  /// **DICE DUE COSE E NON UNA, e sono due ordini diversi.** La voce CQ
  /// 2.09 pretende che la riga dica **che cosa ne e' stato** della parola,
  /// non solo che parola era; l'ordine CY chiede che chiuda con la domanda
  /// che le da' un uso. Tenere una sola delle due lasciava rossa la guardia
  /// dell'altra: qui stanno tutte e due, il fatto prima e la domanda dopo.
  /// **E LA PAROLA STA FRA VIRGOLETTE.** Ordine DD voce 02, 10 settembre
  /// 2026: dentro una frase la Parola del giorno non si distingueva dal
  /// resto, e la sera e' l'unica cosa che chi legge deve riconoscere. Le
  /// virgolette la staccano anche dove il grassetto non arriva; il
  /// grassetto lo mette [FraseConLaParola] a video.
  static String richiamoDellaParola(String parola) =>
      'Stamattina la tua parola era «$parola». Adesso chiude il giro: '
      'dove l\'hai riconosciuta oggi?';

  /// **LA LENTE: COSA FARSENE DELLA PAROLA.** Ordine CY, approvata dal
  /// fondatore il 9 settembre 2026.
  ///
  /// **La domanda che l'ha fatta nascere**, ripetuta piu' volte: *"COSA DEVE
  /// FARSENE L'UTENTE DELLA PAROLA DEL GIORNO? QUAL E' IL SUO OBIETTIVO? DEVE
  /// CERCARLA NELLE ATTIVITA' QUOTIDIANE? O IL DESTINO E LE STELLE LE
  /// METTERANNO DAVANTI QUESTA PAROLA DURANTE LA GIORNATA?"*
  ///
  /// **Nessuna delle due, ed e' la risposta approvata.** Non e' una caccia al
  /// tesoro, perche' cercare una parola in giro trasforma la giornata in un
  /// gioco e la trova ovunque, che vale quanto non trovarla mai. E non e'
  /// un'attesa del destino, perche' promettere che le stelle te la mettano
  /// davanti e' una promessa che questa app non puo' mantenere e non fa.
  ///
  /// **La parola e' una LENTE.** Non la cerchi: la usi per riconoscere una
  /// cosa che c'era gia' e che senza di lei non avresti chiamato per nome. E'
  /// per questo che la sera il Sigillo chiede **dove l'hai riconosciuta** e
  /// non se l'hai trovata: la prima e' una domanda a cui si puo' rispondere,
  /// la seconda e' un compito da superare.
  ///
  /// **Una riga sola.** Chi legge la parola vuole sapere cosa farsene, non
  /// leggere un paragrafo sul metodo.
  static String laLente(String parola) =>
      'Non cercarla: tienila addosso. Serve a riconoscere una cosa che oggi '
      'c\'è già e che senza di lei non avresti chiamato per nome.';

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

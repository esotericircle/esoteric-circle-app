import 'package:shared_preferences/shared_preferences.dart';

/// IL CAMMINO RIPARTE PULITO, UNA VOLTA SOLA. Ordine AR voce 06.
///
/// **Perche' si azzera.** Il Cammino e' stato riprogettato: i traguardi non
/// sono piu' quelli, e i contatori accumulati mentre si provava l'app
/// racconterebbero una storia che non esiste piu'. Strada A, scelta da Mauro:
/// si riparte da zero, una volta sola, per ogni Cerchio.
///
/// **IL SALDO EOS NON SI AZZERA, ed e' una decisione dichiarata.** Gli Eos
/// gia' guadagnati sono denaro: servono a comprare, a provare i lucchetti e a
/// vedere le spese funzionare. La chiave del saldo, `allowance.saldoEos`, non
/// compare in nessuna delle liste qui sotto, ed e' scritto anche qui perche'
/// nessuno la aggiunga per sbaglio "per pulizia".
///
/// **Una volta sola vuol dire una volta sola.** La generazione raggiunta si
/// scrive sul disco: alla seconda apertura non si azzera piu' niente, e chi
/// reinstalla ricomincia dal cammino che il Cerchio gli restituisce, non da
/// un secondo azzeramento.
class RinascitaDelCammino {
  const RinascitaDelCammino._();

  /// **LA GENERAZIONE DEL CAMMINO, e non e' la versione del formato.** La
  /// versione del formato (`VERSIONE_DEL_CAMMINO` sul server) dice come sono
  /// fatti i campi; questa dice quale CAMMINO si sta percorrendo. Cambia solo
  /// quando i traguardi cambiano al punto che i conti di prima non valgono
  /// piu': oggi vale due, perche' la revisione dei 165 e' la seconda vita del
  /// Cammino.
  static const int generazioneAttuale = 2;

  static const String _kGenerazione = 'cammino.generazione';

  /// Le chiavi che l'azzeramento cancella: il diario, il libro degli
  /// accrediti e la coda delle feste. **Sono elencate per nome e non per
  /// prefisso**: un `removeWhere` su "cammino." avrebbe portato via anche
  /// questa stessa generazione, e il giorno che qualcuno mettesse il saldo
  /// sotto quel prefisso lo avrebbe portato via in silenzio.
  static const List<String> chiaviDaAzzerare = [
    // Il diario del cammino.
    'cammino.gesti',
    'cammino.giorni',
    'cammino.oggi',
    'cammino.giornoDiOggi',
    'cammino.ore',
    'cammino.primoGiorno',
    'cammino.ultimoGiorno',
    'cammino.accesi',
    'cammino.accesi.quando',
    'cammino.condivisi',
    'cammino.serie',
    'cammino.ultimoPerRito',
    // Il libro degli accrediti: senza questo i premi gia' pagati
    // resterebbero segnati e i traguardi nuovi non pagherebbero.
    'cammino.accreditati',
    // Le feste in attesa: celebrerebbero traguardi che non esistono piu'.
    'cammino.feste_in_attesa',
  ];

  /// La chiave del saldo, che NON si azzera. Sta qui per essere nominata: una
  /// prova la legge e cade se finisce fra quelle da cancellare.
  static const String chiaveDelSaldoCheResta = 'allowance.saldoEos';

  /// Vero se questo telefono non ha ancora fatto la rinascita di questa
  /// generazione.
  static Future<bool> serveRinascere({SharedPreferences? preferenze}) async {
    final prefs = preferenze ?? await SharedPreferences.getInstance();
    return (prefs.getInt(_kGenerazione) ?? 1) < generazioneAttuale;
  }

  /// Vero se su questo telefono c'era davvero un cammino da azzerare.
  ///
  /// **Serve alla riga onesta.** Un Cerchio nuovo non deve leggere che il suo
  /// cammino e' stato riprogettato: non aveva ancora fatto niente, e quella
  /// frase gli direbbe di una perdita che non ha subito.
  static Future<bool> ceraQualcosaDaAzzerare(
      {SharedPreferences? preferenze}) async {
    final prefs = preferenze ?? await SharedPreferences.getInstance();
    for (final chiave in chiaviDaAzzerare) {
      if (prefs.containsKey(chiave)) return true;
    }
    return false;
  }

  /// Azzera il cammino sul disco e segna la generazione raggiunta.
  ///
  /// Torna vero se ha azzerato qualcosa che esisteva, cioe' se la riga onesta
  /// va mostrata. **E' idempotente**: chiamarla due volte non fa niente la
  /// seconda, perche' la generazione e' gia' quella attuale.
  static Future<bool> rinasci({SharedPreferences? preferenze}) async {
    final prefs = preferenze ?? await SharedPreferences.getInstance();
    if (!await serveRinascere(preferenze: prefs)) return false;
    final cera = await ceraQualcosaDaAzzerare(preferenze: prefs);
    for (final chiave in chiaviDaAzzerare) {
      await prefs.remove(chiave);
    }
    await prefs.setInt(_kGenerazione, generazioneAttuale);
    return cera;
  }

  /// LA RIGA ONESTA, in tono di Maestro.
  ///
  /// Dice cosa e' successo e cosa NON e' successo: la persona che riapre e
  /// trova il Journal spento deve capire in una frase, e deve sapere subito
  /// che i suoi Eos sono dove li aveva lasciati.
  static const String rigaOnesta =
      'Il Cammino e stato riprogettato: centosessantacinque traguardi nuovi, '
      'e il tuo riparte da qui. I tuoi Eos non sono stati toccati.';
}

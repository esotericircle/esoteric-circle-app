import '../maestro/consiglio_finale.dart';

/// **UN MAESTRO NON RIPETE UNA RISPOSTA GIA' DATA.** Ordine EN voce 06, 25
/// settembre 2026.
///
/// **Il fatto, dalle catture del fondatore**: alla richiesta *"Prova ancora a
/// rispondergli su via moglie."* Medora ha restituito la stessa risposta
/// parola per parola. La regola c'era, nell'istruzione di sistema da tre
/// ordini (*"Non ripetere una frase che hai già detto in questa
/// conversazione"*), e il modello l'ha ignorata: una regola che dipende da un
/// modello regge quasi sempre, e il fondatore ha trovato il quasi.
///
/// **Qui la si guarda a valle**, come la voce che non si confonde e
/// l'ancoraggio: la risposta nuova si confronta con quelle gia' date nella
/// stessa conversazione, e se ne ricalca una il controller chiede di nuovo,
/// una volta sola, nominando al modello la risposta da non ripetere.
///
/// **La grandezza misurata e' quanta parte della risposta nuova c'era gia'
/// in una vecchia**, parola per parola, contando le parole di quattro lettere
/// o piu': gli articoli e le preposizioni ci sono in ogni risposta e non
/// dicono niente. La riga d'oro si toglie prima, perche' la sorveglia gia'
/// `ConsiglioFinale.righeGiaScritte`.
abstract final class LaRispostaRipetuta {
  /// Oltre questa parte in comune la risposta e' una ripetizione. **Misurata
  /// sul collaudo dell'ordine EN**, `docs/collaudo/EN/risposte/prima/`: nelle
  /// sei conversazioni sulla moglie la seconda risposta, alla richiesta di
  /// riprovare, divideva con la prima dallo 0 al 23 per cento delle parole;
  /// la risposta ricalcata delle catture del fondatore sta al cento. Settanta
  /// sta lontano da tutte e due.
  static const double soglia = 0.7;

  /// Sotto queste parole la risposta non si confronta. **La suite intera
  /// l'ha mostrato alla prima stesura**: due prove di casa rispondono con
  /// *"Una risposta a testo, la numero 2."*, che conta tre parole ed e'
  /// uguale alla numero 1 in tutte e tre; la rete la chiedeva di nuovo, e il
  /// giorno dopo la stessa domanda chiamava il modello due volte. Una
  /// risposta breve che ridice un fatto (*"Il tuo cane si chiama Argo."*,
  /// tre parole) non e' la lettura ricalcata delle catture del fondatore,
  /// che ne contava decine.
  static const int paroleMinime = 8;

  static Set<String> _parole(String testo) => {
        for (final p in ConsiglioFinale.corpoDa(testo)
            .toLowerCase()
            .split(RegExp(r'[^a-zàèéìíòóùú]+')))
          if (p.length > 3) p,
      };

  /// Quanta parte di [nuova] c'era gia' in [vecchia], da zero a uno.
  static double inComune(String nuova, String vecchia) {
    final pn = _parole(nuova);
    if (pn.isEmpty) return 0;
    final pv = _parole(vecchia);
    return pn.where(pv.contains).length / pn.length;
  }

  /// La risposta gia' data che [nuova] ripete, o null se non ne ripete
  /// nessuna.
  static String? quale(String nuova, Iterable<String> giaDate) {
    if (_parole(nuova).length < paroleMinime) return null;
    String? peggiore;
    var massimo = soglia;
    for (final vecchia in giaDate) {
      final c = inComune(nuova, vecchia);
      if (c >= massimo) {
        massimo = c;
        peggiore = vecchia;
      }
    }
    return peggiore;
  }
}

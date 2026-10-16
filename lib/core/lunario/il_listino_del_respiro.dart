/// **IL LISTINO DELLA RICUCITURA.** Ordine FX voce FX.05, 16 ottobre 2026.
///
/// **TODO integrazione, AGGIORNATO dopo aver trovato il lavoro parallelo
/// sullo stesso ordine.** Mentre scrivevo questo file e' comparso, scritto
/// da un altro agente dello stesso ordine FX,
/// `lib/features/respiro_della_luna/gli_eos_del_respiro.dart`
/// (`GliEosDelRespiro`, voce FX.10): tiene gia' un contatore
/// `perleRicucite` con `aggiungiUnaPerlaRicucita()` e
/// `consumaUnaPerlaRicucita()`, e nomina il prezzo vero come
/// `ListinoDegliEos.perlaRicucita` (non ancora scritto in
/// `lib/core/entitlement/listino_degli_eos.dart`). **Questo agente non ha
/// toccato nessuno dei due file**, per non scontrarsi con chi ci lavora in
/// parallelo: chi integra collega [costoRicucituraInEos] al prezzo vero di
/// `ListinoDegliEos.perlaRicucita` quando quella voce esiste, e fa
/// consumare un credito di `GliEosDelRespiro.consumaUnaPerlaRicucita()`
/// prima di chiamare `LaCollanaDelleLune.ricuciUnaPerlaLocalmente` (vedi il
/// TODO su quel metodo). [massimePerleRicucitePerCiclo] e
/// [massimoGiorniIndietro] restano invece regole di questa voce, che
/// nessun altro file nomina.
///
/// **Il prezzo, scelto e motivato da Code.** Venticinque Eos: sotto i
/// trenta del `confrontoDelCieloInPiu`, che nel listino vero e' il prezzo
/// piu' basso, perche' ricucire una perla non sblocca niente di nuovo,
/// restituisce solo un giorno che si poteva avere gratis respirando una
/// volta. Resta comunque nello stesso ordine di grandezza degli acquisti
/// singoli del listino (circa 30-100 Eos), come chiede l'ordine FX.05.
///
/// **I limiti, scelti e motivati da Code.** Al massimo tre perle ricucite
/// per ciclo: la ricucitura e' il ripiego per una dimenticanza occasionale,
/// non un modo di saltare il rito per un terzo del mese e comprarsi la
/// collana. Al massimo sette giorni indietro, una settimana: e' il tempo in
/// cui un giorno perso si ricorda ancora con chiarezza; oltre quella soglia
/// ricucire somiglierebbe a riscrivere un passato che si e' gia' sbiadito.
abstract final class IlListinoDelRespiro {
  /// Quanti Eos costa ricucire una perla spenta.
  static const int costoRicucituraInEos = 25;

  /// Quante perle si possono ricucire in uno stesso ciclo.
  static const int massimePerleRicucitePerCiclo = 3;

  /// Fino a quanti giorni indietro, dentro il ciclo in corso, si puo'
  /// ricucire una perla.
  static const int massimoGiorniIndietro = 7;
}

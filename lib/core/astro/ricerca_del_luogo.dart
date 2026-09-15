import 'city_catalog.dart';

/// LA RICERCA DEL LUOGO, UNA REGOLA SOLA PER TUTTE LE PORTE.
/// Ordine CF voce 08.
///
/// **Il fatto del fondatore, verbatim**: "in questa schermata non funzionava
/// l'inserimento della citta', ovvero potevo inserirla, ma non trovava nulla
/// nel suo elenco. quindi ho dovuto reinserire i dati dal menu' utente e qui
/// tutto ok".
///
/// **La causa, misurata: due porte con due codici diversi.** Il rito
/// dell'accoglienza cercava con `CityCatalog.unicaEsatta` e, quando il nome
/// scritto per intero combaciava con un solo luogo in catalogo, **svuotava
/// l'elenco dei suggerimenti** e sceglieva da solo. La schermata dei dati di
/// nascita, raggiunta dal menu' utente, non aveva quella riga e l'elenco lo
/// mostrava sempre. Stessa domanda, due risposte: chi scriveva "Roma" nel rito
/// vedeva l'elenco vuoto e concludeva che il Cerchio non conoscesse Roma.
///
/// **La cura e' togliere la porta, non correggerla nel chiamante**, perche'
/// due porte sulla stessa domanda sono la famiglia di difetti piu' numerosa
/// di questo progetto. Qui vive la regola, e le due schermate la chiamano.
///
/// **La scelta automatica RESTA, ed e' una decisione precedente che non si
/// rovescia**: chi scrive per intero il nome della propria citta' ha gia'
/// detto tutto, e nessuno gli chiede di confermare cio' che ha appena
/// scritto. **Cio' che cambia e' che l'elenco non si svuota piu'**: la persona
/// vede il luogo che ha scritto, quindi non ha mai davanti uno schermo che
/// sembra dire "non l'ho trovato".
class RicercaDelLuogo {
  const RicercaDelLuogo._();

  /// Cosa risponde la ricerca a una battuta.
  ///
  /// [scelta] e' il luogo che si sceglie da solo, quando il nome scritto per
  /// intero combacia con un solo luogo in catalogo, altrimenti nulla.
  /// [risultati] sono i suggerimenti da mostrare, e ci sono SEMPRE quando il
  /// catalogo ha qualcosa da dire.
  static ({City? scelta, List<City> risultati}) per(String query) => (
        scelta: CityCatalog.unicaEsatta(query),
        risultati: CityCatalog.search(query),
      );
}

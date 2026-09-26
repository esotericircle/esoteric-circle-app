import 'dart:async';

import 'city_catalog.dart';
import 'il_mondo_intero.dart';

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

/// LA DOMANDA AL MONDO, UNA SOLA ANCHE QUESTA. Ordine DR voce 10.
///
/// **Perche' e' una classe e non tre pezzi di codice uguali.** Le porte che
/// cercano un luogo sono tre: il rito dell'accoglienza, i dati di nascita e il
/// dove vivi adesso. Scrivere in tre posti l'attesa, il conto dei giri e la
/// fusione con l'elenco del catalogo vorrebbe dire creare di nuovo la famiglia
/// di difetti che l'ordine CF voce 08 ha chiuso: due porte sulla stessa
/// domanda sono due verita'. Qui la regola sta una volta, e le schermate la
/// tengono in un campo.
///
/// **QUANDO SI CHIEDE AL MONDO: solo quando il catalogo non sa niente.** Chi
/// scrive "Roma" trova Roma senza rete e senza far partire nessuna chiamata.
/// La domanda esce di casa soltanto quando l'elenco offline e' vuoto, che e'
/// esattamente il momento in cui il fondatore ha visto lo schermo dire "non
/// l'ho trovato": e' quella schermata li' che quest'ordine viene a riempire.
class RicercaNelMondo {
  RicercaNelMondo({this.attesa = const Duration(milliseconds: 600)});

  /// Quanto si lascia passare dall'ultima lettera battuta prima di chiedere.
  /// Non e' cortesia verso il servizio: e' che le lettere in mezzo a una
  /// parola non sono domande, sono una parola a meta'.
  final Duration attesa;

  Timer? _rinvio;

  /// **IL NUMERO DEL GIRO.** Due domande partite in ordine possono tornare
  /// nell'ordine contrario, e la piu' vecchia riempirebbe l'elenco di chi sta
  /// leggendo la piu' nuova. Solo l'ultima parla.
  int _giro = 0;

  /// Vero mentre una domanda e' per strada, per chi vuole mostrarlo.
  bool get inCammino => _inCammino;
  bool _inCammino = false;

  /// Chiede [query] al mondo e chiama [quando] con cio' che ha trovato.
  ///
  /// [gia] e' l'elenco che il catalogo ha gia' dato: se non e' vuoto la
  /// domanda non parte affatto, e [quando] non viene chiamato.
  void chiedi(
    String query, {
    required List<City> gia,
    required void Function(List<City> trovati) quando,
  }) {
    _rinvio?.cancel();
    if (gia.isNotEmpty) {
      _inCammino = false;
      return;
    }
    if (query.trim().length < IlMondoIntero.lunghezzaMinima) {
      _inCammino = false;
      return;
    }
    final mio = ++_giro;
    _inCammino = true;
    _rinvio = Timer(attesa, () async {
      final trovati = await IlMondoIntero.cerca(query);
      if (mio != _giro) return;
      _inCammino = false;
      quando(trovati);
    });
  }

  /// Si chiude quando la schermata si chiude: un rinvio che scatta dopo non
  /// trova piu' nessuno ad ascoltare.
  void chiudi() {
    _rinvio?.cancel();
    _rinvio = null;
    _giro++;
    _inCammino = false;
  }
}

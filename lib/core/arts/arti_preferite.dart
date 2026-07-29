import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../maestro/maestro.dart';
import 'art_catalog.dart';

/// Lo scaffale personale: "Le tue arti".
///
/// Tre regole vivono qui, nel dato, non nelle schermate che lo mostrano.
///
/// 1. **Non parte mai vuoto.** Al primo avvio si semina dal Maestro che la
///    Risonanza ha assegnato: le sue arti vive, piu' una per ciascuno degli
///    altri due, cosi' lo scaffale nasce abitato e non chiude la persona in un
///    dominio solo. Uno scaffale vuoto al primo ingresso sarebbe una stanza
///    spoglia con scritto "personalizzami", che e' un compito, non un dono.
/// 2. **Se lo si svuota, torna il seme.** Togliere l'ultima arte non lascia il
///    vuoto: ricompare lo scaffale iniziale. Non si puo' restare senza niente.
/// 3. **Nessun piano a pagamento la tocca.** I preferiti sono una comodita' di
///    chi usa l'app, non merce: qui non si legge nessun tier e nessun
///    entitlement, e un test lo verifica leggendo questo file.
///
/// Il tetto e' [tetto]: oltre quel numero lo scaffale smette di essere una
/// scelta e ridiventa un elenco.
class ArtiPreferiteController extends ChangeNotifier {
  ArtiPreferiteController({Maestro? maestroAssegnato})
      : _maestro = maestroAssegnato;

  /// Quante arti stanno al massimo nello scaffale personale.
  ///
  /// Sei: le arti vive sono nove, quindi sei lascia una scelta vera senza
  /// trasformare lo scaffale nell'elenco completo.
  static const int tetto = 6;

  static const String _chiave = 'arti_preferite_v1';

  Maestro? _maestro;
  List<String> _ids = const [];
  bool _caricato = false;

  /// Le arti nello scaffale, nell'ordine in cui vanno mostrate.
  List<String> get ids => List.unmodifiable(_ids);

  /// Vero quando lo stato e' stato letto dal disco: prima di allora la
  /// schermata mostra il seme invece di un vuoto momentaneo.
  bool get caricato => _caricato;

  bool contiene(String id) => _ids.contains(id);

  bool get pieno => _ids.length >= tetto;

  /// Il Maestro da cui nasce il seme. Cambiarlo NON riscrive le scelte gia'
  /// fatte: chi ha personalizzato lo scaffale se lo tiene.
  void setMaestro(Maestro maestro) {
    if (_maestro == maestro) return;
    _maestro = maestro;
    if (_ids.isEmpty) {
      _ids = semePer(maestro);
      notifyListeners();
    }
  }

  /// Il seme: le arti vive del proprio Maestro, poi una per ciascuno degli
  /// altri due, in ordine di catalogo. Deterministico, senza numeri casuali:
  /// due persone con lo stesso Maestro partono dallo stesso scaffale.
  static List<String> semePer(Maestro? maestro) {
    final proprie = <String>[];
    final altre = <String>[];
    for (final m in Maestro.values) {
      final vive = ArtCatalog.activeOf(m).map((a) => a.id).toList();
      if (m == maestro) {
        proprie.addAll(vive);
      } else if (vive.isNotEmpty) {
        altre.add(vive.first);
      }
    }
    // Senza Maestro assegnato, cioe' prima della Risonanza, si prende la prima
    // arte viva di ciascuno: lo scaffale nasce comunque abitato.
    if (maestro == null) {
      for (final m in Maestro.values) {
        final vive = ArtCatalog.activeOf(m).map((a) => a.id).toList();
        if (vive.isNotEmpty) proprie.add(vive.first);
      }
      return proprie.take(tetto).toList();
    }
    return [...proprie, ...altre].take(tetto).toList();
  }

  /// Tutte le arti che si possono mettere nello scaffale: le vive di tutti e
  /// tre i Maestri. Fra queste ci sono anche le arti che l'elenco del Santuario
  /// non mostrava, come l'Estrazione Rune e il Sigillo dell'Intenzione.
  static List<String> get selezionabili => [
        for (final m in Maestro.values)
          for (final a in ArtCatalog.activeOf(m)) a.id,
      ];

  Future<void> carica() async {
    final prefs = await SharedPreferences.getInstance();
    final salvate = prefs.getStringList(_chiave);
    // Si tengono solo le arti ancora vive: un'arte ritirata dal catalogo non
    // deve lasciare una tessera che non si apre.
    final valide =
        (salvate ?? const <String>[]).where(selezionabili.contains).toList();
    _ids = valide.isEmpty ? semePer(_maestro) : valide;
    _caricato = true;
    notifyListeners();
  }

  Future<void> _salva() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_chiave, _ids);
  }

  /// Mette o toglie un'arte. Restituisce cosa e' successo, cosi' la schermata
  /// puo' dirlo invece di lasciare la persona a indovinare.
  EsitoPreferita cambia(String id) {
    if (!selezionabili.contains(id)) return EsitoPreferita.sconosciuta;
    if (_ids.contains(id)) {
      _ids = [..._ids]..remove(id);
      // Regola 2: svuotare non lascia il vuoto.
      final tornatoAlSeme = _ids.isEmpty;
      if (tornatoAlSeme) _ids = semePer(_maestro);
      _salva();
      notifyListeners();
      return tornatoAlSeme ? EsitoPreferita.ripristinata : EsitoPreferita.tolta;
    }
    if (pieno) return EsitoPreferita.pieno;
    _ids = [..._ids, id];
    _salva();
    notifyListeners();
    return EsitoPreferita.aggiunta;
  }
}

/// Cosa e' successo a una richiesta di cambio, per poterlo dire a schermo.
enum EsitoPreferita {
  aggiunta,
  tolta,

  /// Era l'ultima: lo scaffale e' tornato al suo seme invece di restare vuoto.
  ripristinata,

  /// Il tetto e' pieno: va tolta un'arte prima di aggiungerne un'altra.
  pieno,

  /// Un identificativo che non corrisponde a nessuna arte viva.
  sconosciuta,
}

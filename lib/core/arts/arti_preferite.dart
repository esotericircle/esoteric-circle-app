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
  /// NOVE, tre per ciascun Maestro. Era sei, e sei era una decisione presa per
  /// lasciare una scelta vera invece dell'elenco completo: il fondatore l'ha
  /// cambiata il 30 luglio 2026, perche' con tre arti a schermo lo scaffale
  /// sembrava scarno e non un luogo che ti appartiene.
  ///
  /// Resta un numero solo, in un punto solo: il foglio della matita lo legge da
  /// qui, non lo ripete.
  static const int tetto = 9;

  /// Quante arti per Maestro entrano nel seme.
  ///
  /// DUE dal 31 luglio 2026, ed era tre dal giorno prima. Il fondatore ha
  /// cambiato la sua stessa decisione per il motivo che avevo dichiarato io:
  /// con nove nel seme e nove arti vive lo scaffale nasceva completo, e la
  /// matita serviva solo a togliere. Con sei nel seme e il tetto a nove la
  /// matita serve davvero ad aggiungere.
  ///
  /// Non e' `tetto` diviso i Maestri: sono due numeri con due ragioni diverse,
  /// e adesso si vede, perche' due per tre fa sei e il tetto e' nove. Una prova
  /// cade se il seme non ne ha esattamente due per ciascuno.
  static const int perMaestro = 2;

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

  /// Il seme: TRE arti vive per ciascun Maestro, nell'ordine del catalogo.
  ///
  /// **Cosa e' cambiato, e perche'.** Prima il seme prendeva le arti del proprio
  /// Maestro piu' una per ciascuno degli altri due, e col Maestro nullo ne
  /// prendeva tre in tutto: e' esattamente la terna scarna che si vedeva a
  /// schermo, horoscope, meditation e rune_draw. Adesso ogni Maestro porta le
  /// sue tre, e lo scaffale nasce pieno come un luogo che ti appartiene.
  ///
  /// Il proprio Maestro va per PRIMO, quando c'e': lo scaffale si apre su cio'
  /// che e' tuo, poi sul resto del Cerchio.
  ///
  /// Deterministico, senza numeri casuali: due persone con lo stesso Maestro
  /// partono dallo stesso scaffale.
  static List<String> semePer(Maestro? maestro) {
    // L'ordine dei Maestri: il proprio davanti, gli altri dietro come sono nel
    // catalogo. Senza Maestro assegnato, cioe' prima della Risonanza, l'ordine
    // del catalogo va bene cosi' com'e'.
    final ordine = <Maestro>[
      if (maestro != null) maestro,
      ...Maestro.values.where((m) => m != maestro),
    ];

    final seme = <String>[];
    for (final m in ordine) {
      seme.addAll(ArtCatalog.activeOf(m).map((a) => a.id).take(perMaestro));
    }
    return seme.take(tetto).toList();
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

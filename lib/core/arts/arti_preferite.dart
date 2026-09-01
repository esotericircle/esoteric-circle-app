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
  /// **DIMENTICA CHI SE NE VA. Ordine BC voce 02.** Vedi
  /// `DimenticanzaDellaMemoriaViva`: i controller vivono per tutta la
  /// sessione, e cancellare l'account senza svuotarli lascia a schermo i dati
  /// di chi se n'e' appena andato. **Questo l'ha trovato la prova che enumera
  /// i provider di `app.dart`**, non l'occhio: era uno dei cinque che nessuno
  /// aveva contato.
  void dimenticaChiSeNeVa() {
    _maestro = null;
    _ids = const [];
    notifyListeners();
  }

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

  /// **IL SEME E' L'ELENCO DI MAURO, nell'ordine suo.** Voce del 17 agosto
  /// 2026, ordine AK voce 01: le sette arti che ogni scaffale nuovo mostra.
  /// La ragione del seme vecchio (due arti per Maestro, per lasciare alla
  /// matita qualcosa da aggiungere) e' superata da questa decisione: sette
  /// nel seme e il tetto a nove lasciano comunque due posti alla matita.
  /// Chi ha gia' personalizzato su disco tiene il suo: il seme vale solo per
  /// chi non ha mai scelto.
  static const List<String> setteDiMauro = [
    'horoscope',
    'tarot_spread_three',
    'synastry_vip',
    'rune_draw',
    'guide_animal',
    'meditation',
    'face_constellation',
  ];

  /// **LE ETICHETTE BREVI DELLO SCAFFALE.** Decisione di Mauro: nella home
  /// la stesa si chiama "Tarocchi"; il catalogo e ogni altro posto dell'app
  /// tengono "Stesa di Tarocchi". E' un dato di QUESTO controller, mai una
  /// seconda voce di catalogo e mai una stringa incollata in un widget.
  ///
  /// **L'OROSCOPO, ordine BK voce 01.** Parole del fondatore: "la
  /// funzionalita' Oroscopo Personalizzato si chiamera' solo oroscopo cosi'
  /// il font sara' piu' grande in home". Il motivo e' misurabile e non
  /// estetico: il titolo della bolla vive in un `FittedBox(scaleDown)`, che
  /// rimpicciolisce quello che non ci sta. "Oroscopo Personalizzato" non ci
  /// stava e veniva reso in piccolo; "Oroscopo" ci sta, e il corpo resta
  /// quello pieno. Il catalogo continua a dire "Oroscopo Personalizzato",
  /// perche' il nome lungo e' il nome dell'arte: cambia solo come si chiama
  /// sullo scaffale di casa.
  static const Map<String, String> _etichetteBrevi = {
    'tarot_spread_three': 'Tarocchi',
    'horoscope': 'Oroscopo',
  };

  /// L'etichetta breve di un'arte nello scaffale, se ne ha una.
  static String? etichettaBreve(String id) => _etichetteBrevi[id];

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

  /// Il seme: LE SETTE DI MAURO, uguali per tutti, nell'ordine suo.
  ///
  /// La storia del seme vecchio (per Maestro, prima tre poi due a testa)
  /// vive nel commento di `setteDiMauro`: e' stata superata dalla voce del
  /// 17 agosto.
  static List<String> semePer(Maestro? maestro) {
    // L'ordine non dipende piu' dal Maestro assegnato: e' l'ordine ESATTO
    // dettato da Mauro, uguale per tutti. Il parametro resta nella firma
    // perche' chi chiama non debba cambiare, e per il giorno in cui il seme
    // tornasse a dipendere dal Maestro.
    return List<String>.from(setteDiMauro);
  }

  /// Tutte le arti che si possono mettere nello scaffale: le vive di tutti e
  /// tre i Maestri. Fra queste ci sono anche le arti che l'elenco del Santuario
  /// non mostrava, come l'Estrazione Rune e il Sigillo dell'Intenzione.
  static List<String> get selezionabili => [
        for (final m in Maestro.values)
          for (final a in ArtCatalog.activeOf(m)) a.id,
      ];

  /// ADOTTA LE ARTI PREFERITE CHE IL CERCHIO HA RESTITUITO. Ordine AP voce 02.
  ///
  /// Si sostituisce e non si unisce, ed e' scritto anche sul server: le arti
  /// preferite sono un ORDINE scelto dalla persona, e unire due elenchi
  /// inventerebbe un ordine che nessuno ha scelto. Cio' che arriva ha gia'
  /// vinto la fusione, quindi qui si adotta e basta.
  Future<void> adottaDalCerchio(List<String> arti) async {
    if (arti.isEmpty) return;
    final valide = [
      for (final a in arti)
        if (selezionabili.contains(a)) a
    ];
    if (valide.isEmpty) return;
    _ids = valide;
    notifyListeners();
    await _salva();
  }

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

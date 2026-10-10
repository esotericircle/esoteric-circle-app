import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'city_catalog.dart';
import 'sky_location.dart';

/// COME SI E' SAPUTO DOVE SEI ADESSO.
enum OrigineDelLuogo {
  /// Dal GPS del telefono, col permesso concesso.
  dispositivo,

  /// SCELTO DALLA PERSONA dal catalogo delle citta'.
  ///
  /// **Vale quanto il GPS per l'ora del sorgere**, e non e' una concessione: il
  /// sorgere dipende da latitudine e longitudine, e dentro una citta' la
  /// differenza fra un quartiere e l'altro non arriva al minuto. Chi dichiara
  /// "vivo a Milano" ha detto tutto quello che serve.
  scelto,
}

/// DOVE SEI ADESSO, e non dove sei nato. Ordine P voce 23.
///
/// **Il difetto che questa classe chiude, e non e' quello che sembrava.** La
/// meta' del difetto era gia' caduta: `PosizioneDiStamattina` garantisce da un
/// ordine precedente che coordinate e scarto di fuso vengano dalla STESSA
/// origine, quindi l'alba non nasce piu' da due punti diversi del mondo messi
/// insieme. Cio' che restava e' il caso di gran lunga piu' frequente: **chi non
/// concede la posizione non ha nessun modo di dire dove vive.**
///
/// Le due strade erano il GPS o la stima dal fuso, e la stima non e'
/// dichiarabile perche' una longitudine dedotta dall'offset puo' sbagliare di
/// mezz'ora abbondante. Risultato: chi nasce a Sydney e vive a Milano, e non
/// concede la posizione, non vede mai l'ora del sorgere. La terza voce
/// dell'ordine pesa piu' delle altre due proprio per questo.
///
/// **La terza strada e' dichiararlo.** Una citta' scelta dal catalogo si
/// conserva fra un avvio e l'altro, non chiede nessun permesso, e per il sorgere
/// vale quanto il GPS.
class LuogoAttuale {
  const LuogoAttuale({
    required this.lat,
    required this.lon,
    required this.citta,
    required this.origine,
  });

  final double lat;
  final double lon;

  /// Il nome leggibile, per dirlo alla persona: "Milano". Mai vuoto.
  final String citta;

  final OrigineDelLuogo origine;

  /// Il luogo che nasce da una citta' del catalogo.
  factory LuogoAttuale.dallaCitta(City c) => LuogoAttuale(
        lat: c.latitude,
        lon: c.longitude,
        citta: c.name,
        origine: OrigineDelLuogo.scelto,
      );

  /// Il luogo che nasce dal dispositivo. Il nome puo' mancare, e allora si dice
  /// cio' che si sa invece di inventare una citta'.
  factory LuogoAttuale.dalDispositivo(SkyPlace p) => LuogoAttuale(
        lat: p.latitude,
        lon: p.longitude,
        citta: (p.citta == null || p.citta!.isEmpty)
            ? 'dove sei adesso'
            : p.citta!,
        origine: OrigineDelLuogo.dispositivo,
      );

  /// Il luogo come lo vuole chi calcola il cielo.
  SkyPlace get comePosto =>
      SkyPlace(latitude: lat, longitude: lon, citta: citta);

  /// **LA CHIAVE DEL NOME NON SI CHIAMA `citta`, e la ragione e' una prova.**
  /// `test/accenti_veri_test.dart` guarda tutte le stringhe di `lib/` e accusa
  /// le parole che in italiano non esistono senza accento: "citta" e' una di
  /// quelle. Qui non era un testo a video ma una chiave di magazzino, quindi
  /// l'accusa era un falso positivo; solo che una chiave di magazzino puo'
  /// chiamarsi come vuole, e cambiarle nome costa meno che insegnare alla prova
  /// a distinguere una chiave da una frase. La prova resta severa e il dato
  /// resta chiaro: si chiama `nome`, che e' anche piu' vero, perche' quando il
  /// luogo viene dal dispositivo puo' non essere il nome di una citta'.
  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'nome': citta,
        'origine': origine.name,
      };

  static LuogoAttuale? fromJson(Map<String, dynamic> j) {
    final lat = (j['lat'] as num?)?.toDouble();
    final lon = (j['lon'] as num?)?.toDouble();
    final citta = j['nome'] as String?;
    if (lat == null || lon == null || citta == null || citta.isEmpty) {
      return null;
    }
    return LuogoAttuale(
      lat: lat,
      lon: lon,
      citta: citta,
      origine: OrigineDelLuogo.values.firstWhere(
        (o) => o.name == j['origine'],
        orElse: () => OrigineDelLuogo.scelto,
      ),
    );
  }
}

/// IL LUOGO ATTUALE CONSERVATO FRA UN AVVIO E L'ALTRO.
///
/// **La conservazione e' la seconda delle tre cose che la voce chiede**, e senza
/// di lei le altre due non servono a niente: una citta' scelta che si dimentica
/// alla chiusura dell'app va scelta ogni mattina, e nessuno la sceglie due volte.
///
/// Si conserva ANCHE il luogo venuto dal dispositivo, e non e' un doppione del
/// GPS: il GPS puo' non rispondere, il servizio puo' essere spento, si puo'
/// essere in metropolitana. L'ultimo posto noto e' meglio di una stima dal fuso,
/// e la sua origine resta scritta, quindi nessuno lo confonde con una lettura
/// fresca.
///
/// Best-effort come gli altri store: senza preferenze torna nulla e il rito
/// resta intero, senza l'ora del sorgere.
class DoveSonoAdesso {
  const DoveSonoAdesso._();

  static const String _chiave = 'luogo.attuale';

  static Future<LuogoAttuale?> letto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grezzo = prefs.getString(_chiave);
      if (grezzo == null) return null;
      return LuogoAttuale.fromJson(jsonDecode(grezzo) as Map<String, dynamic>);
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: senza preferenze il luogo non si
      // ricorda e il rito resta intero, senza nominare l'ora del sorgere.
      return null;
    }
  }

  static Future<void> scrivi(LuogoAttuale luogo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chiave, jsonEncode(luogo.toJson()));
    } catch (errore) {
      // Il disco che non scrive non deve mai fermare un rito: senza luogo
      // salvato si richiedera' la posizione, che e' il comportamento di prima.
    }
  }

  /// Dimentica il luogo. Serve a chi cambia citta' e vuole ripartire.
  static Future<void> dimentica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chiave);
    } catch (errore) {
      // Il disco che non scrive non deve mai fermare un rito: senza luogo
      // salvato si richiedera' la posizione, che e' il comportamento di prima.
    }
  }
}

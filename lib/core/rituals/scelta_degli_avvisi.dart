import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_elements.dart';

/// QUALI DONI TI CHIAMANO, E A CHE ORA. Ordine BC voce 05.
///
/// **Parole del fondatore, maiuscole sue**: "BISOGNA ATTIVARE LE NOTIFICHE
/// VERAMENTE e ne voglio 5, ovvero una per ogni dono con orario che avevamo
/// gia' concordato. Sara' proprio l'utente che potra' gestire e attivare o
/// disattivare i singoli orari delle notifiche nel menu' notifiche."
///
/// **Cosa c'era prima.** Tre chiamate al giorno, e nessuna legata a un Dono:
/// la sera per la Runa del Tramonto, il mattino per le gettate tornate oppure
/// per il cielo di oggi, e un terzo avviso dieci ore dopo se un traguardo era
/// a un passo. Si accendevano tutte insieme col permesso di sistema, e per
/// spegnerne una sola bisognava uscire dall'app e cercare i canali nelle
/// impostazioni di Android.
///
/// **Cosa c'e' adesso.** Cinque, una per Dono, agli orari che i Doni portano
/// gia' scritti dentro di se': Alba 7:00, Soffio 10:30, Arcano 13:00, Tramonto
/// 18:30, Notte 22:30. Ognuna si accende e si spegne per conto suo, da dentro
/// l'app.
///
/// **Perche' la scelta vive qui e non nella schermata.** La programmazione
/// degli avvisi gira all'avvio dell'app, quando nessuna schermata delle
/// impostazioni e' aperta: se la scelta abitasse nel widget che la mostra,
/// chi programma non potrebbe leggerla. Sta nel dato, e la schermata e' solo
/// il posto da cui si tocca.
class SceltaDegliAvvisi extends ChangeNotifier {
  SceltaDegliAvvisi();

  /// La chiave di un Dono sul disco. **Il prefisso e' `rituale.`, e non e' un
  /// dettaglio**: e' uno di quelli che la cancellazione dell'account dimentica,
  /// quindi chi se ne va non lascia le proprie sveglie sul telefono di chi
  /// arriva dopo.
  static String chiaveDi(DailyElement dono) => 'rituale.avviso.${dono.name}';

  /// **QUALI SONO ACCESI QUANDO NESSUNO HA ANCORA SCELTO.**
  ///
  /// Il solo Rito dell'Alba, che e' anche l'unico che l'app abbia mai
  /// promesso a voce quando chiede il permesso. **Accenderli tutti e cinque
  /// d'ufficio vorrebbe dire cinque avvisi al giorno a chi ne ha accettato
  /// uno**, ed e' il modo piu' rapido di far spegnere tutto dalle impostazioni
  /// di sistema e non tornare piu'.
  ///
  /// Gli altri quattro si accendono dal menu' delle notifiche, dove sono
  /// elencati col loro orario.
  static const Set<DailyElement> accesiDiPartenza = {DailyElement.dawn};

  final Map<DailyElement, bool> _scelti = {};
  bool _caricata = false;

  /// Vero quando il disco e' stato letto: prima di allora si risponde col
  /// valore di partenza, mai con un silenzio.
  bool get caricata => _caricata;

  /// Se questo Dono chiama.
  bool chiama(DailyElement dono) =>
      _scelti[dono] ?? accesiDiPartenza.contains(dono);

  /// I Doni che chiamano, in ordine di orario: e' l'elenco che la
  /// programmazione percorre.
  List<DailyElement> get quelliCheChiamano => DailyElement.values
      .where(chiama)
      .toList()
    ..sort((a, b) => a.anchorMinutes.compareTo(b.anchorMinutes));

  /// Legge la scelta dal disco.
  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final d in DailyElement.values) {
        final v = prefs.getBool(chiaveDi(d));
        if (v != null) _scelti[d] = v;
      }
    } catch (_) {
      // Un disco che non risponde vale come nessuna scelta fatta: restano
      // quelli di partenza, e l'app non si ferma per una preferenza.
    }
    _caricata = true;
    notifyListeners();
  }

  /// Accende o spegne un Dono e lo scrive subito.
  ///
  /// **Scrive prima di avvisare**, cosi' chi ricalcola le chiamate sentendo il
  /// cambiamento legge un disco gia' aggiornato: al contrario riprogrammerebbe
  /// con la scelta di un istante fa.
  Future<void> scegli(DailyElement dono, bool acceso) async {
    _scelti[dono] = acceso;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(chiaveDi(dono), acceso);
    } catch (_) {
      // Se il disco rifiuta, la scelta vale per questa sessione: meglio un
      // interruttore che obbedisce adesso e si dimentica domani, che un
      // interruttore che non fa niente.
    }
    notifyListeners();
  }

  /// **Dimentica ogni scelta**, per chi esce o cancella l'account. Le chiavi
  /// portano il prefisso `rituale.`, quindi la dimenticanza del telefono le
  /// prende gia'; questo metodo serve a svuotare anche cio' che sta in
  /// memoria, che il disco da solo non tocca.
  void dimenticaLeScelte() {
    _scelti.clear();
    notifyListeners();
  }
}

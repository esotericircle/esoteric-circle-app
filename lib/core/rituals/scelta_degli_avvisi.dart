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

  /// La chiave dell'ORA scelta per un Dono. Ordine BC voce 05, coda.
  ///
  /// **Richiesta del fondatore**: "nel menu' notifiche, l'utente deve poter
  /// cambiare anche l'orario di ogni notifica."
  ///
  /// Sta accanto a quella dell'interruttore e col suo stesso prefisso, cosi'
  /// **la cancellazione dell'account le dimentica insieme**: un'ora rimasta
  /// senza il suo interruttore sarebbe una sveglia orfana sul telefono di chi
  /// arriva dopo.
  static String chiaveDellOraDi(DailyElement dono) =>
      'rituale.avviso.ora.${dono.name}';

  /// La chiave di un Dono sul disco. **Il prefisso e' `rituale.`, e non e' un
  /// dettaglio**: e' uno di quelli che la cancellazione dell'account dimentica,
  /// quindi chi se ne va non lascia le proprie sveglie sul telefono di chi
  /// arriva dopo.
  static String chiaveDi(DailyElement dono) => 'rituale.avviso.${dono.name}';

  /// **QUALI SONO ACCESI QUANDO NESSUNO HA ANCORA SCELTO: TUTTI E CINQUE.**
  ///
  /// **Decisione del fondatore**: "tutte le notifiche devono essere attive di
  /// default".
  ///
  /// **La prima stesura ne accendeva uno solo, ed e' stata cambiata su sua
  /// parola.** La ragione di allora era buona e si scrive qui perche' non
  /// vada persa: cinque avvisi al giorno a chi ne ha accettato uno sono il
  /// modo piu' rapido di far spegnere tutto dalle impostazioni di Android e
  /// non tornare piu'. **Il fondatore ha deciso diversamente, ed e' una
  /// scelta di prodotto che gli appartiene**: i cinque Doni sono
  /// l'appuntamento quotidiano attorno a cui l'app e' costruita, e chi
  /// accende le notifiche di Esoteric Circle li vuole tutti.
  ///
  /// **Cio' che rende la scelta sostenibile e' che spegnerli e' facile.** Il
  /// menu' Notifiche elenca i cinque con la loro ora, ognuno col suo
  /// interruttore, e **l'ora si puo' spostare** invece di dover scegliere fra
  /// subire e spegnere. La spiegazione che accompagna il permesso li nomina
  /// tutti e cinque prima che il sistema chieda, quindi nessuno accetta al
  /// buio.
  static const Set<DailyElement> accesiDiPartenza = {
    DailyElement.dawn,
    DailyElement.breath,
    DailyElement.oracle,
    DailyElement.rune,
    DailyElement.night,
  };

  final Map<DailyElement, bool> _scelti = {};

  /// L'ora scelta, in minuti dalla mezzanotte. Quello che non c'e' vale l'ora
  /// che il Dono porta scritta dentro di se'.
  final Map<DailyElement, int> _ore = {};
  bool _caricata = false;

  /// Vero quando il disco e' stato letto: prima di allora si risponde col
  /// valore di partenza, mai con un silenzio.
  bool get caricata => _caricata;

  /// Se questo Dono chiama.
  bool chiama(DailyElement dono) =>
      _scelti[dono] ?? accesiDiPartenza.contains(dono);

  /// **A CHE ORA CHIAMA QUESTO DONO**, in minuti dalla mezzanotte.
  ///
  /// Se nessuno l'ha cambiata vale quella che il Dono porta scritta dentro di
  /// se', cioe' l'ora concordata: Alba 7:00, Soffio 10:30, Arcano 13:00,
  /// Tramonto 18:30, Notte 22:30.
  int minutiDi(DailyElement dono) => _ore[dono] ?? dono.anchorMinutes;

  /// La stessa ora in ore e minuti, per chi deve mostrarla o programmarla.
  ({int ora, int minuto}) oraDi(DailyElement dono) {
    final m = minutiDi(dono);
    return (ora: m ~/ 60, minuto: m % 60);
  }

  /// **VERO SE QUESTA E' L'ORA DI CASA**, cioe' quella che il Dono portava
  /// scritta. Serve al menu' per dire "l'hai cambiata" senza doverlo
  /// ricalcolare a ogni riga.
  bool eLOraDiCasa(DailyElement dono) =>
      minutiDi(dono) == dono.anchorMinutes;

  /// I Doni che chiamano, in ordine di orario: e' l'elenco che la
  /// programmazione percorre.
  List<DailyElement> get quelliCheChiamano => DailyElement.values
      .where(chiama)
      .toList()
    ..sort((a, b) => minutiDi(a).compareTo(minutiDi(b)));

  /// Legge la scelta dal disco.
  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final d in DailyElement.values) {
        final v = prefs.getBool(chiaveDi(d));
        if (v != null) _scelti[d] = v;
        final ora = prefs.getInt(chiaveDellOraDi(d));
        // **Un'ora fuori dal giorno si butta**, e non si corregge: un dato
        // scritto male non e' una scelta della persona, e indovinare cosa
        // volesse dire e' peggio che tornare all'ora di casa.
        if (ora != null && ora >= 0 && ora < 1440) _ore[d] = ora;
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

  /// **CAMBIA L'ORA DI UN DONO.** Ordine BC voce 05, coda.
  ///
  /// Richiesta del fondatore: "nel menu' notifiche, l'utente deve poter
  /// cambiare anche l'orario di ogni notifica."
  ///
  /// Come l'interruttore, **scrive prima di avvisare**: chi ricalcola le
  /// chiamate sentendo il cambiamento deve leggere un disco gia' aggiornato,
  /// se no riprogrammerebbe con l'ora di un istante fa.
  Future<void> scegliLOra(DailyElement dono, {required int ora,
      required int minuto}) async {
    final minuti = (ora.clamp(0, 23) * 60) + minuto.clamp(0, 59);
    _ore[dono] = minuti;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(chiaveDellOraDi(dono), minuti);
    } catch (_) {
      // Vale per questa sessione: meglio un'ora che obbedisce adesso e si
      // dimentica domani, che un comando che non fa niente.
    }
    notifyListeners();
  }

  /// **RIMETTE L'ORA DI CASA**, cioe' quella che il Dono portava scritta.
  Future<void> rimettiLOraDiCasa(DailyElement dono) async {
    _ore.remove(dono);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(chiaveDellOraDi(dono));
    } catch (_) {
      // Come sopra.
    }
    notifyListeners();
  }

  /// **Dimentica ogni scelta**, per chi esce o cancella l'account. Le chiavi
  /// portano il prefisso `rituale.`, quindi la dimenticanza del telefono le
  /// prende gia'; questo metodo serve a svuotare anche cio' che sta in
  /// memoria, che il disco da solo non tocca.
  void dimenticaLeScelte() {
    _scelti.clear();
    _ore.clear();
    notifyListeners();
  }
}

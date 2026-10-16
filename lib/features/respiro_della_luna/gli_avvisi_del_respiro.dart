/// GLI AVVISI DEL RESPIRO, ordine FX voce FX.08, 16 ottobre 2026.
///
/// "La Luna sorge adesso a Piacenza; ogni giorno l'orario cambia. Poi la
/// Luna piena, la nuova, la Superluna" (la proposta approvata).
///
/// **Sul modello di `lib/features/lunario/i_promemoria_del_lunario.dart`**:
/// due booleani persistiti, un canale di sistema dichiarato in
/// `AvvisiLocali.canali`, e un'unica porta (`ServizioAvvisi`) per
/// programmare e annullare. **Sette giorni alla volta, come
/// `LeChiamateDelCielo`** (`lib/core/horoscope/le_chiamate_del_cielo.dart`):
/// a ogni riprogrammazione si annullano prima tutti gli id, poi si
/// programmano i sorgere dei prossimi sette giorni che restano davanti
/// all'istante dato, cosi' chi riapre l'app almeno una volta alla settimana
/// non resta mai senza. La Luna piena e la Luna nuova, invece, sono eventi
/// rari (una ogni circa 29 giorni e mezzo): si programma solo la prossima di
/// ciascuna, non sette.
///
/// **La levata non si ricalcola qui.** `prossimoSorgere` esiste gia' in
/// `lib/core/lunario/il_sorgere_della_luna.dart` (ordine FX voce 2): la
/// soglia di Meeus 15.1 con la parallasse vera della Luna, verificata al
/// minuto contro effemeridi pubblicate, non la soglia generica del Real
/// Time Cosmo. E' la stessa porta che chiamava la bussola (tolta dall'ordine FY) per la
/// riga "quando sorge" (FX.06): un solo calcolo, due usi.
///
/// **La Superluna non ha una schedulazione a parte.** E' un caso speciale
/// della Luna piena: quando la prossima Luna piena cade a meno di
/// [sogliaSuperlunaKm] dal centro della Terra (`IlCieloDiMeeus.distanzaInKm`,
/// che il motore lunare ha gia' e verificato, ordine FX voce 1 di questo
/// stesso ordine), il testo dello stesso avviso lo dice. **La soglia**,
/// 361885 km: il criterio di Richard Nolle (1979), il 90% della massima
/// vicinanza possibile al perigeo, e' la definizione piu' citata (GreenMe e
/// MeteoWeb, che a loro volta citano l'UAI e Timeanddate; ricerca web del 16
/// ottobre 2026, "superluna soglia distanza km definizione perigeo"); il
/// perigeo minimo possibile e' circa 356410 km, l'apogeo massimo circa
/// 406740 km. Non e' un criterio dell'International Astronomical Union, ma
/// e' quello che il pubblico italiano legge quando sente "superluna", e
/// questa app non ne inventa un altro.
///
/// **Nessun avviso di notte fonda.** Scelta: dalle 23 alle 7, nessun avviso
/// parte. Una levata o una sizigia che cade in quella fascia **si salta**,
/// non si rimanda alle 7: un avviso che dice "la Luna sorge adesso" quando
/// invece e' sorta alle tre del mattino sarebbe falso, e la fiducia nel
/// Respiro vale piu' di una notifica recuperata. Chi vuole sapere quando e'
/// sorta la Luna la notte scorsa lo trova nella Bussola o nella Parola di
/// Medora, non in un avviso tardivo.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/astro/celestial.dart';
import '../../core/astro/luogo_attuale.dart';
import '../../core/astro/meeus/il_cielo_di_meeus.dart';
import '../../core/lunario/il_motore_lunare.dart';
import '../../core/lunario/il_sorgere_della_luna.dart';
import '../../core/rituals/avvisi_del_rito.dart';

abstract final class GliAvvisiDelRespiro {
  /// Quanti giorni di levata si programmano in avanti, oggi compreso.
  static const int giorni = 7;

  /// Gli id: sette per la Luna che sorge, uno per la prossima Luna nuova,
  /// uno per la prossima Luna piena. Lontani dai Doni, dai Sigilli, dal
  /// Calendario Lunare (91000-91999) e dalle Chiamate del Cielo
  /// (90510-90526).
  static const int primoIdDellaLunaCheSorge = 92000;
  static const int idDellaLunaNuova = 92100;
  static const int idDellaLunaPiena = 92101;

  /// Tutti gli id, per chi deve annullarli o contarli.
  static List<int> get tuttiGliId => [
        for (var i = 0; i < giorni; i++) primoIdDellaLunaCheSorge + i,
        idDellaLunaNuova,
        idDellaLunaPiena,
      ];

  /// Il canale di sistema, dichiarato in `AvvisiLocali.canali`.
  static const String canale = 'respiro_della_luna';

  /// Il carico che l'apertura dell'avviso riceve.
  static const String carico = 'respiro:luna';

  /// La soglia della Superluna, in chilometri: vedi il commento sopra il
  /// file per la fonte (Richard Nolle, 1979).
  static const double sogliaSuperlunaKm = 361885;

  /// La fascia di quiete: nessun avviso fra queste due ore, vedi il
  /// commento sopra il file.
  static const int oraInizioQuiete = 23;
  static const int oraFineQuiete = 7;

  static bool _dentroLaQuiete(DateTime t) {
    final ora = t.toLocal().hour;
    return ora >= oraInizioQuiete || ora < oraFineQuiete;
  }

  static String _oraLocale(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  static String testoDellaLunaCheSorge(String citta) =>
      'La Luna sorge adesso a $citta.';

  static String testoDellaLunaNuova() =>
      'In questo momento la Luna è nuova: il cielo si fa buio per lei.';

  static String testoDellaLunaPiena(double distanzaKm) =>
      distanzaKm <= sogliaSuperlunaKm
          ? 'Questa notte la Luna piena è una Superluna: la trovi più vicina '
              'e più grande del solito.'
          : 'Questa notte la Luna è piena.';

  /// Annulla gli avvisi di prima e programma quelli che restano davanti ad
  /// [adesso]. Torna gli id davvero programmati.
  static Future<List<int>> programma({
    required ServizioAvvisi servizio,
    required DateTime adesso,
    LuogoAttuale? luogo,
    required bool lunaCheSorge,
    required bool luneNuoveEPiene,
  }) async {
    for (final id in tuttiGliId) {
      await servizio.annulla(id);
    }
    final fatti = <int>[];
    if (lunaCheSorge && luogo != null) {
      final oggi = DateTime(adesso.year, adesso.month, adesso.day);
      for (var i = 0; i < giorni; i++) {
        final giorno = DateTime(oggi.year, oggi.month, oggi.day + i);
        final sorge = prossimoSorgere(giorno, luogo.lat, luogo.lon);
        if (sorge == null) continue;
        final quando = sorge.toLocal();
        if (!quando.isAfter(adesso) || _dentroLaQuiete(quando)) continue;
        await servizio.programma(
          id: primoIdDellaLunaCheSorge + i,
          quando: quando,
          titolo: 'Il Respiro della Luna',
          testo: testoDellaLunaCheSorge(luogo.citta),
          canale: canale,
          carico: carico,
        );
        fatti.add(primoIdDellaLunaCheSorge + i);
      }
    }
    if (luneNuoveEPiene) {
      // Una lunazione dura al piu' 29,83 giorni (vedi il commento sopra
      // `IlMotoreLunare`): trentasei giorni di finestra trovano sempre la
      // prossima nuova e la prossima piena, qualunque sia il punto del ciclo
      // da cui si parte.
      final fine = adesso.add(const Duration(days: 36));
      final nuove = IlMotoreLunare.luneNuoveFra(adesso, fine);
      if (nuove.isNotEmpty) {
        final quando = nuove.first;
        if (quando.isAfter(adesso) && !_dentroLaQuiete(quando)) {
          await servizio.programma(
            id: idDellaLunaNuova,
            quando: quando,
            titolo: 'Il Respiro della Luna',
            testo: testoDellaLunaNuova(),
            canale: canale,
            carico: carico,
          );
          fatti.add(idDellaLunaNuova);
        }
      }
      final piene = IlMotoreLunare.lunePieneFra(adesso, fine);
      if (piene.isNotEmpty) {
        final quando = piene.first;
        if (quando.isAfter(adesso) && !_dentroLaQuiete(quando)) {
          final jd = Celestial.julianDay(quando.toUtc());
          final distanza = IlCieloDiMeeus.distanzaInKm(jd);
          await servizio.programma(
            id: idDellaLunaPiena,
            quando: quando,
            titolo: 'Il Respiro della Luna',
            testo: testoDellaLunaPiena(distanza),
            canale: canale,
            carico: carico,
          );
          fatti.add(idDellaLunaPiena);
        }
      }
    }
    return fatti;
  }

  /// L'ora scritta per umani, usata dai testi sopra (e da chi mostra la
  /// schermata, se vuole dire "alle HH:mm" senza riscrivere il formato).
  static String oraLeggibile(DateTime t) => _oraLocale(t);
}

/// **I DUE INTERRUTTORI DEGLI AVVISI DEL RESPIRO**, conservati sul
/// telefono sotto il prefisso `respiro.` (vedi
/// `lib/core/identity/cio_che_e_tuo.dart`): se ti e' gia' stato chiesto di
/// essere avvisato, e con che risposta.
class IGliAvvisiDelRespiro extends ChangeNotifier {
  IGliAvvisiDelRespiro({required this.avvisi});

  final ServizioAvvisi avvisi;

  static const String _chiaveLunaCheSorge = 'respiro.avvisi.luna_sorge';
  static const String _chiaveLuneNuoveEPiene = 'respiro.avvisi.lune';

  bool _lunaCheSorge = false;
  bool _luneNuoveEPiene = false;
  bool _letto = false;

  /// Vero se l'avviso della Luna che sorge e' acceso.
  bool get lunaCheSorge => _lunaCheSorge;

  /// Vero se gli avvisi della Luna piena e nuova (e della Superluna) sono
  /// accesi.
  bool get luneNuoveEPiene => _luneNuoveEPiene;

  bool get letto => _letto;

  Future<void> leggi() async {
    try {
      final p = await SharedPreferences.getInstance();
      _lunaCheSorge = p.getBool(_chiaveLunaCheSorge) ?? false;
      _luneNuoveEPiene = p.getBool(_chiaveLuneNuoveEPiene) ?? false;
    } catch (errore) {
      debugPrint('Il Respiro della Luna: gli avvisi non si leggono ($errore)');
    }
    _letto = true;
    notifyListeners();
  }

  Future<void> _scrivi() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_chiaveLunaCheSorge, _lunaCheSorge);
      await p.setBool(_chiaveLuneNuoveEPiene, _luneNuoveEPiene);
    } catch (errore) {
      debugPrint('Il Respiro della Luna: gli avvisi non si scrivono ($errore)');
    }
  }

  Future<void> impostaLunaCheSorge(bool valore,
      {LuogoAttuale? luogo, DateTime? adesso}) async {
    _lunaCheSorge = valore;
    notifyListeners();
    await _scrivi();
    await _riprogramma(luogo: luogo, adesso: adesso);
  }

  Future<void> impostaLuneNuoveEPiene(bool valore,
      {LuogoAttuale? luogo, DateTime? adesso}) async {
    _luneNuoveEPiene = valore;
    notifyListeners();
    await _scrivi();
    await _riprogramma(luogo: luogo, adesso: adesso);
  }

  Future<List<int>> _riprogramma({LuogoAttuale? luogo, DateTime? adesso}) {
    return GliAvvisiDelRespiro.programma(
      servizio: avvisi,
      adesso: adesso ?? DateTime.now(),
      luogo: luogo,
      lunaCheSorge: _lunaCheSorge,
      luneNuoveEPiene: _luneNuoveEPiene,
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;

import 'il_motore_lunare.dart';
import 'le_lune_della_nasa.dart';

/// **IL DIAL-A-MOON, ORA PER ORA.** Ordine FX voce FX.03, 16 ottobre 2026.
///
/// La Luna al centro del Respiro della Luna non e' piu' una delle trenta
/// fotografie fisse del Calendario Lunare (`LeLuneDellaNasa`): e' il
/// fotogramma vero dell'ora in corso, preso dal Dial-A-Moon dello
/// Scientific Visualization Studio della NASA. Senza rete, o se la NASA non
/// risponde, la funzione non resta mai senza Luna: ricade sulla stessa delle
/// trenta lune locali, scelta per elongazione.
///
/// **L'indirizzo, verificato il 16 ottobre 2026** visitando
/// https://svs.gsfc.nasa.gov/5587/ (la pagina del Dial-A-Moon, serie "Moon
/// Phase and Libration, 2026") e scaricando davvero un fotogramma.
/// La pagina pubblica un fotogramma per ogni ora del 2026, 8760 in tutto,
/// con la stessa regola gia' usata da `tool/le_lune_della_nasa_scelta.dart`
/// per scegliere le trenta lune locali dalla stessa serie: il fotogramma N
/// e' l'istante 1 gennaio 2026 00:00 UT piu' N meno 1 ore. L'indirizzo di
/// ogni fotogramma, confermato scaricando davvero
/// `moon.6797.jpg` (38,7 KB, JPEG vero):
///
/// ```
/// https://svs.gsfc.nasa.gov/vis/a000000/a005500/a005587/frames/730x730_1x1_30p/moon.NNNN.jpg
/// ```
///
/// con `NNNN` il numero del fotogramma su quattro cifre, da `0001`. Il
/// formato e' JPEG, 730 per 730 punti (la stessa misura gia' usata per le
/// trenta lune locali); la stessa cartella offre anche le misure da 216 a
/// 5760x3240 e i formati TIF ed EXR, non usati qui. I dettagli della
/// verifica, con le date e gli indirizzi visitati, stanno in
/// `docs/collaudo/FX/fx03_dial_a_moon_verifica.md`.
///
/// **Fuori dal 2026** (un'altra serie annuale, il cui indirizzo non e'
/// ancora stato verificato) la richiesta non parte nemmeno: si va dritti al
/// ripiego locale, perche' un indirizzo indovinato e non controllato
/// sarebbe peggio di nessun indirizzo.
///
/// **Le condizioni d'uso**, nasa.gov/nasa-brand-center/images-and-media,
/// verificate il 16 ottobre 2026 (sono le stesse dell'ordine FV voce FV.03,
/// gia' nella citazione di `lib/core/legal/fonti_dei_dati.dart`, che questo
/// file non duplica): l'attribuzione alla NASA e' dovuta, l'insignia e il
/// logotipo della NASA non si usano mai, nessun testo lascia intendere
/// un'approvazione o una sponsorizzazione, e nei prodotti con intelligenza
/// artificiale l'attribuzione diretta alla NASA non e' permessa (frasi come
/// "secondo la NASA" sono proibite).
///
/// **GUARDIA DI STILE**, per chi costruisce la schermata che usa questa
/// classe: nessun testo di un Maestro (Medora, Aura, Caligo) nomina mai la
/// NASA, e nessun logo della NASA si disegna a schermo. La sola citazione
/// resta quella di `fonti_dei_dati.dart`, dove la schermata delle fonti
/// gia' la mostra.
class IlDialAMoon {
  IlDialAMoon({http.Client? client}) : _client = client;

  /// L'unico, quello dell'app.
  static IlDialAMoon diCasa = IlDialAMoon();

  final http.Client? _client;
  late final http.Client _rete = _client ?? http.Client();

  /// La cartella dei fotogrammi orari della serie 2026, 730x730 JPEG.
  static const String _basePattern = 'https://svs.gsfc.nasa.gov/vis/'
      'a000000/a005500/a005587/frames/730x730_1x1_30p/moon.';

  /// Il primo istante della serie: il fotogramma 1.
  static final DateTime _inizioSerie2026 = DateTime.utc(2026, 1, 1);

  /// Quanti fotogrammi ha la serie 2026 (8760, un'ora per le 24 ore dei
  /// 365 giorni del 2026, che non e' bisestile).
  static const int _fotogrammiSerie2026 = 8760;

  /// Il numero del fotogramma per l'istante UTC [istante], o null se
  /// l'istante cade fuori dalla serie 2026 (la sola di cui l'indirizzo e'
  /// verificato).
  @visibleForTesting
  static int? fotogrammaPer(DateTime istanteUtc) {
    final ore = istanteUtc.difference(_inizioSerie2026).inHours;
    if (ore < 0 || ore >= _fotogrammiSerie2026) return null;
    return ore + 1;
  }

  /// L'indirizzo del fotogramma NASA per l'istante, o null fuori dalla
  /// serie verificata: in quel caso non si tenta nessuna richiesta.
  @visibleForTesting
  static Uri? indirizzoPer(DateTime istante) {
    final fotogramma = fotogrammaPer(istante.toUtc());
    if (fotogramma == null) return null;
    final numero = fotogramma.toString().padLeft(4, '0');
    return Uri.parse('$_basePattern$numero.jpg');
  }

  /// **LA LUNA VERA PER L'ISTANTE [istante]**, per chi guarda dalla
  /// [latitudine] data.
  ///
  /// Prova il fotogramma della NASA per l'ora (timeout di 4 secondi: l'app
  /// non deve restare bloccata senza rete). Se l'istante cade fuori dalla
  /// serie verificata, se la rete manca, se l'host non risponde in tempo o
  /// se la risposta non e' 200, ricade su `LeLuneDellaNasa.immaginePer`
  /// con l'elongazione vera dell'istante (`IlMotoreLunare.elongazione`): la
  /// funzione non resta mai senza Luna.
  ///
  /// La rotazione di 180 gradi per l'emisfero sud (`LeLuneDellaNasa.
  /// ruotaPer`) si decide sempre dalla latitudine, qualunque sia la fonte
  /// della foto: chi disegna applica [FotoDellaLuna.ruota] con un
  /// `Transform.rotate`, come fa gia' `LaLunaNelCastone` per le trenta lune
  /// locali.
  ///
  /// **Nessuna cache su file propria**: l'immagine NASA torna come
  /// `NetworkImage`, che usa la cache in memoria standard di Flutter; il
  /// ripiego torna come `AssetImage`, gia' nel binario. Chi disegna la
  /// Luna riceve un `ImageProvider` e non deve sapere da dove viene.
  Future<FotoDellaLuna> perIstante(
    DateTime istante, {
    required double latitudine,
  }) async {
    final utc = istante.toUtc();
    final ruota = LeLuneDellaNasa.ruotaPer(latitudine);
    final indirizzo = indirizzoPer(utc);
    if (indirizzo != null) {
      try {
        final risposta = await _rete
            .get(indirizzo)
            .timeout(const Duration(seconds: 4));
        if (risposta.statusCode == 200) {
          return FotoDellaLuna(
            immagine: NetworkImage(indirizzo.toString()),
            ruota: ruota,
            daNasa: true,
          );
        }
      } catch (_) {
        // Nessuna rete, timeout o errore del fornitore: si ricade sotto,
        // senza che chi chiama debba saperlo o debba gestire un'eccezione.
      }
    }
    final elongazione = IlMotoreLunare.elongazione(utc);
    final percorso =
        LeLuneDellaNasa.immaginePer(elongazione) ?? LeLuneDellaNasa.castone;
    return FotoDellaLuna(
      immagine: AssetImage(percorso),
      ruota: ruota,
      daNasa: false,
    );
  }
}

/// Il risultato di una richiesta della Luna vera: l'immagine da mostrare,
/// se va ruotata di 180 gradi per l'emisfero sud e se viene davvero dalla
/// NASA o dal ripiego locale (utile solo a chi registra o collauda, non
/// cambia mai un testo a schermo: la fonte non si nomina mai).
class FotoDellaLuna {
  const FotoDellaLuna({
    required this.immagine,
    required this.ruota,
    required this.daNasa,
  });

  final ImageProvider immagine;
  final bool ruota;
  final bool daNasa;
}

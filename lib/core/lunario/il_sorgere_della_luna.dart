/// **IL SORGERE, IL TRAMONTO E LA CULMINAZIONE DELLA LUNA**, per un luogo e
/// un istante. Ordine FX voce 2, 16 ottobre 2026 ("Il Respiro della Luna").
///
/// Un file nuovo e non un'estensione di `IlMotoreLunare`: quel motore
/// risponde per un GIORNO CIVILE intero (fase, segno, Luna fuori corso),
/// nell'ora locale del telefono senza bisogno del luogo. Questa domanda e'
/// diversa nella forma, un singolo istante che dipende dalla latitudine e
/// dalla longitudine, non dal giorno civile: lo stesso motivo per cui il
/// Real Time Cosmo (`real_time_cosmo/i_bersagli_del_cielo.dart`) tiene il
/// suo `quandoSorgeIlBersaglio` fuori da `IlMotoreLunare`.
///
/// Tre istanti, cercati in avanti da un dato momento, tutti col pattern di
/// ricerca del Cielo esistente (`primoIstanteSopraInFinestra`, la stessa
/// regola di `primoIstanteSopra`, voce 7.4 dell'ordine FH, ma con la finestra
/// allargata): dieci minuti di passo, poi il minuto per affinare dentro
/// l'intervallo trovato.
/// - **Il sorgere**: quando l'altezza della Luna passa da sotto a sopra la
///   soglia dell'orizzonte.
/// - **Il tramonto**: quando la ripassa da sopra a sotto (lo stesso predicato
///   negato: `primoIstanteSopraInFinestra` non sa se cerca un sorgere o un
///   tramonto, sa solo attraversare una soglia).
/// - **La culminazione**: il passaggio al meridiano locale, quando l'angolo
///   orario della Luna passa da negativo a positivo (zero e' il meridiano).
///   Non e' un attraversamento di un'ALTEZZA ma di un ANGOLO diverso, quindi
///   non e' lo stesso predicato: la Luna culmina alla sua altezza massima,
///   ma "l'altezza sta salendo" non si presta alla stessa ricerca binaria
///   (l'altezza sale e scende con continuita', l'angolo orario invece
///   attraversa lo zero una volta sola per giro, in un verso solo, perche'
///   la Luna si sposta sempre nello stesso senso dell'orbita). La ricerca qui
///   sotto, [prossimaCulminazione], e' la stessa struttura a due passi scritta
///   per questo secondo attraversamento.
///
/// **La soglia del sorgere e del tramonto non e' zero gradi.** Il centro
/// geometrico della Luna attraversa l'orizzonte VERO (il centro della Terra,
/// senza atmosfera) quando il suo bordo superiore, visto da un osservatore
/// sulla superficie, sta gia' sopra la linea vera: la rifrazione atmosferica
/// standard lo alza di 34 primi (la stessa correzione di
/// `lib/core/astro/meeus/l_alba_e_il_tramonto.dart` per il Sole), ma la Luna
/// e' vicina e la sua parallasse orizzontale (fino a un grado) lo riabbassa
/// di una frazione di se stessa: Meeus, *Astronomical Algorithms*, 2a ed.
/// 1998, cap. 15, eq. 15.1, h0 = 0,7275 pi' - 34', con pi' la parallasse
/// orizzontale del momento. Qui pi' si calcola dalla distanza VERA della
/// Luna (`IlCieloDiMeeus.distanzaInKm`, ordine FX voce 1, stesso ordine:
/// pi' = asin(raggio equatoriale della Terra / distanza)), non da una
/// parallasse media fissa: i due coefficienti dello stesso ordine si
/// compongono invece di duplicarsi.
///
/// **Verifica**: contro il sorgere, il tramonto e la culminazione pubblicati
/// da timeanddate.com per tre citta' a latitudini ed emisferi diversi
/// (Piacenza, New York, Sydney), lo scarto massimo in minuti e' dichiarato
/// in `docs/collaudo/FX/fx02_sorgere_regola_a.txt` e misurato da
/// `test/il_sorgere_della_luna_test.dart`.
library;

import 'dart:math' as math;

import '../astro/celestial.dart';
import '../astro/il_primo_istante_sopra.dart';
import '../astro/meeus/il_cielo_di_meeus.dart';

/// Il raggio equatoriale della Terra, in km (lo stesso valore standard della
/// parallasse equatoriale di Meeus, appendice II).
const double _raggioEquatorialeTerraKm = 6378.14;

/// La finestra di ricerca: ventisette ore, non ventiquattro. Il giorno
/// lunare dura circa 24h50m, quindi il sorgere e il tramonto arrivano circa
/// cinquanta minuti piu' tardi ogni giorno: ventiquattro ore sole possono
/// mancare l'evento che cade nell'ultima mezz'ora prima del giro.
const Duration _finestraDiRicerca = Duration(hours: 27);

/// La soglia dell'altezza del CENTRO della Luna per il sorgere e il
/// tramonto, in gradi, all'istante di giorno giuliano [jd] (Meeus cap. 15,
/// eq. 15.1, con la parallasse vera di quel momento).
double _sogliaDellOrizzonte(double jd) {
  final distanzaKm = IlCieloDiMeeus.distanzaInKm(jd);
  final parallasseGradi =
      math.asin(_raggioEquatorialeTerraKm / distanzaKm) * 180 / math.pi;
  final h0Primi = 0.7275 * (parallasseGradi * 60) - 34;
  return h0Primi / 60;
}

/// L'altezza GEOCENTRICA (non quella topocentrica di
/// `posizioneOrizzontaleDellaLuna`, in `la_posizione_orizzontale_della_luna.dart`)
/// della Luna, in gradi, all'istante [jd]:
/// la soglia di Meeus 15.1, [_sogliaDellOrizzonte], e' definita apposta sul
/// centro geocentrico, la sua correzione 0,7275*pi' e' gia' la parallasse.
/// Confrontarla con un'altezza gia' corretta per la parallasse la conterebbe
/// due volte: il primo collaudo l'ha mostrato, otto minuti di scarto sul
/// sorgere di Piacenza, spariti passando all'altezza geocentrica.
double _altezzaGeocentrica(double jd, double lat, double lonEst) {
  final e = Celestial.moonEquatorial(jd);
  return Celestial.equatorialToHorizontal(
    raDeg: e.raDeg,
    decDeg: e.decDeg,
    latDeg: lat,
    lstDeg: Celestial.localSiderealDegrees(jd, lonEst),
  ).altDeg;
}

bool _sopraLaSogliaDiMeeus(DateTime istante, double lat, double lonEst) {
  final jd = IlCieloDiMeeus.giornoGiuliano(istante);
  return _altezzaGeocentrica(jd, lat, lonEst) > _sogliaDellOrizzonte(jd);
}

/// L'angolo orario della Luna, ricondotto fra -180 (a est, prima del
/// meridiano) e 180 gradi (a ovest, dopo): zero e' la culminazione, il
/// passaggio al meridiano locale.
double _angoloOrarioDellaLuna(DateTime istante, double lat, double lonEst) {
  final jd = IlCieloDiMeeus.giornoGiuliano(istante);
  final equatoriale = Celestial.moonEquatorial(jd);
  final lst = Celestial.localSiderealDegrees(jd, lonEst);
  final h = lst - equatoriale.raDeg;
  return ((h + 180) % 360 + 360) % 360 - 180;
}

/// IL PROSSIMO SORGERE della Luna da [da] (compreso), per il luogo a
/// latitudine [lat] e longitudine [lonEst] (est positiva). Torna [da] se la
/// Luna e' gia' sopra la soglia dell'orizzonte in quell'istante (la stessa
/// convenzione di `primoIstanteSopra`), nullo se non sorge dentro la
/// finestra di ricerca (non capita alle nostre latitudini, ma la firma lo
/// dichiara).
DateTime? prossimoSorgere(DateTime da, double lat, double lonEst) =>
    primoIstanteSopraInFinestra(
      (t) => _sopraLaSogliaDiMeeus(t, lat, lonEst),
      da,
      _finestraDiRicerca,
    );

/// IL PROSSIMO TRAMONTO della Luna da [da] (compreso): lo stesso predicato
/// di [prossimoSorgere], negato, perche' `primoIstanteSopraInFinestra` cerca
/// un attraversamento qualunque, non sa se e' un sorgere o un tramonto.
DateTime? prossimoTramonto(DateTime da, double lat, double lonEst) =>
    primoIstanteSopraInFinestra(
      (t) => !_sopraLaSogliaDiMeeus(t, lat, lonEst),
      da,
      _finestraDiRicerca,
    );

/// LA PROSSIMA CULMINAZIONE della Luna da [da] (compreso): il passaggio al
/// meridiano locale, massima altezza del giorno lunare. Cercata come
/// [prossimoSorgere] ma sull'angolo orario invece che sull'altezza: dieci
/// minuti di passo (la Luna avanza di circa 2,4 gradi di angolo orario per
/// passo, molto meno dei 360 di un giro: nessun passaggio si perde), poi il
/// minuto per affinare. A differenza del sorgere, qui non si ritorna [da]
/// anche se l'angolo orario a quell'istante fosse gia' zero: si cerca sempre
/// il PROSSIMO passaggio da negativo a non negativo, perche' un istante
/// preso a caso durante il giorno lunare sta quasi sempre con l'angolo
/// orario positivo (dopo la culminazione precedente) e tornarlo subito
/// sarebbe sbagliato quanto tornare un tramonto per un sorgere.
DateTime? prossimaCulminazione(DateTime da, double lat, double lonEst) {
  var precedente = da;
  var angoloPrecedente = _angoloOrarioDellaLuna(da, lat, lonEst);
  final minuti = _finestraDiRicerca.inMinutes;
  for (var m = 10; m <= minuti; m += 10) {
    final t = da.add(Duration(minutes: m));
    final angolo = _angoloOrarioDellaLuna(t, lat, lonEst);
    if (angoloPrecedente < 0 && angolo >= 0) {
      for (var k = 1; k <= 10; k++) {
        final f = precedente.add(Duration(minutes: k));
        if (_angoloOrarioDellaLuna(f, lat, lonEst) >= 0) return f;
      }
      return t;
    }
    precedente = t;
    angoloPrecedente = angolo;
  }
  return null;
}

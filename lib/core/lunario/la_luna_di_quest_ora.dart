/// **I NUMERI SOTTO LA LUNA DI QUEST'ORA.** Ordine FX voce FX.03, 16 ottobre
/// 2026.
///
/// "SOTTO LA LUNA, dal motore di P2 per il luogo di P7: la percentuale di
/// luce; il sorgere, il tramonto e la culminazione della Luna con il conto
/// alla rovescia; la distanza dalla Terra in chilometri, con l'avviso di
/// Superluna; quanto manca alla prossima Luna piena e alla prossima nuova."
///
/// **Un punto solo**, che compone le porte già costruite da quest'ordine:
/// `Celestial.moonIllumination` per la percentuale, `prossimoSorgere` /
/// `prossimoTramonto` / `prossimaCulminazione` (`il_sorgere_della_luna.dart`,
/// voce 2) per i tre istanti, `IlCieloDiMeeus.distanzaInKm` (voce 1) per la
/// distanza, `GliAvvisiDelRespiro.sogliaSuperlunaKm` (FX.08, la stessa soglia
/// dichiarata una sola volta) per la Superluna, `IlMotoreLunare.lunePieneFra`
/// / `luneNuoveFra` (ordine FV, già esistenti) per le sizigie prossime.
/// Nessuna duplicazione: solo composizione.
library;

import '../astro/celestial.dart';
import '../astro/luogo_attuale.dart';
import '../astro/meeus/il_cielo_di_meeus.dart';
import 'il_motore_lunare.dart';
import 'il_sorgere_della_luna.dart';
import 'la_posizione_orizzontale_della_luna.dart';

/// La soglia della Superluna in chilometri: lo stesso numero di
/// `GliAvvisiDelRespiro.sogliaSuperlunaKm` (FX.08), il criterio di Richard
/// Nolle (1979). Dichiarata qui e non importata da quel file: quel file vive
/// in `lib/features/respiro_della_luna/` (la UI degli avvisi) e questo in
/// `lib/core/lunario/` (il dato puro), e un file di dominio non dipende da
/// un file di schermata. Le due costanti sono la stessa fonte citata due
/// volte, non due scelte diverse: una guardia dichiarata nel manifesto le
/// confronta.
const double sogliaSuperlunaKm = 361885;

/// I dati di questa funzione, per un istante e un luogo. Se [luogo] è nullo
/// (nessun permesso, nessuna città scelta), [sorgere], [tramonto] e
/// [culminazione] sono nulli: senza un posto da cui guardare il cielo non si
/// inventa un orizzonte.
class DatiDellaLunaDiQuestOra {
  const DatiDellaLunaDiQuestOra({
    required this.istante,
    required this.percentualeDiLuce,
    required this.crescente,
    this.sorgere,
    this.tramonto,
    this.culminazione,
    this.altezzaGradi,
    required this.distanzaKm,
    required this.superluna,
    required this.prossimaPiena,
    required this.prossimaNuova,
  });

  final DateTime istante;

  /// Da 0 (Luna nuova) a 1 (Luna piena).
  final double percentualeDiLuce;
  final bool crescente;

  final DateTime? sorgere;
  final DateTime? tramonto;
  final DateTime? culminazione;

  /// L'altezza topocentrica della Luna adesso, in gradi (nulla senza
  /// [luogo]): sopra zero vuol dire che e' sopra l'orizzonte, e la
  /// schermata enfatizza il tramonto invece del sorgere.
  final double? altezzaGradi;

  final double distanzaKm;

  /// Vera solo quando la prossima Luna piena cade sotto [sogliaSuperlunaKm]:
  /// non è "questa distanza è una Superluna" (la Superluna è un evento della
  /// Luna PIENA, non di un giorno qualunque del ciclo), ma "la prossima Luna
  /// piena lo sarà", la domanda a cui la voce FX.08 risponde con l'avviso.
  final bool superluna;

  final DateTime prossimaPiena;
  final DateTime prossimaNuova;

  static DatiDellaLunaDiQuestOra calcola(DateTime istante, LuogoAttuale? luogo) {
    final jd = Celestial.julianDay(istante.toUtc());
    final illuminazione = Celestial.moonIllumination(jd);
    final distanzaKm = IlCieloDiMeeus.distanzaInKm(jd);
    // Una lunazione dura al più 29,83 giorni (vedi il commento sopra
    // `IlMotoreLunare`): trentasei giorni di finestra trovano sempre la
    // prossima piena e la prossima nuova, qualunque sia il punto del ciclo.
    final fine = istante.add(const Duration(days: 36));
    final piene = IlMotoreLunare.lunePieneFra(istante, fine);
    final nuove = IlMotoreLunare.luneNuoveFra(istante, fine);
    final prossimaPiena = piene.isNotEmpty ? piene.first : istante;
    final prossimaNuova = nuove.isNotEmpty ? nuove.first : istante;
    // La distanza della PROSSIMA piena, non quella di oggi: la Superluna è
    // un evento della Luna piena.
    final jdDellaPiena = Celestial.julianDay(prossimaPiena.toUtc());
    final distanzaDellaPienaKm = IlCieloDiMeeus.distanzaInKm(jdDellaPiena);
    return DatiDellaLunaDiQuestOra(
      istante: istante,
      percentualeDiLuce: illuminazione.fraction,
      crescente: illuminazione.waxing,
      sorgere: luogo == null ? null : prossimoSorgere(istante, luogo.lat, luogo.lon),
      tramonto:
          luogo == null ? null : prossimoTramonto(istante, luogo.lat, luogo.lon),
      culminazione: luogo == null
          ? null
          : prossimaCulminazione(istante, luogo.lat, luogo.lon),
      altezzaGradi: luogo == null
          ? null
          : posizioneOrizzontaleDellaLuna(istante, luogo.lat, luogo.lon)
              .altezzaGradi,
      distanzaKm: distanzaKm,
      superluna: distanzaDellaPienaKm <= sogliaSuperlunaKm,
      prossimaPiena: prossimaPiena,
      prossimaNuova: prossimaNuova,
    );
  }
}

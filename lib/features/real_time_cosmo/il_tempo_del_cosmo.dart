/// IL TEMPO DEL COSMO, la sorgente unica della data. Aggiunta della Macchina
/// del tempo all'ordine FH, voci C1-C3.
///
/// Una classe sola tiene l'istante mostrato, il luogo in uso e lo stato della
/// corsa. E' l'UNICO punto del Real Time Cosmo che legge l'orologio di
/// sistema: la guardia `un_solo_tempo` lo pretende. Cielo, pianeti, Luna,
/// veli, linee delle figure e oggetti del cielo profondo si disegnano dal
/// cielo dell'istante che questa classe dice, e nessuna data arriva da due
/// strade diverse allo stesso disegno.
library;

import 'package:flutter/foundation.dart';

import '../../core/astro/real_time_cosmo/il_riavvolgimento.dart';
import '../../core/astro/sky_location.dart';

/// Le fasi della corsa (docs/Specifica_Real_Time_Cosmo.md, 1-bis): l'eta'
/// prima di partire, la corsa, l'arrivo con la sua frase, il cielo fermo.
enum FaseDelRitorno { eta, ritorno, arrivo, fermo }

/// Dove arriva la corsa: decide la frase d'arrivo (voce E11).
enum ArrivoDellaCorsa { nascita, passato, oggi, futuro }

/// Il luogo in uso nella Macchina del tempo (voce D5): due voci sole.
enum LuogoDelTempo { nascita, attuale }

class IlTempoDelCosmo {
  IlTempoDelCosmo({DateTime Function()? orologio})
      : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;

  /// L'adesso. Il solo posto del Real Time Cosmo che lo chiede al sistema.
  DateTime adesso() => _orologio();

  /// Il giorno giuliano dell'istante mostrato, e il luogo da cui si guarda.
  double jdMostrato = 0;
  SkyPlace? luogoMostrato;

  /// La corsa in corso o l'ultima fatta: il piano degli istanti, la fase,
  /// l'orologio della fase.
  PianoDelRiavvolgimento? piano;
  final ValueNotifier<FaseDelRitorno> fase = ValueNotifier(FaseDelRitorno.eta);
  Duration inizioDellaFase = Duration.zero;

  /// Dove arriva la corsa e in che verso va (voci E2 e E5).
  ArrivoDellaCorsa arrivo = ArrivoDellaCorsa.nascita;
  bool versoIlPassato = true;

  /// Se la corsa porta l'eta' (verso la nascita, partendo dopo) o l'anno.
  bool conLEta = true;

  /// Lo scarto del luogo dal tempo universale alla partenza e all'arrivo: il
  /// giorno che scorre sotto il numero e' quello del luogo.
  Duration scartoDellaPartenza = Duration.zero;
  Duration scartoDellArrivo = Duration.zero;

  /// Il giorno d'arrivo, come lo legge la persona (giorno, mese, anno del
  /// luogo d'arrivo).
  DateTime? giornoDArrivo;

  /// Dice l'istante mostrato: lo chiama chi cambia il cielo disegnato.
  void mostra(double jd, SkyPlace luogo) {
    jdMostrato = jd;
    luogoMostrato = luogo;
  }

  /// Fa partire una corsa col [nuovo] piano.
  void parti(PianoDelRiavvolgimento nuovo, {required bool conLEta}) {
    piano = nuovo;
    this.conLEta = conLEta;
    versoIlPassato = nuovo.istanti.last < nuovo.istanti.first;
    inizioDellaFase = Duration.zero;
    fase.value = conLEta ? FaseDelRitorno.eta : FaseDelRitorno.ritorno;
  }

  void dispose() => fase.dispose();
}

/// LA FRASE D'ARRIVO, testi dell'Architetto (voce E11): non vengono dal
/// modello e non promettono un esito. La nascita porta la marca del genere
/// nella forma a posizioni; le altre portano la data lunga ("14 marzo
/// 1987", voce E12).
String fraseDArrivo(ArrivoDellaCorsa arrivo, String dataLunga) =>
    switch (arrivo) {
      ArrivoDellaCorsa.nascita => kFraseDellaNascita,
      ArrivoDellaCorsa.passato => 'QUESTO ERA IL CIELO DEL $dataLunga',
      ArrivoDellaCorsa.oggi => 'QUESTO È IL CIELO DI OGGI',
      ArrivoDellaCorsa.futuro => 'QUESTO SARÀ IL CIELO DEL $dataLunga',
    };

/// La frase della nascita, con la marca del genere (ordine FH voce 8.5).
const String kFraseDellaNascita =
    'QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI [NATO|NATA|VENUTO AL MONDO]';

/// La riga che corre sopra il numero (voce E5).
String rigaDellaCorsa({required bool versoIlPassato}) => versoIlPassato
    ? 'STO TORNANDO INDIETRO NEL TEMPO'
    : 'STO ANDANDO AVANTI NEL TEMPO';

/// Dove arriva una corsa al giorno [giorno], dato il giorno di nascita
/// [nascita] (o nessuno) e il giorno di oggi [oggi], tutti come giorni del
/// calendario.
ArrivoDellaCorsa arrivoAl(DateTime giorno, DateTime? nascita, DateTime oggi) {
  bool stesso(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  if (nascita != null && stesso(giorno, nascita)) {
    return ArrivoDellaCorsa.nascita;
  }
  if (stesso(giorno, oggi)) return ArrivoDellaCorsa.oggi;
  final g = DateTime(giorno.year, giorno.month, giorno.day);
  final o = DateTime(oggi.year, oggi.month, oggi.day);
  return g.isBefore(o) ? ArrivoDellaCorsa.passato : ArrivoDellaCorsa.futuro;
}

/// LA LICENZA DI SCENA DELLA CORSA (voci F2-F4). La Luna cresce fino a
/// [kScalaDiScena] volte: da 1 a 5 nel primo quinto della corsa, 5 fino
/// all'ottanta per cento, di nuovo 1 nell'ultimo quinto. All'arrivo torna
/// alla sua misura. La terra nella corsa si vede al [kTerraDiScena].
const double kScalaDiScena = 5;
const double kTerraDiScena = 0.2;

/// Il fattore di scena della Luna al punto [s] della corsa, fra 0 e 1.
double fattoreDiScena(double s) {
  double dolce(double x) {
    final y = x.clamp(0.0, 1.0);
    return y * y * (3 - 2 * y);
  }

  if (s <= 0 || s >= 1) return 1;
  if (s < 0.2) return 1 + (kScalaDiScena - 1) * dolce(s / 0.2);
  if (s <= 0.8) return kScalaDiScena;
  return 1 + (kScalaDiScena - 1) * dolce((1 - s) / 0.2);
}

/// Dove stanno i testi della corsa, in frazione dell'altezza dello schermo:
/// il blocco dei numeri centrato al 72 per cento (voce E6), la frase
/// d'arrivo al 78 (voce E7).
const double kAltezzaDeiNumeri = 0.72;

/// La risposta del pulsante quando il giorno e il luogo scelti sono quelli
/// gia' mostrati.
const String kGiaInQuestoCielo =
    'Sei già nel cielo di questo giorno: scegli un altro giorno o un altro luogo.';
const double kAltezzaDellArrivo = 0.78;

/// LA FINESTRA DELLA MACCHINA (voce D1): dal 1 gennaio 1900 al 31 dicembre
/// 2100, estremi compresi.
const int kPrimoAnnoDellaMacchina = 1900;
const int kUltimoAnnoDellaMacchina = 2100;

/// I giorni del mese [mese] dell'anno [anno]: il 29 febbraio solo negli anni
/// bisestili (voce D8).
int giorniDelMese(int anno, int mese) => DateTime(anno, mese + 1, 0).day;

/// Il giorno scelto con le tre ruote, tenuto dentro la finestra e dentro il
/// mese: se mese o anno rendono il giorno impossibile, scala all'ultimo valido
/// (voce D8), senza messaggi; fuori dalla finestra si ferma agli estremi
/// (voce D1).
DateTime giornoValido(int anno, int mese, int giorno) {
  final a = anno.clamp(kPrimoAnnoDellaMacchina, kUltimoAnnoDellaMacchina);
  final m = mese.clamp(1, 12);
  final g = giorno.clamp(1, giorniDelMese(a, m));
  return DateTime(a, m, g);
}

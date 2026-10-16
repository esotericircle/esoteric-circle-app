/// **LA CONSULTAZIONE DELLA LUNA.** Ordine FX aggiunta FXA.09, 16 ottobre
/// 2026.
///
/// Il fondatore, sull'anteprima della build 2312: "La funzione del respiro
/// dovrebbe essere un valore aggiunto valido per la retention, ma
/// principalmente la funzionalità resta di consultazione e informazione".
/// La struttura e i dati vengono dalla cattura di Dora
/// (`docs/collaudo/FX/fxa09_cattura_dora_riferimento.jpg`), mai l'aspetto:
/// la fase per nome, sorgere, culminazione e tramonto del giorno col conto
/// alla rovescia, la prossima piena e la prossima nuova, l'eta' della Luna,
/// la distanza esatta, il segno e la Luna fuori corso.
///
/// **Solo composizione**, come [DatiDellaLunaDiQuestOra] (FX.03): i numeri
/// vengono dal motore lunare (`IlMotoreLunare`, ordine FV), dal sorgere della
/// Luna (`il_sorgere_della_luna.dart`, FX.02) e dalla distanza di Meeus
/// (FX.01). Qui si sceglie quale istante mostrare, e come dirlo.
library;

import '../astro/luogo_attuale.dart';
import '../l10n/numero_del_cerchio.dart';
import '../astro/zodiac.dart';
import 'il_giorno_lunare.dart';
import 'il_motore_lunare.dart';
import 'il_sorgere_della_luna.dart';
import 'la_luna_di_quest_ora.dart';

/// **LA SOGLIA DELLA MICROLUNA**, in chilometri: oltre questa distanza la
/// Luna e' "lontana" e accanto alla distanza compare il sigillo della
/// Microluna. 405.000 km e' il criterio di timeanddate.com, la fonte che
/// gli avvisi del Respiro (FX.08) gia' citano per la Superluna; la Superluna
/// resta [sogliaSuperlunaKm] (Richard Nolle, 1979), dichiarata in FX.03.
/// Nessuna delle due e' un criterio dell'International Astronomical Union.
const double sogliaMicrolunaKm = 405000;

/// Vicina o lontana: quale sigillo sta accanto alla distanza, o nessuno.
enum VicinanzaDellaLuna { superluna, microluna }

/// Un evento del giorno (sorge, culmina, tramonta): l'istante e se cade il
/// giorno dopo quello guardato.
class EventoDelGiorno {
  const EventoDelGiorno({required this.istante, required this.domani});

  final DateTime istante;

  /// Vero se nel giorno guardato l'evento non c'e', e quello mostrato cade
  /// il giorno dopo: la riga lo segna con "(+1)".
  final bool domani;
}

/// I dati della consultazione, per un istante e un luogo.
class LaConsultazioneDellaLuna {
  const LaConsultazioneDellaLuna({
    required this.istante,
    required this.dati,
    required this.fase,
    required this.inizioDellaFase,
    required this.inizioDellaFasePrecedente,
    required this.inizioDellaFaseSuccessiva,
    required this.ultimaNuova,
    required this.segno,
    required this.prossimoCambioDiSegno,
    required this.fineDelFuoriCorso,
    this.sorge,
    this.culmina,
    this.tramonta,
  });

  final DateTime istante;

  /// I numeri di FX.03: percentuale, distanza, sizigie prossime.
  final DatiDellaLunaDiQuestOra dati;

  final FaseLunare fase;
  final DateTime inizioDellaFase;
  final DateTime inizioDellaFasePrecedente;
  final DateTime inizioDellaFaseSuccessiva;

  /// L'ultima Luna nuova prima dell'istante: da li' si conta l'eta'.
  final DateTime ultimaNuova;

  final Zodiac segno;

  /// Il prossimo ingresso della Luna in un segno, nullo solo se il motore
  /// non lo trova nei tre giorni dopo (non succede: la Luna resta in un segno
  /// al piu' due giorni e mezzo).
  final CambioDiSegno? prossimoCambioDiSegno;

  /// La fine della Luna fuori corso, solo quando l'istante cade dentro un
  /// intervallo di fuori corso.
  final DateTime? fineDelFuoriCorso;

  /// Nulli senza luogo: senza un posto da cui guardare il cielo non si
  /// inventa un orizzonte (la stessa regola di FX.03).
  final EventoDelGiorno? sorge;
  final EventoDelGiorno? culmina;
  final EventoDelGiorno? tramonta;

  Duration get eta => istante.difference(ultimaNuova);

  VicinanzaDellaLuna? get vicinanza => dati.distanzaKm <= sogliaSuperlunaKm
      ? VicinanzaDellaLuna.superluna
      : dati.distanzaKm >= sogliaMicrolunaKm
          ? VicinanzaDellaLuna.microluna
          : null;

  static LaConsultazioneDellaLuna calcola(
      DateTime istante, LuogoAttuale? luogo) {
    final dati = DatiDellaLunaDiQuestOra.calcola(istante, luogo);
    final fase = faseAllIstante(istante);
    final inizio = _inizioDellaFase(istante);
    final precedente =
        _inizioDellaFase(inizio.subtract(const Duration(minutes: 1)));
    final successiva = _inizioDellaFaseSuccessiva(istante);
    final nuove = IlMotoreLunare.luneNuoveFra(
        istante.subtract(const Duration(days: 31)), istante);
    final ingressiPrima = IlMotoreLunare.ingressiFra(
        istante.subtract(const Duration(days: 3)), istante);
    final ingressiDopo = IlMotoreLunare.ingressiFra(
        istante, istante.add(const Duration(days: 3)));
    final segno = ingressiPrima.isNotEmpty
        ? ingressiPrima.last.segno
        : IlMotoreLunare.delGiorno(istante).segno;
    DateTime? fineDelFuoriCorso;
    for (final v in IlMotoreLunare.fuoriCorsoFra(
        istante.subtract(const Duration(days: 3)),
        istante.add(const Duration(days: 1)))) {
      if (!istante.isBefore(v.inizio) && istante.isBefore(v.fine)) {
        fineDelFuoriCorso = v.fine;
      }
    }
    EventoDelGiorno? delGiorno(
        DateTime? Function(DateTime, double, double) cerca,
        [DateTime? Function(DateTime, double, double)? contrario]) {
      if (luogo == null) return null;
      final mezzanotte = DateTime(istante.year, istante.month, istante.day);
      var e = cerca(mezzanotte, luogo.lat, luogo.lon);
      // **IL SORGERE VERO, NON LA MEZZANOTTE.** `prossimoSorgere` torna
      // l'istante stesso se la Luna e' gia' sopra l'orizzonte (e
      // `prossimoTramonto` se e' gia' sotto): a mezzanotte la risposta
      // sarebbe "sorge alle 00:00". Il sorgere del giorno e' allora il primo
      // dopo il tramonto che viene, e viceversa. Preso dalla prova di
      // calcolo sul 24 ottobre 2026 a Piacenza, contro la cattura di Dora.
      if (contrario != null && e == mezzanotte) {
        final opposto = contrario(mezzanotte, luogo.lat, luogo.lon);
        e = opposto == null ? null : cerca(opposto, luogo.lat, luogo.lon);
      }
      if (e == null) return null;
      final l = e.toLocal();
      final stessoGiorno = l.year == mezzanotte.year &&
          l.month == mezzanotte.month &&
          l.day == mezzanotte.day;
      return EventoDelGiorno(istante: e, domani: !stessoGiorno);
    }

    return LaConsultazioneDellaLuna(
      istante: istante,
      dati: dati,
      fase: fase,
      inizioDellaFase: inizio,
      inizioDellaFasePrecedente: precedente,
      inizioDellaFaseSuccessiva: successiva,
      ultimaNuova: nuove.isNotEmpty
          ? nuove.last
          : istante.subtract(const Duration(days: 29)),
      segno: segno,
      prossimoCambioDiSegno:
          ingressiDopo.isNotEmpty ? ingressiDopo.first : null,
      fineDelFuoriCorso: fineDelFuoriCorso,
      sorge: delGiorno(prossimoSorgere, prossimoTramonto),
      culmina: delGiorno(prossimaCulminazione),
      tramonta: delGiorno(prossimoTramonto, prossimoSorgere),
    );
  }

  /// La fase per nome, dalla stessa regola del Calendario Lunare: otto
  /// settori di 45 gradi d'elongazione ([IlMotoreLunare.faseDi]).
  static FaseLunare faseAllIstante(DateTime t) =>
      IlMotoreLunare.faseDi(IlMotoreLunare.elongazione(t));

  /// L'istante in cui la fase di [t] e' cominciata: si torna indietro a
  /// passi di un'ora finche' la fase cambia, poi si stringe a un minuto.
  static DateTime _inizioDellaFase(DateTime t) {
    final f = faseAllIstante(t);
    var dentro = t;
    var fuori = t;
    for (var h = 1; h <= 24 * 6; h++) {
      fuori = t.subtract(Duration(hours: h));
      if (faseAllIstante(fuori) != f) break;
      dentro = fuori;
    }
    return _confine(fuori, dentro, f);
  }

  static DateTime _inizioDellaFaseSuccessiva(DateTime t) {
    final f = faseAllIstante(t);
    var dentro = t;
    var fuori = t;
    for (var h = 1; h <= 24 * 6; h++) {
      fuori = t.add(Duration(hours: h));
      if (faseAllIstante(fuori) != f) break;
      dentro = fuori;
    }
    // Il primo istante della fase dopo: il confine visto dall'altra parte.
    return _confine(dentro, fuori, faseAllIstante(fuori));
  }

  /// Fra [a] (fuori dalla fase [f]) e [b] (dentro [f]) il primo minuto in
  /// cui la fase e' [f], per bisezione.
  static DateTime _confine(DateTime a, DateTime b, FaseLunare f) {
    var fuori = a;
    var dentro = b;
    while (dentro.difference(fuori).abs() > const Duration(minutes: 1)) {
      final meta = fuori.add(
          Duration(microseconds: dentro.difference(fuori).inMicroseconds ~/ 2));
      if (faseAllIstante(meta) == f) {
        dentro = meta;
      } else {
        fuori = meta;
      }
    }
    return dentro;
  }
}

/// **COME SI DICE UN TEMPO**, nelle righe della consultazione.
abstract final class IlTempoDetto {
  static String ora(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  /// "tra 32 min", "tra 7 h 19 min", "11 h 1 min fa", "adesso".
  static String rispetto(DateTime evento, DateTime guardato) {
    final d = evento.difference(guardato);
    final minuti = d.inMinutes.abs();
    if (minuti == 0) return 'adesso';
    final ore = minuti ~/ 60;
    final resto = minuti % 60;
    final quanto = ore == 0
        ? '$resto min'
        : resto == 0
            ? '$ore h'
            : '$ore h $resto min';
    return d.isNegative ? '$quanto fa' : 'tra $quanto';
  }

  /// "1 g 12 h 30 min": giorni, ore e minuti di una durata.
  static String durata(Duration d) {
    final minuti = d.inMinutes.abs();
    final giorni = minuti ~/ (24 * 60);
    final ore = (minuti % (24 * 60)) ~/ 60;
    final resto = minuti % 60;
    return giorni > 0 ? '$giorni g $ore h $resto min' : '$ore h $resto min';
  }

  /// "375.560 km": la distanza intera, col separatore delle migliaia della
  /// lingua dell'app (`NumeroDelCerchio`, mai scritto a mano: in inglese e'
  /// la virgola).
  static String chilometri(double km) =>
      '${NumeroDelCerchio.interi(km.round())} km';
}

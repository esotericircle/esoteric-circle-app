/// LA PAROLA DI MEDORA DEL RESPIRO, ordine FX voce FX.07, 16 ottobre 2026.
///
/// "Tre righe di oggi: la Luna nel segno, il giorno lunare e la Luna fuori
/// corso in tempo reale" (la proposta approvata).
///
/// **Nessuna chiamata al modello, mai: e' la regola R2 di quest'ordine.**
/// Le tre righe nascono da un corpus scritto qui, dentro questo file, e dai
/// numeri che il motore lunare (`IlMotoreLunare`) ha gia' calcolato: nessuna
/// rete, nessuna AI, nessuna attesa.
///
/// **La regola R8, copiata alla lettera** (il respiro e' un rito, mai una
/// terapia, e un corpus scritto a mano non promette un esito): niente
/// salute, niente soldi, nessuna promessa di esito. Cio' che non e'
/// documentato si dice "chiave di Medora", mai "tradizione": qui vale per
/// il tratto di carattere di ciascun segno (una parola sola, sotto
/// [LaParolaDiMedoraDelRespiro._chiaveDelSegno], scelta per lo stile del
/// respiro e non presa da una fonte citabile). La Luna fuori corso invece
/// VIENE dalla tradizione astrologica classica, e lo dice: la fonte e' la
/// stessa che il motore lunare cita sopra di se', William Lilly, *Christian
/// Astrology* (1647), libro I.
///
/// **Il giorno lunare non porta un significato per numero.** Cercato con
/// `WebSearch` il 16 ottobre 2026 ("30 lunar days meanings folklore age of
/// the moon documented source", "lunar day meanings folklore"): nessuna
/// fonte seriamente documentata e citabile assegna un significato a
/// ciascuno dei trenta giorni nella tradizione popolare europea. Il sistema
/// piu' vicino trovato, il tithi induista (wisdomlib.org,
/// ficino.sourcelibrary.org), nomina a cicli di tre solo i primi quindici
/// giorni (Nanda, Bhadra, Jaya, Rikta, Purna) ed e' un'altra tradizione, non
/// quella richiesta dall'ordine: non entra. La terza riga resta il solo
/// numero, senza un significato simbolico inventato (regola dell'ordine FX,
/// voce FX.07).
///
/// **La Luna fuori corso "in tempo reale"**: se l'istante esatto di adesso
/// cade dentro un intervallo di `GiornoLunare.fuoriCorso`, la riga dice fino
/// a quando; se non c'e' un intervallo adesso ma ce n'e' uno piu' tardi nello
/// stesso giorno, la riga anticipa quando arriva; se nel giorno non c'e'
/// nessun intervallo, la riga non compare (scelta dichiarata dalla voce
/// FX.07: una riga vuota sul nulla sarebbe peggio di una riga assente).
library;

import '../astro/zodiac.dart';
import 'il_giorno_lunare.dart';
import 'il_motore_lunare.dart';

/// Le tre righe di oggi, pronte per lo schermo del Respiro della Luna.
class ParolaDiMedoraDelRespiro {
  const ParolaDiMedoraDelRespiro({
    required this.segno,
    required this.giornoLunare,
    this.fuoriCorso,
  });

  /// La prima riga: sempre presente.
  final String segno;

  /// La seconda riga: nulla se oggi non c'e' nessun intervallo di fuori
  /// corso (vedi il commento sopra il file).
  final String? fuoriCorso;

  /// La terza riga: sempre presente, solo il numero.
  final String giornoLunare;

  /// Le righe davvero da mostrare, nell'ordine della voce: segno, fuori
  /// corso (se c'e'), giorno lunare.
  List<String> get righe => [
        segno,
        if (fuoriCorso != null) fuoriCorso!,
        giornoLunare,
      ];
}

abstract final class LaParolaDiMedoraDelRespiro {
  /// Il tratto di ciascun segno: chiave di Medora (vedi il commento sopra il
  /// file), una parola sola, pensata per non promettere salute, soldi o
  /// esiti, e per restare intonata al respiro come rito.
  static const Map<Zodiac, String> _chiaveDelSegno = {
    Zodiac.aries: 'd\'impulso',
    Zodiac.taurus: 'di radice',
    Zodiac.gemini: 'di parola',
    Zodiac.cancer: 'di casa',
    Zodiac.leo: 'di scena',
    Zodiac.virgo: 'di ordine',
    Zodiac.libra: 'di equilibrio',
    Zodiac.scorpio: 'di profondità',
    Zodiac.sagittarius: 'di orizzonte',
    Zodiac.capricorn: 'di soglia',
    Zodiac.aquarius: 'di distanza',
    Zodiac.pisces: 'di sogno',
  };

  /// Le tre righe di oggi, dal giorno lunare di [adesso] (calcolato in ora
  /// locale da `IlMotoreLunare.delGiorno`, o da [giorno] se lo si passa:
  /// iniettabile per le prove, che altrimenti dipenderebbero dal giorno
  /// vero in cui girano) e dall'istante esatto [adesso] stesso, per la riga
  /// del fuori corso "in tempo reale".
  static ParolaDiMedoraDelRespiro diOggi(DateTime adesso, {GiornoLunare? giorno}) {
    giorno ??= IlMotoreLunare.delGiorno(adesso);
    return ParolaDiMedoraDelRespiro(
      segno: _rigaDelSegno(giorno, adesso),
      fuoriCorso: _rigaDelFuoriCorso(giorno, adesso),
      giornoLunare: _rigaDelGiornoLunare(giorno),
    );
  }

  static String _ora(DateTime t) {
    final l = t.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  /// La riga del segno: non si appoggia al segno calcolato a mezzogiorno
  /// (`GiornoLunare.segno`), che a cambio gia' avvenuto nella mattinata
  /// sarebbe gia' il segno nuovo mentre la riga vorrebbe ancora annunciarlo.
  /// Si guarda invece [adesso] contro l'istante del cambio, se c'e' n'e' uno
  /// oggi: prima del cambio il segno che la Luna lascia e' quello che lo
  /// precede nel ciclo dei dodici (lo zodiaco e' ciclico), dopo e' quello in
  /// cui e' appena entrata.
  static String _rigaDelSegno(GiornoLunare giorno, DateTime adesso) {
    final cambi = giorno.cambiDiSegno;
    if (cambi.isEmpty) {
      final chiave = _chiaveDelSegno[giorno.segno]!;
      return 'La Luna è nel segno del ${giorno.segno.italianName}, $chiave: '
          'oggi non cambia segno.';
    }
    final cambio = cambi.first;
    if (adesso.isBefore(cambio.istante)) {
      final precedente = Zodiac.values[
          (cambio.segno.index + Zodiac.values.length - 1) %
              Zodiac.values.length];
      final chiave = _chiaveDelSegno[precedente]!;
      return 'La Luna è nel segno del ${precedente.italianName}, $chiave, '
          'fino alle ${_ora(cambio.istante)}: poi entra nel segno del '
          '${cambio.segno.italianName}.';
    }
    final chiave = _chiaveDelSegno[cambio.segno]!;
    return 'La Luna è entrata nel segno del ${cambio.segno.italianName}, '
        '$chiave, alle ${_ora(cambio.istante)}.';
  }

  /// La riga del fuori corso, in tempo reale: vedi il commento sopra il
  /// file per le tre scelte (adesso, piu' tardi, assente).
  static String? _rigaDelFuoriCorso(GiornoLunare giorno, DateTime adesso) {
    for (final v in giorno.fuoriCorso) {
      if (!adesso.isBefore(v.inizio) && adesso.isBefore(v.fine)) {
        return 'In questo momento la Luna è fuori corso, dalla tradizione '
            'di William Lilly (Christian Astrology, 1647): fino alle '
            '${_ora(v.fine)} non perfeziona più nessun aspetto prima di '
            'cambiare segno.';
      }
    }
    for (final v in giorno.fuoriCorso) {
      if (v.inizio.isAfter(adesso)) {
        return 'Più tardi oggi, dalle ${_ora(v.inizio)} alle ${_ora(v.fine)}, '
            'la Luna sarà fuori corso.';
      }
    }
    return null;
  }

  /// La riga del giorno lunare: solo il numero, vedi il commento sopra il
  /// file sulla ricerca senza esito.
  static String _rigaDelGiornoLunare(GiornoLunare giorno) =>
      'È il giorno lunare numero ${giorno.giornoLunare}.';
}

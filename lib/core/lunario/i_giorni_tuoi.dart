import '../astro/meeus/il_cielo_di_meeus.dart';
import '../identity/birth_identity.dart';
import 'il_corpus_del_lunario.g.dart';
import 'il_motore_lunare.dart';
import 'il_segno_del_giorno_tuo.dart';

/// **I GIORNI TUOI.** Ordine FV voce FV.07, 15 ottobre 2026 (proposta
/// dell'Architetto, voce 3; il fondatore: "Siz approvo tutto"). Implementa
/// la porta `IGiorniTuoiDelMese` di `il_segno_del_giorno_tuo.dart`: dati la
/// nascita e un mese, i quattro segni che solo la persona vede.
///
/// **Senza l'ora di nascita** (`BirthIdentity.hasBirthTime` falso) non si
/// calcolano [TipoDelGiornoTuo.ritornoLunare] e [TipoDelGiornoTuo.faseDiNascita]:
/// dipendono dal grado esatto della Luna di nascita, che l'ora affina (senza
/// l'ora il momento e' ancorato a mezzogiorno, un punto convenzionale, non
/// quello vero). [TipoDelGiornoTuo.lunaSulTuoSole] e
/// [TipoDelGiornoTuo.lunaNelTuoSegno] non dipendono dall'ora e si calcolano
/// sempre. La schermata filtra di nuovo per sicurezza
/// (`CalendarioLunareScreen._segniTuoi`), ma e' piu' pulito non calcolare
/// quello che non si puo' mostrare.
///
/// **Il metodo.** La longitudine della Luna e del Sole di nascita vengono da
/// `IlCieloDiMeeus`, lo stesso motore di `IlMotoreLunare` (nessun secondo
/// motore, R del motore unico). Il "ritorno" di un grado si cerca
/// controllando, giorno per giorno, se la longitudine (della Luna o
/// dell'elongazione) attraversa il grado bersaglio fra la mezzanotte locale
/// di un giorno e quella del giorno dopo: la Luna avanza di circa 13 gradi
/// al giorno, quindi attraversa ogni grado una volta sola nel mese giusto,
/// con la tolleranza di un giorno civile che l'ordine chiede. "La Luna nel
/// tuo segno solare" non ha bisogno di questa ricerca: usa direttamente il
/// segno che `IlMotoreLunare.delMese` da' gia' per ogni giorno.
abstract final class IGiorniTuoi {
  /// I segni tuoi del mese [anno]-[mese] per [nascita]; vuoto per la nascita
  /// d'esempio (nessuna data vera).
  static List<SegnoDelGiornoTuo> delMese(
      BirthIdentity nascita, int anno, int mese) {
    if (nascita.isExample) return const [];
    final giorni = IlMotoreLunare.delMese(anno, mese);
    if (giorni.isEmpty) return const [];
    final primo = giorni.first.giorno;
    final quanti = giorni.length;

    final lonLunaNascita = IlCieloDiMeeus.longitudineAllIstante(
        CorpoCeleste.luna, nascita.birthMoment);
    final lonSoleNascita = IlCieloDiMeeus.longitudineAllIstante(
        CorpoCeleste.sole, nascita.birthMoment);
    final elongazioneNascita = (lonLunaNascita - lonSoleNascita) % 360;

    final risultato = <SegnoDelGiornoTuo>[];

    // LA LUNA NEL TUO SEGNO: non dipende dall'ora, diretto dal motore.
    for (final g in giorni) {
      if (g.segno == nascita.segnoDellaNascita) {
        risultato.add(_segno(TipoDelGiornoTuo.lunaNelTuoSegno, g.giorno));
      }
    }

    // LA LUNA SUL TUO SOLE: non dipende dall'ora.
    for (final g in _giornoDelRitorno(
        CorpoCeleste.luna, primo, quanti, lonSoleNascita)) {
      risultato.add(_segno(TipoDelGiornoTuo.lunaSulTuoSole, g));
    }

    if (nascita.hasBirthTime) {
      // IL RITORNO DELLA TUA LUNA: dipende dall'ora.
      for (final g in _giornoDelRitorno(
          CorpoCeleste.luna, primo, quanti, lonLunaNascita)) {
        risultato.add(_segno(TipoDelGiornoTuo.ritornoLunare, g));
      }

      // IL RITORNO DELLA TUA FASE DI NASCITA: dipende dall'ora. La stessa
      // ricerca del grado, sull'elongazione (Luna meno Sole) invece che
      // sulla sola Luna: avanza nello stesso senso, un poco piu' lenta
      // (circa 12 gradi al giorno, il moto della Luna meno quello del
      // Sole), quindi lo stesso attraversamento vale.
      for (final g
          in _giornoDelRitornoElongazione(primo, quanti, elongazioneNascita)) {
        risultato.add(_segno(TipoDelGiornoTuo.faseDiNascita, g));
      }
    }

    risultato.sort((a, b) => a.giorno.compareTo(b.giorno));
    return risultato;
  }

  static SegnoDelGiornoTuo _segno(TipoDelGiornoTuo tipo, DateTime giorno) =>
      SegnoDelGiornoTuo(
        giorno: giorno,
        tipo: tipo,
        titolo: _titoli[tipo]!,
        testo: testiDelLunario[_chiavi[tipo]]!,
      );

  static const Map<TipoDelGiornoTuo, String> _titoli = {
    TipoDelGiornoTuo.ritornoLunare: 'Torna la tua Luna',
    TipoDelGiornoTuo.lunaSulTuoSole: 'La Luna sul tuo Sole',
    TipoDelGiornoTuo.lunaNelTuoSegno: 'La Luna nel tuo segno',
    TipoDelGiornoTuo.faseDiNascita: 'Torna la tua fase di nascita',
  };

  static const Map<TipoDelGiornoTuo, String> _chiavi = {
    TipoDelGiornoTuo.ritornoLunare: 'giorni_tuoi.ritorno_lunare',
    TipoDelGiornoTuo.lunaSulTuoSole: 'giorni_tuoi.luna_sul_sole',
    TipoDelGiornoTuo.lunaNelTuoSegno: 'giorni_tuoi.luna_nel_segno',
    TipoDelGiornoTuo.faseDiNascita: 'giorni_tuoi.fase_di_nascita',
  };

  /// I giorni (a mezzanotte locale) in cui [corpo] attraversa la longitudine
  /// [bersaglio] fra [primo] e [primo] piu' [quanti] giorni.
  static List<DateTime> _giornoDelRitorno(
      CorpoCeleste corpo, DateTime primo, int quanti, double bersaglio) {
    final confini = [
      for (var i = 0; i <= quanti; i++)
        IlCieloDiMeeus.longitudineAllIstante(
            corpo, DateTime(primo.year, primo.month, primo.day + i)),
    ];
    return [
      for (var i = 0; i < quanti; i++)
        if (_attraversaIlGrado(confini[i], confini[i + 1], bersaglio))
          DateTime(primo.year, primo.month, primo.day + i),
    ];
  }

  /// Come [_giornoDelRitorno], ma sull'elongazione (Luna meno Sole) invece
  /// che su un solo corpo.
  static List<DateTime> _giornoDelRitornoElongazione(
      DateTime primo, int quanti, double bersaglio) {
    final confini = [
      for (var i = 0; i <= quanti; i++)
        () {
          final t = DateTime(primo.year, primo.month, primo.day + i);
          return (IlCieloDiMeeus.longitudineAllIstante(CorpoCeleste.luna, t) -
                  IlCieloDiMeeus.longitudineAllIstante(CorpoCeleste.sole, t)) %
              360;
        }(),
    ];
    return [
      for (var i = 0; i < quanti; i++)
        if (_attraversaIlGrado(confini[i], confini[i + 1], bersaglio))
          DateTime(primo.year, primo.month, primo.day + i),
    ];
  }

  /// Vero se [corpo] (la sua longitudine, o l'elongazione) passa da [a] a
  /// [b] attraversando [bersaglio], muovendosi sempre in avanti (gradi
  /// crescenti, modulo 360): il caso normale della Luna, che non e' mai
  /// retrograda.
  static bool _attraversaIlGrado(double a, double b, double bersaglio) {
    final percorso = (b - a) % 360;
    if (percorso <= 0) return false;
    final distanza = (bersaglio - a) % 360;
    return distanza < percorso;
  }
}

/// **IL CONTRATTO DEL CORPUS DELLE REGOLE LUNARI.** Ordine FV voce FV.06, 15
/// ottobre 2026. Questi tipi sono il bersaglio di
/// `tool/il_corpus_del_lunario.py genera`, che li riempie da
/// `docs/corpus/lunario/fonti.md` e `regole.md` in
/// `lib/core/lunario/il_corpus_del_lunario.g.dart`; `LeRegoleDelLunario`
/// (`lib/core/lunario/le_regole_del_lunario.dart`) li legge e basta. La
/// grammatica per esteso e' in `docs/corpus/lunario/LEGGIMI.md`.
library;

import '../astro/zodiac.dart';
import 'il_giorno_lunare.dart';
import 'le_attivita_del_lunario.dart';

/// La luce della Luna: crescente dalla Luna nuova alla piena, calante dalla
/// piena alla nuova (`GiornoLunare.crescente`).
enum LuceDellaLuna {
  crescente,
  calante;

  /// Dal valore scritto nella fonte ("crescente", "calante"); nullo se non
  /// riconosciuto.
  static LuceDellaLuna? daChiave(String chiave) => switch (chiave) {
        'crescente' => LuceDellaLuna.crescente,
        'calante' => LuceDellaLuna.calante,
        _ => null,
      };
}

/// **LA CONDIZIONE DI UNA REGOLA**: ogni campo non nullo e' in AND con gli
/// altri; dentro un campo, piu' valori sono in OR. Un campo nullo non entra
/// nel giudizio (ne' a favore ne' contro).
class CondizioneDelLunario {
  const CondizioneDelLunario({
    this.luce,
    this.fasi,
    this.segni,
    this.tipi,
    this.fuoriCorso,
  });

  /// La luce richiesta (chiave `luce` della fonte).
  final LuceDellaLuna? luce;

  /// Una o piu' fasi (chiave `fase`, i valori separati da virgola sono OR).
  final List<FaseLunare>? fasi;

  /// Uno o piu' segni (chiave `segno`).
  final List<Zodiac>? segni;

  /// Uno o piu' tipi biodinamici (chiave `bio`).
  final List<TipoBiodinamico>? tipi;

  /// Vera per `fuoricorso=si`, falsa per `fuoricorso=no`, nulla se la
  /// regola non parla di Luna fuori corso.
  final bool? fuoriCorso;

  /// Vale per [giorno]: ogni campo non nullo deve combaciare. Il campo
  /// [tipi] TACE (la regola non si applica, ne' a favore ne' contro) quando
  /// il giorno non ha un tipo biodinamico documentato (l'Ofiuco).
  bool valePer(GiornoLunare giorno) {
    if (luce != null) {
      final crescenteRichiesto = luce == LuceDellaLuna.crescente;
      if (giorno.crescente != crescenteRichiesto) return false;
    }
    if (fasi != null && !fasi!.contains(giorno.fase)) return false;
    if (segni != null && !segni!.contains(giorno.segno)) return false;
    if (tipi != null) {
      final tipo = giorno.tipoBiodinamico;
      if (tipo == null || !tipi!.contains(tipo)) return false;
    }
    if (fuoriCorso != null && giorno.haFuoriCorso != fuoriCorso) return false;
    return true;
  }
}

/// **UNA FONTE DEL CORPUS LUNARE**: da dove viene una regola o un testo, con
/// la citazione, l'indirizzo, la data in cui Code l'ha letta e cosa dice.
class FonteDelLunario {
  const FonteDelLunario({
    required this.id,
    required this.citazione,
    required this.indirizzo,
    required this.letta,
    required this.dice,
  });

  final String id;
  final String citazione;
  final String indirizzo;

  /// La data di lettura, in forma leggibile (AAAA-MM-GG).
  final String letta;
  final String dice;
}

/// **UNA REGOLA LUNARE**: per quali attivita' vale, quando vale, come pesa
/// sul grado del giorno, da dove viene e cosa dice la voce di Medora quando
/// contribuisce.
class RegolaDelLunario {
  const RegolaDelLunario({
    required this.id,
    required this.attivita,
    required this.quando,
    this.peso = 0,
    this.toglieLOro = false,
    required this.fonti,
    required this.detto,
  });

  final String id;

  /// Le attivita' per cui questa regola vale.
  final List<AttivitaDelLunario> attivita;
  final CondizioneDelLunario quando;

  /// Il peso che la regola porta alla somma del giorno quando vale (positivo
  /// verso l'oro, negativo verso l'evitare). Zero per le regole che portano
  /// solo [toglieLOro].
  final int peso;

  /// Vera per le regole della Luna fuori corso che spengono l'oro (R8
  /// dell'ordine FV), indipendentemente dalla somma dei pesi.
  final bool toglieLOro;

  /// Gli id delle fonti di `fonti.md` che sostengono questa regola.
  final List<String> fonti;

  /// Il testo breve nel perche' del giorno, nella voce di Medora. Per le
  /// regole con `quando.fuoriCorso` vero, `LeRegoleDelLunario.valuta` compone
  /// al suo posto la riga con gli orari veri: vedi LEGGIMI.md.
  final String detto;
}

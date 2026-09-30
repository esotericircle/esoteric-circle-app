/// **IL MICROFONO SI RIAPRE QUANDO LA VOCE DEL MAESTRO TACE DAVVERO.** Ordine
/// ES voce 22, 30 settembre 2026.
///
/// Visto sul Realme nel collaudo del LIVE di quel giorno, venti domande dette
/// dalle casse del PC con la stanza registrata dal microfono del PC
/// (`docs/collaudo/ES/live_realme.txt`). Il telefono tornava ad ascoltare
/// 700 millesimi dopo che il volto diceva di aver finito, o dopo la durata
/// dell'audio piu' tre secondi quando non lo diceva. Nella registrazione la
/// voce di Medora continuava invece **da 2,3 a 3,1 secondi dopo il segnale**
/// in tredici turni su tredici misurabili, e in un turno il segnale e'
/// arrivato 6,6 secondi prima della fine dell'audio (16,2 secondi dall'inizio
/// su 22,8 di voce: il volto lo manda anche quando resta senza audio da dire
/// mentre il resto sta ancora arrivando). Chi parlava appena il Maestro
/// sembrava aver finito parlava sopra la sua coda: l'orecchio sentiva la
/// domanda a pezzi, e chi trascrive ne ha inventate due su venti.
///
/// Padre: ordine EJ voce 01 (i 700 millesimi di coda, misurati allora) e
/// ordine EQ voce 03 (la voce della prima frase mandata in anticipo, che fa
/// dire al volto "ho finito" fra un pezzo e l'altro).
///
/// Due cure, tutte e due qui perche' si provano senza una stanza vera:
/// - **il segnale non vale prima della fine piu' vicina possibile**: dal primo
///   suono mandato, la voce dura almeno quanto il suo audio
///   ([mancaAllaFineMinima]);
/// - **poi si ascolta la traccia che il telefono riceve dal volto**, con le
///   stesse statistiche con cui si misura quando la persona comincia a
///   sentirlo (ordine EQ voce 03): si torna ad ascoltare quando la potenza
///   resta sotto la soglia per [quiete] di fila.
class LaVoceCheTace {
  /// La potenza media sopra la quale l'audio ricevuto e' voce: la stessa
  /// soglia di "si sente".
  static const double soglia = 1e-4;

  /// Quanto silenzio di fila ci vuole: piu' della pausa fra due frasi della
  /// voce sintetica, che senno' si scambierebbe per la fine.
  static const Duration quiete = Duration(milliseconds: 900);

  /// Oltre questo non si aspetta: una traccia che non tace mai non deve
  /// tenere chiuso il microfono per sempre.
  static const Duration tetto = Duration(seconds: 12);

  /// Ogni quanto si leggono le statistiche.
  static const Duration passo = Duration(milliseconds: 80);

  /// Senza statistiche (la traccia non c'e', il telefono non le da') si
  /// aspetta la coda misurata sul Realme: tre secondi.
  static const Duration codaSenzaMisura = Duration(seconds: 3);

  /// Quanto manca alla fine piu' vicina possibile della voce, quando il
  /// volto dice di aver finito: il primo suono mandato piu' la durata
  /// dell'audio, meno il tempo gia' passato. Zero se e' gia' passata.
  static Duration mancaAllaFineMinima({
    required Duration? primoSuono,
    required double secondiDiVoce,
    required Duration trascorso,
  }) {
    final fine = (primoSuono ?? Duration.zero) +
        Duration(milliseconds: (secondiDiVoce * 1000).round());
    final manca = fine - trascorso;
    return manca.isNegative ? Duration.zero : manca;
  }

  num? _energia;
  num? _durata;
  Duration? _ultima;
  Duration _quieta = Duration.zero;

  /// Se almeno una lettura ha portato le statistiche.
  bool get misurata => _misurata;
  bool _misurata = false;

  /// Una lettura delle statistiche della traccia ricevuta, [adesso] da
  /// quando si e' cominciato ad aspettare. Vero quando si puo' tornare ad
  /// ascoltare.
  bool lettura({
    required num? energia,
    required num? durata,
    required Duration adesso,
  }) {
    if (adesso >= tetto) return true;
    if (energia == null || durata == null) {
      return !_misurata && adesso >= codaSenzaMisura;
    }
    _misurata = true;
    final primaEnergia = _energia;
    final primaDurata = _durata;
    final prima = _ultima;
    _energia = energia;
    _durata = durata;
    _ultima = adesso;
    if (primaEnergia == null || primaDurata == null || prima == null) {
      return false;
    }
    final passata = durata - primaDurata;
    // Se la traccia non ha suonato campioni nuovi, non sta suonando voce.
    final voce = passata > 0 && (energia - primaEnergia) / passata > soglia;
    _quieta = voce ? Duration.zero : _quieta + (adesso - prima);
    return _quieta >= quiete;
  }
}

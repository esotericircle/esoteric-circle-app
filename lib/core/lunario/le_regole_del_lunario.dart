import 'il_corpus_del_lunario.g.dart';
import 'il_giorno_lunare.dart';
import 'la_regola_del_lunario.dart';
import 'le_attivita_del_lunario.dart';

/// **IL MOTORE DELLE REGOLE LUNARI.** Ordine FV voce FV.06, 15 ottobre 2026.
/// Applica il corpus generato (`regoleDelLunario`, da
/// `docs/corpus/lunario/regole.md`) a un [GiornoLunare] per un'attivita', e
/// decide il grado del giorno.
///
/// **Come si decide il grado.** Si somma il [RegolaDelLunario.peso] di ogni
/// regola che vale per il giorno e l'attivita'; se almeno una regola che vale
/// porta [RegolaDelLunario.toglieLOro], il giorno non puo' essere oro,
/// qualunque sia la somma (R8 dell'ordine FV: "Le ore fuori corso tolgono
/// l'oro a inizi, firme, amore e viaggi"). Poi:
/// - somma positiva e nessun `toglieLOro` attivo: **oro**;
/// - somma negativa (con o senza `toglieLOro`): **evitare**;
/// - altrimenti (somma zero, o somma positiva con `toglieLOro` attivo):
///   **neutro**. Questa soglia (zero, non un altro numero) e' la scelta di
///   Code dichiarata nel rapporto dell'ordine: senza regole che valgono la
///   somma e' zero e il giorno resta un giorno come gli altri, ed e' lo
///   stesso comportamento che aveva il punto di unione provvisorio
///   (`CalendarioLunareScreen.senzaRegole`) prima di questa voce.
///
/// **Come si compone il perche'.** Una riga per ogni regola che vale, nella
/// voce del [RegolaDelLunario.detto], ECCETTO le regole sulla Luna fuori
/// corso (`quando.fuoriCorso` non nullo): per quelle la riga si compone qui,
/// con gli orari veri di [GiornoLunare.fuoriCorso] (per esempio "Fuori corso
/// dalle 3:10 alle 5:40"), perche' il `detto` del corpus non puo' conoscere
/// l'orario del giorno vero. Nessuna riga si ripete due volte.
abstract final class LeRegoleDelLunario {
  /// Il giudizio di un giorno per un'attivita', dal corpus delle regole.
  static EsitoDelGiorno valuta(
      AttivitaDelLunario attivita, GiornoLunare giorno) {
    var somma = 0;
    var toglieLOro = false;
    final perche = <String>[];
    final fonti = <String>{};
    var fuoriCorsoDetto = false;

    for (final regola in regoleDelLunario) {
      if (!regola.attivita.contains(attivita)) continue;
      if (!regola.quando.valePer(giorno)) continue;

      somma += regola.peso;
      if (regola.toglieLOro) toglieLOro = true;
      fonti.addAll(regola.fonti);

      if (regola.quando.fuoriCorso != null) {
        if (giorno.haFuoriCorso && !fuoriCorsoDetto) {
          perche.add(_fuoriCorsoDetto(giorno));
          fuoriCorsoDetto = true;
        }
      } else if (!perche.contains(regola.detto)) {
        perche.add(regola.detto);
      }
    }

    final grado = toglieLOro
        ? (somma < 0 ? GradoDelGiorno.evitare : GradoDelGiorno.neutro)
        : (somma > 0
            ? GradoDelGiorno.oro
            : (somma < 0 ? GradoDelGiorno.evitare : GradoDelGiorno.neutro));

    return EsitoDelGiorno(
      grado: grado,
      perche: perche,
      fonti: fonti.toList(growable: false),
    );
  }

  /// I giudizi di tutti i giorni di un mese per un'attivita'.
  static List<EsitoDelGiorno> delMese(
          AttivitaDelLunario attivita, List<GiornoLunare> giorni) =>
      [for (final g in giorni) valuta(attivita, g)];

  static String _ora(DateTime t) =>
      '${t.hour}:${t.minute.toString().padLeft(2, '0')}';

  /// "Fuori corso dalle H:MM alle H:MM", unendo piu' intervalli nello stesso
  /// giorno con "e".
  static String _fuoriCorsoDetto(GiornoLunare giorno) {
    final intervalli = [
      for (final f in giorno.fuoriCorso)
        'dalle ${_ora(f.inizio)} alle ${_ora(f.fine)}',
    ];
    return 'Fuori corso ${intervalli.join(' e ')}';
  }
}

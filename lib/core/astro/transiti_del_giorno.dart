import '../tempo/confine_del_giorno.dart';
import 'celestial.dart';
import 'effemeridi.dart';

/// IL CIELO DI OGGI, A UN ISTANTE SOLO PER TUTTO IL GIORNO.
///
/// **Perche' l'istante e' fisso.** Se i transiti si calcolassero "adesso",
/// l'oroscopo del mattino sarebbe diverso da quello della sera: la Luna si
/// muove mezzo grado ogni ora, quindi un aspetto stretto potrebbe esserci a
/// colazione e non esserci a cena. La persona lo vedrebbe cambiare sotto gli
/// occhi senza aver fatto niente, e un responso che si smentisce da solo nella
/// stessa giornata non e' un responso.
///
/// **Quale istante, e perche' quello.** Mezzogiorno UTC del giorno civile.
/// Mezzogiorno perche' e' il punto piu' lontano dai due bordi: qualunque
/// momento della giornata dista al massimo dodici ore dall'istante usato,
/// invece delle ventiquattro che si avrebbero prendendo la mezzanotte. UTC
/// perche', scelto il giorno, l'istante non deve piu' dipendere da dove sta il
/// dispositivo.
///
/// **QUAL E' il giorno civile lo dice `ConfineDelGiorno`, non questo file.**
/// Il confine d'uso cade a mezzanotte locale ed e' gia' scritto in un punto
/// solo, quello che governa i contatori delle domande. Qui non se ne scrive un
/// secondo: si chiede a lui e si costruisce l'istante sulla sua risposta.
///
/// **Nessuna rete.** Niente callable, niente chiave, niente quota, niente
/// cache: e' aritmetica, e rifarla costa meno che ricordarsela.
class TransitiDelGiorno {
  const TransitiDelGiorno._();

  /// L'ora UTC a cui si fotografa il cielo del giorno.
  static const int oraDelloScatto = 12;

  /// L'istante dei transiti per il giorno civile in cui cade [adesso].
  ///
  /// Due chiamate nello stesso giorno civile danno lo stesso istante, alla
  /// mezzanotte locale ne danno uno nuovo. Il giorno lo decide
  /// `ConfineDelGiorno.chiaveDi`, che e' l'autorita' del confine.
  static DateTime istanteDi(DateTime adesso) {
    final parti = ConfineDelGiorno.chiaveDi(adesso).split('-');
    return DateTime.utc(
      int.parse(parti[0]),
      int.parse(parti[1]),
      int.parse(parti[2]),
      oraDelloScatto,
    );
  }

  /// Le longitudini eclittiche dei corpi per il giorno civile di [adesso].
  static Map<CorpoCeleste, double> posizioni(DateTime adesso) =>
      Effemeridi.tutte(Celestial.julianDay(istanteDi(adesso)));

  /// La longitudine di un solo corpo per il giorno civile di [adesso].
  static double posizioneDi(CorpoCeleste corpo, DateTime adesso) =>
      Effemeridi.longitudineEclittica(
          corpo, Celestial.julianDay(istanteDi(adesso)));
}

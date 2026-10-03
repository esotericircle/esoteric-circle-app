import 'maestro.dart';

/// **UNA SINTESI CHE NON NOMINA NESSUNO NON STA CONFRONTANDO.** Ordine EE
/// voce 10, 23 settembre 2026.
///
/// **Il fatto del fondatore.** Sulla cattura del Consiglio del 23 settembre,
/// la sintesi comparativa diceva *"Le letture convergono... Tutti gli sguardi
/// sottolineano... Si evidenzia la maestria... La Ruota della Fortuna, per
/// tutti"*: quattro modi di dire "tutti e tre dicono la stessa cosa", e
/// **nessuno dei tre Maestri chiamato per nome**. Un confronto ha bisogno di
/// due termini, e i termini qui sono i Maestri: senza i nomi resta un
/// riassunto travestito.
///
/// **NON E' LA REGOLA, E' UN'ESTRAZIONE SFORTUNATA, e questo cambia la cura.**
/// Il collaudo dell'ordine ED, mossa 17, ha rifatto quella sintesi con lo
/// stesso identico materiale della cattura, lo stesso modello, la stessa
/// istruzione: **sette giri veri, tre Maestri su tre nominati tutte e sette
/// le volte**, con e senza il profilo. L'istruzione **gia' chiede** di mettere
/// a confronto le prese di posizione, e il modello quasi sempre obbedisce.
///
/// **Quasi.** E' esattamente il quadro dell'ordine EC voce 03: rafforzare una
/// frase che il modello gia' riceve non si puo' nemmeno misurare, perche' il
/// prima e' gia' verde. Cio' che si puo' fare e' **guardare cio' che e'
/// tornato**, e richiedere quando e' tornato senza nomi. Lo fa
/// [VoceSorvegliata], nello stesso punto e con la stessa forma con cui
/// gestisce la voce che si confonde.
///
/// **PERCHE' IL CANCELLO E' A ZERO E NON A TRE.** Una sintesi che ne nomina
/// due su tre sta confrontando: *"Medora guarda al lavoro, Caligo
/// all'espansione, e il terzo sguardo li tiene insieme"* e' un confronto
/// legittimo, e pretendere tutti e tre i nomi farebbe richiedere una sintesi
/// buona. **Zero e' un'altra cosa**: e' il testo che non ha termini da
/// confrontare affatto, cioe' il difetto vero della cattura.
abstract final class LaSintesiNominaChiConfronta {
  /// I Maestri che [sintesi] chiama per nome, fra quelli [interpellati].
  static List<Maestro> nominatiIn(List<Maestro> interpellati, String sintesi) {
    final basso = sintesi.toLowerCase();
    return [
      for (final m in interpellati)
        if (basso.contains(m.displayName.toLowerCase())) m,
    ];
  }

  /// Vero quando la sintesi non nomina **nessuno** dei Maestri di cui parla.
  ///
  /// Su meno di due sguardi non c'e' confronto da fare e non si giudica: una
  /// sintesi di una lettura sola non e' il caso che questa rete sorveglia.
  static bool nonNominaNessuno(List<Maestro> interpellati, String sintesi) =>
      interpellati.length >= 2 &&
      sintesi.trim().isNotEmpty &&
      nominatiIn(interpellati, sintesi).isEmpty;

  /// Fra due sintesi, quella che nomina piu' Maestri. A parita' vince la
  /// [prima], perche' la seconda non ha portato niente di meglio e la prima
  /// e' quella che la persona avrebbe comunque ricevuto.
  static String laPiuNominata(
    List<Maestro> interpellati,
    String prima,
    String poi,
  ) =>
      nominatiIn(interpellati, poi).length >
              nominatiIn(interpellati, prima).length
          ? poi
          : prima;
}

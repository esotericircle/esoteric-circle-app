import '../astro/effemeridi.dart';
import '../astro/natal_chart.dart';
import '../horoscope/cielo_di_oggi.dart';

/// LA RISPOSTA DEL SOFFIO: cosa si apre oggi, e cosa oggi non si lascia
/// forzare.
///
/// **Perche' il Soffio lascia una risposta e non altro.** Il Rito dell'Alba
/// chiude con una parola e un gesto, e il Soffio non deve somigliargli: se i
/// due riti finissero nello stesso modo, farne due sarebbe un raddoppio.
/// Il nome dice cosa promette: si soffia una domanda e torna una risposta.
///
/// **Due righe, e nessuna delle due comanda.** Non c'e' una domanda alla
/// persona, non c'e' un compito da eseguire, non c'e' un esito promesso, e non
/// c'e' un verbo all'imperativo. L'imperativo e' la forma dell'Alba, che
/// infatti dice "volgi lo sguardo", "appoggia le mani": qui si dichiara come
/// sta il cielo, e cosa se ne fa lo decide chi legge.
///
/// **Esce dai transiti veri, dalla porta che c'e' gia'.**
/// `CieloDiOggi.perIlGiorno` e' la stessa porta dell'Oroscopo e del Rito
/// dell'Alba. Non se ne apre una seconda: due porte sullo stesso cielo
/// possono dire due cose diverse nella stessa mattina, ed e' il difetto che
/// questo progetto ha gia' pagato piu' volte.
///
/// **Se il transito che una variante nomina non c'e', la variante non entra.**
/// Non esiste una riga di ripiego che parli lo stesso: quando il cielo non
/// offre un aspetto morbido, la riga di cio' che si apre semplicemente non
/// compare, e cosi' l'altra. Se non ne compare nessuna, non c'e' risposta, e
/// chi la mostra deve dirlo invece di inventarla.
class RispostaDelSoffio {
  const RispostaDelSoffio({required this.apre, required this.nonForzare});

  /// La porta che il cielo tiene aperta adesso. Nulla se oggi non c'e' un
  /// aspetto morbido: meglio una riga in meno di una riga che finge.
  final String? apre;

  /// Quella che oggi e' meglio non forzare. Nulla se oggi non c'e' un aspetto
  /// teso, il che accade davvero e non e' un guasto.
  final String? nonForzare;

  /// Vero quando c'e' almeno una delle due righe.
  bool get ceQualcosa => apre != null || nonForzare != null;

  /// LA RISPOSTA DI OGGI, dai transiti veri sulla carta di questa persona.
  ///
  /// Nulla quando il cielo non e' stato interrogato davvero, cioe' quando la
  /// carta manca: senza ora e luogo di nascita non ci sono transiti sulla
  /// carta, e una risposta senza cielo sarebbe un oroscopo da giornale.
  static RispostaDelSoffio? diOggi(CieloDiOggi cielo) {
    if (!cielo.ceCieloVero) return null;
    // LE VOCI ARRIVANO GIA' ORDINATE PER ORBO CRESCENTE, cioe' dalla piu'
    // stretta: la prima di ogni famiglia e' quella che oggi pesa di piu'.
    final morbida = _prima(cielo, AspectHarmony.soft);
    final tesa = _prima(cielo, AspectHarmony.hard);
    final r = RispostaDelSoffio(
      apre: morbida == null ? null : _apre(morbida),
      nonForzare: tesa == null ? null : _nonForzare(tesa),
    );
    return r.ceQualcosa ? r : null;
  }

  static VoceDelCielo? _prima(CieloDiOggi cielo, AspectHarmony armonia) {
    for (final v in cielo.voci) {
      if (v.aspetto.harmony == armonia) return v;
    }
    return null;
  }

  /// La riga di cio' che si apre. Dichiarativa, e nomina il transito da cui
  /// viene: chi legge deve poter risalire al cielo, non fidarsi.
  static String _apre(VoceDelCielo v) =>
      'Oggi si apre ${_terreno[v.transito]!}, '
      'con ${v.transito.nome} in ${v.aspetto.italianName.toLowerCase()} '
      'al tuo ${v.bersaglio}.';

  /// La riga di cio' che non si lascia forzare. Anche questa dichiarativa: dice
  /// come sta il cielo, non cosa fare, e soprattutto non promette che
  /// aspettare funzionera'.
  static String _nonForzare(VoceDelCielo v) =>
      'Non si lascia forzare ${_terreno[v.transito]!}, '
      'con ${v.transito.nome} in ${v.aspetto.italianName.toLowerCase()} '
      'al tuo ${v.bersaglio}.';

  /// IL TERRENO DI OGNI CORPO, cioe' su cosa quel pianeta ha voce.
  ///
  /// Tradizione astrologica di base, la stessa che regge il resto dell'app: la
  /// significazione classica dei pianeti. Sono nomi di ambito, non predizioni,
  /// e per questo funzionano sia per cio' che si apre sia per cio' che non
  /// cede: e' lo stesso terreno, guardato da due parti.
  /// **Nessuna di queste voci contiene un verbo che possa leggersi come un
  /// comando.** Due lo contenevano, "ti fai riconoscere" e "ti fai capire": in
  /// italiano `fai` e' insieme indicativo e imperativo, e la prova che vieta la
  /// forma dell'Alba le ha prese. Riscritte, invece di ammorbidire la prova:
  /// una regola che si allarga per far passare il caso di oggi non sorveglia
  /// piu' niente domani.
  static const Map<CorpoCeleste, String> _terreno = {
    CorpoCeleste.sole: 'il modo in cui gli altri ti riconoscono',
    CorpoCeleste.luna: 'quello che senti prima di capirlo',
    CorpoCeleste.mercurio: 'il modo in cui le tue parole arrivano',
    CorpoCeleste.venere: 'cio' ' che ti avvicina agli altri',
    CorpoCeleste.marte: 'la spinta con cui cominci le cose',
    CorpoCeleste.giove: 'lo spazio che ti concedi',
    CorpoCeleste.saturno: 'quello che stai costruendo con pazienza',
    CorpoCeleste.urano: 'cio' ' che vuole cambiare forma',
    CorpoCeleste.nettuno: 'quello che immagini prima di vederlo',
    CorpoCeleste.plutone: 'cio' ' che stai lasciando andare',
  };
}

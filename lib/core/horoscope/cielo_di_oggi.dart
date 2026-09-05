import '../astro/aspetti_di_oggi.dart';
import '../astro/effemeridi.dart';
import '../astro/natal_chart.dart';
import '../astro/transiti_del_giorno.dart';
import '../astro/transiti_nelle_case.dart';

/// IL CIELO DI OGGI SOPRA UNA PERSONA, misurato e non inventato.
///
/// **QUI MUORE L'HASH.** L'Oroscopo componeva le sue quattro schede con una
/// hash FNV-1a su segno, giorno e anno: un numero stabile, che pero' il cielo
/// non lo guarda. Due persone dello stesso segno nate a vent'anni di distanza
/// leggevano la stessa identica cosa, e il giorno cambiava il testo soltanto
/// perche' cambiava il numero, non perche' fosse cambiato qualcosa la' sopra.
///
/// Questo file raccoglie in un posto solo i tre pezzi di cielo vero che l'app
/// gia' sapeva calcolare, e che nessuno stava usando per scrivere: gli aspetti
/// fra i pianeti di oggi e la carta natale, la casa che ogni pianeta sta
/// attraversando, e chi e' retrogrado. Il testo lo scrive
/// `CorrenteDelCielo`: qui ci sono solo i fatti.
///
/// **Senza carta natale non c'e' niente da raccogliere, e non si finge.** Chi
/// ha dato solo la data di nascita ha un cielo essenziale: [voci] resta vuota,
/// [ceCieloVero] dice di no, e chi compone deve dichiarare il ripiego invece
/// di far credere che il cielo sia stato interrogato.
///
/// **Aritmetica pura, nessuna rete.** Tutto viene dal motore locale e dalla
/// carta gia' conservata: gira in aereo, non costa un token.
class CieloDiOggi {
  const CieloDiOggi({
    required this.voci,
    required this.livello,
  });

  /// Il cielo di chi non ha una carta: nessuna voce, nessun fatto.
  static const CieloDiOggi nessuno = CieloDiOggi(
    voci: [],
    livello: LivelloPersonalizzazione.soloSegno,
  );

  /// I fatti del giorno, dal piu' stretto al piu' largo.
  ///
  /// L'ordine e' quello di `AspettiDiOggi`: un aspetto e' tanto piu' forte
  /// quanto piu' e' vicino all'angolo esatto, quindi il primo della lista e'
  /// quello che oggi pesa di piu'.
  final List<VoceDelCielo> voci;

  /// Quanto si e' potuto personalizzare davvero, data la carta in mano.
  final LivelloPersonalizzazione livello;

  /// Vero quando c'e' almeno un fatto vero da raccontare.
  bool get ceCieloVero => voci.isNotEmpty;

  /// IL CIELO DI QUESTA PERSONA IN QUESTO GIORNO.
  ///
  /// L'istante dei transiti e' quello fisso del giorno, quindi due aperture
  /// nella stessa giornata danno gli stessi identici fatti.
  static CieloDiOggi perIlGiorno({
    required DateTime adesso,
    required NatalChart? carta,
  }) {
    final livello = AspettiDiOggi.livello(carta);
    if (livello == LivelloPersonalizzazione.soloSegno) return nessuno;

    final aspetti = AspettiDiOggi.perIlGiorno(adesso: adesso, carta: carta);
    final case_ = TransitiNelleCase.perIlGiorno(adesso: adesso, carta: carta);
    final retrogradi = AspettiDiOggi.retrogradiDelGiorno(adesso);
    final jd = TransitiDelGiorno.giornoGiulianoDi(adesso);
    final nomiNatali = <String, String>{
      for (final p in carta!.planets) p.id: p.name,
      AspettiDiOggi.idAscendente: 'Ascendente',
      AspettiDiOggi.idMedioCielo: 'Medio Cielo',
    };

    final voci = <VoceDelCielo>[];
    for (final a in aspetti) {
      final corpo = _corpoDa(a.aId);
      if (corpo == null) continue;
      voci.add(VoceDelCielo(
        transito: corpo,
        bersaglio: nomiNatali[a.bId] ?? a.bId ?? '',
        idBersaglio: a.bId ?? '',
        aspetto: a.type,
        orbe: a.orbe,
        applicativo: a.applicativo,
        casa: case_[corpo],
        retrogrado: retrogradi.contains(corpo),
        giorniDiIncertezza: Effemeridi.giorniDiIncertezza(corpo, jd),
      ));
    }
    return CieloDiOggi(voci: voci, livello: livello);
  }

  static CorpoCeleste? _corpoDa(String? id) {
    if (id == null) return null;
    for (final c in CorpoCeleste.values) {
      if (c.id == id) return c;
    }
    return null;
  }
}

/// UN FATTO SOLO DEL CIELO DI OGGI: un pianeta, cosa tocca, dove passa.
class VoceDelCielo {
  const VoceDelCielo({
    required this.transito,
    required this.bersaglio,
    required this.idBersaglio,
    required this.aspetto,
    required this.orbe,
    required this.applicativo,
    required this.casa,
    required this.retrogrado,
    required this.giorniDiIncertezza,
  });

  /// Il pianeta che oggi si muove.
  final CorpoCeleste transito;

  /// Il punto natale che tocca, col nome che la carta gli da'.
  final String bersaglio;

  /// L'identificatore dello stesso punto, per chi deve confrontarlo.
  final String idBersaglio;

  final AspectType aspetto;

  /// Di quanto e' lontano dall'angolo esatto. Piu' e' stretto piu' pesa.
  final double orbe;

  /// Se si sta formando (vero) oppure sciogliendo (falso). Nullo se non si sa.
  final bool? applicativo;

  /// La casa natale che il pianeta sta attraversando. Nulla senza ora di
  /// nascita: le cuspidi discendono dall'orizzonte all'istante della nascita,
  /// e una casa inventata darebbe una frase esatta e falsa insieme.
  final int? casa;

  final bool retrogrado;

  /// DI QUANTI GIORNI E' INCERTO il giorno in cui l'aspetto e' esatto.
  ///
  /// **E' il numero che decide la lingua.** Misurato il 5 agosto 2026 con
  /// `flutter test tool/quanto_e_incerto_il_giorno.dart` su tre date distanti:
  /// Sole, Luna, Mercurio e Venere stanno a un centesimo di giorno, Marte fra
  /// 0,05 e 0,10, Giove fra 0,10 e 0,27, Urano fra 0,07 e 0,45, Nettuno fra
  /// 0,52 e 1,14, Plutone fra 0,49 e 1,56, e SATURNO fra 1,29 e 8,92.
  ///
  /// Sopra un giorno, dire "oggi" prometterebbe una precisione che il motore
  /// non ha: vedi [ilGiornoSiPuoDire].
  final double giorniDiIncertezza;

  /// SE SI PUO' DIRE "OGGI" DI QUESTO PASSAGGIO.
  ///
  /// **La soglia e' un giorno, e non e' scelta a caso: e' la grana stessa
  /// della parola.** "Oggi" nomina una casella larga un giorno; se l'incertezza
  /// sul giorno esatto supera un giorno, quella casella non la sappiamo
  /// indicare, e la lingua deve allargarsi a "in questi giorni". Per dire che
  /// l'aspetto C'E' il motore basta e avanza, perche' l'orbo piu' stretto e'
  /// due gradi contro uno scarto massimo di 0,1414: quattordici volte. E' il
  /// GIORNO esatto che non sa dare.
  bool get ilGiornoSiPuoDire => giorniDiIncertezza <= 1.0;
}
